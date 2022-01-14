"""
   Copyright (C) 2021  Argyros Argyridis arargyridis at gmail dot com
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""

from concurrent.futures import ProcessPoolExecutor
from datetime import datetime
from osgeo import gdal, ogr, osr
import json, os, multiprocessing,  numpy as np, pathlib, re

import sys
sys.path.extend(['..']) #to properly import modules from other dirs
from Libs.AlignToImage import AlignToImage
from Libs.ConfigurationParser import ConfigurationParser
from Libs.Utils import *
from Libs.Constants import Constants

def interpolateColor(areaPerc, palette):
    keys = [int(k) for k in palette.keys()]
    keys.sort()
    if (areaPerc == keys[0]):
        return palette[str(keys[0])]
    elif areaPerc == keys[-1]:
        return palette[str(keys[-1])]
    bins = len(keys) - 1
    valRange = 100 / bins
    mn = int(areaPerc / valRange)
    mx = mn + 1
    lowColor = palette[str(keys[mn])]
    highColor = palette[str(keys[mx])]
    cls = []
    for low, high in zip(lowColor, highColor):
        cls.append(int((high - low) * (areaPerc - keys[mn])/100.0 + low))
    return cls



class GeomProcessor():
    def __init__(self, ft, dstOSR, inImages, dstResolution, product, cfgObj):
        self.__ft = ft
        self.__rasterFt = None
        self.__rasterExtents = None
        self.__dstOSR = dstOSR
        self.__srcImages = inImages
        self.__dstResolution = dstResolution
        self.__product = product
        self._config = cfgObj
        self.__variable = Constants.PRODUCT_INFO[product].variable
        self.__valueRange = Constants.PRODUCT_INFO[product].valueRange
        self.__pixelToAreaFunc = None

    def __del__(self):
        del self.__ft
        del self.__rasterFt
        self.__rasterExtents = None
        del self.__dstOSR
        self.__srcImages = None
        self.__dstResolution = None
        self.__variable = None
        self.__pixelToAreaFunc = None

    def __setPixelToAreaFunc(self):
        tmpData = gdal.Open(self.__srcImages[0][1])
        sr = osr.SpatialReference()
        sr.ImportFromWkt(tmpData.GetProjection())
        units = sr.GetAttrValue("UNIT")
        if units == "Metre":
            self.__pixelToAreaFunc = pixelsToAreaM2Meters
        elif units == "degree":
            self.__pixelToAreaFunc = pixelsToAreaM2Degrees


    def __storeToDB(self, data):

        dbVals = ""
        for dt in data:
            if isinstance(dt, int):
                continue
            #cheking which product matches the current image
            xpr = re.compile(Constants.PRODUCT_INFO[self.__product].pattern)
            vals = xpr.findall(os.path.split(dt["image_rel_path"])[1])

            date = Constants.PRODUCT_INFO[self.__product].createDate(vals[0])
            dbVals += "({0},{1},'{2}','{3}',{4},{5},{6},{7},'{8}','{9}','{10}','{11}', '{12}'),"\
                .format(dt["poly_id"], dt["product_id"], dt["image_rel_path"],
                        date, dt["no"], dt["sparse"], dt["mid"],dt["dense"], json.dumps(dt["novalcolor"]),
                        json.dumps(dt["sparsevalcolor"]), json.dumps(dt["midvalcolor"]), json.dumps(dt["highvalcolor"]),
                        json.dumps(dt["histogram"].tolist()))

        query = """WITH tmp_data(poly_id, product_id, rel_file_path, date, noval_area_ha, sparse_area_ha, mid_area_ha, dense_area_ha,
        noval_color, sparseval_color, midval_color, highval_color, histogram) AS( VALUES {0})
         ,ins1 AS(
            INSERT INTO {1}.product_file(product_id, rel_file_path, date)
            SELECT product_id, rel_file_path, date::timestamp without time zone
            FROM tmp_data
            ON CONFLICT(product_id, rel_file_path) DO UPDATE SET date=EXCLUDED.date RETURNING id, product_id, rel_file_path     
         )
         INSERT INTO {1}.poly_stats(poly_id, product_file_id, noval_area_ha, sparse_area_ha, mid_area_ha, dense_area_ha,
         noval_color, sparseval_color, midval_color, highval_color, histogram)
         SELECT tdt.poly_id, ins1.id, tdt.noval_area_ha, tdt.sparse_area_ha, tdt.mid_area_ha, tdt.dense_area_ha,
         noval_color::jsonb, sparseval_color::jsonb, midval_color::jsonb, highval_color::jsonb, histogram::jsonb
         FROM tmp_data tdt
         JOIN ins1 ON tdt.product_id = ins1.product_id AND tdt.rel_file_path = ins1.rel_file_path
         ON CONFLICT(poly_id, product_file_id) DO NOTHING;
        """.format(dbVals[0:-1], self._config.statsInfo.schema)
        self._config.pgConnections[self._config.statsInfo.connectionId].executeQueries([query])
        return

    def __geomRasterizer(self):
        #assuming that all input images are aligned on the same grid

        allignedImage = AlignToImage(self.__ft, self.__srcImages[0][1])

        self.__rasterExtents = allignedImage.process(vector=True)
        outRasterXSize =  int((self.__rasterExtents[1][0] - self.__rasterExtents[0][0]) / self.__dstResolution)
        outRasterYSize = int((self.__rasterExtents[0][1] - self.__rasterExtents[1][1]) / self.__dstResolution)
        drv = gdal.GetDriverByName("MEM")

        print("Poly id: {0}, Output image dimensions: ({1},{2})".format(self.__ft.GetFID(),
                                                                        outRasterXSize, outRasterYSize))

        self.__rasterFt = drv.Create("tmp_img_{0}.tif".format(self.__ft.GetFID()),outRasterXSize,outRasterYSize
                                , 1, gdal.GDT_Byte)
        self.__rasterFt.SetProjection(self.__ft.GetGeometryRef().GetSpatialReference().ExportToWkt())
        self.__rasterFt.SetGeoTransform((self.__rasterExtents[0][0], self.__dstResolution, 0, self.__rasterExtents[0][1], 0, -self.__dstResolution))

        # create temporary dataset
        ogrDrv = ogr.GetDriverByName("Memory")
        memVSource = ogrDrv.CreateDataSource(str(self.__ft.GetFID()))

        memVLayer = memVSource.CreateLayer("tmp", self.__dstOSR, geom_type=ogr.wkbPolygon)
        tmpFtDefn = memVLayer.GetLayerDefn()
        tmpFt = ogr.Feature(tmpFtDefn)
        tmpFt.SetGeometry(self.__ft.geometry().MakeValid())
        memVLayer.CreateFeature(tmpFt)

        gdal.RasterizeLayer(self.__rasterFt, [1], memVLayer, burn_values=[1, ])
        del memVLayer
        memVLayer = None
        del memVSource
        memVSource = None


    def __extractStats(self, low, mid, high):
        out = list(range(len(self.__srcImages)))
        imgIdx = 0
        for (rawImage, image) in self.__srcImages:
            inRasterData = gdal.Open(image)
            metaData = inRasterData.GetMetadata()
            tmpLow = reverseValue(metaData, low, self.__variable)
            tmpSparse = reverseValue(metaData, mid, self.__variable)
            tmpHigh = reverseValue(metaData, high, self.__variable)
            noDataValue = inRasterData.GetRasterBand(1).GetNoDataValue()

            inGt = inRasterData.GetGeoTransform()
            upperLeft  = xyToColRow(self.__rasterExtents[0][0], self.__rasterExtents[0][1], inGt)
            lowerRight = xyToColRow(self.__rasterExtents[1][0], self.__rasterExtents[1][1], inGt)
            id = self.__ft.GetFID()

            if (not (upperLeft[0] >= 0 and upperLeft[1] >= 0 and lowerRight[0] < inRasterData.RasterXSize and lowerRight[1] < inRasterData.RasterYSize)):
                continue

            cntNo = 0
            cntSparse = 0
            cntMid = 0
            cntDense = 0

            bins = 10
            hist = np.zeros(bins)

            for i in range(self.__rasterFt.RasterYSize):
                #data row
                dtRow = inRasterData.ReadAsArray(upperLeft[0], upperLeft[1]+i, self.__rasterFt.RasterXSize, 1)[0]
                plRow = self.__rasterFt.ReadAsArray(0, i, self.__rasterFt.RasterXSize, 1)[0]
                res = dtRow[(dtRow!=noDataValue) & (plRow == 1)]
                tmpHist = np.histogram(res, bins=10, range=(Constants.PRODUCT_INFO[self.__product].minValue,
                Constants.PRODUCT_INFO[self.__product].maxValue))
                hist += tmpHist[0]
                cntNo += res[res < tmpLow].shape[0]
                cntSparse += res[(res >= tmpLow) & (res < tmpSparse)].shape[0]
                cntMid += res[(res >= tmpSparse) & (res < tmpHigh)].shape[0]
                cntDense += res[res >= tmpHigh].shape[0]
                del plRow
                del dtRow

            noAreaHa = np.round(self.__pixelToAreaFunc(cntNo, inGt[1])/10000,2)
            sparseAreaHa = np.round(self.__pixelToAreaFunc(cntSparse, inGt[1])/10000,2)
            midAreaHa = np.round(self.__pixelToAreaFunc(cntMid, inGt[1])/10000,2)
            denseAreaHa = np.round(self.__pixelToAreaFunc(cntDense, inGt[1])/10000,2)

            #print(noAreaHa, sparseAreaHa, midAreaHa, denseAreaHa)
            sumAreaHa = noAreaHa + sparseAreaHa + midAreaHa + denseAreaHa
            if sumAreaHa == 0:
                continue

            noValColor = sparseValColor = midValColor = highValColor = 'NULL'
            if Constants.PRODUCT_INFO[self.__product].novalColorRamp is not None:
                noValColor = interpolateColor(round(noAreaHa / sumAreaHa * 100),
                             Constants.PRODUCT_INFO[self.__product].novalColorRamp)

            if Constants.PRODUCT_INFO[self.__product].sparsevalColorRamp is not None:
                sparseValColor = interpolateColor(round(sparseAreaHa / sumAreaHa * 100),
                             Constants.PRODUCT_INFO[self.__product].sparsevalColorRamp)

            if Constants.PRODUCT_INFO[self.__product].midvalColorRamp is not None:
                midValColor = interpolateColor(round(midAreaHa / sumAreaHa * 100),
                                 Constants.PRODUCT_INFO[self.__product].midvalColorRamp)

            if Constants.PRODUCT_INFO[self.__product].highvalColorRamp is not None:
                highValColor = interpolateColor(round(denseAreaHa / sumAreaHa * 100),
                                 Constants.PRODUCT_INFO[self.__product].highvalColorRamp)
            out[imgIdx] = {
                "poly_id": id,
                "product_id": Constants.PRODUCT_INFO[self.__product].id,
                "image_rel_path": os.path.relpath(pathlib.Path(rawImage), self._config.filesystem.imageryPath),
                "no": noAreaHa,
                "sparse": sparseAreaHa,
                "mid": midAreaHa,
                "dense": denseAreaHa,
                "novalcolor":noValColor,
                "sparsevalcolor": sparseValColor,
                "midvalcolor": midValColor,
                "highvalcolor": highValColor,
                "histogram": hist
           }
            imgIdx += 1
            del inRasterData
            inRasterData = None
        return out

    def process(self):
        self.__setPixelToAreaFunc()
        self.__geomRasterizer()
        data = self.__extractStats(self.__valueRange["low"], self.__valueRange["mid"], self.__valueRange["high"])
        self.__storeToDB(data)

def geomProcessor(inImages, poly, productInfo, cfgObj):
    inRasterData = gdal.Open(inImages[0][1])

    resolution = inRasterData.GetGeoTransform()[1]

    dstOSR = osr.SpatialReference()
    dstOSR.ImportFromWkt(inRasterData.GetProjection())

    ftSRS = osr.SpatialReference()
    ftSRS.ImportFromEPSG(poly[2])

    defn = ogr.FeatureDefn()
    defn.SetGeomType(ogr.wkbMultiPolygon)

    geom = ogr.CreateGeometryFromWkt(poly[1], ftSRS)
    ft = ogr.Feature(defn)

    ft.SetGeometry(geom)
    ft.SetFID(poly[0])

    geoProc = GeomProcessor(ft, dstOSR, inImages, resolution, productInfo, cfgObj)
    ret = geoProc.process()

    del ft
    del geom

    del ftSRS
    del dstOSR
    del inRasterData
    return ret



class ZonalStatsExtractor():
    def __init__(self, inImages, stratificationType, configFile = "../config.json"):
        self._images = inImages
        self._stratificationType = stratificationType
        self._config = ConfigurationParser(configFile)



    def process(self, nThreads=multiprocessing.cpu_count()-1):
        try:
            self._config.parse()
            Constants.load(self._config.getFile())

            #checking input
            if len(self._images) == 0:
                print("No images provided. Exiting")
                return

            netcdfSubDatasets = {}
            for image in self._images:
                if not os.path.isfile(image):
                    raise FileExistsError

                #building netCDF subdatasets by matching the input file with the product pattern
                for product in Constants.PRODUCT_INFO.keys():
                    xpr = re.compile(Constants.PRODUCT_INFO[product].pattern)
                    chk = os.path.split(image)[1]
                    if xpr.match(chk) is not None:  # product found, preparing to append to DB
                        if product not in netcdfSubDatasets:
                            netcdfSubDatasets[product] = []

                        examineDate = datetime.strptime(Constants.PRODUCT_INFO[product].createDate(xpr.findall(chk)[0]),
                                                                                                       "%Y-%m-%dT%H:%M:%S")
                        if Constants.PRODUCT_INFO[product].extractedDates is None or examineDate not in \
                                Constants.PRODUCT_INFO[product].extractedDates:
                            netcdfSubDatasets[product].append([image, """NETCDF:"{0}":{1}"""
                                                 .format(image, Constants.PRODUCT_INFO[product].variable)])
                            if gdal.Open(netcdfSubDatasets[product][-1][1]) is None:
                                raise IOError

            #creating cursor to retrieve polygons from DB
            session = self._config.pgConnections[self._config.statsInfo.connectionId].getNewSession()
            polyQuery = "SELECT sg.id, ST_ASTEXT(geom), ST_SRID(geom) FROM {0}.stratification_geom sg " \
                        "JOIN {0}.stratification s ON s.id = sg.stratification_id  " \
                        "WHERE description='{1}' "\
                .format(self._config.statsInfo.schema, self._stratificationType)
            executor = ProcessPoolExecutor(max_workers=nThreads)
            for product in netcdfSubDatasets:
                res = self._config.pgConnections[self._config.statsInfo.connectionId].getIteratableResult(polyQuery,
                                                                                                          session)
                values = []
                if len(netcdfSubDatasets[product]) > 0:
                    #for poly in res:
                    #    geomProcessor(netcdfSubDatasets[product], poly, product, self._config)

                    threads = [
                        executor.submit(geomProcessor,netcdfSubDatasets[product], poly, product, self._config)
                        for poly in res]

                else:
                    print("No new images for stats extraction were found for product: {0}. Exiting".format(product))

        except FileExistsError:
            print("A specified does not exist. Verify the list of input files")
            return None
        except IOError:
            print("The specified variable does not exist.")
            return None
        #except:
        #    print("Unable to compute statistics. Existing")


        return




def main():
    if len(sys.argv) < 4:
        print("Usage: python ZonalStatsExtractor.py path_to_images config_file stratification_type")
        return 1

    inputImageDir = sys.argv[1]
    cfg = sys.argv[2]
    stratificationType = sys.argv[3]

    #loading constants
    Constants.load(cfg)

    inImages = getListOfFiles(inputImageDir)
    inImages = [img for img in inImages if img.endswith(".nc")]

    #raw data server directory: /home/argyros/Desktop/data/BIOPAR/BioPar_NDVI300_V2_Global/
    print("Processing: {0} Images".format(len(inImages)))

    #requirements:
    obj = ZonalStatsExtractor(inImages, stratificationType, cfg)
    obj.process(8)
    print("Finished!")

if __name__ == "__main__":
    main()

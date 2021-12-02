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
from itertools import repeat
from osgeo import gdal, ogr, osr
import os, multiprocessing,  numpy as np, re

import sys
sys.path.extend(['..']) #to properly import modules from other dirs
from Libs.AlignToImage import AlignToImage
from Libs.ConfigurationParser import ConfigurationParser
from Libs.Utils import *
from Libs.Constants import Constants

class GeomProcessor():
    def __init__(self, ft, dstOSR, inImages, dstResolution, variable="NDVI"):
        self.__ft = ft
        self.__rasterFt = None
        self.__rasterExtents = None
        self.__dstOSR = dstOSR
        self.__srcImages = inImages
        self.__dstResolution = dstResolution
        self.__variable = variable
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
        tmpData = gdal.Open(self.__srcImages[0])
        sr = osr.SpatialReference()
        sr.ImportFromWkt(tmpData.GetProjection())
        units = sr.GetAttrValue("UNIT")
        if units == "Metre":
            self.__pixelToAreaFunc = pixelsToAreaM2Meters
        elif units == "degree":
            self.__pixelToAreaFunc = pixelsToAreaM2Degrees

    def __geomRasterizer(self):
        #assuming that all input images are aligned on the same grid

        allignedImage = AlignToImage(self.__ft, self.__srcImages[0])

        self.__rasterExtents = allignedImage.process(vector=True)

        drv = gdal.GetDriverByName("MEM")

        self.__rasterFt = drv.Create("tmp_img_{0}.tif".format(self.__ft.GetFID()),
                                int((self.__rasterExtents[1][0] - self.__rasterExtents[0][0]) / self.__dstResolution),
                                int((self.__rasterExtents[0][1] - self.__rasterExtents[1][1]) / self.__dstResolution), 1, gdal.GDT_Byte)
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
        print("Poly id: {0}, Ouput image dimensions: ({1},{2})"
              .format(self.__ft.GetFID(),self.__rasterFt.RasterXSize, self.__rasterFt.RasterYSize))
        gdal.RasterizeLayer(self.__rasterFt, [1], memVLayer, burn_values=[1, ])
        del memVLayer
        memVLayer = None
        del memVSource
        memVSource = None


    def __extractStats(self, low, sparse, high):
        out = list(range(len(self.__srcImages)))
        imgIdx = 0
        for image in self.__srcImages:
            inRasterData = gdal.Open(image)
            metaData = inRasterData.GetMetadata()
            tmpLow = reverseValue(metaData, low, self.__variable)
            tmpSparse = reverseValue(metaData, sparse, self.__variable)
            tmpHigh = reverseValue(metaData, high, self.__variable)
            noDataValue = inRasterData.GetRasterBand(1).GetNoDataValue()

            inGt = inRasterData.GetGeoTransform()
            upperLeft  = xyToColRow(self.__rasterExtents[0][0], self.__rasterExtents[0][1], inGt)
            lowerRight = xyToColRow(self.__rasterExtents[1][0], self.__rasterExtents[1][1], inGt)
            id = self.__ft.GetFID()

            if (not (upperLeft[0] >= 0 and upperLeft[1] >= 0 and lowerRight[0] < inRasterData.RasterXSize and lowerRight[1] < inRasterData.RasterYSize)):
                return

            cntNo = 0
            cntSparse = 0
            cntMid = 0
            cntDense = 0

            for i in range(self.__rasterFt.RasterYSize):
                #data row
                dtRow = inRasterData.ReadAsArray(upperLeft[0], upperLeft[1]+i, self.__rasterFt.RasterXSize, 1)[0]
                plRow = self.__rasterFt.ReadAsArray(0, i, self.__rasterFt.RasterXSize, 1)[0]
                res = dtRow[(dtRow!=noDataValue) & (plRow == 1)]
                cntNo += res[res < tmpLow].shape[0]
                cntSparse += res[(res >= tmpLow) & (res <= tmpSparse)].shape[0]
                cntMid += res[(res >= tmpSparse) & (res <= tmpHigh)].shape[0]
                cntDense += res[res > tmpHigh].shape[0]
                del plRow
                del dtRow

            out[imgIdx] = {
                "image_name": os.path.split(image)[1],
                "poly_id": id,
                "no": np.round(self.__pixelToAreaFunc(cntNo, inGt[1])/10000,2),
                "sparse": np.round(self.__pixelToAreaFunc(cntSparse, inGt[1])/10000,2),
                "mid":np.round(self.__pixelToAreaFunc(cntMid, inGt[1])/10000,2),
                "dense": np.round(self.__pixelToAreaFunc(cntDense, inGt[1])/10000,2)
            }
            imgIdx += 1
            del inRasterData
            inRasterData = None
        return out

    def process(self, low=0.225, sparse=0.45, high=0.675):
        self.__setPixelToAreaFunc()
        self.__geomRasterizer()
        return self.__extractStats(low, sparse, high)


def geomProcessor(inImages, poly, variable):
    inRasterData = gdal.Open(inImages[0])

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

    geoProc = GeomProcessor(ft, dstOSR, inImages, resolution, variable)

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

    def __storeToDB(self, data):

        dbVals = ""
        for dt in data:
            #cheking which product matches the current image
            for product in Constants.PRODUCT_INFO.keys():
                xpr = re.compile(Constants.PRODUCT_INFO[product]["PATTERN"])
                vals = xpr.findall(dt["image_name"])

                if vals != []: #product found, preparing to append to DB
                    date = Constants.PRODUCT_INFO[product]["CREATE_DATE"](vals[0])
                    dbVals += "({0},'{1}','{2}',{3},{4},{5},{6}),".format(dt["poly_id"], product, date, dt["no"], dt["sparse"], dt["mid"],dt["dense"])

        query = """WITH tmp_data(poly_id, product_name, date, noval_area_ha, sparse_area_ha, mid_area_ha, dense_area_ha) AS( VALUES {0})
         INSERT INTO {1}.poly_stats(poly_id, product_type, date, noval_area_ha, sparse_area_ha, mid_area_ha, dense_area_ha)
         SELECT tdt.poly_id, p.id, tdt.date::timestamp without time zone, tdt.noval_area_ha, tdt.sparse_area_ha, tdt.mid_area_ha, tdt.dense_area_ha
         FROM tmp_data tdt
         JOIN {1}.product p ON tdt.product_name = p.name
         ON CONFLICT(poly_id, product_type, date) DO UPDATE SET noval_area_ha = EXCLUDED.noval_area_ha, sparse_area_ha = EXCLUDED.sparse_area_ha,
         mid_area_ha = EXCLUDED.mid_area_ha, dense_area_ha = EXCLUDED.dense_area_ha, date_created = EXCLUDED.date_created
        """.format(dbVals[0:-1], self._config.statsInfo.schema)
        self._config.pgConnections[self._config.statsInfo.connectionId].executeQueries([query])
        return

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
                    xpr = re.compile(Constants.PRODUCT_INFO[product]["PATTERN"])
                    if xpr.match(os.path.split(image)[1]) is not None:  # product found, preparing to append to DB
                        if product not in netcdfSubDatasets:
                            netcdfSubDatasets[product] = []

                        netcdfSubDatasets[product].append("""NETCDF:"{0}":{1}"""
                                                 .format(image, Constants.PRODUCT_INFO[product]["VARIABLE"]))
                        if gdal.Open(netcdfSubDatasets[product][-1]) is None:
                            raise IOError

            #creating cursor to retrieve polygons from DB
            session = self._config.pgConnections[self._config.statsInfo.connectionId].getNewSession()
            polyQuery = "SELECT id, ST_ASTEXT(geom), ST_SRID(geom) FROM {0}.stratification " \
                        "WHERE stratification_description='{1}'"\
                .format(self._config.statsInfo.schema, self._stratificationType)

            executor = ProcessPoolExecutor(max_workers=nThreads)
            for product in netcdfSubDatasets:
                res = self._config.pgConnections[self._config.statsInfo.connectionId].getIteratableResult(polyQuery,
                                                                                                          session)
                values = []
                if len(netcdfSubDatasets[product]) > 0:
                        threads = [
                            executor.submit(geomProcessor,netcdfSubDatasets[product], poly,
                                            Constants.PRODUCT_INFO[product]["VARIABLE"]) for poly in res]
                        for process in threads:
                            result = process.result()
                            if result is not None:
                                values += result
                        if len(values) > 0:
                            self.__storeToDB(values)
                        else:
                            print("No stats were extracted for product: {0}. Exiting".format(product))




        except FileExistsError:
            print("A specified does not exist. Verify the list of input files")
            return None
        except IOError:
            print("The specified variable does not exist.")
            return None
        except:
            print("Unable to compute statistics. Existing")


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
    obj.process()
    print("Finished!")

if __name__ == "__main__":
    main()

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

from multiprocessing import Process, Manager
from datetime import datetime
from osgeo import gdal, ogr, osr
import json, os, multiprocessing,  numpy as np, pathlib, re
import sys
sys.path.extend(['../../']) #to properly import modules from other dirs
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

def computeStats(threadID, imageFile, geomMask, chunk, upperLeft, productId, bins, tmpLow, tmpSparse, tmpHigh, result):
    inRasterData = gdal.Open(imageFile)
    noDataValue = inRasterData.GetRasterBand(1).GetNoDataValue()
    hist = np.zeros(bins)
    cntNo = 0
    cntSparse = 0
    cntMid = 0
    cntDense = 0
    for i in chunk:
        #print("i=",i)
        # data row
        dtCol = inRasterData.ReadAsArray(upperLeft[0] + i, upperLeft[1], 1, geomMask.shape[0]).flatten()
        plCol = geomMask[:,i]#self._rasterFt.ReadAsArray(i, 0, 1, self._rasterFt.RasterYSize)
        res = dtCol[(dtCol != noDataValue) & (plCol == 1)]
        tmpHist = np.histogram(res, bins=10, range=(Constants.PRODUCT_INFO[productId].minValue,
                                                    Constants.PRODUCT_INFO[productId].maxValue))
        hist += tmpHist[0]
        cntNo += res[res < tmpLow].shape[0]
        cntSparse += res[(res >= tmpLow) & (res < tmpSparse)].shape[0]
        cntMid += res[(res >= tmpSparse) & (res < tmpHigh)].shape[0]
        cntDense += res[res >= tmpHigh].shape[0]

    result[threadID] = {
        "cntNo": cntNo,
        "cntSparse": cntSparse,
        "cntMid": cntMid,
        "cntDense": cntDense,
        "hist": hist
    }

class GeomProcessor():
    def __init__(self, ft, dstOSR, inImages, dstResolution, product, cfgObj):
        self.__ft = ft
        self._rasterFt = None
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
        del self._rasterFt
        self.__rasterExtents = None
        del self.__dstOSR
        self.__srcImages = None
        self.__dstResolution = None
        self.__variable = None
        self.__pixelToAreaFunc = None

    def __setPixelToAreaFunc(self):
        tmpData = gdal.Open(self.__srcImages[0][0])
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

            dbVals += "({0},{1},{2},{3},{4},{5},'{6}','{7}','{8}','{9}', '{10}'),"\
                .format(dt["poly_id"], dt["product_file_id"], dt["no"], dt["sparse"], dt["mid"],dt["dense"], json.dumps(dt["novalcolor"]),
                        json.dumps(dt["sparsevalcolor"]), json.dumps(dt["midvalcolor"]), json.dumps(dt["highvalcolor"]),
                        json.dumps(dt["histogram"]))
        query = """WITH tmp_data(poly_id, product_file_id, noval_area_ha, sparse_area_ha, mid_area_ha, dense_area_ha,
        noval_color, sparseval_color, midval_color, highval_color, histogram) AS( VALUES {0})
         INSERT INTO {1}.poly_stats(poly_id, product_file_id, noval_area_ha, sparse_area_ha, mid_area_ha, dense_area_ha,
         noval_color, sparseval_color, midval_color, highval_color, histogram)
         SELECT tdt.poly_id::bigint, tdt.product_file_id::bigint, tdt.noval_area_ha::double precision, 
         tdt.sparse_area_ha::double precision, tdt.mid_area_ha::double precision, tdt.dense_area_ha::double precision,
         noval_color::jsonb, sparseval_color::jsonb, midval_color::jsonb, highval_color::jsonb, histogram::jsonb
         FROM tmp_data tdt
         ON CONFLICT(poly_id, product_file_id) DO NOTHING;""".format(dbVals[0:-1], self._config.statsInfo.schema)

        self._config.pgConnections[self._config.statsInfo.connectionId].executeQueries([query])
        return

    def __geomRasterizer(self):
        #assuming that all input images are aligned on the same grid

        allignedImage = AlignToImage(self.__ft, self.__srcImages[0])

        self.__rasterExtents = allignedImage.process(vector=True)
        self._rasterFt = geomRasterizer(self.__rasterExtents, self.__dstResolution, self.__ft, self.__dstOSR)
        
    def __extractStats(self, low, mid, high, nThreads):
        out = list(range(len(self.__srcImages)))
        imgIdx = 0

        chunkCnt = nThreads
        if self._rasterFt.shape[0] < 500 and self._rasterFt.shape[1] < 500:
            chunkCnt = 1

        chunks = chunkIt(range(self._rasterFt.shape[1]), chunkCnt)
        for chunk in chunks:
            print(chunk)

        for image in self.__srcImages:
            #print(image[0])
            inRasterData = gdal.Open(image[0])
            metaData = inRasterData.GetMetadata()
            tmpLow = low
            tmpSparse = mid
            tmpHigh = high
            maxVal = Constants.PRODUCT_INFO[self.__product].maxValue
            minVal = Constants.PRODUCT_INFO[self.__product].minValue

            if image[0][0:6] == "NETCDF":
                tmpLow = reverseValue(metaData, low, self.__variable)
                tmpSparse = reverseValue(metaData, mid, self.__variable)
                tmpHigh = reverseValue(metaData, high, self.__variable)
                maxVal = scaleValue(metaData, maxVal, self.__variable)
                minVal = scaleValue(metaData, minVal, self.__variable)

            noDataValue = inRasterData.GetRasterBand(1).GetNoDataValue()

            inGt = inRasterData.GetGeoTransform()
            upperLeft  = xyToColRow(self.__rasterExtents[0][0], self.__rasterExtents[0][1], inGt)
            lowerRight = xyToColRow(self.__rasterExtents[1][0], self.__rasterExtents[1][1], inGt)

            id = self.__ft.GetFID()

            cntNo = 0
            cntSparse = 0
            cntMid = 0
            cntDense = 0

            bins = 10
            hist = np.zeros(bins)
            histWidth = (maxVal-minVal) / bins

            histXaxis = list(range(bins+1))
            for i in range(bins+1):
                histXaxis[i] = np.round(minVal + i* histWidth,3)

            out[imgIdx] = {
                "poly_id": id,
                "product_file_id": self.__srcImages[imgIdx][1],
                "no": "NULL",
                "sparse": "NULL",
                "mid": "NULL",
                "dense": "NULL",
                "novalcolor": "NULL",
                "sparsevalcolor": "NULL",
                "midvalcolor": "NULL",
                "highvalcolor": "NULL",
                "histogram": {"x":histXaxis, "y": hist.tolist()}
            }

            if (not (upperLeft[0] >= 0 and upperLeft[1] >= 0 and lowerRight[0] < inRasterData.RasterXSize and lowerRight[1] < inRasterData.RasterYSize)):
                imgIdx += 1
                continue

            threads = list(range(len(chunks)))
            trd = 0

            results = Manager().dict()
            for i in range(len(chunks)):
                results[i] = None

            for chunk in chunks:
                threads[trd] = Process(target=computeStats, args=(trd, image[0],self._rasterFt, chunk, upperLeft,
                                                                self.__product, bins,tmpLow, tmpSparse, tmpHigh,
                                                                  results))
                threads[trd].start()
                trd +=1

            for trd in threads:
                trd.join()

            for key in results:
                cntNo += results[key]["cntNo"]
                cntSparse += results[key]["cntSparse"]
                cntMid += results[key]["cntMid"]
                cntDense += results[key]["cntDense"]
                hist += results[key]["hist"]

            noAreaHa = np.round(self.__pixelToAreaFunc(cntNo, inGt[1])/10000,2)
            sparseAreaHa = np.round(self.__pixelToAreaFunc(cntSparse, inGt[1])/10000,2)
            midAreaHa = np.round(self.__pixelToAreaFunc(cntMid, inGt[1])/10000,2)
            denseAreaHa = np.round(self.__pixelToAreaFunc(cntDense, inGt[1])/10000,2)

            #print(noAreaHa, sparseAreaHa, midAreaHa, denseAreaHa)
            sumAreaHa = noAreaHa + sparseAreaHa + midAreaHa + denseAreaHa

            if sumAreaHa != 0:
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
                    "product_file_id": self.__srcImages[imgIdx][1],
                    "no": noAreaHa,
                    "sparse": sparseAreaHa,
                    "mid": midAreaHa,
                    "dense": denseAreaHa,
                    "novalcolor":noValColor,
                    "sparsevalcolor": sparseValColor,
                    "midvalcolor": midValColor,
                    "highvalcolor": highValColor,
                    "histogram": {"x":histXaxis, "y": hist.tolist()}
                }
            imgIdx += 1
            del inRasterData
            inRasterData = None

        return out

    def process(self, nThreads = 12):
        self.__setPixelToAreaFunc()
        self.__geomRasterizer()
        if self._rasterFt is not None:
            data = self.__extractStats(self.__valueRange["low"], self.__valueRange["mid"], self.__valueRange["high"], nThreads)
            #self.__storeToDB(data)

def geomProcessor(inImages, poly, productInfo, cfgObj, nThreads):
    inRasterData = gdal.Open(inImages[0][0])

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
    ret = geoProc.process(nThreads)

    del geoProc
    geoProc = None
    del ft
    ft = None
    del geom
    geom = None

    del ftSRS
    ftSRS = None
    del dstOSR
    dstOSR = None
    del inRasterData
    inRasterData = None
    return ret

class ZonalStatsExtractor():
    def __init__(self, stratificationType, configFile = "../config.json"):
        self._stratificationType = stratificationType
        self._config = ConfigurationParser(configFile)

    def process(self, nThreads=multiprocessing.cpu_count()-1, productIds=[12,]):
        try:
            self._config.parse()
            Constants.load(self._config.getFile())

            #creating cursor to retrieve polygons and respective images from DB
            session = self._config.pgConnections[self._config.statsInfo.connectionId].getNewSession()

            for prdId in productIds:
                dataQuery = """
                SELECT sg.id, pfd.id, ARRAY_AGG(JSON_BUILD_ARRAY(pf.rel_file_path, pf.id)) images, ST_ASTEXT(sg.geom)
                , ST_SRID(sg.geom) 
                FROM stratification s 
                JOIN stratification_geom sg ON s.id = sg.stratification_id --AND sg.id = 1
                JOIN product p ON TRUE
                JOIN product_file_description pfd ON p.id = pfd.product_id AND pfd.id = {0} 
                JOIN product_file pf ON pfd.id = pf.product_description_id 
                LEFT JOIN poly_stats ps ON ps.poly_id = sg.id AND ps.product_file_id = pf.id
                WHERE sg.id = 47 AND s.description ='{1}' AND ((p.type='raw'AND pfd.variable IS NOT NULL) OR p.type='anomaly') AND ps.id IS NULL 
                GROUP BY sg.id, pfd.id ORDER BY pfd.id, sg.id""".format(prdId,
                                                                        self._stratificationType)

                print(dataQuery)
                res = self._config.pgConnections[self._config.statsInfo.connectionId].getIteratableResult(dataQuery,
                                                                                                         session)
                for row in res:
                    images = list(range(len(row[2])))
                    path = self._config.filesystem.imageryPath
                    if Constants.PRODUCT_INFO[row[1]].productType == "anomaly":
                        path = self._config.filesystem.anomalyProductsPath

                    for i in range(len(row[2])):
                        imgPath = os.path.join(path, row[2][i][0])
                        if imgPath.endswith(".nc"):
                            imgPath = netCDFSubDataset(imgPath, Constants.PRODUCT_INFO[row[1]].variable)
                        images[i] = [imgPath, row[2][i][1]]

                    geomProcessor(images, [row[0], row[3],row[4]], row[1], self._config, nThreads)
                res = None


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

    if len(sys.argv) < 3:
        print("Usage: python ZonalStatsExtractor.py config_file stratification_type")
        return 1

    cfg = sys.argv[1]
    stratificationType = sys.argv[2]

    #loading constants
    Constants.load(cfg)

    #raw data server directory: /home/argyros/Desktop/data/BIOPAR/BioPar_NDVI300_V2_Global/

    #requirements:
    obj = ZonalStatsExtractor(stratificationType, cfg)
    obj.process(nThreads=12)
    print("Finished!")

if __name__ == "__main__":
    main()

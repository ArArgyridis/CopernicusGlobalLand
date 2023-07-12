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

import os, re, numpy as np, shutil, signal, sys, xml.etree.ElementTree as ET, multiprocessing
from osgeo import gdal, osr
from concurrent.futures import ProcessPoolExecutor
sys.path.extend(['../../']) #to properly import modules from other dirs

from Libs.MapServer import MapServer, LayerInfo
from Libs.Utils import GDALErrorHandler, getImageExtent, netCDFSubDataset, plainScaller, linearScaller
from Libs.Constants import Constants
from Libs.ConfigurationParser import ConfigurationParser


def myProgress(progress, progressData, callbackData):
    progress = np.round(progress,2)*100

    if progress == 0 or ( progress % 10 == 0 and progress >= 10):
        print("{0}%".format(progress), end=" ")
        callbackData["cnt"] = 0
    elif callbackData["cnt"] < 3:
        callbackData["cnt"] += 1
        print(".", end=" ")


def applyColorTable(dstImg, style):
    ns = {"sld": "http://www.opengis.net/sld"}
    root = ET.fromstring(style)

    colors = gdal.ColorTable()
    for color in root.findall(".//*[@quantity]", ns):
        h = color.attrib["color"].lstrip("#")
        colors.SetColorEntry(int(color.attrib["quantity"]), tuple(int(h[i:i + 2], 16) for i in (0, 2, 4)))

    outDt = gdal.Open(dstImg, gdal.GA_Update)
    outDt.GetRasterBand(1).SetRasterColorTable(colors)
    outDt = None
    
def runSingleImage(params, relImagePath):
    obj = SingleImageProcessor(params, relImagePath)
    ret = obj.processSingleImage()
    obj = None
    return ret


class SingleImageProcessor:
    def __init__(self, params, relImagePath):
        self._params = params
        self._relImagePath = relImagePath
        self._dstImg = None
        self._dstOverviews = None
        import signal as lsignal
        self.lsignal = lsignal
        self._originalSIGTERMHandler = lsignal.getsignal(signal.SIGTERM)
        self.lsignal.signal(lsignal.SIGTERM, self.rollBack)
        
    def __del__(self):
        self.lsignal.signal(self.lsignal.SIGTERM, self._originalSIGTERMHandler)
        self.lsignal = None
        print("destroyed image processor")

    def rollBack(self, **kwargs):
        print("rolling back for images: {0}\t {1}".format(self._dstImg, self._dstOverviews))
        if self._dstImg is not None and os.path.isfile(self._dstImg):
            os.remove(self._dstImg)

        if self._dstOverviews is not None and os.path.isfile(self._dstOverviews):
            os.remove(self._dstOverviews)

    def processSingleImage(self):
        image = os.path.join(self._params["dataPath"],self._relImagePath[0])
        ret = []

        variable = self._params["variable"]
        if variable is None:
            variable = ''
        variableParams = self._params["productInfo"].variables[self._params["variable"]]
        buildOverviews = False
        try:
            if self._params["productInfo"].productType == "raw":
                if image.endswith(".nc"):
                    image = netCDFSubDataset(image, variable)

                self._dstImg = os.path.join(self._params["mapserverPath"], *["raw", self._params["productInfo"].productNames[0],
                                                                 self._relImagePath[1].strftime("%Y"),
                                                                 self._relImagePath[1].strftime("%m"),
                                                                 variable,
                                                                 os.path.split(self._relImagePath[0])[-1].split(".")[0] + ".tif"])
                
                self._dstOverviews = self._dstImg + ".ovr"
                
                try:
                    gdal.Open(self._dstImg)
                except:
                    print("processing: ", image)

                    buildOverviews = True
                    tmpDt = gdal.Open(image)
                    os.makedirs(os.path.split(self._dstImg)[0], exist_ok=True)

                    outDrv = gdal.GetDriverByName("COG")
                    outDt = outDrv.Create(self._dstImg, tmpDt.RasterXSize, tmpDt.RasterYSize, bands=1, eType=gdal.GDT_Byte,
                                      options=["COMPRESS=LZW", "TILED=YES", "PREDICTOR=2"])
                    outDt.SetProjection(tmpDt.GetProjection())
                    outDt.SetGeoTransform(tmpDt.GetGeoTransform())
                    outBnd = outDt.GetRasterBand(1)
                    origNoDataValue = tmpDt.GetRasterBand(1).GetNoDataValue()

                    scaler = None
                    if variableParams.minProdValue >= 0 and variableParams.maxProdValue <= 255:
                        scaler = plainScaller
                    else:
                        scaler = linearScaller
                    try:
                        for row in range(tmpDt.RasterXSize):
                            rowDt = tmpDt.ReadAsArray(row, 0, 1, tmpDt.RasterYSize)
                            fixedDt = scaler(rowDt, variableParams.minValue,
                                             variableParams.maxValue, origNoDataValue, 255,
                                             variableParams.minProdValue, variableParams.maxProdValue)

                            outBnd.WriteArray(fixedDt, row, 0)

                        outBnd.SetNoDataValue(255)

                        outDt.FlushCache()
                        outDt = None
                    except Exception as e:
                        print("issue for image: ", self._dstImg)
                        print ("issue: ", e)
                        self.rollBack()


            elif self._params["productInfo"].productType == "anomaly": #for now just copy file
                localGDAL = os.path.join(self._params["mapserverPath"], *["anomaly", self._relImagePath[0]])
                try:
                    gdal.Open(self._dstImg)
                except:
                    print("processing: ", image)
                    buildOverviews = True
                    os.makedirs(os.path.split(self._dstImg)[0], exist_ok=True)
                    shutil.copy(image, self._dstImg)

            if variableParams.style is not None:
                applyColorTable(self._dstImg, variableParams.style)

            outDt = None
            

            if not os.path.isfile(self._dstOverviews ):
                buildOverviews = True

            if buildOverviews:
                outDt = gdal.Open(self._dstImg)
                print("Building overviews for: " + os.path.split(self._dstImg)[1])

                if os.path.isfile(self._dstOverviews ):
                    os.remove(self._dstOverviews )

                outDt.BuildOverviews(resampling="AVERAGE", overviewlist=[2, 4, 8, 16, 32, 64])
                outDt = None

            ptr = re.compile(self._params["productInfo"].pattern)
            date = self._params["productInfo"].createDate(ptr.findall(os.path.split(self._relImagePath[0])[1])[0])

            layerName = None
            if self._params["productInfo"].productType == "raw":
                layerName = "{0}_{1}".format(date[0:10], variable)
            elif self._params["productInfo"].productType == "anomaly":
                layerName = date[0:10]

            ret.append(LayerInfo(self._dstImg, layerName, "EPSG:4326",None, None, getImageExtent(self._dstImg), date,
                                 self._params["productInfo"].id))
            return ret
        except Exception as e:#rolling back filesystem
            print("issue for image: ", self._dstImg)
            print("issue: ", e)
            self.rollBack()
            return None



class MapserverImporter(object):
    def __init__(self, cfg):
        self._config = ConfigurationParser(cfg)
        self._config.parse()

        self._layerInfo = []

    def __prepareLayerForImport(self, productId, variable, productFiles, nThreads=8):
        executor = ProcessPoolExecutor(max_workers=nThreads)
        rootPath = self._config.filesystem.imageryPath
        if Constants.PRODUCT_INFO[productId].productType == "anomaly":
            rootPath = self._config.filesystem.anomalyProductsPath

        threads = executor.map(runSingleImage, [{
            "dataPath":rootPath,
            "mapserverPath": self._config.filesystem.mapserverPath,
            "productInfo":Constants.PRODUCT_INFO[productId],
            "variable": variable,
            }]*productFiles.rowcount, productFiles)

        for result in threads:
            if result is not None:
                self._layerInfo += result

    def process(self, productId):
        productGroups = dict()
        #for productId in Constants.PRODUCT_INFO:
        #print(Constants.PRODUCT_INFO[productId].productType)
        query = """SELECT rel_file_path, date FROM product_file WHERE product_file_description_id = {0} 
        ORDER BY rel_file_path""".format(productId)

        for variable in Constants.PRODUCT_INFO[productId].variables:
            res = self._config.pgConnections[self._config.statsInfo.connectionId].getIteratableResult(query)
            self.__prepareLayerForImport(productId, variable, res)

            #grouping layers per product and year
            for layer in self._layerInfo:
                #check if the current product exists
                if layer.productKey not in productGroups:
                    productGroups[layer.productKey] = {}

                #check if another product for the examined year has been appended
                year = layer.date[0:4]
                if year not in productGroups[layer.productKey]:
                    productGroups[layer.productKey][year] = {}
                month = layer.date[5:7]
                if month not in productGroups[layer.productKey][year]:
                    productGroups[layer.productKey][year][month] = []

                #finally append the product
                productGroups[layer.productKey][year][month].append(layer)

            for productKey in productGroups:
                for year in productGroups[productKey]:
                    mapservURL = self._config.mapserver.rawDataWMS

                    if (Constants.PRODUCT_INFO[productKey].productType == "anomaly"):
                        mapservURL = self._config.mapserver.anomaliesWMS



                    for month in productGroups[productKey][year]:
                        outPathParams = [Constants.PRODUCT_INFO[productKey].productType,
                                         Constants.PRODUCT_INFO[productKey].productNames[0], year, month,
                                         "mapserver.map"]
                        if variable != "":
                            outPathParams.insert(-1, variable)


                        outFile = os.path.join(self._config.filesystem.mapserverPath, *outPathParams)

                        #print(outFile)
                        mapserv = MapServer(productGroups[productKey][year][month],
                                        mapservURL.format(Constants.PRODUCT_INFO[productKey].productNames[0],
                                                          year,month, variable), outFile)
                        mapserv.process()




def main():
    if len(sys.argv) < 2:
        print("Usage: python MapserverImporter.py config_file")
        return

    cfg = sys.argv[1]
    Constants.load(cfg)
    for productId in Constants.PRODUCT_INFO:
        obj = MapserverImporter(cfg)
        obj.process(productId)



if __name__ == "__main__":
    main()

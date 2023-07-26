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
import copy
import os, re, numpy as np, shutil, signal, sys, xml.etree.ElementTree as ET, multiprocessing
from osgeo import gdal, osr
from concurrent.futures import ProcessPoolExecutor
sys.path.extend(['../../']) #to properly import modules from other dirs

from Libs.MapServer import MapServer, LayerInfo
from Libs.Utils import checkAndDeleteFile, getImageExtent, netCDFSubDataset, plainScaller, linearScaller
from Libs.Constants import Constants
from Libs.ConfigurationParser import ConfigurationParser
gdal.DontUseExceptions()

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
    





class SingleImageProcessor:
    def __init__(self, params, info):
        print("starting! ", info)
        self._params = params
        self._relImagePath = info[0]
        self._date = info[1]
        self._rtFlag = info[2]
        self._dstImg = None
        self._dstOverviews = None
        self._tmpImg = None
        self._tmpOverviews = None
        import signal as lsignal
        self._signal = lsignal
        self._originalSIGTERMHandler = self._signal.getsignal(signal.SIGTERM)

        
    def __del__(self):
        self._signal.signal(self._signal.SIGTERM, self._originalSIGTERMHandler)
        checkAndDeleteFile(self._tmpImg)
        checkAndDeleteFile(self._tmpOverviews)
        print("destroyed image processor")

    def rollBack(self, **kwargs):
        print("rolling back for images: {0}\t {1}".format(self._dstImg, self._dstOverviews))
        checkAndDeleteFile(self._dstImg)
        checkAndDeleteFile(self._dstOverviews)
        checkAndDeleteFile(self._tmpImg)
        checkAndDeleteFile(self._tmpOverviews)
        self._signal.signal(self._signal.SIGTERM, self._originalSIGTERMHandler)

    def processSingleImage(self):
        self._signal.signal(signal.SIGTERM, self.rollBack)
        image = os.path.join(self._params["dataPath"],self._relImagePath)
        variable = self._params["variable"]

        if variable is None:
            variable = ''
        variableParams = self._params["productInfo"].variables[self._params["variable"]]
        buildOverviews = False

        if self._params["productInfo"].productType == "raw":
            if variable != "": #netcdf-like subdataset
                image = netCDFSubDataset(image, variable)

            self._dstImg = os.path.join(self._params["mapserverPath"],
                                        *["raw", self._params["productInfo"].productNames[0],
                                          self._date.strftime("%Y"),
                                          self._date.strftime("%m"),
                                          variable,
                                          os.path.split(self._relImagePath)[-1].split(".")[0] + ".tif"])

            if not self._params["useCOG"]:
                self._dstOverviews = self._dstImg + ".ovr"

            dstImgDt = gdal.Open(self._dstImg)
            if dstImgDt is None:
                print("processing: ", image)
                buildOverviews = True
                inDt = gdal.Open(image)

                tmpDrv = gdal.GetDriverByName("GTiff")

                self._tmpImg = os.path.join(self._params["tmpPath"],
                                            *["raw", self._params["productInfo"].productNames[0],
                                              self._date.strftime("%Y"),
                                              self._date.strftime("%m"),
                                              variable,
                                              os.path.split(self._relImagePath)[-1].split(".")[0] + ".tif"])

                #creating respective directories
                os.makedirs(os.path.split(self._dstImg)[0], exist_ok=True)
                os.makedirs(os.path.split(self._tmpImg)[0], exist_ok=True)

                checkAndDeleteFile(self._tmpImg)

                dstImgDt = tmpDrv.Create(self._tmpImg, inDt.RasterXSize, inDt.RasterYSize, bands=1, eType=gdal.GDT_Byte,
                                  options=["COMPRESS=LZW", "TILED=YES", "PREDICTOR=2"])
                dstImgDt.SetProjection(inDt.GetProjection())
                dstImgDt.SetGeoTransform(inDt.GetGeoTransform())
                outBnd = dstImgDt.GetRasterBand(1)
                origNoDataValue = inDt.GetRasterBand(1).GetNoDataValue()

                scaler = None
                if variableParams.minProdValue >= 0 and variableParams.maxProdValue <= 255:
                    scaler = plainScaller
                else:
                    scaler = linearScaller

                for row in range(inDt.RasterXSize):
                    rowDt = inDt.ReadAsArray(row, 0, 1, inDt.RasterYSize)
                    fixedDt = scaler(rowDt, variableParams.minValue,
                                     variableParams.maxValue, origNoDataValue, 255,
                                     variableParams.minProdValue, variableParams.maxProdValue)

                    outBnd.WriteArray(fixedDt, row, 0)

                outBnd.SetNoDataValue(255)
                del outBnd
                outBnd = None
                del inDt
                inDt = None

            del dstImgDt
            dstImgDt = None

        elif self._params["productInfo"].productType == "anomaly": #for now just copy file
            self._dstImg = os.path.join(self._params["mapserverPath"], *["anomaly", self._relImagePath])
            if not self._params["useCOG"]:
                self._dstOverviews = self._dstImg + ".ovr"

            dstImgDt = gdal.Open(self._dstImg)
            if dstImgDt is None:
                print("processing: ", image)
                buildOverviews = True
                os.makedirs(os.path.split(self._dstImg)[0], exist_ok=True)
                shutil.copy(image, self._dstImg)
                self._tmpImg = self._dstImg

            del dstImgDt
            dstImgDt = None

        if self._tmpImg is not None and variableParams.style is not None:
            applyColorTable(self._tmpImg, variableParams.style)

        if self._dstOverviews is not None and not os.path.isfile(self._dstOverviews):
            buildOverviews = True

        if not self._params["useCOG"]:
            if buildOverviews:
                tmpDt = gdal.Open(self._tmpImg)
                print("Building overviews for: " + os.path.split(self._tmpImg)[1])

                checkAndDeleteFile(self._dstOverviews)
                self._tmpOverviews = self._tmpImg + ".ovr"
                checkAndDeleteFile(self._tmpOverviews)

                tmpDt.BuildOverviews(resampling="AVERAGE", overviewlist=[2, 4, 8, 16, 32, 64])
                tmpDt = None
        elif self._tmpImg is not None:
            #convert tmp image to cog
            splitTmpImg = list(os.path.split(self._tmpImg))
            splitTmpImg[1] = "cog_" + splitTmpImg[1]
            cogImg = os.path.join(*splitTmpImg)
            checkAndDeleteFile(cogImg)
            kwargs = {'format': 'COG'}
            gdal.Warp(cogImg, self._tmpImg, **kwargs)
            checkAndDeleteFile(self._tmpImg)
            self._tmpImg = cogImg

        #copying files to destination directory
        if self._tmpImg is not None:
            shutil.copy(self._tmpImg, self._dstImg)
            checkAndDeleteFile(self._tmpImg)

            if self._dstOverviews is not None:
                shutil.copy(self._tmpOverviews, self._dstOverviews)
                checkAndDeleteFile(self._tmpOverviews)

        ptr = re.compile(self._params["productInfo"].pattern)
        date = self._params["productInfo"].createDate(ptr.findall(os.path.split(self._relImagePath)[1])[0])

        layerName = None
        if self._params["productInfo"].productType == "raw":
            layerName = "{0}_{1}".format(date[0:10], variable)
        elif self._params["productInfo"].productType == "anomaly":
            layerName = date[0:10]

        if self._rtFlag is not None:
            layerName += "_RT{0}".format(self._rtFlag)

        layerImg = self._dstImg
        if self._params["virtualPrefixPath"] is not None:
            layerImg = self._params["virtualPrefixPath"] + layerImg

        #cleaning up handler
        self._signal.signal(self._signal.SIGTERM, self._originalSIGTERMHandler)
        return LayerInfo(layerImg, layerName, "EPSG:4326", None, None, getImageExtent(self._dstImg), date,
                             self._params["productInfo"].id)

def runSingleImage(params, relImagePath):
    obj = SingleImageProcessor(params, relImagePath)
    ret = obj.processSingleImage()
    del obj
    return ret



class MapserverImporter(object):
    def __init__(self, cfg):
        self._config = ConfigurationParser(cfg)
        self._config.parse()

        self._layerInfo = []

    def __prepareLayerForImport(self, productId, variable, productFiles, nThreads=8):
        with ProcessPoolExecutor(max_workers=nThreads) as executor:
            rootPath = self._config.filesystem.imageryPath

            if Constants.PRODUCT_INFO[productId].productType == "anomaly":
                rootPath = self._config.filesystem.anomalyProductsPath

            threads = executor.map(runSingleImage, [{
                "dataPath":rootPath,
                "mapserverPath": self._config.filesystem.mapserverPath,
                "virtualPrefixPath": self._config.mapserver.virtualPrefix,
                "tmpPath": self._config.filesystem.tmpPath,
                "useCOG": self._config.mapserver.useCOG,
                "productInfo":Constants.PRODUCT_INFO[productId],
                "variable": variable,
                }]*productFiles.rowcount, productFiles)

            for result in threads:
                if result is not None:
                    self._layerInfo.append(result)



    def process(self, productId):
        productGroups = dict()
        query = """SELECT rel_file_path, date, rt_flag FROM product_file 
        WHERE product_file_description_id = {0} 
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


                        outFile = os.path.join(self._config.filesystem.mapserverFilePath, *outPathParams)

                        #print(outFile)
                        mapserv = MapServer(productGroups[productKey][year][month],
                                        mapservURL.format(Constants.PRODUCT_INFO[productKey].productNames[0],
                                                          year,month, variable), outFile,
                                            "NatStats CGLS WMS Service", self._config.mapserver.configOption,
                                            7000)
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

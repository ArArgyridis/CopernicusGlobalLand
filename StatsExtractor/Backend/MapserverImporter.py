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

import os, re, numpy as np, shutil, sys, xml.etree.ElementTree as ET, multiprocessing
from osgeo import gdal, osr
from concurrent.futures import ProcessPoolExecutor

sys.path.extend(['../../']) #to properly import modules from other dirs

from Libs.MapServer import MapServer, LayerInfo
from Libs.Utils import getImageExtent, getListOfFiles, netCDFSubDataset
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

def processSingleImage(params, relImagePath):

    from osgeo import gdal
    gdal.SetConfigOption("COMPRESS_OVERVIEW", "DEFLATE")

    image = os.path.join(params["dataPath"],relImagePath[0])
    print(image)

    dstImg = None
    if params["productInfo"].productType == "raw":
        if image.endswith(".nc"):
            subDataset = netCDFSubDataset(image, params["productInfo"].variable)
            tmpDt = gdal.Open(subDataset)
            tmpGt = tmpDt.GetGeoTransform()

            dstImg = os.path.join(params["mapserverPath"], *["raw", relImagePath[0].split(".")[0]+".tif"])
            os.makedirs(os.path.split(dstImg)[0], exist_ok=True)

            print(dstImg)

            if not os.path.isfile(dstImg):
                outDrv = gdal.GetDriverByName("GTiff")
                outDt = outDrv.Create(dstImg, tmpDt.RasterXSize, tmpDt.RasterYSize, bands=1, eType=gdal.GDT_Byte,
                                  options=["COMPRESS=LZW", "TILED=YES", "PREDICTOR=2"])
                outDt.SetProjection(tmpDt.GetProjection())
                outDt.SetGeoTransform(tmpDt.GetGeoTransform())
                outBnd = outDt.GetRasterBand(1)

                try:
                    for row in range(tmpDt.RasterXSize):
                        outBnd.WriteArray(tmpDt.ReadAsArray(row, 0, 1, tmpDt.RasterYSize), row, 0)
                        outBnd.SetNoDataValue(tmpDt.GetRasterBand(1).GetNoDataValue())
                    outBnd = None
                    outDt = None
                except:
                    print("issue for image: ", dstImg)


    elif params["productInfo"].productType == "anomaly": #for now just copy file
        dstImg = os.path.join(params["mapserverPath"], *["anomaly", relImagePath[0]])
        if not os.path.isfile(dstImg):
            os.makedirs(os.path.split(dstImg)[0], exist_ok=True)
            shutil.copy(image, dstImg)

    if params["productInfo"].style is not None:
        applyColorTable(dstImg, params["productInfo"].style)


    dstOverviews = dstImg + ".ovr"
    outDt = gdal.Open(dstImg)
    if not os.path.isfile(dstOverviews):
        outDt = gdal.Open(dstImg)
        print("Building overviews for: " + os.path.split(dstImg)[1])

        # , callback=myProgress
        callbackData = {
            "cnt": 0
        }
        outDt.BuildOverviews(resampling="AVERAGE", overviewlist=[2, 4, 8, 16, 32, 64], callback=myProgress,callback_data=callbackData)
        outDt = None

    outDt = gdal.Open(dstImg)
    ptr = re.compile(params["productInfo"].pattern)
    date = params["productInfo"].createDate(ptr.findall(os.path.split(relImagePath[0])[1])[0])
    return LayerInfo(dstImg, "{0}_{1}".format(date[0:10], params["productInfo"].variable), "EPSG:4326", outDt.RasterXSize,
                      outDt.RasterYSize, getImageExtent(dstImg), date, params["productInfo"].id)


class MapserverImporter(object):
    def __init__(self, cfg):
        self._config = ConfigurationParser(cfg)
        self._config.parse()

        self._layerInfo = []

    def __prepareLayerForImport(self, productId, productFiles, nThreads=multiprocessing.cpu_count()-1):
        executor = ProcessPoolExecutor(max_workers=nThreads)
        rootPath = self._config.filesystem.imageryPath
        if Constants.PRODUCT_INFO[productId].productType == "anomaly":
            rootPath = self._config.filesystem.anomalyProductsPath
        """
        for row in productFiles:
            
            processSingleImage({ "dataPath":rootPath,
                                 "mapserverPath": self._config.filesystem.mapserverPath,
                                 "productInfo":Constants.PRODUCT_INFO[productId]
                                }, row)
        """

        threads = executor.map(processSingleImage, [{ "dataPath":rootPath,
                                                     "mapserverPath": self._config.filesystem.mapserverPath,
                                                     "productInfo":Constants.PRODUCT_INFO[productId]
                                                     }]*productFiles.rowcount, productFiles)

        for result in threads:
            if result is not None:
                self._layerInfo.append(result)


    def process(self):
        productGroups = dict()
        for productId in Constants.PRODUCT_INFO:
            print(Constants.PRODUCT_INFO[productId].productType)
            query = "SELECT rel_file_path FROM product_file WHERE product_description_id = {0}".format(productId)
            res = self._config.pgConnections[self._config.statsInfo.connectionId].getIteratableResult(query)
            self.__prepareLayerForImport(productId, res)

        #grouping layers per product and year
        for layer in self._layerInfo:
            #check if the current product exists
            if layer.productKey not in productGroups:
                productGroups[layer.productKey] = {}

            #check if another product for the examined year has been appended
            year = layer.date[0:4]
            if year not in productGroups[layer.productKey]:
                productGroups[layer.productKey][year] = []

            #finally append the product
            productGroups[layer.productKey][year].append(layer)

        for productKey in productGroups:
            for year in productGroups[productKey]:
                outFile = os.path.join(self._config.filesystem.mapserverPath,
                                       *(Constants.PRODUCT_INFO[productKey].productType,
                                         Constants.PRODUCT_INFO[productKey].productNames[0], year, "mapserver.map"))
                mapservURL = self._config.mapserver.rawDataWMS
                if(Constants.PRODUCT_INFO[productKey].productType == "anomaly"):
                    mapservURL = self._config.mapserver.anomaliesWMS

                mapserv = MapServer(productGroups[productKey][year], mapservURL.format(Constants.PRODUCT_INFO[productKey].productNames[0], year), outFile)
                mapserv.process()




def main():
    if len(sys.argv) < 2:
        print("Usage: python MapserverImporter.py config_file")
        return

    cfg = sys.argv[1]
    Constants.load(cfg)




    #config = ConfigurationParser(cfg)
    #config.parse()

    obj = MapserverImporter(cfg)
    obj.process()



if __name__ == "__main__":
    main()

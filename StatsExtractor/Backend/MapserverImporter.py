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

import os, numpy as np, sys, xml.etree.ElementTree as ET, multiprocessing
from osgeo import gdal, osr
from concurrent.futures import ProcessPoolExecutor

from samba.dcerpc.dcerpc import response

from Libs.MapServer import MapServer, LayerInfo
from Libs.Utils import getImageExtent, getListOfFiles, netCDFSubDataset
from Libs.Constants import Constants
from Libs.ConfigurationParser import ConfigurationParser

def myProgress(progress, progressData, another):
    progress = np.round(progress,2)
    prt = "."
    if progress % 0.1 == 0:
        prt = "{0}%".format(progress * 100)
    print(prt, end=" ")

def applyColorTable(dstImg, product):
    ns = {"sld": "http://www.opengis.net/sld"}
    root = ET.fromstring(product.style)

    colors = gdal.ColorTable()

    for color in root.findall(".//*[@quantity]", ns):
        h = color.attrib["color"].lstrip("#")
        colors.SetColorEntry(int(color.attrib["quantity"]), tuple(int(h[i:i + 2], 16) for i in (0, 2, 4)))

    outDt = gdal.Open(dstImg, gdal.GA_Update)
    outDt.GetRasterBand(1).SetRasterColorTable(colors)
    outDt = None

def processSingleImage(image):
    from osgeo import gdal
    gdal.SetConfigOption("COMPRESS_OVERVIEW", "DEFLATE")

    tmpImg = os.path.split(image)[1]
    res = Constants.getImageProduct(tmpImg)
    if res is None:
        print("Unable to match image {0} with any products. Continuing".format(tmpImg))
        return None

    productKey, product, date = res
    subDataset = netCDFSubDataset(image, product.variable)
    tmpDt = gdal.Open(subDataset)
    tmpGt = tmpDt.GetGeoTransform()

    dstImg = os.path.splitext(image)[0] + ".tif"

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

    applyColorTable(dstImg, product)

    dstOverviews = dstImg + ".ovr"
    outDt = gdal.Open(dstImg)
    if not os.path.isfile(dstOverviews):
        outDt = gdal.Open(dstImg)
        print("Building overviews for: " + os.path.split(dstImg)[1])

        # , callback=myProgress
        outDt.BuildOverviews(resampling="AVERAGE", overviewlist=[2, 4, 8, 16, 32, 64], callback=myProgress)
        outDt = None

    outDt = gdal.Open(dstImg)
    return LayerInfo(dstImg, "{0}_{1}".format(date[0:10], product.variable), "EPSG:4326", outDt.RasterXSize,
                      outDt.RasterYSize, getImageExtent(subDataset), date, productKey)

class MapserverImporter(object):
    def __init__(self, productDirectory):
        self._productsDirectory = productDirectory
        self._imageList = []
        self._layerInfo = []

    def __prepareLayerForImport(self, nThreads=multiprocessing.cpu_count()-1):
        executor = ProcessPoolExecutor(max_workers=nThreads)
        threads = executor.map(processSingleImage, self._imageList)

        for result in threads:
            if result is not None:
                self._layerInfo.append(result)

    def process(self):
        self._imageList = getListOfFiles(self._productsDirectory)
        self._imageList = [img for img in self._imageList if img.endswith(".nc")]
        self.__prepareLayerForImport()

        productGroups = dict()
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
                outFile = os.path.join(self._productsDirectory, *(productKey, year, "mapserver.map"))
                mapserv = MapServer(productGroups[productKey][year], "http://192.168.2.2/wms/{0}/{1}".format(productKey, year), outFile)
                mapserv.process()



def main():
    if len(sys.argv) < 3:
        print("Usage: python MapserverImporter.py config_file stratification_type")
        return

    cfg = sys.argv[1]
    Constants.load(cfg)
    config = ConfigurationParser(cfg)
    config.parse()
    stratificationType = sys.argv[2]


    obj = MapserverImporter(config.filesystem.imageryPath)
    obj.process()



if __name__ == "__main__":
    main()
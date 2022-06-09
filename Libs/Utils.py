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

import numpy as np, os, socket
from osgeo import gdal

netCDFSubDataset = lambda  fl, var: """NETCDF:"{0}":{1}""".format(fl, var)

def chunkIt(seq, num):
    avg = len(seq) / float(num)
    out = []
    last = 0.0

    while last < len(seq):
        out.append(seq[int(last):int(last + avg)])
        last += avg

    return out

def getImageExtent(inImage):
    inData = gdal.Open(inImage)
    gt = inData.GetGeoTransform()
    bounds = [
        gt[0],
        gt[3] + gt[4] * inData.RasterXSize + gt[5] * inData.RasterYSize,
        gt[0] + gt[1] * inData.RasterXSize + gt[2] * inData.RasterYSize,
        gt[3]
    ]
    inData = None
    return bounds

def getListOfFiles(dirName):
    # create a list of file and sub directories
    # names in the given directory
    listOfFile = os.listdir(dirName)
    allFiles = list()
    # Iterate over all the entries
    for entry in listOfFile:
        # Create full path
        fullPath = os.path.join(dirName, entry)
        # If entry is a directory then get the list of files in this directory
        if os.path.isdir(fullPath):
            allFiles = allFiles + getListOfFiles(fullPath)
        else:
            allFiles.append(fullPath)

    return allFiles

def pixelsToAreaM2Degrees(pxCount, pixelSize):
    return pxCount*np.power((pixelSize*np.pi/180*6371000),2)

def pixelsToAreaM2Meters(pxCount, pixelSize):
    return pxCount*pixelSize*pixelSize

def scaleValue(metadataDict, value, variable):
    # applying netCDF scaling
    scale = float(metadataDict["{0}#scale_factor".format(variable)])
    addOffset = 0
    if "{0}#add_offset".format(variable) in metadataDict:
        addOffset = float(metadataDict["{0}#add_offset".format(variable)])
    return scale*value + addOffset

def reverseValue(metadataDict, value, variable):
    scale = float(metadataDict["{0}#scale_factor".format(variable)])
    addOffset = float(metadataDict["{0}#add_offset".format(variable)])
    return int((value - addOffset)/scale)

def xyToColRow(X, Y, gt):
    row = int((Y - gt[3] - gt[4] / gt[1] * X + gt[0] * gt[4] / gt[1]) / (gt[5] - (gt[2] * gt[4] / gt[1])))
    col = int((X - gt[0] - gt[2] * row) / gt[1])
    return [col, row]

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

from osgeo import gdal,ogr,osr

class AlignToImage:
    def __init__(self, dataset,  grid):
        self.__dataset = dataset
        self.__grid = grid

    def __del__(self):
        self.__dataset = None
        self.__grid = None

    def __computeCornerCenters(self, mt):
        #lower right corner is the upper left of the 'next' (non-existing) pixel
        upperLeft = (*self.__rowColToXY(0, 0, mt["gt"]), 0)
        lowerRight = (*self.__rowColToXY(mt["dims"]["x"], mt["dims"]["y"], mt["gt"]), 0)
        lowerLeft = (*self.__rowColToXY(0, mt["dims"]["y"], mt["gt"]), 0)
        UpperRight = (*self.__rowColToXY(mt["dims"]["x"], 0, mt["gt"]), 0)

        return (upperLeft, lowerRight, lowerLeft, UpperRight)

    def __computeAlignedGrid(self, imageryMetaData, gridMetaData):
        #transform upper left lower right imagery corner to grid crs
        datasetToGridTransform = osr.CoordinateTransformation(imageryMetaData["crs"], gridMetaData["crs"])
        dstImageryUpperLeft, dstImageryLowerRight, dstImageryLowerLeft, dstImageryUpperRight = \
            self.__computeCornerCenters(imageryMetaData)
        if (not imageryMetaData["crs"].IsSame(gridMetaData["crs"])):
            dstImageryUpperLeft = datasetToGridTransform.TransformPoint(*dstImageryUpperLeft)
            dstImageryLowerRight = datasetToGridTransform.TransformPoint(*dstImageryLowerRight)
            dstImageryUpperRight = datasetToGridTransform.TransformPoint(*dstImageryUpperRight)
            dstImageryLowerLeft  = datasetToGridTransform.TransformPoint(*dstImageryLowerLeft)

        finalUpperLeft = [
            max(dstImageryUpperLeft[0], dstImageryLowerLeft[0]),
            min(dstImageryUpperLeft[1], dstImageryUpperRight[1])
        ]

        finalLowerRight = [
            min(dstImageryLowerRight[0], dstImageryUpperRight[0]),
            max(dstImageryLowerLeft[1], dstImageryLowerRight[1])
        ]

        #compute nearest grid pixel coordinate (image reference system) for both corners
        gridCRSUpperLeft = self.__xyToRowCol(*finalUpperLeft[0:2], gridMetaData["gt"])
        #clipping to get image within grid bounds
        if gridCRSUpperLeft[0] < 0:
            gridCRSUpperLeft[0] = 0

        if gridCRSUpperLeft[1] < 0:
            gridCRSUpperLeft[1] = 0


        gridCRSLowerRight = self.__xyToRowCol(*finalLowerRight[0:2], gridMetaData["gt"])
        if gridCRSLowerRight[0] > gridMetaData["dims"]["x"]:
            gridCRSLowerRight[0] = gridMetaData["dims"]["x"]-1

        if gridCRSLowerRight[1] > gridMetaData["dims"]["y"]:
            gridCRSLowerRight[1] = gridMetaData["dims"]["y"]-1
        alignedUpperLeft = self.__rowColToXY(*gridCRSUpperLeft, gridMetaData["gt"])
        alignedLowerRight = self.__rowColToXY(*gridCRSLowerRight, gridMetaData["gt"])

        return (alignedUpperLeft, alignedLowerRight)

    def __readImageryMetadata(self, imagery):
        data = gdal.Open(imagery)
        sr = osr.SpatialReference()
        sr.ImportFromWkt(data.GetProjection())
        sr.SetAxisMappingStrategy(osr.OAMS_TRADITIONAL_GIS_ORDER)
        ret = {"crs":sr, "gt":data.GetGeoTransform(), "dims":{"x":data.RasterXSize, "y":data.RasterYSize}}
        data = None
        return ret

    def __readVectorMetadata(self, vector):
        sr = None
        xSize = None
        ySize = None
        pixelSize = 0.01
        gt = None
        if isinstance(vector, ogr.Feature):
            geom = vector.geometry()
            envelope = geom.GetEnvelope()
            sr = geom.GetSpatialReference()
            gt = (envelope[0],pixelSize,0,
                envelope[3],0,-pixelSize)
            xSize = round( (envelope[1]-envelope[0])/pixelSize)
            ySize = round((envelope[3] - envelope[2]) / pixelSize)

        sr.SetAxisMappingStrategy(osr.OAMS_TRADITIONAL_GIS_ORDER)
        return {"crs": sr, "gt": gt, "dims": {"x": xSize, "y": ySize}}

    def __rowColToXY(self, col, row, gt):
        x = gt[0] + gt[1]*col + gt[2]*row
        y = gt[3] + gt[4]*col + gt[5]*row
        return [x,y]

    def __xyToRowCol(self, X, Y, gt):
        y = round((Y - gt[3] - gt[4] / gt[1] * X + gt[0] * gt[4] / gt[1]) / (gt[5] - (gt[2] * gt[4] / gt[1])))
        x = round((X - gt[0] - gt[2] * y) / gt[1])
        return [x, y]

    def process(self,vector=False):
        datasetMetaData = None
        if not vector:
            datasetMetaData = self.__readImageryMetadata(self.__dataset)
        else:
            datasetMetaData = self.__readVectorMetadata(self.__dataset)

        gridMetaData = self.__readImageryMetadata(self.__grid)
        return self.__computeAlignedGrid(datasetMetaData, gridMetaData)

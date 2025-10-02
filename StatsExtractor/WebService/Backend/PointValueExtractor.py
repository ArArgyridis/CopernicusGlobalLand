"""
   Copyright (C) 2022  Argyros Argyridis arargyridis at gmail dot com
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

import sys, re, os, numpy as np, pandas as pd
sys.path.extend(['../../../'])

from osgeo import gdal, osr
from Libs.Utils import xyToColRow, scaleValue
gdal.DontUseExceptions()



class PointValueExtractor():
    def __init__(self, data, xCoord, yCoord, epsg="EPSG:4326"):
        self._data = data
        self._xCoord = xCoord
        self._yCoord = yCoord
        self._pointEPSG = epsg

    def __createDate(self, product):
        fileName  = os.path.split(product)[1]
        if self._productPattern.match(fileName):
            dt = self._productPattern.findall(fileName)[0]
            return self._createDate.format(*dt)
        return None

    def __getNETCDFSubdataset(self, img):
        return """NETCDF:"{0}":{1}""".format(img, self._data[0][1])

    def process(self):
        ret = [None]*len(self._data)
        i = 0
        issueImg = None
        try:
            transformed = False
            for dataRow in self._data:
                img = dataRow[2]
                if not os.path.isfile(img):
                    issueImg  = img
                    raise FileExistsError
                
                inData = None
                if img.endswith(".nc"):
                    inData = gdal.Open(self.__getNETCDFSubdataset(img))
                else:
                    inData = gdal.Open(img)
                
                if inData is None:
                    continue

                #checking if coordinates are in the same epsg with the dataset
                if not transformed:
                    prj = inData.GetProjection()
                    sr = osr.SpatialReference()
                    sr.ImportFromWkt(prj)
                    sr.SetAxisMappingStrategy(osr.OAMS_TRADITIONAL_GIS_ORDER)
                    epsg = "EPSG:{0}".format(sr.GetAttrValue("AUTHORITY",1))
                    if self._pointEPSG != epsg:
                        srSource = osr.SpatialReference()
                        srSource.ImportFromEPSG(int(self._pointEPSG.split(":")[1]))
                        srSource.SetAxisMappingStrategy(osr.OAMS_TRADITIONAL_GIS_ORDER)
                        transform = osr.CoordinateTransformation(srSource, sr)
                        self._xCoord, self._yCoord, z  = transform.TransformPoint(self._xCoord, self._yCoord)
                    transformed = True

                gt = inData.GetGeoTransform()
                col,row = xyToColRow(self._xCoord, self._yCoord, gt)
                value = inData.GetRasterBand(1).ReadAsArray(col, row, 1, 1)[0,0].astype(float)
                
                ret[i] =[dataRow[3],inData.GetRasterBand(1).GetScale()*value + inData.GetRasterBand(1).GetOffset()]
                if value == inData.GetRasterBand(1).GetNoDataValue():
                    ret[i][1] = None

                i += 1
        except FileExistsError:
            print("The specified file does not exist: ", issueImg )
            ret = None
        except IOError:
            print("The specified variable does not exist")
            ret = None
        except:
           print("Unable to extract statistics. Exiting")
           print("Params:", dataRow)
           ret = None

        return ret

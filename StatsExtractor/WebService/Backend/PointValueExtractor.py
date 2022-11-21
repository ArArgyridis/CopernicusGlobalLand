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
sys.path.extend(['../../']) #to properly import modules from other dirs

from osgeo import gdal, osr
from Libs.Utils import xyToColRow, scaleValue, getListOfFiles



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
        return """NETCDF:"{0}":{1}""".format(img, self._data[0])

    def _movingAverage(self, ret,windowSize = 3):
        if ret is None or ret["raw"] is None:
            return

        rawData = [s[1] for s in ret["raw"]]
        averages =pd.Series(rawData).rolling(window=windowSize, min_periods=1).mean()
        #difs = rawData[windowSize - 1::] - ll
        difs = list(range(len(rawData)))
        for k, l, i in zip(rawData, averages, range(len(rawData))):
            if k is None:
                difs[i] = np.nan
            else:
                difs[i] = k-l

        mn = np.nanmean(difs)
        std = np.nanstd(difs)
        difs = np.round(difs, 3)
        ret["filtered"] = list(range(len(averages)))
        ret["filtered"] = [ [x[0], None] if np.isnan(y) else [x[0],y] for x,y in zip(ret["raw"], averages)  ]
        for rawVal, dif in zip(ret["raw"], difs):
            rawVal.append(int(dif < mn-3*std)*(-3)
            + int(dif >= mn - 3*std and dif <mn - 2*std)*(-2)
            + int(dif >= mn - 2*std and dif <mn - 1*std)*(-1)
            + int(dif >= mn - 1*std and dif <mn + 1*std)*(0)
            + int(dif >= mn + 1*std and dif <mn + 2*std)*(1)
            + int(dif >= mn + 2*std and dif <mn + 3*std)*(2)
            + int(dif >= mn + 3 * std)*(3))

    def process(self):
        ret = {}
        ret["raw"] = list(range(len(self._data[1])))
        ret["filtered"] = {}
        i = 0
        issueImg = None
        try:
            transformed = False
            for img in self._data[1]:
                if not os.path.isfile(img):
                    issueImg  = img
                    raise FileExistsError
            
                inData = None
                if self._data[0] is None: #that should be an anomaly....
                    inData = gdal.Open(img)
                else:
                    inData = gdal.Open(self.__getNETCDFSubdataset(img))
                
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
                ret["raw"][i] = [self._data[1][img], value]
                if value == inData.GetRasterBand(1).GetNoDataValue():
                    ret["raw"][i][1] = None
                #applying netCDF scaling for raw data
                elif self._data[0] is not None:
                    ret["raw"][i][1] =  np.round(scaleValue(inData.GetMetadata(), ret["raw"][i][1], self._data[0]), 4)
                i += 1
        except FileExistsError:
            print("The specified file does not exist: ", issueImg )
            ret = None
        except IOError:
            print("The specified variable does not exist")
            ret = None
        except:
            print("Unable to extract statistics. Exiting")
            ret = None

        #self._movingAverage(ret)
        return ret

def main():
    data = ('NDVI', ['/home/madagu/Projects/JRCStatsExtractor/ExperimentalData/Imagery/BioPar_NDVI300_V2_Global/2020/20201101/c_gls_NDVI300_202011010000_GLOBE_OLCI_V2.0.1/c_gls_NDVI300_202011010000_GLOBE_OLCI_V2.0.1.nc', '/home/madagu/Projects/JRCStatsExtractor/ExperimentalData/Imagery/BioPar_NDVI300_V2_Global/2020/20201111/c_gls_NDVI300_202011110000_GLOBE_OLCI_V2.0.1/c_gls_NDVI300_202011110000_GLOBE_OLCI_V2.0.1.nc', '/home/madagu/Projects/JRCStatsExtractor/ExperimentalData/Imagery/BioPar_NDVI300_V2_Global/2021/20210411/c_gls_NDVI300_202104110000_GLOBE_OLCI_V2.0.1/c_gls_NDVI300_202104110000_GLOBE_OLCI_V2.0.1.nc', '/home/madagu/Projects/JRCStatsExtractor/ExperimentalData/Imagery/BioPar_NDVI300_V2_Global/2021/20210421/c_gls_NDVI300_202104210000_GLOBE_OLCI_V2.0.1/c_gls_NDVI300_202104210000_GLOBE_OLCI_V2.0.1.nc', '/home/madagu/Projects/JRCStatsExtractor/ExperimentalData/Imagery/BioPar_NDVI300_V2_Global/2021/20210621/c_gls_NDVI300_202106210000_GLOBE_OLCI_V2.0.1/c_gls_NDVI300_202106210000_GLOBE_OLCI_V2.0.1.nc', '/home/madagu/Projects/JRCStatsExtractor/ExperimentalData/Imagery/BioPar_NDVI300_V2_Global/2021/20210701/c_gls_NDVI300_202107010000_GLOBE_OLCI_V2.0.1/c_gls_NDVI300_202107010000_GLOBE_OLCI_V2.0.1.nc'], {'/home/madagu/Projects/JRCStatsExtractor/ExperimentalData/Imagery/BioPar_NDVI300_V2_Global/2020/20201101/c_gls_NDVI300_202011010000_GLOBE_OLCI_V2.0.1/c_gls_NDVI300_202011010000_GLOBE_OLCI_V2.0.1.nc': '2020-11-01T00:00:00', '/home/madagu/Projects/JRCStatsExtractor/ExperimentalData/Imagery/BioPar_NDVI300_V2_Global/2020/20201111/c_gls_NDVI300_202011110000_GLOBE_OLCI_V2.0.1/c_gls_NDVI300_202011110000_GLOBE_OLCI_V2.0.1.nc': '2020-11-11T00:00:00', '/home/madagu/Projects/JRCStatsExtractor/ExperimentalData/Imagery/BioPar_NDVI300_V2_Global/2021/20210411/c_gls_NDVI300_202104110000_GLOBE_OLCI_V2.0.1/c_gls_NDVI300_202104110000_GLOBE_OLCI_V2.0.1.nc': '2021-04-11T00:00:00', '/home/madagu/Projects/JRCStatsExtractor/ExperimentalData/Imagery/BioPar_NDVI300_V2_Global/2021/20210421/c_gls_NDVI300_202104210000_GLOBE_OLCI_V2.0.1/c_gls_NDVI300_202104210000_GLOBE_OLCI_V2.0.1.nc': '2021-04-21T00:00:00', '/home/madagu/Projects/JRCStatsExtractor/ExperimentalData/Imagery/BioPar_NDVI300_V2_Global/2021/20210621/c_gls_NDVI300_202106210000_GLOBE_OLCI_V2.0.1/c_gls_NDVI300_202106210000_GLOBE_OLCI_V2.0.1.nc': '2021-06-21T00:00:00', '/home/madagu/Projects/JRCStatsExtractor/ExperimentalData/Imagery/BioPar_NDVI300_V2_Global/2021/20210701/c_gls_NDVI300_202107010000_GLOBE_OLCI_V2.0.1/c_gls_NDVI300_202107010000_GLOBE_OLCI_V2.0.1.nc': '2021-07-01T00:00:00'}, 'c_gls_NDVI300_(\\d{4})(\\d{2})(\\d{2})(\\d{2})(\\d{2})_GLOBE_OLCI_V2.0.1.nc', '(int, int, int, int, int,)', '{0}-{1}-{2}T{3}:{4}:00')

    xCoord = 3002465.761143498
    yCoord = 990286.9527982064
    epsg = "EPSG:3857"

    obj = PointValueExtractor(data, xCoord, yCoord, epsg)
    val = obj.process()


    print(val)




if __name__ == "__main__":
    main()

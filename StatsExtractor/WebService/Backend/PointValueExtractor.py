import sys, re, os, numpy as np, pandas as pd
sys.path.extend(['../../'])
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
        try:
            transformed = False
            for img in self._data[2]:
                if not os.path.isfile(img):
                    raise FileExistsError

                inData = gdal.Open(self.__getNETCDFSubdataset(img))
                if inData is None:
                    raise IOError

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
                value = inData.GetRasterBand(1).ReadAsArray(col, row, 1, 1)[0,0]
                ret["raw"][i] = [self._data[2][img], value]
                if value == inData.GetRasterBand(1).GetNoDataValue():
                    ret["raw"][i][1] = None
                #applying netCDF scaling
                else:
                    ret["raw"][i][1] =  np.round(scaleValue(inData.GetMetadata(), ret["raw"][i][1], self._data[0]), 4)
                i += 1

        except FileExistsError:
            print("The specified file does not exist")
            ret = None
        except IOError:
            print("The specified variable does not exist")
            ret = None
        except:
            print("Unable to extract statistics. Exiting")
            ret = None

        ret = {'raw': [['2020-07-01T00:00:00', 0.684], ['2020-07-11T00:00:00', 0.668], ['2020-07-21T00:00:00', 0.66], ['2020-08-01T00:00:00', 0.644], ['2020-08-11T00:00:00', 0.668], ['2020-08-21T00:00:00', 0.668], ['2020-09-01T00:00:00', 0.672], ['2020-09-11T00:00:00', 0.652], ['2020-09-21T00:00:00', 0.676], ['2020-10-01T00:00:00', 0.684], ['2020-10-11T00:00:00', 0.824], ['2020-10-21T00:00:00', 0.828], ['2020-11-01T00:00:00', 0.812], ['2020-11-11T00:00:00', None], ['2020-11-21T00:00:00', 0.844], ['2020-12-01T00:00:00', None], ['2020-12-11T00:00:00', None], ['2020-12-21T00:00:00', None], ['2021-01-01T00:00:00', None], ['2021-01-11T00:00:00', 0.704], ['2021-01-21T00:00:00', None], ['2021-02-01T00:00:00', None], ['2021-02-11T00:00:00', 0.448], ['2021-02-21T00:00:00', 0.864], ['2021-03-01T00:00:00', 0.616], ['2021-03-11T00:00:00', 0.648], ['2021-03-21T00:00:00', 0.632], ['2021-04-01T00:00:00', 0.504], ['2021-04-11T00:00:00', 0.592], ['2021-04-21T00:00:00', 0.632], ['2021-05-01T00:00:00', 0.588], ['2021-05-11T00:00:00', 0.572], ['2021-05-21T00:00:00', 0.536], ['2021-06-01T00:00:00', 0.652], ['2021-06-11T00:00:00', 0.604], ['2021-06-21T00:00:00', 0.668], ['2021-07-01T00:00:00', 0.696], ['2021-07-11T00:00:00', 0.552], ['2021-07-21T00:00:00', 0.544], ['2021-08-01T00:00:00', 0.636], ['2021-08-11T00:00:00', 0.548], ['2021-08-21T00:00:00', 0.648], ['2021-09-01T00:00:00', 0.664], ['2021-09-11T00:00:00', 0.424], ['2021-09-21T00:00:00', 0.76], ['2021-10-01T00:00:00', 0.708], ['2021-10-11T00:00:00', 0.64], ['2021-10-21T00:00:00', 0.892], ['2021-11-01T00:00:00', 0.868], ['2021-11-11T00:00:00', None], ['2021-11-21T00:00:00', None], ['2021-12-01T00:00:00', None], ['2021-12-11T00:00:00', None], ['2021-12-21T00:00:00', None], ['2022-01-01T00:00:00', None], ['2022-01-11T00:00:00', 0.648], ['2022-01-21T00:00:00', 0.832], ['2022-02-01T00:00:00', None], ['2022-02-11T00:00:00', 0.916]], 'filtered': {}}
        self._movingAverage(ret)
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

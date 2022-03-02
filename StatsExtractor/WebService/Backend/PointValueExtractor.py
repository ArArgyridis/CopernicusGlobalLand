import sys, re, os, numpy as np
sys.path.extend(['../../'])
from osgeo import gdal, osr
from Libs.Utils import xyToColRow, scaleValue, getListOfFiles



class PointValueExtractor():
    def __init__(self, inImages, inVariable, pattern, createDate, xCoord, yCoord, epsg="EPSG:4326"):
        self._images = inImages
        self._variable = inVariable
        self._productPattern = re.compile(pattern)
        self._createDate = createDate
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
        return """NETCDF:"{0}":{1}""".format(img, self._variable)

    def _movingAverage(self, ret,windowSize = 4):
        if ret is None or ret["raw"] is None:
            return

        window = np.ones(int(windowSize)) / float(windowSize)

        rawData = [s[1] for s in ret["raw"]]
        ll = np.convolve(rawData, window, mode='valid')
        difs = rawData[windowSize - 1::] - ll
        mn = difs.mean()
        std = difs.std()
        ret["filtered"] = [ [x[0],y] for x,y in zip(ret["raw"][windowSize - 1::],ll)]
        for rawVal, dif in zip(ret["raw"][windowSize - 1::], difs):
            rawVal.append(int(dif < mn-3*std)*(-3)
            + int(dif >= mn - 3*std and dif <mn - 2*std)*(-2)
            + int(dif >= mn - 2*std and dif <mn - 1*std)*(-1)
            + int(dif >= mn - 1*std and dif <mn + 1*std)*(0)
            + int(dif >= mn + 1*std and dif <mn + 2*std)*(1)
            + int(dif >= mn + 2*std and dif <mn + 3*std)*(2)
            + int(dif >= mn + 3 * std)*(3))
            print("OK")





    def process(self):
        ret = {}
        ret["raw"] = list(range(len(self._images)))
        ret["filtered"] = {}
        i = 0
        try:
            transformed = False
            for img in self._images:
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
                ret["raw"][i] = [self.__createDate(img), value]
                if value == inData.GetRasterBand(1).GetNoDataValue():
                    ret["raw"][i][1] = None
                #applying netCDF scaling
                else:
                    ret["raw"][i][1] =  np.round(scaleValue(inData.GetMetadata(), ret["raw"][i][1], self._variable), 4)
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


        self._movingAverage(ret)
        return ret

def main():
    inputImageDir = "/home/madagu/Projects/JRCStatsExtractor/ExperimentalData/Imagery/BioPar_NDVI300_V2_Global/"
    inImages = getListOfFiles(inputImageDir)
    inImages = [img for img in inImages if img.endswith(".nc")]
    variable = "NDVI"
    pattern = "c_gls_NDVI300_(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})_GLOBE_OLCI_V2.0.1.nc"
    createDate = "{0}-{1}-{2}T{3}:{4}:00"
    xCoord = 3002465.761143498
    yCoord = 990286.9527982064
    epsg = "EPSG:3857"

    obj = PointValueExtractor(inImages, variable, pattern, createDate, xCoord, yCoord, epsg)
    val = obj.process()


    print(val)




if __name__ == "__main__":
    main()

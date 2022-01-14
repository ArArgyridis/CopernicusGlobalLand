import sys
sys.path.extend(['../../'])
from osgeo import gdal, osr
import os, numpy as np
from Libs.Utils import xyToColRow, scaleValue, getListOfFiles



class PointValueExtractor():
    def __init__(self, inImages, inVariable, xCoord, yCoord, epsg="EPSG:4326"):
        self._images = inImages
        self._variable = inVariable
        self._xCoord = xCoord
        self._yCoord = yCoord
        self._pointEPSG = epsg

    #def __extractValue(self, subDataset):
    def __getNETCDFSubdataset(self, img):
        return """NETCDF:"{0}":{1}""".format(img, self._variable)

    def process(self):
        ret = list(range(len(self._images)))
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
                ret[i] = [img, value]
                if value == inData.GetRasterBand(1).GetNoDataValue():
                    ret[i][1] = None
                #applying netCDF scaling
                else:
                    ret[i][1] =  np.round(scaleValue(inData.GetMetadata(), ret[i][1], self._variable), 4)
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
        return ret

def main():
    inputImageDir = "/home/madagu/Projects/JRCStatsExtractor/ExperimentalData/Imagery/BioPar_NDVI300_V2_Global/"
    inImages = getListOfFiles(inputImageDir)
    inImages = [img for img in inImages if img.endswith(".nc")]
    variable = "NDVI"
    xCoord = 3002465.761143498
    yCoord = 990286.9527982064
    epsg = "EPSG:3857"
    obj = PointValueExtractor(inImages, variable, xCoord, yCoord, epsg)
    val = obj.process()
    print(val)




if __name__ == "__main__":
    main()

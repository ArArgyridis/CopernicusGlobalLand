import os,sys, numpy as np, pandas as pd
sys.path.extend(['../'])
from osgeo import gdal
from datetime import datetime, timedelta
from dateutil.relativedelta import relativedelta
from Libs.ConfigurationParser import ConfigurationParser
from Libs.Utils import xyToColRow, netCDFSubDataset, scaleValue
from Libs.Constants import Constants
from multiprocessing import Process, cpu_count
from shutil import rmtree
gdal.DontUseExceptions()


def computeAnomaly(outImg, products, ltsmedian, ltsStd, startRow, endRow, noDataValue, variableName="NDVI"):
    #loading data
    outImgSrc = gdal.Open(outImg, gdal.GA_Update)
    outImgBnd = outImgSrc.GetRasterBand(1)

    inProductsSrc = [0]*len(products)
    inProductsBnd = [0]*len(products)
    inProductsMeta = [0]*len(products)
    for i in range(len(products)):
        inProductsSrc[i] = gdal.Open(products[i])
        inProductsBnd[i] = inProductsSrc[i].GetRasterBand(1)
        inProductsMeta[i] = inProductsSrc[i].GetMetadata()

    #loading lts median & std
    inLtsmedianSrc = gdal.Open(ltsmedian)
    inLtsmedianBnd = inLtsmedianSrc.GetRasterBand(1)

    inLtsStdSrc = gdal.Open(ltsStd)
    inLtsStdBnd = inLtsStdSrc.GetRasterBand(1)

    cols = inLtsmedianSrc.RasterXSize
    #iterating over output rows
    for row in range(startRow, endRow):
        #scaling data
        inProductBuffer = [0]*len(products)
        scaledNoDataValue = None
        for i in range(len(products)):
            inProductBuffer[i] = scaleValue(inProductsMeta[i],
                                            inProductsBnd[i].ReadAsArray(0, row, cols, 1)[0],variableName)
            scaledNoDataValue = scaleValue(inProductsMeta[i], noDataValue, variableName)

        if len(products) > 0:
            inProductBuffer = np.stack(inProductBuffer).mean(axis=0)
        else:
            inProductBuffer = inProductBuffer[0]

        ltsmedianBuffer = inLtsmedianBnd.ReadAsArray(0, row, cols, 1)[0]
        ltsStdBuffer = inLtsStdBnd.ReadAsArray(0, row, cols, 1)[0]
        idx = ltsmedianBuffer!=noDataValue
        idx = np.logical_and(idx, ltsStdBuffer != noDataValue)
        idx = np.logical_and(idx, inProductBuffer != scaledNoDataValue)

        outBuffer = np.zeros(inProductBuffer.shape).astype(float)
        outBuffer.fill(noDataValue)
        #compute deviation from long-term median in [0,6]
        outBuffer[idx] = (inProductBuffer[idx] < ltsmedianBuffer[idx] - 3 * ltsStdBuffer[idx]).astype(int) * (0)\
                         + np.logical_and(inProductBuffer[idx] >= ltsmedianBuffer[idx] - 3 * ltsStdBuffer[idx],
                          inProductBuffer[idx] < ltsmedianBuffer[idx] - 2 * ltsStdBuffer[idx]).astype(int) * (1)\
                         + np.logical_and(inProductBuffer[idx] >= ltsmedianBuffer[idx] - 2 * ltsStdBuffer[idx],
                                          inProductBuffer[idx] < ltsmedianBuffer[idx] - 1 * ltsStdBuffer[idx]) * (2) \
                         + np.logical_and(inProductBuffer[idx] >= ltsmedianBuffer[idx] - 1 * ltsStdBuffer[idx],
                                          inProductBuffer[idx] < ltsmedianBuffer[idx] + 1 * ltsStdBuffer[idx]) * (3) \
                         + np.logical_and(inProductBuffer[idx] >= ltsmedianBuffer[idx] + 1 * ltsStdBuffer[idx],
                                          inProductBuffer[idx] < ltsmedianBuffer[idx] + 2 * ltsStdBuffer[idx]) * (4) \
                         + np.logical_and(inProductBuffer[idx] >= ltsmedianBuffer[idx] + 2 * ltsStdBuffer[idx],
                                          inProductBuffer[idx] < ltsmedianBuffer[idx] + 3 * ltsStdBuffer[idx]) * (5) \
                         + (inProductBuffer[idx] >= ltsmedianBuffer[idx] + 3 * ltsStdBuffer[idx]) * (6) \
                         + np.isnan(inProductBuffer[idx]) * 255
        #writing result
        outImgBnd.WriteArray(outBuffer.reshape(1, cols), 0, row)

    outImgSrc.FlushCache()
    outImgSrc = None

    return

def computemedian(outImg, medianImgs, stdImgs, startRow, endRow, noDataValue):


    imgCnt = len(medianImgs)
    medianImgSrc = gdal.Open(outImg[0], gdal.GA_Update)
    medianImgBnd = medianImgSrc.GetRasterBand(1)
    medianImgSrcs = [0]*len(medianImgs)
    medianImgBnds = [0]*len(medianImgs)
    medianImgMeta = [0]*len(medianImgs)

    stdImgSrc = gdal.Open(outImg[1], gdal.GA_Update)
    stdImgBnd = stdImgSrc.GetRasterBand(1)
    stdImgSrcs = [0] * len(medianImgs)
    stdImgBnds = [0] * len(medianImgs)
    stdImgMeta = [0] * len(medianImgs)

    cols = medianImgSrc.RasterXSize

    for i in range(imgCnt):
        medianImgSrcs[i] = gdal.Open(medianImgs[i])
        medianImgBnds[i] = medianImgSrcs[i].GetRasterBand(1)
        medianImgMeta[i] = medianImgSrcs[i].GetMetadata()

        stdImgSrcs[i] = gdal.Open(stdImgs[i])
        stdImgBnds[i] = stdImgSrcs[i].GetRasterBand(1)
        stdImgMeta[i] = stdImgSrcs[i].GetMetadata()

    for row in range(startRow, endRow):
        medianBuffer = [0]*imgCnt
        stdBuffer = [0]*imgCnt
        for i in range(imgCnt):
            medianBuffer[i] = medianImgBnds[i].ReadAsArray(0, row, cols, 1)[0].astype(float)
            idx = medianBuffer[i] != noDataValue
            medianBuffer[i][idx] = scaleValue(medianImgMeta[i], medianBuffer[i][idx], "median")
            stdBuffer[i] = stdImgBnds[i].ReadAsArray(0, row, cols, 1)[0].astype(float)
            stdBuffer[i][idx] = scaleValue(stdImgMeta[i], stdBuffer[i][idx], "stdev")

        medianBuffer = np.stack(medianBuffer)
        medianImgBnd.WriteArray(medianBuffer.mean(axis=0).reshape(1,cols), 0, row)

        stdBuffer = np.stack(stdBuffer)
        stdImgBnd.WriteArray((np.sqrt(np.power(stdBuffer,2).sum(axis=0)/imgCnt)).reshape(1,cols), 0, row)

    for i in range(imgCnt):
        medianImgSrcs[i] = None
        stdImgSrcs[i] = None




class LongTermComparisonAnomalyDetector:
    def __init__(self, dateStart, dateEnd, cfg, anomalyProductId, anomalyProductVariableId, nThreads =cpu_count() - 1):
        self._dateStart = dateStart
        self._dateEnd = dateEnd
        self._cfg = ConfigurationParser(cfg)
        self._cfg.parse()
        self._anomalyProductId = anomalyProductId
        self._anomalyProductVariableId = anomalyProductVariableId
        #self._anomalyProductName = anomalyProductName
        self._nThreads = nThreads
        self._images = {}
        self._products = {}
        self._sessionTMPFolder = os.path.join(self._cfg.filesystem.tmpPath, "LTCAD")


    def __del__(self):
        if os.path.isdir(self._sessionTMPFolder):
            rmtree(self._sessionTMPFolder)


    def __getDekads(self, dekads=[1,11,21]):
        curDekads = []
        # build required dekads:
        curDt = datetime.strptime(self._dateStart, '%Y-%m-%d')
        while curDt < datetime.strptime(self._dateEnd, '%Y-%m-%d'):
            if curDt.day in dekads:
                dkd = datetime.strftime(curDt, "'%m%d'")
                if dkd not in curDekads:
                    curDekads.append(dkd)
            curDt += timedelta(days=1)
        return curDekads

    def _computeLongTermmedianStd(self, statFiles):
        if os.path.isfile(self._sessionTMPFolder):
            rmtree(self._sessionTMPFolder)
        os.makedirs(self._sessionTMPFolder, exist_ok=True)

        if len(statFiles) > 0 : #compute the average of the LTSmedian/StDev
            print("Starting computing long term median")
            #open a file to get required info
            medianDt = netCDFSubDataset(os.path.join(self._cfg.filesystem.ltsPath, statFiles[0][0]), statFiles[0][1])


            tmpInData = gdal.Open(medianDt)
            drv = gdal.GetDriverByName("GTiff")
            ret = [os.path.join(self._sessionTMPFolder, "ltsmedian.tif"),
                        os.path.join(self._sessionTMPFolder, "ltsstd.tif")]

            for newProd in ret:

                tmpProd = drv.Create(newProd, xsize=tmpInData.RasterXSize, ysize=tmpInData.RasterYSize,
                                    bands=1, eType=gdal.GDT_Float32)
                tmpProd.SetProjection(tmpInData.GetProjection())
                tmpProd.SetGeoTransform(tmpInData.GetGeoTransform())
                noDataValue = tmpInData.GetRasterBand(1).GetNoDataValue()
                tmpProd.GetRasterBand(1).SetNoDataValue(noDataValue)
                rasterYSize = tmpProd.RasterYSize

                tmpProd = None

            step = int(rasterYSize / (self._nThreads))
            threads = []
            medianImages = [netCDFSubDataset(
                os.path.join(self._cfg.filesystem.ltsPath, k[0]), k[1]) for k in statFiles]
            stdImages =[netCDFSubDataset(
                os.path.join(self._cfg.filesystem.ltsPath, k[2]), k[3]) for k in statFiles]

            #computemedian(ret, medianImages, stdImages, 3000, 4000, noDataValue)

            for prevRow in range(0, rasterYSize - step + 1, step):
                curRow = prevRow + step
                if rasterYSize-curRow < step:
                    curRow = rasterYSize
                print(prevRow, curRow)

                threads.append(Process(target=computemedian,args=(ret, medianImages, stdImages, prevRow, curRow,
                                           noDataValue)))
                threads[-1].start()


            for trd in threads:
                trd.join()
        print("Long term median computation finished!")

        return ret

    def process(self):
            curDekads = self.__getDekads()
            #check if product already exists
            query = """
            WITH anom_product AS(
	            SELECT pfanom.rel_file_path, '{0}'::date "date_start", '{1}'::date date_end, ltai.*
	            FROM long_term_anomaly_info ltai 
	            JOIN product_file_variable pfvanom ON ltai.anomaly_product_variable_id  = pfvanom.id
	            JOIN product_file_description pfdanom ON pfvanom.product_file_description_id = pfdanom.id
	            LEFT JOIN product_file pfanom ON pfanom.product_file_description_id = pfdanom.id AND pfanom."date" = '{0}' 
	            WHERE ltai.anomaly_product_variable_id = 4 --here place the id of the variable not description
            ),statsfiles AS(
            	SELECT ARRAY_AGG(array[pfmean.rel_file_path, pfvmean.variable, 
            	pfstdev.rel_file_path, pfvstdev.variable]) statsfiles
	            FROM anom_product ap 
	            JOIN product_file_variable pfvmean ON ap.mean_variable_id = pfvmean.id
	            JOIN product_file_description pfdmean ON pfvmean.product_file_description_id = pfdmean.id
	            JOIN product_file pfmean ON pfmean.product_file_description_id = pfdmean.id
	            
	            JOIN product_file_variable pfvstdev ON ap.stdev_variable_id = pfvstdev.id 
	            JOIN product_file_description pfdstdev ON pfvstdev.product_file_description_id = pfdstdev.id
	            JOIN product_file pfstdev ON pfstdev.product_file_description_id = pfdstdev.id

	            WHERE to_char(pfmean."date", 'mmdd') IN ({3}) and to_char(pfstdev."date", 'mmdd') IN ({3})
            ),prodfiles AS(
	            SELECT ARRAY_AGG(pfcur.rel_file_path) prodfiles, variable
	            FROM anom_product ap 
	            JOIN product_file_variable pfvcur ON ap.raw_product_variable_id = pfvcur.id
	            JOIN product_file_description pfdcur ON pfvcur.product_file_description_id = pfdcur.id 
	            JOIN product_file pfcur ON pfcur.product_file_description_id = pfdcur.id 
	            WHERE pfcur."date"  >= ap.date_start AND pfcur."date" < ap.date_end
	            GROUP BY pfvcur.variable
            )
            SELECT ap.rel_file_path, statsfiles, prodfiles, variable
            FROM anom_product ap
            JOIN statsfiles ON TRUE
            JOIN prodfiles ON TRUE  """.format(self._dateStart,
                                               self._dateEnd, self._anomalyProductVariableId, ",".join(curDekads))
            res = self._cfg.pgConnections[self._cfg.statsInfo.connectionId].fetchQueryResult(query)

            if res == 1 or len(res) == 0 or res[0][0] is not None:
                return
            print("Starting computing anomalies")

            #try:
            ltsmedian, ltsStd = self._computeLongTermmedianStd(res[0][1])

            if ltsmedian is None:
                return 1

            mn = gdal.Open(ltsmedian)

            gt = mn.GetGeoTransform()
            xImageMax = gt[0] + mn.RasterXSize * gt[1] + mn.RasterYSize * gt[2]
            yImageMin = gt[3] + mn.RasterXSize * gt[4] + mn.RasterYSize * gt[5]
            noDataValue = mn.GetRasterBand(1).GetNoDataValue()
            #warp image to match the coordinates
            #build output file
            products = []
            print("warping results")

            variable = res[0][3]
            for row in res[0][2]:
                tmpProd = os.path.join(self._sessionTMPFolder, row)
                tmpProd = os.path.splitext(tmpProd)[0] + ".tif"
                tmpDir = os.path.split(tmpProd)[0]
                os.makedirs(tmpDir, exist_ok=True)
                products.append(tmpProd)
                subDt = netCDFSubDataset(os.path.join(self._cfg.filesystem.imageryPath,row),variable)

                #"multithread": True,
                kwargs = {
                          'format': "GTiff",
                          'outputBounds': [gt[0],yImageMin,xImageMax,gt[3]],
                          "xRes": np.abs(gt[1]),
                          "yRes": np.abs(gt[5])}
                gdal.Warp(tmpProd, subDt, **kwargs)


            #create output dataset
            outImgPath = os.path.join(self._cfg.filesystem.anomalyProductsPath,
                                      *(Constants.PRODUCT_INFO[self._anomalyProductId].productNames[0],
                                        self._dateStart[0:4]))

            outImg = os.path.join(outImgPath,
                                  Constants.PRODUCT_INFO[self._anomalyProductId].fileNameCreationPattern.format(
                                      self._dateStart, self._dateEnd))
            print(outImg)
            #building output paths

            os.makedirs(outImgPath, exist_ok=True)

            drv = gdal.GetDriverByName("GTiff")

            outProduct = drv.Create(outImg, xsize=mn.RasterXSize, ysize=mn.RasterYSize,
                                    bands=1, eType=gdal.GDT_Byte)

            outProduct.SetProjection(mn.GetProjection())
            outProduct.SetGeoTransform(mn.GetGeoTransform())
            outProduct.GetRasterBand(1).SetNoDataValue(noDataValue)
            outProduct = None
            #computeAnomaly(outImg, products, ltsmedian, ltsStd, 7000,8000, noDataValue, row[0])

            prevRow = 0
            step = int(mn.RasterYSize /self._nThreads)
            threads = []
            print("starting threading")
            for prevRow in range(0, mn.RasterYSize - step + 1, step):
                curRow = prevRow + step
                if mn.RasterYSize - curRow < step:
                    curRow = mn.RasterYSize
                print(prevRow, curRow)
                threads.append(Process(target=computeAnomaly,
                                       args=(outImg, products, ltsmedian, ltsStd, prevRow, curRow, noDataValue,
                                             variable)))
                threads[-1].start()
                prevRow = curRow

            for trd in threads:
                trd.join()

            #update db!
            query = """INSERT INTO product_file(product_file_description_id, rel_file_path, date) VALUES ({0},'{1}','{2}') 
                    ON CONFLICT(product_file_description_id, rel_file_path) DO UPDATE set rel_file_path=EXCLUDED.rel_file_path; 
                    """.format(
                self._anomalyProductId,
                os.path.relpath(outImg, self._cfg.filesystem.anomalyProductsPath),
                self._dateStart
            )

            self._cfg.pgConnections[self._cfg.statsInfo.connectionId].executeQueries([query,])

            print("anomalies computation finished!")

            #except:
            #    print("An error has occured. Exiting")

            return 0

def main():
    if len(sys.argv) < 3:
        print("Usage: python LongTermComparisonAnomalyDetector.py config_json_file anomaly_product_id")
        return

    cfg = sys.argv[1]
    anomalyProductId = int(sys.argv[2])
    Constants.load(cfg)
    run(anomalyProductId, cfg)

def run(anomalyProductId, cfg):

    datePtrn = "%Y-%m-%d"

    curTime = datetime.strptime("2020-07-01",datePtrn)
    dateEnd = datetime.now()
    relDelta = relativedelta(days=5)
    while curTime < dateEnd - relDelta:
        dekads = [1,11,21]
        for i in range(len(dekads)):
            d1 = curTime.replace(day=dekads[i]).strftime(datePtrn)
            d2 = None
            if (i+1 == len(dekads)):
                if curTime.month > 11:
                    d2 = curTime.replace(year = curTime.year+1, month=1, day=1)
                else:
                    d2 = curTime.replace(month=curTime.month+1, day=1)
            else:
                d2 = curTime.replace(day=dekads[i+1])

            d2 = d2.strftime(datePtrn)

            for variable in Constants.PRODUCT_INFO[anomalyProductId].variables:
                id = Constants.PRODUCT_INFO[anomalyProductId].variables[variable].id
                obj = LongTermComparisonAnomalyDetector(d1, d2, cfg, anomalyProductId, id)
                obj.process()
        curTime += relDelta



if __name__ == "__main__":
    main()
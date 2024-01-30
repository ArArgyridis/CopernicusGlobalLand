import os,sys, numpy as np, pandas as pd

sys.path.extend(['../'])
from osgeo import gdal
from datetime import datetime, timedelta
from dateutil.relativedelta import relativedelta
from Libs.ConfigurationParser import ConfigurationParser
from Libs.Utils import xyToColRow, netCDFSubDataset, scaleValue
from Libs.Constants import Constants
from multiprocessing import Process, cpu_count
from shutil import copy, rmtree
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

def computemedian(outImg, medianImgs, stdImgs, startRow, endRow, medianVarName, stdVarName, noDataValue):


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
            medianBuffer[i][idx] = scaleValue(medianImgMeta[i], medianBuffer[i][idx], medianVarName)
            stdBuffer[i] = stdImgBnds[i].ReadAsArray(0, row, cols, 1)[0].astype(float)
            stdBuffer[i][idx] = scaleValue(stdImgMeta[i], stdBuffer[i][idx], stdVarName)

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
        self._cfg = cfg
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

    def _computeLongTermMedianStd(self, statFiles):
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
            medianVarName = statFiles[0][1]
            stdVarName = statFiles[0][3]

            for prevRow in range(0, rasterYSize - step + 1, step):
                curRow = prevRow + step
                if rasterYSize-curRow < step:
                    curRow = rasterYSize
                print(prevRow, curRow)

                threads.append(Process(target=computemedian,args=(ret, medianImages, stdImages, prevRow, curRow,
                                           medianVarName, stdVarName, noDataValue)))
                threads[-1].start()


            for trd in threads:
                trd.join()
        print("Long term median computation finished!")

        return ret

    @property
    def process(self):
            curDekads = self.__getDekads()
            #check if product already exists
            query = """
            WITH prodfiles AS(
	            SELECT ARRAY_AGG(DISTINCT pfcur.rel_file_path) prodfiles, 
	            ARRAY_AGG(DISTINCT to_char(pfcur.date, 'mmdd')) daymonths,
                MIN(pfcur.date) reference_date,
	            variable, pfcur.rt_flag,
	            ltai.*
	            FROM product_file_variable pfvcur
	            JOIN product_file_description pfdcur ON pfvcur.product_file_description_id = pfdcur.id 
	            JOIN product_file pfcur ON pfcur.product_file_description_id = pfdcur.id 
	            JOIN long_term_anomaly_info ltai ON pfvcur.id = ltai.raw_product_variable_id
	            WHERE pfcur."date"  >= '{0}'::date AND pfcur."date" < '{1}'::date AND ltai.anomaly_product_variable_id = {2}
	            GROUP BY pfvcur.variable, pfcur.rt_flag,  ltai.id, ltai.anomaly_product_variable_id, ltai.mean_variable_id, ltai.stdev_variable_id, 
	            ltai.raw_product_variable_id
            ),anom_product AS(
	            SELECT pfanom.rel_file_path, prodfiles.*
	            FROM prodfiles
	            JOIN product_file_variable pfvanom ON prodfiles.anomaly_product_variable_id  = pfvanom.id
	            JOIN product_file_description pfdanom ON pfvanom.product_file_description_id = pfdanom.id
	            LEFT JOIN product_file pfanom ON pfanom.product_file_description_id = pfdanom.id AND pfanom."date" = prodfiles.reference_date 
	            AND CASE WHEN prodfiles.rt_flag IS NULL THEN TRUE ELSE prodfiles.rt_flag = pfanom.rt_flag END
            ),statsfiles AS(
            	SELECT ARRAY_AGG(array[pfmean.rel_file_path, pfvmean.variable, pfstdev.rel_file_path, pfvstdev.variable]) statsfiles, pfmean.rt_flag
	            FROM anom_product ap 
	            JOIN product_file_variable pfvmean ON ap.mean_variable_id = pfvmean.id
	            JOIN product_file_description pfdmean ON pfvmean.product_file_description_id = pfdmean.id
	            JOIN product_file pfmean ON pfmean.product_file_description_id = pfdmean.id 
   	            JOIN prodfiles prdfls ON CASE WHEN prdfls.rt_flag IS NULL THEN TRUE ELSE prdfls.rt_flag = pfmean.rt_flag END

	            JOIN product_file_variable pfvstdev ON ap.stdev_variable_id = pfvstdev.id 
	            JOIN product_file_description pfdstdev ON pfvstdev.product_file_description_id = pfdstdev.id
	            JOIN product_file pfstdev ON pfstdev.product_file_description_id = pfdstdev.id AND CASE WHEN pfmean.rt_flag IS NULL THEN TRUE ELSE pfmean.rt_flag = pfstdev.rt_flag END

	            WHERE to_char(pfmean."date", 'mmdd') = ANY(prdfls.daymonths) and to_char(pfstdev."date", 'mmdd') = ANY(prdfls.daymonths)
	            GROUP BY pfmean.rt_flag
            )
            SELECT ap.rel_file_path, statsfiles, ap.prodfiles, ap.variable,  statsfiles.rt_flag, ap.reference_date
            FROM anom_product ap
            JOIN statsfiles ON CASE WHEN statsfiles.rt_flag IS NULL THEN TRUE 
            ELSE statsfiles.rt_flag = ap.rt_flag END """.format(self._dateStart,
                                                                       self._dateEnd, self._anomalyProductVariableId)

            result = self._cfg.pgConnections[self._cfg.statsInfo.connectionId].fetchQueryResult(query)

            if result == 1 or len(result) == 0:
                return
            print("Starting computing anomalies")

            for batch in result:

                if batch[0] is not None:
                    continue

                #try:
                ltsmedian, ltsStd = self._computeLongTermMedianStd(batch[1])

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

                variable = batch[3]
                for row in batch[2]:
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

                tmpImgPath = outImgPath.replace(self._cfg.filesystem.anomalyProductsPath,
                                                self._cfg.filesystem.tmpPath)
                os.makedirs(outImgPath, exist_ok=True)
                os.makedirs(tmpImgPath, exist_ok=True)

                outImg = None
                if batch[4] is None:
                    outImg = os.path.join(outImgPath,
                                      Constants.PRODUCT_INFO[self._anomalyProductId].fileNameCreationPattern.format(
                                          self._dateStart, self._dateEnd))
                else:
                    outImg = os.path.join(outImgPath,
                      Constants.PRODUCT_INFO[self._anomalyProductId].fileNameCreationPattern.format(batch[4],
                          self._dateStart, self._dateEnd))

                tmpImg = outImg.replace(outImgPath, tmpImgPath)

                print(tmpImg)
                #building output paths



                drv = gdal.GetDriverByName("GTiff")

                tmpProduct = drv.Create(tmpImg, xsize=mn.RasterXSize, ysize=mn.RasterYSize,
                                        bands=1, eType=gdal.GDT_Byte)

                tmpProduct.SetProjection(mn.GetProjection())
                tmpProduct.SetGeoTransform(mn.GetGeoTransform())
                tmpProduct.GetRasterBand(1).SetNoDataValue(noDataValue)
                tmpProduct = None
                #computeAnomaly(tmpImg, products, ltsmedian, ltsStd, 7000,8000, noDataValue, row[0])

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
                                           args=(tmpImg, products, ltsmedian, ltsStd, prevRow, curRow, noDataValue,
                                                 variable)))
                    threads[-1].start()
                    prevRow = curRow

                for trd in threads:
                    trd.join()

                #copy to destination
                copy(tmpImg, outImg)

                #deleting tmpImg
                os.remove(tmpImg)

                #update db!
                rtFlag = 'NULL'
                if batch[4] is not None:
                    rtFlag = batch[4]

                #as anomaly date is selected the minimum date of the product files used to compute the anomaly
                query = """INSERT INTO product_file(product_file_description_id, rel_file_path, date, rt_flag) VALUES ({0},'{1}','{2}', {3}) 
                        ON CONFLICT(product_file_description_id, "date", rt_flag) DO UPDATE set rel_file_path=EXCLUDED.rel_file_path; 
                        """.format(
                    self._anomalyProductId,
                    os.path.relpath(outImg, self._cfg.filesystem.anomalyProductsPath),
                    batch[5].isoformat(sep="T",timespec="auto")[0:10], rtFlag)


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

    tmpParser = ConfigurationParser(cfg)
    tmpParser.parse()

    query = """
    SELECT min(date), max(date)
    FROM product_file_description pfd 
    JOIN product_file_variable pfv ON pfd.id = pfv.product_file_description_id 
    JOIN long_term_anomaly_info ltai ON pfv.id = ltai.anomaly_product_variable_id 
    JOIN product_file_variable pfvraw ON ltai.raw_product_variable_id  = pfvraw.id 
    JOIN product_file_description pfdraw ON pfvraw.product_file_description_id  = pfdraw.id 
    JOIN product_file pf ON pfdraw.id = pf.product_file_description_id 
    WHERE pfd.id = {0};""".format(anomalyProductId)

    result = tmpParser.pgConnections[tmpParser.statsInfo.connectionId].fetchQueryResult(query)
    if len(result) == 0:
        print("Anomalies cannot be computed!")
        return 1
    curTime = result[0][0]

    relDelta = relativedelta(days=5)
    while curTime < result[0][1] + relDelta:
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
                obj = LongTermComparisonAnomalyDetector(d1, d2, tmpParser, anomalyProductId, id)
                obj.process
        curTime += relDelta



if __name__ == "__main__":
    main()
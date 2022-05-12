import os,sys, numpy as np, pandas as pd
sys.path.extend(['../StatsExtractor/'])
from osgeo import gdal
from datetime import datetime, timedelta
from dateutil.relativedelta import relativedelta
from Libs.ConfigurationParser import ConfigurationParser
from Libs.Utils import xyToColRow, netCDFSubDataset, scaleValue
from WebService.Backend.PointValueExtractor import PointValueExtractor
from multiprocessing import Process, cpu_count
from shutil import rmtree

def computeAnomaly(outImg, products, ltsMean, ltsStd, startRow, endRow, noDataValue, variableName="NDVI"):
    print("computing anomally!!")
    outImgSrc = gdal.Open(outImg, gdal.GA_Update)
    outImgBnd = outImgSrc.GetRasterBand(1)

    inProductsSrc = [0]*len(products)
    inProductsBnd = [0]*len(products)
    inProductsMeta = [0]*len(products)
    for i in range(len(products)):
        inProductsSrc[i] = gdal.Open(products[i])
        inProductsBnd[i] = inProductsSrc[i].GetRasterBand(1)
        inProductsMeta[i] = inProductsSrc[i].GetMetadata()

    inLtsMeanSrc = gdal.Open(ltsMean)
    inLtsMeanBnd = inLtsMeanSrc.GetRasterBand(1)

    inLtsStdSrc = gdal.Open(ltsStd)
    inLtsStdBnd = inLtsStdSrc.GetRasterBand(1)

    cols = inLtsMeanSrc.RasterXSize
    for row in range(startRow, endRow):
        #read data
        inProductBuffer = [0]*len(products)
        for i in range(len(products)):
            inProductBuffer[i] = scaleValue(inProductsMeta[i],
                                            inProductsBnd[i].ReadAsArray(0, row, cols, 1)[0],#.astype(np.float32),
                                            variableName)

        inProductBuffer = np.stack(inProductBuffer).mean(axis=0)
        ltsMeanBuffer = inLtsMeanBnd.ReadAsArray(0, row, cols, 1)[0]
        ltsStdBuffer = inLtsStdBnd.ReadAsArray(0, row, cols, 1)[0]
        idx = ltsMeanBuffer!=noDataValue
        idx = np.logical_and(idx, ltsStdBuffer != noDataValue)
        idx = np.logical_and(idx, inProductBuffer != noDataValue)

        outBuffer = np.zeros(inProductBuffer.shape).astype(float)
        outBuffer.fill(noDataValue)
        outBuffer[idx] = (inProductBuffer[idx] - ltsMeanBuffer[idx])/ltsStdBuffer[idx]
        #outBuffer[idx] = inProductBuffer[idx]
        outImgBnd.WriteArray(outBuffer.reshape(1, cols), 0, row)

    outImgSrc.FlushCache()
    outImgSrc = None
    return

def computeMean(outImg, imgs, dataPath, startRow, endRow, noDataValue):
    meanImgs = [netCDFSubDataset(os.path.join(dataPath, k), "mean") for k in imgs]
    stdImgs = [netCDFSubDataset(os.path.join(dataPath, k), "stdev") for k in imgs]

    imgCnt = len(meanImgs)
    meanImgSrc = gdal.Open(outImg[0], gdal.GA_Update)
    meanImgBnd = meanImgSrc.GetRasterBand(1)
    meanImgSrcs = [0]*len(meanImgs)
    meanImgBnds = [0]*len(meanImgs)
    meanImgMeta = [0]*len(meanImgs)

    stdImgSrc = gdal.Open(outImg[1], gdal.GA_Update)
    stdImgBnd = stdImgSrc.GetRasterBand(1)
    stdImgSrcs = [0] * len(meanImgs)
    stdImgBnds = [0] * len(meanImgs)
    stdImgMeta = [0] * len(meanImgs)

    cols = meanImgSrc.RasterXSize

    for i in range(imgCnt):
        meanImgSrcs[i] = gdal.Open(meanImgs[i])
        meanImgBnds[i] = meanImgSrcs[i].GetRasterBand(1)
        meanImgMeta[i] = meanImgSrcs[i].GetMetadata()

        stdImgSrcs[i] = gdal.Open(stdImgs[i])
        stdImgBnds[i] = stdImgSrcs[i].GetRasterBand(1)
        stdImgMeta[i] = stdImgSrcs[i].GetMetadata()



    for row in range(startRow, endRow):
        meanBuffer = [0]*imgCnt
        stdBuffer = [0]*imgCnt
        for i in range(imgCnt):
            meanBuffer[i] = meanImgBnds[i].ReadAsArray(0, row, cols, 1)[0].astype(float)
            idx = meanBuffer[i] != noDataValue
            meanBuffer[i][idx] = scaleValue(meanImgMeta[i], meanBuffer[i][idx], "mean")
            stdBuffer[i] = stdImgBnds[i].ReadAsArray(0, row, cols, 1)[0].astype(float)
            stdBuffer[i][idx] = scaleValue(stdImgMeta[i], stdBuffer[i][idx], "stdev")

        meanBuffer = np.stack(meanBuffer)
        meanImgBnd.WriteArray(meanBuffer.mean(axis=0).reshape(1,cols), 0, row)

        stdBuffer = np.stack(stdBuffer)
        stdImgBnd.WriteArray((np.sqrt(np.power(stdBuffer,2).sum(axis=0)/imgCnt)).reshape(1,cols), 0, row)

    for i in range(imgCnt):
        meanImgSrcs[i] = None
        stdImgSrcs[i] = None




class LongTermComparisonAnomalyDetector:
    def __init__(self, productId, dateStart, dateEnd, cfg, nThreads = cpu_count() -1):
        self._productId = productId
        self._dateStart = dateStart
        self._dateEnd = dateEnd
        self._cfg = ConfigurationParser(cfg)
        self._cfg.parse()
        self._nThreads = nThreads
        self._images = {}
        self._products = {}
        self._sessionTMPFolder = os.path.join(self._cfg.filesystem.tmpPath, "LTCAD")

    def __del__(self):
        rmtree(self._sessionTMPFolder)

    def __getDekads(self, dekads=[1,11,21]):
        curDekads = []
        # build required dekads:
        curDt = datetime.strptime(self._dateStart, '%Y-%m-%d')
        while curDt <= datetime.strptime(self._dateEnd, '%Y-%m-%d'):
            if curDt.day in dekads:
                dkd = datetime.strftime(curDt, "'%m%d'")
                if dkd not in curDekads:
                    curDekads.append(dkd)
            curDt += timedelta(days=1)
        return curDekads

    def _computeLongTermMeanStd(self, ):
        print("Starting computing long term mean")
        if os.path.isfile(self._sessionTMPFolder):
            rmtree(self._sessionTMPFolder)
        os.makedirs(self._sessionTMPFolder, exist_ok=True)
        curDekads = self.__getDekads()

        query = """
        SELECT pf.rel_file_path
        FROM product p 
        JOIN product_file_description pfd  ON p.id = pfd.product_id 
        JOIN product_file pf ON pfd.id = pf.product_description_id 
        WHERE p.name = 'BioPar_NDVI_STATS_Global' AND pf.rel_file_path LIKE '%.nc'
        AND  to_char(pf."date", 'mmdd') IN ({0})""".format(",".join(curDekads))
        res = self._cfg.pgConnections[self._cfg.statsInfo.connectionId].fetchQueryResult(query)
        ret = [None,None]
        if res == False:
            ret = [None, None]
        elif len(res) == 1:
            ret = [
                netCDFSubDataset(os.path.join(self._cfg.filesystem.imageryPath, res[0][0]), "mean"),
                netCDFSubDataset(os.path.join(self._cfg.filesystem.imageryPath, res[0][0]), "stdev")
            ]
        else: #compute the average of the LTSMean/StDev
            #open a file to get required info
            tmpInData = gdal.Open(netCDFSubDataset(os.path.join(self._cfg.filesystem.imageryPath, res[0][0]), "mean"))
            drv = gdal.GetDriverByName("GTiff")
            ret = [os.path.join(self._sessionTMPFolder, "ltsmean.tif"),
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

            step = int(rasterYSize / (self._nThreads-1))
            threads = []
            images = [os.path.join(self._cfg.filesystem.imageryPath, k[0]) for k in res]

            #computeMean(ret, images, self._cfg.filesystem.imageryPath, 3000, 4000, noDataValue)
            for prevRow in range(0, rasterYSize - step + 1, step):
                curRow = prevRow + step
                if curRow > rasterYSize:
                    curRow = rasterYSize
                print(prevRow, curRow)

                threads.append(Process(target=computeMean,args=(
                                           ret, images, self._cfg.filesystem.imageryPath, prevRow, curRow, noDataValue)))
                threads[-1].start()


            for trd in threads:
                trd.join()
        print("Long term mean computation finished!")

        return ret

    def process(self):
            print("Starting computing anomalies")

            #try:
            ltsMean, ltsStd = self._computeLongTermMeanStd()

            #retrieve products from DB
            productQuery = """SELECT pfd.variable,  '{0}'||pf.rel_file_path, pf.date, pfd.pattern, pfd.TYPES
                FROM product_file_description pfd 
                JOIN product_file pf ON pfd.id = pf.product_description_id
                WHERE pfd.product_id = 1 AND pf."date" BETWEEN '{1}' AND '{2}'
                AND  pf.rel_file_path LIKE '%.nc';""".\
                format(self._cfg.filesystem.imageryPath, self._dateStart, self._dateEnd)
            print("products retrieved")

            res = self._cfg.pgConnections[self._cfg.statsInfo.connectionId].getIteratableResult(productQuery)
            mn = gdal.Open(ltsMean)

            gt = mn.GetGeoTransform()
            xImageMax = gt[0] + mn.RasterXSize * gt[1] + mn.RasterYSize * gt[2]
            yImageMin = gt[3] + mn.RasterXSize * gt[4] + mn.RasterYSize * gt[5]
            noDataValue = mn.GetRasterBand(1).GetNoDataValue()
            #warp image to match the coordinates
            #build output file
            products = []
            print("warping results")

            variable = None
            for row in res:
                variable = row[0]
                tmpProd = os.path.join(self._sessionTMPFolder, row[1].split(self._cfg.filesystem.imageryPath)[1])
                tmpProd = os.path.splitext(tmpProd)[0] + ".tif"
                tmpDir = os.path.split(tmpProd)[0]
                os.makedirs(tmpDir, exist_ok=True)
                products.append(tmpProd)

                gdal.Warp(tmpProd, netCDFSubDataset(row[1],row[0]), xRes = np.abs(gt[1]), yRes = np.abs(gt[5]),
                         format = "GTiff", outputBounds =[gt[0],yImageMin,xImageMax,gt[3]])


            #create output dataset
            outImgPath = os.path.join(self._cfg.filesystem.anomalyProductsPath, "LongTermComparisonAnomalyDetector")
            outImg = os.path.join(outImgPath,"{0}_{1}.tif".format(self._dateStart, self._dateEnd))
            #building output paths
            os.makedirs(outImgPath, exist_ok=True)

            drv = gdal.GetDriverByName("GTiff")

            outProduct = drv.Create(outImg, xsize=mn.RasterXSize, ysize=mn.RasterYSize,
                                    bands=1, eType=gdal.GDT_Float32)
            #,options=['COMPRESS=Deflate', 'PREDICTOR=3', "BIGTIFF=YES"]

            outProduct.SetProjection(mn.GetProjection())
            outProduct.SetGeoTransform(mn.GetGeoTransform())
            outProduct.GetRasterBand(1).SetNoDataValue(noDataValue)
            outProduct.FlushCache()
            outProduct = None
            #computeAnomaly(outImg, products, ltsMean, ltsStd, 7000,8000, noDataValue, row[0])

            prevRow = 0
            step = int(mn.RasterYSize / (self._nThreads - 1))
            threads = []
            print("starting threading")
            for prevRow in range(0, mn.RasterYSize - step + 1, step):
                curRow = prevRow + step
                if curRow > mn.RasterYSize:
                    curRow = mn.RasterYSize
                print(prevRow, curRow)
                threads.append(Process(target=computeAnomaly,
                                       args=(outImg, products, ltsMean, ltsStd, prevRow, curRow, noDataValue, variable)))
                threads[-1].start()
                prevRow = curRow

            for trd in threads:
                trd.join()


            print("anomalies computation finished!")

            #except:
            #    print("An error has occured. Exiting")

            return 0

def main():
    if len(sys.argv) < 2:
        print("Usage: python LongTermComparisonAnomalyDetector.py config_json_file")
        return

    cfg = sys.argv[1]

    datePtrn = "%Y-%m-%d"
    curTime = datetime.strptime("2020-07-01",datePtrn)
    dateEnd = datetime.now()
    relDelta = relativedelta(months=1)
    while (curTime < dateEnd-relDelta):
        d1 = curTime.strftime(datePtrn)
        d2 = (curTime+relDelta).strftime(datePtrn)
        obj = LongTermComparisonAnomalyDetector(1, d1, d2, cfg)
        obj.process()
        curTime += relDelta


if __name__ == "__main__":
    main()
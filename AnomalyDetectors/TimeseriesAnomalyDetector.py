import os,sys, numpy as np, pandas as pd
sys.path.extend(['../StatsExtractor/'])
from osgeo import gdal
from Libs.ConfigurationParser import ConfigurationParser
from Libs.Utils import xyToColRow
from WebService.Backend.PointValueExtractor import PointValueExtractor
from multiprocessing import Process

def runTimeSeriesMovingAverage(images, products, startRow, endRow, cols):
    # creating proxies
    inDataProxies = {}
    outDataProxies = {}
    noDataValue = None

    keys = list(images.keys())
    keys.sort()
    for key in keys:
        tmp = gdal.Open(images[key])
        inDataProxies[key] = gdal.Open(tmp.GetSubDatasets()[0][0])
        noDataValue = inDataProxies[key].GetRasterBand(1).GetNoDataValue()
        outDataProxies[key] = gdal.Open(products[key], gdal.GA_Update)

    # reading column by column
    for row in range(startRow, endRow):  # range(int(cols/12)):
        dts = [0] * len(keys)
        print("start loading data")
        tmpPos = 0
        for key in keys:
            dts[tmpPos] = inDataProxies[key].ReadAsArray(0, row, cols, 1)[0]
            tmpPos += 1
        dts = np.array(dts)
        print("loading data finished!")
        eval = np.any(dts != noDataValue, axis=0)
        positions = np.argwhere(eval == True).T[0]
        dtsFix = np.where(dts == noDataValue, np.nan, dts)
        averages = pd.DataFrame(dtsFix[:, positions]).rolling(window=3, min_periods=1).mean().to_numpy().astype(
            np.float32)
        difs = dtsFix[:, positions] - averages
        mn = np.nanmean(difs, axis=0)
        std = np.nanstd(difs, axis=0)

        res = (difs < mn - 3 * std).astype(int) * (0) \
              + np.logical_and(difs >= mn - 3 * std, difs < mn - 2 * std).astype(int) * (1) \
              + np.logical_and(difs >= mn - 2 * std, difs < mn - 1 * std) * (2) \
              + np.logical_and(difs >= mn - 1 * std, difs < mn + 1 * std) * (3) \
              + np.logical_and(difs >= mn + 1 * std, difs < mn + 2 * std) * (4) \
              + np.logical_and(difs >= mn + 2 * std, difs < mn + 3 * std) * (5) \
              + (difs >= mn + 3 * std) * (6) \
              + np.isnan(difs) * 255
        dts[:, positions] = res
        print("processing finished!")
        i = 0
        for key in keys:
            outDataProxies[key].GetRasterBand(1).WriteArray(dts[i, :].reshape(1, cols), 0, row)
            i += 1
        print("Finished!!", row)
        # print("ok")
    for key in keys:
        outDataProxies[key] = None

class TimeseriesAnomalyDetector:
    def __init__(self, productId, dateStart, dateEnd, cfg):
        self._productId = productId
        self._dateStart = dateStart
        self._dateEnd = dateEnd
        self._cfg = ConfigurationParser(cfg)
        self._cfg.parse()
        self._images = {}
        self._products = {}

    def _writeOutputs(self, nthreads = 10):
        key = list(self._products.keys())[0]
        outData = gdal.Open(self._products[key],gdal.GA_Update)
        band = outData.GetRasterBand(1)
        cols = band.XSize
        rows = band.YSize
        outData = None
        runTimeSeriesMovingAverage(self._images, self._products, 30000, 31000, cols)

        prevRow = 0
        step = int(rows/nthreads)
        threads = []
        for curRow in range(step, rows+step-1, step):
            print(prevRow, curRow)
            threads.append(Process(target=runTimeSeriesMovingAverage, args=(self._images, self._products, prevRow, curRow, cols )))
            threads[-1].start()
            prevRow = curRow


        for trd in threads:
            trd.join()

        print("End Processing!!")

    def process(self):
        #retrieve unprocessed products
        query = """SELECT pfd.variable, JSON_OBJECT_AGG( pf.date, pf.rel_file_path), pfd.pattern, pfd.TYPES, pfd.create_date
        FROM product_file pf 
        JOIN product_file_description pfd ON pf.product_description_id = pfd.id
        JOIN product p ON pfd.product_id = p.id
        LEFT JOIN output_product op ON pf.id = op.product_file_id 
        WHERE p.name != 'BioPar_NDVI_STATS_Global' AND (pfd.variable is not null) AND p.id = {0}
        GROUP BY pfd.variable, pfd.pattern, pfd.TYPES, pfd.create_date""".format(self._productId)
        res = self._cfg.pgConnections["the_localhost"].fetchQueryResult(query)
        print(res)
        #creating new images for unprocessed products
        exts = ["", ".ovr", ".aux.xml"]
        print("Initializing New Timeseries Anomaly Products")
        for dt in res[0][1]:
            img = os.path.join(self._cfg.filesystem.imageryPath, res[0][1][dt])
            #destination path
            self._images[dt] = img
            outImg = os.path.join(os.path.join(self._cfg.filesystem.anomalyProductsPath, *["TimeSeriesAnomalyDetector",res[0][1][dt]]))
            outImg = os.path.splitext(outImg)[0] + ".tif"
            outDir = os.path.split(outImg)[0]
            if not os.path.isdir(outDir):
                os.makedirs(outDir,exist_ok=True)

            #getting metadata info
            inData = gdal.Open(img)
            inSubDataset = gdal.Open(inData.GetSubDatasets()[0][0])
            #checking if file exists
            for ext in exts:
                if os.path.isfile(outImg+ext):
                    os.remove(outImg+ext)

            self._products[dt] = outImg

            drv = gdal.GetDriverByName("GTiff")
            outProduct = drv.Create(outImg, xsize=inSubDataset.RasterXSize, ysize=inSubDataset.RasterYSize,
                    bands=1, eType=gdal.GDT_Byte, options=['COMPRESS=LZW', 'PREDICTOR=2', "BIGTIFF=YES"])
            outProduct.SetProjection(inSubDataset.GetProjection())
            outProduct.SetGeoTransform(inSubDataset.GetGeoTransform())
            outProduct.GetRasterBand(1).SetNoDataValue(255)
            outProduct = None
            

        print("Initialization Finished!")
        self._writeOutputs()



if __name__ == "__main__":
    cfg = "../StatsExtractor/active_config_argyros_desktop.json"
    obj = TimeseriesAnomalyDetector(1, "2019-01-01", "2022-03-11", cfg)
    obj.process()
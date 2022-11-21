import numpy as np, os, pandas as pd, sys
from osgeo import gdal
from statsmodels.tsa.filters import bk_filter
from statsmodels.tsa.seasonal import seasonal_decompose
import matplotlib.pyplot as plt
from datetime import datetime


from Libs.Constants import Constants
from Libs.ConfigurationParser import ConfigurationParser
from Libs.Utils import *


def parser(s):
    return datetime.fromisoformat(s)

config = sys.argv[1]
# loading constants
Constants.load(config)

cfg = ConfigurationParser(config)
cfg.parse()

productId = 1
query = """
select pf."date", pf.rel_file_path 
from product_file pf 
where pf.product_description_id = {0}
order by rel_file_path 
""".format(productId)
res = cfg.pgConnections["the_localhost"].fetchQueryResult(query)

outFile = "out.csv"
fl = open(outFile, "w")
row = int(13829)
col = int(68304)
i = 0
for rw in res:
    imgPath = os.path.join(cfg.filesystem.imageryPath, rw[1])
    imgSubDataPath = netCDFSubDataset(imgPath, Constants.PRODUCT_INFO[productId].variable)

    inData = gdal.Open(imgSubDataPath)
    bnd = inData.GetRasterBand(1)
    val = bnd.ReadAsArray(col, row, 1, 1)[0,0]
    val = scaleValue(inData.GetMetadata(), val, Constants.PRODUCT_INFO[productId].variable)
    fl.write("{0},{1}\n".format(i, val))
    i += 1
fl.close()

#baxter-king filter
"""
dt = bk_filter.bkfilter(outData["val"], 1.5, 3,3)

df.to_csv("raw.csv")
dt.to_csv("filtered.csv")
"""
outData = pd.read_csv(outFile, index_col=0)
outData = outData.dropna()
plt.rc('figure',figsize=(12,8))
plt.rc('font',size=15)
result = seasonal_decompose(outData,model='additive')
fig = result.plot()






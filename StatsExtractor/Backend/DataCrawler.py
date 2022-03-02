import os,paramiko,sys
sys.path.extend(['..']) #to properly import modules from other dirs
from Libs.ConfigurationParser import ConfigurationParser

class DataCrawler:
    def __init__(self, cnObj):
        self._sftpCn = paramiko.Transport((cnObj.host, cnObj.port))
        self._sftpCn.set_keepalive(20)
        self._sftpCn.connect(None, cnObj.userName, cnObj.password)
        self._sftpCn = paramiko.SFTPClient.from_transport(self._sftpCn)

    def fetchProduct(self, dir, outDir, product="BioPar_NDVI300_V2_Global"):
        outProdDir = os.path.join(outDir, product)
        if not os.path.isdir(outProdDir):
            os.makedirs(outProdDir, exist_ok=True)

        productDir = os.path.join(dir, product)
        years = self._sftpCn.listdir(productDir)
        years.remove('2020')
        years.remove("2021")
        for year in years:
            yearDir = os.path.join(productDir, year)
            dates = self._sftpCn.listdir(yearDir)
            for date in dates:
                dateDir = os.path.join(yearDir, date)
                product = self._sftpCn.listdir(dateDir)[0]
                productDir = os.path.join(dateDir, product)
                files = self._sftpCn.listdir(productDir)
                outFileDir = os.path.join(*[outProdDir,year,date,product])
                if not os.path.isfile(outFileDir):
                    os.makedirs(outFileDir, exist_ok=True)
                for fl in files:
                    remotePath = os.path.join(productDir, fl)
                    localPath = os.path.join(outFileDir, fl)
                    print("Downloading: ", fl)
                    self._sftpCn.get(remotePath, localPath)
                    print("Downloading Finished!")

cfg = "../active_config.json"
cfg = ConfigurationParser(cfg)
if cfg.parse() != 1:
    obj = DataCrawler(cfg.sftpParams["terrascope.be"])
    obj.fetchProduct(dir="/home/argyros/Desktop/data/BIOPAR/", outDir=cfg.filesystem.imageryPath,
                 product="BioPar_NDVI300_V2_Global")

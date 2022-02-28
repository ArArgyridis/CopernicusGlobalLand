import os,paramiko
from stat import S_ISDIR

class DataCrawler:
    def __init__(self, hostname="uservm.terrascope.be", username="argyros", password="powertoeua87", port=24247):
        #self._sftCn = pysftp.Connection(hostname, username=username, password=password, port=port)
        self._sftpCn = paramiko.Transport((hostname, port))
        self._sftpCn.connect(None, username, password)
        self._sftpCn = paramiko.SFTPClient.from_transport(self._sftpCn)

    def fetchProduct(self, dir, outDir, product="BioPar_NDVI300_V2_Global"):
        if not os.path.isdir(outDir):
            os.makedirs(outDir, exist_ok=True)

        productDir = os.path.join(dir, product)
        years = self._sftpCn.listdir(productDir)
        for year in years:
            yearDir = os.path.join(productDir, year)
            dates = self._sftpCn.listdir(yearDir)
            for date in dates:
                dateDir = os.path.join(yearDir, date)
                product = self._sftpCn.listdir(dateDir)[0]
                productDir = os.path.join(dateDir, product)
                files = self._sftpCn.listdir(productDir)
                outFileDir = os.path.join(*[outDir,year,date,product])
                if not os.path.isfile(outFileDir):
                    os.makedirs(outFileDir, exist_ok=True)
                for file in files:
                    remotePath = os.path.join(productDir, file)
                    localPath = os.path.join(outFileDir, file)
                    self._sftpCn.get(remotePath, localPath)












obj = DataCrawler()
obj.fetchProduct(dir="/home/argyros/Desktop/data/BIOPAR/",outDir ="my_output_dir", product="BioPar_NDVI300_V2_Global")
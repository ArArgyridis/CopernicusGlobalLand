"""
   Copyright (C) 2022  Argyros Argyridis arargyridis at gmail dot com
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""
import hashlib, os,paramiko,re,socks,sys

from pycparser.c_ast import While

sys.path.extend(['../../']) #to properly import modules from other dirs
from Libs.ConfigurationParser import ConfigurationParser
from Libs.Constants import Constants
from multiprocessing import Pool

class FileValidateOptions:
    def __init__(self, fl, storageDir, prodInfo, cn):
        self.fl = fl
        self.storageDir = storageDir
        self.prodInfo = prodInfo
        self.cn = cn

def scanDir(dirList, product, found=False):
    #examineList = []
    for dir in dirList:
        lst = os.listdir(dir)

        for subDir in lst:
            tmpPath = os.path.join(dir, subDir)
            if not os.path.isdir(tmpPath):
                continue

            if subDir in product:
                found = True
                return os.path.join(dir, tmpPath)
            else:
                dirList.append(tmpPath)
                #dirList.pop(0)

    #if not found:
    #    return scanDir(examineList, product)

def validateFile(validateOptions):
    from osgeo import gdal
    gdal.DontUseExceptions()

    chk = os.path.split(validateOptions.fl)[1]
    productParams = validateOptions.prodInfo.getFileNameInfo(chk)
    if productParams is None:
        return None

    if len(validateOptions.prodInfo.variables) > 0:  # try to open file with gdal
        tmpDt = gdal.Open(validateOptions.fl)
        if tmpDt is None and os.path.splitext(validateOptions.fl)[1] in ('.tiff', '.tif', ".nc"):
            return [chk, "INVALID FILE"]

        del tmpDt
        tmpDt = None

    relFilePath = os.path.relpath(validateOptions.fl, validateOptions.storageDir)

    # check if product exists in DB
    checkQuery = """SELECT EXISTS (
                    SELECT *
                    FROM product_file pf 
                    JOIN product_file_description pfd ON pf.product_file_description_id = pfd.id
                    JOIN product p ON p.id = pfd.product_id 
                    WHERE pf.rel_file_path LIKE '%{0}'
                    AND pfd.id = {1});""".format(relFilePath, validateOptions.prodInfo.id)

    res = validateOptions.cn.pgConnections[validateOptions.cn.statsInfo.connectionId].fetchQueryResult(checkQuery)
    if res[0][0]:
        return None

    rtFlag = 'NULL'
    if validateOptions.prodInfo.rtFlag is not None:
        rtFlag = validateOptions.prodInfo.rtFlag.format(*productParams)

    satelliteSystem = 'NULL'
    if validateOptions.prodInfo.satelliteSystemPattern is not None:
        satelliteSystem = """'{0}'""".format(validateOptions.prodInfo.satelliteSystemPattern.format(*productParams))

    version = 'NULL'
    if validateOptions.prodInfo.versionPattern is not None:
        version = """'{0}'""".format(validateOptions.prodInfo.versionPattern.format(*productParams))

    return "({0})".format(",".join([str(validateOptions.prodInfo.id), "'{0}'".format(relFilePath),
                                           "'{0}'".format(validateOptions.prodInfo._dateptr.format(*productParams)),
                                           rtFlag, satelliteSystem, version]))



class DataCrawler:
    def __init__(self, cn, product, useProxy=False, mode="download"):
        self._cn = cn
        self._validationReportFile = "{0}_{1}_validation_report.txt".format(product.productNames[0],
                                                                  os.path.splitext(product.patterns[0])[1][1::].upper())
        self.sock = None
        self._mode = mode
        self._outLogData = {}
        if self._mode == "validate":
            #if log exists, load info
            if os.path.isfile(self._validationReportFile):
                infl = open(self._validationReportFile, "r")
                infl.readline() #skip header
                for row in infl:
                    if len(row) == 0:
                        continue
                    spt = row.split(",")
                    self._outLogData[spt[0]] = spt[1].replace("\n","")
                infl.close()
                infl = None

        if useProxy:
            self.sock = socks.socksocket()
            self.sock.set_proxy(
                proxy_type=socks.HTTP,
                addr=self._cn.sftpParams["terrascope.be"].proxy.host,
                port=self._cn.sftpParams["terrascope.be"].proxy.port
            )

            self.sock.connect((self._cn.sftpParams["terrascope.be"].host, self._cn.sftpParams["terrascope.be"].port))

        self._sshCn = paramiko.SSHClient()
        self._sshCn.load_system_host_keys()
        self._prodInfo = product
        self._fileExtension = os.path.splitext(self._prodInfo.patterns[0])[1]

    def __del__(self):
        self._cn = self.sock = self._download = self._sshCn = self._prodInfo = None


    def fetchOrValidateAgainstVITO(self, dir, storageDir):
        self._sshCn.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        if self.sock is None:
            self._sshCn.connect(self._cn.sftpParams["terrascope.be"].host, self._cn.sftpParams["terrascope.be"].port,
                            self._cn.sftpParams["terrascope.be"].userName, self._cn.sftpParams["terrascope.be"].password)
        else:
            self._sshCn.connect(self._cn.sftpParams["terrascope.be"].host, self._cn.sftpParams["terrascope.be"].port,
                                self._cn.sftpParams["terrascope.be"].userName,
                                self._cn.sftpParams["terrascope.be"].password, sock=self.sock)
        #product info
        detectedProductName = None
        listFiles = None
        i = 0
        #subfolders with products
        subFolders = ["REMOTE_PRODUCTS",]
        listFiles = []
        inProdDir = None
        curDirs = [dir,]
        foundStatus = "notfound"

        while foundStatus == "notfound": # and i < len(self._prodInfo.productNames):
            prdPath = self._prodInfo.productNames[i]
            #check all currentDirs
            foundStatus = "notfound"

            curDirId = 0
            while curDirId < len(curDirs) and foundStatus == "notfound":
                inProdDir = os.path.join(curDirs[curDirId], prdPath)
                #print(inProdDir)

                #check if the directory exists
                stdin, stdout, stderr = self._sshCn.exec_command("""if test -d {0}; then echo "exist"; \\
                else echo "notfound"; fi""".format(inProdDir))
                foundStatus = stdout.read().decode("ascii").replace("\n","")
                if foundStatus == "exist":
                    detectedProductName = prdPath

                curDirId += 1

            if foundStatus =="notfound" and i < len(self._prodInfo.productNames):
                i += 1

            if foundStatus == "notfound" and i == len(self._prodInfo.productNames):
                newCurDirs = []

                for curDir in curDirs:
                    #get subdirectories
                    stdin, stdout, stderr = self._sshCn.exec_command("find {0} -maxdepth 1 -type d".format(curDir))
                    newCurDirs += stdout.read().decode("ascii").split("\n")[1::]
                curDirs = newCurDirs
                i = 0

        if detectedProductName is None:
            return

        stdin, stdout, stderr = self._sshCn.exec_command("find {0}".format(inProdDir))
        listFiles = [f for f in stdout.read().decode("ascii").split("\n") if os.path.splitext(f)[1] == self._fileExtension]




        print("Files/Paths available for product file: {0}({1}){2} : {3}".format(self._prodInfo.productNames[0],
                                                                        detectedProductName, self._fileExtension,
                                                                                    len(listFiles)))

        if len(listFiles) == 0:
            return

        outProdDir = os.path.join(storageDir, self._prodInfo.productNames[0])
        listFiles = sorted(listFiles)

        for fl in listFiles:
            flName = os.path.split(fl)[1]
            productParams = self._prodInfo.getFileNameInfo(flName)

            if productParams is not None:
                #check if product exists in DB
                checkQuery = """WITH tmp AS(
                        SELECT pf.rel_file_path
                        FROM product_file pf 
                        JOIN product_file_description pfd ON pf.product_file_description_id = pfd.id
                        JOIN product p ON p.id = pfd.product_id 
                        WHERE pf.rel_file_path LIKE '%{0}'
                        AND  '{1}' = ANY(p."name")) 
                        SELECT EXISTS(SELECT * FROM tmp), tmp.rel_file_path
                        FROM (SELECT 1) LEFT JOIN tmp ON true;""".format(flName, detectedProductName)

                res = self._cn.pgConnections[self._cn.statsInfo.connectionId].fetchQueryResult(checkQuery)

                if self._mode == "download" and not res[0][0] : # download mode and not in the db
                    #download file if not exists in DB
                    outFilePath = fl.replace(inProdDir, outProdDir)
                    outFileDir = os.path.split(outFilePath)[0]
                    if not os.path.isdir(outFileDir):
                        os.makedirs(outFileDir, exist_ok=True)

                    #downloading file
                    print("Downloading: ", flName)
                    self._sshCn.open_sftp().get(fl, outFilePath)

                    rtFlag = 'NULL'
                    if self._prodInfo.rtFlag is not None:
                        rtFlag = self._prodInfo.rtFlag.format(*productParams)

                    self._store(["({0})".format(",".join([str(self._prodInfo.id),
                                                      "'{0}'".format(os.path.relpath(outFilePath, storageDir)),
                                                      "'{0}'".format(self._prodInfo._dateptr.format(*productParams)),
                                                          rtFlag]))])

                    print("Downloading Finished!")
                elif not self._mode == "download" and res[0][0]: #the system validates and the file exists in the DB
                    print("Validating: ", flName, end=" ")
                    localFilePath = os.path.join(storageDir, res[0][1])
                    localmd5 = hashlib.md5(open(localFilePath,"rb").read()).hexdigest()
                    stdin, stdout, stderr = self._sshCn.exec_command("md5sum {0}".format(fl))
                    check = "FAILED"
                    if stdout.read().split()[0].decode("ascii") == localmd5:
                        check = "OK"
                    self._outLogData[flName]=check
                    print("status = ", check)
                elif not self._mode == "download" and not res[0][0] and flName not in self._outLogData:
                    self._outLogData[flName] = "NOT FOUND"
        if self._mode == "validate":
            self._storeValidationData()

    def _storeValidationData(self):
        outFl = open(self._validationReportFile, "w")
        outFl.write("FileName,Status\n")
        for key in sorted(self._outLogData.keys()):
            outFl.write("{0},{1}\n".format(key, self._outLogData[key]))
        outFl.close()
        outFl = None


    def _store(self, dbData):
        query = """
            WITH tmp_data(product_file_description_id, rel_file_path, date, rt_flag, satellite_system, version) AS (
            VALUES {0}
            )
                    
            INSERT INTO product_file(product_file_description_id, rel_file_path, date, rt_flag, satellite_system, version) 
                SELECT product_file_description_id, max(rel_file_path), date::timestamp without time zone, rt_flag::smallint,
                satellite_system, version
                FROM tmp_data
                GROUP BY product_file_description_id,date,rt_flag, satellite_system, version
            
                ON CONFLICT(product_file_description_id, "date", rt_flag) DO NOTHING;"""
        self._cn.pgConnections[self._cn.statsInfo.connectionId].executeQueries([query.format(",\n".join(dbData)), ])

    def importProductFromLocalStorage(self, storageDir):

        inDir = None
        while inDir is None:
            inDir = scanDir([storageDir, ], self._prodInfo.productNames)

        if inDir is None:
            return
        #fl, storageDir, prodInfo, cn
        files = [
            FileValidateOptions(
                os.path.join(dp, f),
                storageDir,
                self._prodInfo,
                self._cn
            ) for dp, dn, filenames in os.walk(inDir) for f in filenames]

        dbData = []

        with Pool() as pool:
            for result in pool.map(validateFile, files):
                if isinstance(result, str):
                    dbData.append(result)
                elif isinstance(result, list):
                    self._outLogData[result[0]] = result[1]

        if len(dbData) > 0:
            self._store(dbData)

        if len(self._outLogData) > 0:
            self._storeValidationData()

def main():
    if len(sys.argv) < 3:
        print("usage: python DataCrawler.py config_file mode (download or validate) location (remote_server_path or disk_import)")
        return 1

    cfg = sys.argv[1]

    # loading constants
    Constants.load(cfg)

    cfg = ConfigurationParser(cfg)

    if cfg.parse() != 1:
        for pid in Constants.PRODUCT_INFO:
            print("Processing: ", Constants.PRODUCT_INFO[pid].productNames[0])
            obj = DataCrawler(cfg, Constants.PRODUCT_INFO[pid], False, sys.argv[2])
            if sys.argv[3] == "disk_import":
                inDir = cfg.filesystem.imageryPath
                if Constants.PRODUCT_INFO[pid].productType == "anomaly":
                    inDir = cfg.filesystem.anomalyProductsPath
                elif Constants.PRODUCT_INFO[pid].productType == "lts":
                    inDir = cfg.filesystem.ltsPath
                obj.importProductFromLocalStorage(inDir)
            else:
                if Constants.PRODUCT_INFO[pid].productType == "anomaly":
                    continue

                storageDir = cfg.filesystem.imageryPath
                if Constants.PRODUCT_INFO[pid].productType == "lts":
                    storageDir = cfg.filesystem.ltsPath

                obj.fetchOrValidateAgainstVITO(dir=sys.argv[3], storageDir=storageDir)

if __name__ == "__main__":
    main()



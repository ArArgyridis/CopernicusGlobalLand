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
sys.path.extend(['../../']) #to properly import modules from other dirs
from Libs.ConfigurationParser import ConfigurationParser
from Libs.Constants import Constants
from multiprocessing import Pool

class FileValidateOptions:
    def __init__(self, fl,storageDir, prodInfo, cn):
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
    pattern = re.compile(validateOptions.prodInfo.pattern)
    chk = os.path.split(validateOptions.fl)[1]

    match = pattern.search(chk)
    if not match:
        return None

    subStr = chk[match.start()::]
    if not pattern.fullmatch(subStr):
        return None

    if len(validateOptions.prodInfo.variables) > 0:  # try to open file with gdal
        tmpDt = gdal.Open(validateOptions.fl)
        if tmpDt is None and os.path.splitext(validateOptions.fl)[1] in ('.tif', ".nc"):
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

    productParams = pattern.findall(subStr)[0]
    rtFlag = 'NULL'
    if validateOptions.prodInfo.rtFlag is not None:
        rtFlag = validateOptions.prodInfo.rtFlag.format(*productParams)

    return "({0})".format(",".join([str(validateOptions.prodInfo.id), "'{0}'".format(relFilePath),
                                           "'{0}'".format(validateOptions.prodInfo._dateptr.format(*productParams)),
                                           rtFlag]))



class DataCrawler:
    def __init__(self, cn, product, useProxy=False, mode="download"):
        self._cn = cn
        self._missingFileLog = "{0}_{1}_missing_files.txt".format(product.productNames[0],
                                                                  os.path.splitext(product.pattern)[1][1::].upper())
        self.sock = None
        self._mode = mode
        self._outLogData = {}
        if self._mode == "validate":
            #if log exists, load info
            if os.path.isfile(self._missingFileLog):
                infl = open(self._missingFileLog, "r")
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

        while detectedProductName is None and i < len(self._prodInfo.productNames):
            prdPath = self._prodInfo.productNames[i]
            inProdDir = os.path.join(dir, prdPath)

            stdin, stdout, stderr = self._sshCn.exec_command("find {0}".format(inProdDir))
            listFiles = stdout.read().split()
            if len(listFiles) == 0: #checking the valid subfolders if the products are there
                fldId = 0
                while fldId < len(subFolders) and len(listFiles) == 0:
                    inProdDir = os.path.join(dir, *[subFolders[i],prdPath])
                    stdin, stdout, stderr = self._sshCn.exec_command("find {0}".format(inProdDir))
                    listFiles = stdout.read().split()

            if len(listFiles) > 0:
                detectedProductName = prdPath
            i += 1

        if detectedProductName is None:
            return

        outProdDir = os.path.join(storageDir, detectedProductName)

        print("Files/Paths available for product:{0} : {1}".format(detectedProductName, len(listFiles)))
        for fl in listFiles:
            fl = fl.decode("ascii")
            pattern = re.compile(self._prodInfo.pattern)
            chk = os.path.split(fl)[1]
            if pattern.fullmatch(chk) or pattern.fullmatch(chk[6::]):
                #check if product exists in DB
                checkQuery = """WITH tmp AS(
                        SELECT pf.rel_file_path
                        FROM product_file pf 
                        JOIN product_file_description pfd ON pf.product_file_description_id = pfd.id
                        JOIN product p ON p.id = pfd.product_id 
                        WHERE pf.rel_file_path LIKE '%{0}'
                        AND  '{1}' = ANY(p."name")) 
                        SELECT EXISTS(SELECT * FROM tmp), tmp.rel_file_path
                        FROM (SELECT 1) LEFT JOIN tmp ON true;""".format(chk, detectedProductName)

                res = self._cn.pgConnections[self._cn.statsInfo.connectionId].fetchQueryResult(checkQuery)
                flName = fl.split("/")[-1]
                if self._mode == "download" and not res[0][0] : # download mode and not in the db
                    #download file if not exists in DB
                    productParams = pattern.findall(chk)[0]
                    outFilePath = fl.replace(inProdDir, outProdDir)
                    outFileDir = os.path.split(outFilePath)[0]
                    if not os.path.isdir(outFileDir):
                        os.makedirs(outFileDir, exist_ok=True)

                    #downloading file
                    print("Downloading: ", chk)
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
                    localFilePath = os.path.join(storageDir, res[0][1])
                    localmd5 = hashlib.md5(open(localFilePath,"rb").read()).hexdigest()
                    stdin, stdout, stderr = self._sshCn.exec_command("md5sum {0}".format(fl))
                    check = "FAILED"
                    if stdout.read().split()[0].decode("ascii") == localmd5:
                        check = "OK"
                    self._outLogData[flName]=check
                elif not self._mode == "download" and not res[0][0] and flName not in self._outLogData:
                    self._outLogData[flName] = "NOT FOUND"
        if self._mode == "validate":
            self._storeValidationData()

    def _storeValidationData(self):
        outFl = open(self._missingFileLog, "w")
        outFl.write("FileName,Status\n")
        for key in sorted(self._outLogData.keys()):
            outFl.write("{0},{1}\n".format(key, self._outLogData[key]))
        outFl.close()
        outFl = None


    def _store(self, dbData):
        query = """
            WITH tmp_data(product_file_description_id, rel_file_path, date, rt_flag) AS (
            VALUES {0}
            )
                    
            INSERT INTO product_file(product_file_description_id, rel_file_path, date, rt_flag) 
                SELECT product_file_description_id, max(rel_file_path), date::timestamp without time zone, rt_flag::smallint
                FROM tmp_data
                GROUP BY product_file_description_id,date,rt_flag 
            
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



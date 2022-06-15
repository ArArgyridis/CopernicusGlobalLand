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
import os,paramiko,re,socks,sys
sys.path.extend(['../../']) #to properly import modules from other dirs
from Libs.ConfigurationParser import ConfigurationParser
from Libs.Constants import Constants


def scanDir(dirList, product, found=False):
    examineList = []
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
                examineList.append(tmpPath)

    if not found:
        return scanDir(examineList, product)


class DataCrawler:
    def __init__(self, cn, product, useProxy=False):
        self._cn = cn
        self.sock = None
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


    def fetchProductFromVITO(self, dir, storageDir):
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
        while detectedProductName is None:
            prdPath = self._prodInfo.productNames[i]
            stdin, stdout, stderr = self._sshCn.exec_command("find {0}".format(os.path.join(dir, prdPath)))
            listFiles = stdout.read().split()
            if len(listFiles) > 0:
                detectedProductName = prdPath

            i += 1

        if detectedProductName is None:
            return

        outProdDir = os.path.join(storageDir, detectedProductName)
        inProdDir = os.path.join(dir, detectedProductName)

        print("Files/Paths available for product:{0} : {1}".format(detectedProductName, len(listFiles)))
        for fl in listFiles:
            fl = fl.decode("ascii")
            pattern = re.compile(self._prodInfo.pattern)
            chk = os.path.split(fl)[1]
            if pattern.fullmatch(chk):
                #check if product exists in DB
                checkQuery = """SELECT EXISTS (
                        SELECT *
                        FROM product_file pf 
                        JOIN product_file_description pfd ON pf.product_description_id = pfd.id
                        JOIN product p ON p.id = pfd.product_id 
                        WHERE pf.rel_file_path LIKE '%{0}'
                        AND  '{1}' = ANY(p."name"));""".format(chk, detectedProductName)

                res = self._cn.pgConnections[self._cn.statsInfo.connectionId].fetchQueryResult(checkQuery)
                if res[0][0]:
                    continue
                #download file if not exists in DB
                dateInfo = pattern.findall(chk)[0]
                outFilePath = fl.replace(inProdDir, outProdDir)
                outFileDir = os.path.split(outFilePath)[0]
                if not os.path.isdir(outFileDir):
                    os.makedirs(outFileDir, exist_ok=True)

                #downloading file
                print("Downloading: ", chk)
                self._sshCn.open_sftp().get(fl, outFilePath)

                self._store(["({0})".format(",".join([str(self._prodInfo.id),
                                                      "'{0}'".format(os.path.relpath(outFilePath, storageDir)),
                                                      "'{0}'".format(self._prodInfo._dateptr.format(*dateInfo))]))])

                print("Downloading Finished!")


    def _store(self, dbData):
        query = """INSERT INTO product_file(product_description_id, rel_file_path, date) VALUES {0} 
                ON CONFLICT(product_description_id, rel_file_path) DO NOTHING; """
        self._cn.pgConnections[self._cn.statsInfo.connectionId].executeQueries([query.format(",".join(dbData)), ])

    def importProductFromLocalStorage(self, storageDir):

        execute = False
        inDir = None
        while inDir is None:
            inDir = scanDir([storageDir, ], self._prodInfo.productNames)

        if inDir is None:
            return
        #inDir = [x[0] for x in os.walk(storageDir) if x[0].endswith(product)][0]
        print(inDir)
        files = [os.path.join(dp, f) for dp, dn, filenames in os.walk(inDir) for f in filenames]
        dbData = []
        for fl in files:
            pattern = re.compile(self._prodInfo.pattern)
            chk = os.path.split(fl)[1]
            if pattern.fullmatch(chk):
                dateInfo = pattern.findall(chk)[0]
                dbData.append("({0})".format(",".join([str(self._prodInfo.id), "'{0}'".format(
                    os.path.relpath(fl, storageDir)),"'{0}'".format(self._prodInfo._dateptr.format(*dateInfo)) ])))
                execute = True


        if execute:
            self._store(dbData)


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("usage: python DataCrawler.py config_file remote_server_path (optional) disk_import")

    cfg = sys.argv[1]

    # loading constants
    Constants.load(cfg)

    cfg = ConfigurationParser(cfg)

    if cfg.parse() != 1:
        for pid in Constants.PRODUCT_INFO:
            obj = DataCrawler(cfg, Constants.PRODUCT_INFO[pid], False)
            if Constants.PRODUCT_INFO[pid].productType != "raw": #this should be used only when fetching data remotely
                continue
            if sys.argv[2] == "disk_import":
                obj.importProductFromLocalStorage(cfg.filesystem.imageryPath)
            else:
                obj.fetchProductFromVITO(dir=sys.argv[2], storageDir=cfg.filesystem.imageryPath)



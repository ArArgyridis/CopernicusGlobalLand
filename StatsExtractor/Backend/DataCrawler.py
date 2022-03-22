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
import os,paramiko,sys
sys.path.extend(['..']) #to properly import modules from other dirs
from Libs.ConfigurationParser import ConfigurationParser
import re

class DataCrawler:
    def __init__(self, cn, product):
        self._cn = cn
        self._sshCn = paramiko.SSHClient()
        self._sshCn.load_system_host_keys()
        self._prodInfo = self._cn.pgConnections[self._cn.statsInfo.connectionId].fetchQueryResult(
            """SELECT pfd.id, pfd.pattern, pfd.TYPES, pfd.create_date
                FROM product p 
                JOIN product_file_description pfd ON p.id = pfd.product_id 
                WHERE p."name" ='{0}'""".format(product))


    def fetchProductFromVITO(self, dir, outDir, product="BioPar_NDVI300_V2_Global"):
        self._sshCn.connect(self._cn.sftpParams["terrascope.be"].host, self._cn.sftpParams["terrascope.be"].port,
                            self._cn.sftpParams["terrascope.be"].userName, self._cn.sftpParams["terrascope.be"].password)
        #product info
        outProdDir = os.path.join(outDir, product)
        inProdDir = os.path.join(dir, product)

        stdin, stdout, stderr = self._sshCn.exec_command("find {0}".format(os.path.join(dir, product)))
        listFiles = stdout.read().split()
        print("Files available for product:{0} : {1}".format(product, len(listFiles)))
        for fl in listFiles:
            fl = fl.decode("ascii")
            for ptr in self._prodInfo:
                pattern = re.compile(ptr[1])
                chk = os.path.split(fl)[1]
                if pattern.fullmatch(chk):
                    #check if product exists in DB
                    checkQuery = """
                    SELECT EXISTS (
                        SELECT *
                        FROM product_file pf 
                        JOIN product_file_description pfd ON pf.product_description_id = pfd.id
                        JOIN product p ON p.id = pfd.product_id 
                        WHERE pf.rel_file_path LIKE '%{0}'
                        AND p."name" = '{1}');
                    """.format(chk, product)
                    res = self._cn.pgConnections[self._cn.statsInfo.connectionId].fetchQueryResult(checkQuery)
                    if res[0][0]:
                        continue
                    #download file if not exists in DB
                    dtInfo = pattern.findall(chk)[0]
                    outFilePath = fl.replace(inProdDir, outProdDir)
                    outFileDir = os.path.split(outFilePath)[0]
                    if not os.path.isdir(outFileDir):
                        os.makedirs(outFileDir, exist_ok=True)

                    #downloading file
                    print("Downloading: ", chk)
                    self._sshCn.open_sftp().get(fl, outFilePath)
                    self.importProductFromLocalStorage(self, outDir, product)
                    print("Downloading Finished!")

    def importProductFromLocalStorage(self, storageDir, product):
        inDir = os.path.join(storageDir, product)
        files = [os.path.join(dp, f) for dp, dn, filenames in os.walk(inDir) for f in filenames]
        query = """INSERT INTO product_file(product_description_id, rel_file_path, date) VALUES {0} 
        ON CONFLICT(product_description_id, rel_file_path) DO NOTHING; """
        dbData = []

        execute = False
        for fl in files:
            for info in self._prodInfo:
                pattern = re.compile(info[1])
                chk = os.path.split(fl)[1]
                if pattern.fullmatch(chk):
                    dateInfo = pattern.findall(chk)[0]
                    dbData.append("({0})".format(",".join([str(info[0]), "'{0}'".format(os.path.relpath(fl, storageDir)), "'{0}'".format(info[3].format(*dateInfo)) ])))
                    execute = True

        if execute:
            self._cn.pgConnections[self._cn.statsInfo.connectionId].executeQueries([query.format(",".join(dbData)),])

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("usage: python DataCrawler.py config_file remote_server_path")


    cfg = sys.argv[1]
    cfg = ConfigurationParser(cfg)
    products = ["BioPar_NDVI300_V2_Global",
             "BioPar_NDVI_STATS_Global",
             "BioPar_FAPAR300_V1_Global"]
    
    products = ["BioPar_NDVI_STATS_Global","BioPar_NDVI300_V2_Global"]
    if cfg.parse() != 1:
        for product in products:
            obj = DataCrawler(cfg, product)
            obj.fetchProductFromVITO(dir=sys.argv[2], outDir=cfg.filesystem.imageryPath,
                                     product=product)
            obj.importProductFromLocalStorage(cfg.filesystem.imageryPath, product)


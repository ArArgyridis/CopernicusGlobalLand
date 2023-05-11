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
import sys, os
sys.path.extend(['../../../']) #to properly import modules from other dirs
from Libs.ConfigurationParser import ConfigurationParser
from DBDeployer import DBDeployer

class DBExporter:
    def __init__(self, cfg):
        self._cfg = cfg

    def process(self, out="../../schema.sql"):
        #temp db setup
        tmpDBPath = os.path.join(self._cfg.filesystem.tmpPath, "tmp_schema.sql")
        print("exporting tmp backup...")
        #exporting entire db to tmpdb

        cmd = """export PGPASSWORD='{0}' && pg_dump -d {1} -U {2} -h {3} -Fc > {4}""".format(
            self._cfg.pgConnections[self._cfg.statsInfo.connectionId].password,
            self._cfg.pgConnections[self._cfg.statsInfo.connectionId].db,
            self._cfg.pgConnections[self._cfg.statsInfo.connectionId].user,
            self._cfg.pgConnections[self._cfg.statsInfo.connectionId].host,
            tmpDBPath
        )
        os.system(cmd)
        print("import tmp backup to tmpdb")
        dpl = DBDeployer(self._cfg.cfgFile, tmpDBPath)
        createDBOptions = self._cfg.pgConnections[self._cfg.statsInfo.exportId]
        dpl.process(True, createDBOptions)
        os.remove(tmpDBPath)

        print("truncating uneeded data")
        #emptying tables which are not needed
        self._cfg.pgConnections[self._cfg.statsInfo.exportId].executeQueries([
            """TRUNCATE stratification RESTART IDENTITY CASCADE;""",
            """TRUNCATE product_file RESTART IDENTITY CASCADE;"""
        ])

        print("writing final backup")
        cmd = "export PGPASSWORD='{0}' && pg_dump -d {1} -U {2} -h {3} -Fc > {4}".format(
            self._cfg.pgConnections[self._cfg.statsInfo.exportId].password,
            self._cfg.pgConnections[self._cfg.statsInfo.exportId].db,
            self._cfg.pgConnections[self._cfg.statsInfo.exportId].user,
            self._cfg.pgConnections[self._cfg.statsInfo.exportId].host,
            out
        )
        os.system(cmd)





if __name__ == "__main__":
    cfg = "../../active_config.json"
    cfg = ConfigurationParser(cfg)
    if cfg.parse() != 1:
        obj = DBExporter(cfg)
        obj.process()

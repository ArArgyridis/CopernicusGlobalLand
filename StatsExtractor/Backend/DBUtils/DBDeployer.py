"""
   Copyright (C) 2021  Argyros Argyridis arargyridis at gmail dot com
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

class DBDeployer(object):
    def __init__(self, cfg, template):
        self._cfg = ConfigurationParser(cfg)
        self._template = template
        self.__createDBOptions = None
        self.__creationQueries = []

    def __createDBIfNotExists(self, dropDBIfExists):
        if dropDBIfExists:
            self.__creationQueries.append("DROP DATABASE IF EXISTS {0};".format(self.__createDBOptions.db))
        #check if db exists
        self.__creationQueries.append("CREATE DATABASE {0};".format(self.__createDBOptions.db))


    def __createUserIfNotExists(self):
        #check if user exists
        res = self._cfg.pgConnections["admin"].fetchQueryResult("""SELECT EXISTS (SELECT FROM pg_catalog.pg_roles
        WHERE  rolname = '{0}')""".format(self.__createDBOptions.user))

        if not res[0][0]:
            query = "CREATE USER {0}".format(self.__createDBOptions.user)
            if self.__createDBOptions.password is not None:
                query += " WITH ENCRYPTED PASSWORD '{0}'".format(self.__createDBOptions.password)
            query +=";"
            self.__creationQueries.append(query)
            self.__creationQueries.append("GRANT ALL ON DATABASE {0} TO USER {1};".format(self.__createDBOptions.db,
                                                                                          self.__createDBOptions.user))

    def __loadSchema(self):
        cmd = "export PGPASSWORD='{0}' && pg_restore -d {1} -U {2} -h {3} < {4}".format(
            self._cfg.pgConnections["admin"].password,
            self._cfg.pgConnections[self._cfg.statsInfo.connectionId].db,
            self._cfg.pgConnections["admin"].user,
            self._cfg.pgConnections["admin"].host,
            self._template
        )
        os.system(cmd)

    def process(self, dropIfExists=True):
        self._cfg.parse()
        self.__createDBOptions = self._cfg.pgConnections[self._cfg.statsInfo.connectionId]
        self.__createDBIfNotExists(dropIfExists)
        self.__createUserIfNotExists()
        self._cfg.pgConnections["admin"].executeNoTransaction(self.__creationQueries)
        self.__loadSchema()
        session = self._cfg.pgConnections["admin"].getNewSession(self.__createDBOptions.db)
        schemas = self._cfg.pgConnections[self._cfg.statsInfo.connectionId].fetchQueryResult(
            "SELECT schema_name FROM information_schema.schemata", session)
        for row in schemas:
            self._cfg.pgConnections["admin"].executeQueries(
                ["GRANT ALL ON SCHEMA {0} TO {1}".format(row[0], self.__createDBOptions.user),
                 "GRANT ALL ON ALL TABLES IN SCHEMA {0} TO {1}".format(row[0], self.__createDBOptions.user),
                 "GRANT ALL ON ALL SEQUENCES IN SCHEMA {0} TO {1};".format(row[0], self.__createDBOptions.user)
                 ], session)



def main():
    if len(sys.argv) < 3:
        print("Usage: python DBDeployer.py config.json_file schema.sql")
        return 1
    cfg = sys.argv[1]
    template = sys.argv[2]
    obj = DBDeployer(cfg, template)
    obj.process()

if __name__ == "__main__":
    main()



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
    def __init__(self, cfg, schema, data):
        self._cfg = ConfigurationParser(cfg)
        self._cfg.parse()
        self._schema = schema
        self._data = data
        self.__creationQueries = []

    def __createDBIfNotExists(self, dropDBIfExists, createDBOptions):
        if dropDBIfExists:
            self.__creationQueries.append("DROP DATABASE IF EXISTS {0};".format(createDBOptions.db))
        #check if db exists
        self.__creationQueries.append("CREATE DATABASE {0};".format(createDBOptions.db))


    def __createUserIfNotExists(self, createDBOptions):
        #check if user exists
        res = self._cfg.pgConnections["admin"].fetchQueryResult("""SELECT EXISTS (SELECT FROM pg_catalog.pg_roles
        WHERE  rolname = '{0}')""".format(createDBOptions.user))

        if not res[0][0]:
            query = "CREATE USER {0}".format(createDBOptions.user)
            if createDBOptions.password is not None:
                query += " WITH ENCRYPTED PASSWORD '{0}'".format(createDBOptions.password)
            query +=";"
            self.__creationQueries.append(query)
            self.__creationQueries.append("ALTER DATABASE {0} OWNER TO {1};".format(createDBOptions.db,
                                                                                          createDBOptions.user))

    def __loadSchema(self, createDBOptions):
        cmd = "export PGPASSWORD='{0}' && pg_restore -d {1} -U {2} -h {3} --role={2} < {4}".format(
            self._cfg.pgConnections["admin"].password,
            createDBOptions.db,
            self._cfg.pgConnections["admin"].user,
            self._cfg.pgConnections["admin"].host,
            self._schema
        )
        os.system(cmd)

        cmd = "export PGPASSWORD='{0}' && pg_restore -d {1} -U {2} -h {3} --role={2} < {4}".format(
            self._cfg.pgConnections["admin"].password,
            createDBOptions.db,
            self._cfg.pgConnections["admin"].user,
            self._cfg.pgConnections["admin"].host,
            self._data
        )
        os.system(cmd)

    def dbInit(self, createDBOptions, dropIfExists):
        self.__createDBIfNotExists(dropIfExists, createDBOptions)
        self.__createUserIfNotExists(createDBOptions)
        self._cfg.pgConnections["admin"].executeNoTransaction(self.__creationQueries)

    def process(self, dropIfExists=True, createDBOptions=None):
        if createDBOptions is None:
            createDBOptions=self._cfg.pgConnections[self._cfg.statsInfo.connectionId]

        self.dbInit(createDBOptions, dropIfExists)

        self.__loadSchema(createDBOptions)
        
        session = self._cfg.pgConnections["admin"].getNewSession(createDBOptions.db)
        schemas = createDBOptions.fetchQueryResult(
            "SELECT schema_name FROM information_schema.schemata", session)

        for row in schemas:
            self._cfg.pgConnections["admin"].executeQueries(
                ["GRANT ALL ON SCHEMA {0} TO {1}".format(row[0], createDBOptions.user),
                 "GRANT ALL ON ALL TABLES IN SCHEMA {0} TO {1}".format(row[0], createDBOptions.user),
                 "GRANT ALL ON ALL SEQUENCES IN SCHEMA {0} TO {1};".format(row[0], createDBOptions.user)
                 ], session)
                
        refreshQueries = []
        execQueries = [ ("""SELECT table_schema || '.' || table_name 
                FROM information_schema.tables 
                WHERE table_schema  IN('public','tmp') 
                AND table_name NOT IN ('spatial_ref_sys','geography_columns','geometry_columns')""",
                """ALTER TABLE {0} OWNER TO {1};"""),
                (""" SELECT sequence_schema || '.' || sequence_name FROM information_schema.sequences  ORDER BY sequence_name""",
                """ALTER SEQUENCE {0} OWNER TO {1}; """)]
    
        for ptrn in execQueries:

            res = self._cfg.pgConnections[self._cfg.statsInfo.connectionId].fetchQueryResult(ptrn[0])

            for row in res:
                refreshQueries.append(ptrn[1].format(row[0], createDBOptions.user))

        self._cfg.pgConnections["admin"].executeQueries(refreshQueries, session)



def main():
    if len(sys.argv) < 4:
        print("Usage: python DBDeployer.py config.json_file schema.sql data.sql")
        return 1
    cfg     = sys.argv[1]
    schema  = sys.argv[2]
    data    = sys.argv[3]
    obj = DBDeployer(cfg, schema, data)
    obj.process()

if __name__ == "__main__":
    main()



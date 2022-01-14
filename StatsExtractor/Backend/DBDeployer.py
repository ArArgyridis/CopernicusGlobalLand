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

import sys, json
sys.path.extend(['..']) #to properly import modules from other dirs
from Libs.ConfigurationParser import ConfigurationParser

class DBDeployer(object):
    PRODUCT_INFO = [
        {
            "name":"BioPar_NDVI300_V2_Global",
            "pattern": "c_gls_NDVI300_(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})_GLOBE_OLCI_V2.0.1.nc",
            "types": "(int, int, int, int, int,)",
            "create_date": "{0}-{1}-{2}T{3}:{4}:00",
            "variable": "NDVI",
            "style": "../Styles/BioPar_NDVI300_V2_Global.sld",
            "description": "NDVI Data @ 300Km",
            "low_value": 0.225,
            "mid_value": 0.45,
            "high_value":0.75,
            "noval_colors": json.dumps({"0": [254, 240, 217], "25": [253, 204, 138], "50": [252, 141, 89], "75": [227, 74, 51], "100": [179, 0, 0]}),
            "sparseval_colors":json.dumps({"0": [247, 252, 245], "25": [201, 234, 194], "50": [123, 199, 124], "75": [42, 146, 75], "100": [0, 68, 27]}),
            "midval_colors": json.dumps({"0": [247, 252, 245], "25": [201, 234, 194], "50": [123, 199, 124], "75": [42, 146, 75],"100": [0, 68, 27]}),
            "highval_colors": json.dumps({"0": [247, 252, 245], "25": [201, 234, 194], "50": [123, 199, 124], "75": [42, 146, 75],"100": [0, 68, 27]}),
            "min_value":0,
            "max_value":250

        },
        {
            "name": "BioPar_FAPAR300_V1_Global",
            "pattern": "c_gls_FAPAR300-RT(\d+)_(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})_GLOBE_(\w+)_(.*?).nc",
            "types": "(int, int, int, int, int,)",
            "create_date": "{0}-{1}-{2}T{3}:{4}:00",
            "variable": "FAPAR",
            "style": "../Styles/BioPar_NDVI300_V2_Global.sld",
            "description": "Fraction of Absorbed Photosynthetically Active Radiation 333m",
            "low_value": 0.225,
            "mid_value": 0.45,
            "high_value":0.75,
            "noval_colors": json.dumps({"0": [254, 240, 217], "25": [253, 204, 138], "50": [252, 141, 89], "75": [227, 74, 51], "100": [179, 0, 0]}), #CAN BE 'NULL'
            "sparseval_colors":json.dumps({"0": [247, 252, 245], "25": [201, 234, 194], "50": [123, 199, 124], "75": [42, 146, 75], "100": [0, 68, 27]}), #CAN BE 'NULL'
            "midval_colors": json.dumps({"0": [247, 252, 245], "25": [201, 234, 194], "50": [123, 199, 124], "75": [42, 146, 75],"100": [0, 68, 27]}), #CAN BE 'NULL'
            "highval_colors": json.dumps({"0": [247, 252, 245], "25": [201, 234, 194], "50": [123, 199, 124], "75": [42, 146, 75],"100": [0, 68, 27]}), #CAN BE 'NULL'
            "min_value":0,
            "max_value":238
        }
    ]

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

        self.__creationQueries.append("GRANT ALL PRIVILEGES ON DATABASE {0} to {1};"
                                      .format(self.__createDBOptions.db, self.__createDBOptions.user))

    def __loadProducts(self):
        values = ""
        for product in DBDeployer.PRODUCT_INFO:
            values += "("
            for key in product:
                if key != "style":
                    values += "'{0}',".format(product[key])
                else:
                    values += "'{0}',".format(open(product[key]).read())

            values = values[0:-1] + "),"

        query = "INSERT INTO {0}.product(name, pattern, types, create_date, variable, style, description, low_value, " \
                "mid_value, high_value, noval_colors, sparseval_colors, midval_colors, highval_colors, min_prod_value," \
                "max_prod_value) VALUES {1}".format(self._cfg.statsInfo.schema, values[0:-1])
        session = self._cfg.pgConnections["admin"].getNewSession(db=self.__createDBOptions.db)
        self._cfg.pgConnections["admin"].executeQueries([query, ], session)


    def __loadSchema(self):
        query = open(self._template).read().format(self._cfg.statsInfo.tmpSchema,
                                                   self._cfg.statsInfo.schema, self.__createDBOptions.user)

        session = self._cfg.pgConnections["admin"].getNewSession(db=self.__createDBOptions.db)
        self._cfg.pgConnections["admin"].executeQueries([query,], session)

    def process(self, dropIfExists=True):
        self._cfg.parse()
        self.__createDBOptions = self._cfg.pgConnections[self._cfg.statsInfo.connectionId]
        self.__createDBIfNotExists(dropIfExists)
        self.__createUserIfNotExists()
        self._cfg.pgConnections["admin"].executeNoTransaction(self.__creationQueries)
        self.__loadSchema()
        self.__loadProducts()



def main():
    if len(sys.argv) < 3:
        print("Usage: python DBDeployer.py config.json_file schema.sql.template_file")
        return 1
    cfg = sys.argv[1]
    template = sys.argv[2]
    obj = DBDeployer(cfg, template)
    obj.process()




if __name__ == "__main__":
    main()



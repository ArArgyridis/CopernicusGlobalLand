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

import json,  os, psycopg2 as pg, subprocess, sys
sys.path.extend(['../../../'])
from Libs.ConfigurationParser import ConfigurationParser

class DBImporter:
    def __init__(self, shpFile, dstTable, descriptor, descriptionColumn, configFile,):
        self.__file = shpFile
        self.__tmpTable = dstTable
        self.__descriptor = descriptor
        self.__descriptionColumn = descriptionColumn
        self.__geomColumn = "geom"
        self.__configuration = ConfigurationParser(configFile)


    def __executeOGRCommand(self):
        code = 0
        try:
            cmd = """ogr2ogr -overwrite -f "PostgreSQL" PG:"{0}" -nlt PROMOTE_TO_MULTI "{1}" -lco GEOMETRY_NAME={3} -nln {2}""".format(
                self.__configuration.pgConnections[self.__configuration.statsInfo.connectionId].getConnectionString(),
                self.__file, "{0}.{1}".format(self.__configuration.statsInfo.tmpSchema,
                                              self.__tmpTable), self.__geomColumn)

            code = subprocess.call(cmd, shell=True)
            if code != 0:
                raise RuntimeError
        except RuntimeError:
            print("Unable to import data through ogr2ogr into DB. Exiting")

        return code

    def __migrateData(self):
        #fetching table columns
        try:
            session = self.__configuration.pgConnections[self.__configuration.statsInfo.connectionId].getNewSession()

            print("""INSERT INTO {0}.stratification (description) VALUES ('{1}') ON CONFLICT(description) 
                       DO NOTHING;""".format(self.__configuration.statsInfo.schema, self.__descriptor))


            queries = ["DELETE FROM {0}.stratification where description = '{1}';".format(
                self.__configuration.statsInfo.schema, self.__descriptor),
            """INSERT INTO {0}.stratification (description) VALUES ('{1}') ON CONFLICT(description) 
            DO NOTHING;""".format(self.__configuration.statsInfo.schema, self.__descriptor),

            """ INSERT INTO {0}.stratification_geom (stratification_id, geom, geom3857, description) SELECT s.id, ST_Transform({2},4326),
             ST_Transform({2}, 3857), {3} FROM {4}.{5} JOIN {0}.stratification s 
             ON s.description= '{1}'; """.format(self.__configuration.statsInfo.schema,self.__descriptor,self.__geomColumn,
                                                 self.__descriptionColumn,
                                                 self.__configuration.statsInfo.tmpSchema, self.__tmpTable),
            """DROP TABLE {0}.{1}""".format(self.__configuration.statsInfo.tmpSchema, self.__tmpTable)
            ]
            code = self.__configuration.pgConnections[self.__configuration.statsInfo.connectionId].executeQueries(queries, session)
            if code != 0:
                raise pg.DataError

        except pg.ProgrammingError:
            print("Unable to retrieve temporary table columns. Exiting")
            return 1
        except pg.DataError:
            print("Unable to populate/update stratification table. Exiting")
            return 2
        return 0

    def process(self):
        try:
            #load configuration file
            funcs = [
                self.__configuration.parse,
                self.__executeOGRCommand,
                self.__migrateData
            ]
            for func in funcs:
                code = func()
                if code != 0:
                    raise
            print("Process completed successfully!!")

        except:
            print("Unable to complete import process. Exiting")





if __name__ == "__main__":
    if len(sys.argv) < 6:
        print("Usage: python DBImporter.py shpfile, tmptablename, identifier, column_with_description_name, config_file")
    shpFile = sys.argv[1]
    dstTable = sys.argv[2]
    descriptor = sys.argv[3]
    descriptionColumn = sys.argv[4]
    config = sys.argv[5]


    obj = DBImporter(shpFile, dstTable, descriptor, descriptionColumn, config)
    obj.process()

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

import json, os, psycopg2 as pg

class PGOptions(object):
    def __init__(self, db, host, port, user, pwd):
        self.db = db
        self.host = host
        self.port = port
        self.user = user
        self.password = pwd

    def __del__(self):
        self.db = None
        self.host = None
        self.port = None
        self.user = None
        self.password = None

    def getConnectionString(self, db=None):
        if db is None:
            db = self.db
        return "dbname={0} host={1} port={2} user={3} password={4}".format(db, self.host, self.port, self.user,
                                                                           self.password)
    def getOGRConnectionString(self):
        return "PG: "+self.getConnectionString()

    def getNewSession(self, db=None):
        return pg.connect(self.getConnectionString(db))

    def executeNoTransaction(self, queries, session=None):
        try:
            if session is None:
                session = self.getNewSession()

            autocommit = pg.extensions.ISOLATION_LEVEL_AUTOCOMMIT
            session.set_isolation_level(autocommit)

            cursor = session.cursor()
            for query in queries:
                cursor.execute(query)
            cursor.close()



        except:
            session.rollback()
            print("Unable to execute non-transaction queries. Exiting")
            return 1

    def executeQueries(self, queries, session=None):
            query = None
        #try:
            if session is None:
                session = self.getNewSession()

            cursor = session.cursor()
            for i in range(len(queries)):
                query = queries[i]
                cursor.execute(query)
            session.commit()
            return 0
        #except:
        #    session.rollback()
        #    print(query)
        #    print("Unable to exequte queries. Exiting")
        #    return 1

    def fetchQueryResult(self, query, session=None):
        try:
            if session is None:
                session = self.getNewSession()

            cursor = session.cursor()
            cursor.execute(query)
            res = cursor.fetchall()
            return res
        except:
            session.rollback()
            print("Unable to execute query. Exiting")
            return 1

    def getIteratableResult(self, query, session=None):
        try:
            if session is None:
                session = self.getNewSession()

            cursor = session.cursor()
            cursor.execute(query)
            return cursor

        except:
            session.rollback()
            print(query)
            print("Unable to fetch iteratable. Exiting")
            return 1


class StatsInfo(object):
    def __init__(self, schema, tmpSchema, connectionId):
        self.schema = schema
        self.tmpSchema = tmpSchema
        self.connectionId = connectionId

class FileSystem(object):
    def __init__(self, cfg):
        self.imageryPath = cfg["imagery_path"]


class ConfigurationParser(object):
    def __init__(self, cfgFile):
        self.__cfgFile = cfgFile
        self.pgConnections = {}
        self.statsInfo = None

    def getFile(self):
        return self.__cfgFile

    def parse(self):
        try:
            if not os.path.isfile(self.__cfgFile):
                raise FileExistsError
            #loading configuration
            configData = json.load(open(self.__cfgFile))

            #importing connections
            for cn in configData["pg_connections"].keys():
                self.pgConnections[cn] = PGOptions(configData["pg_connections"][cn]["db"],
                                                   configData["pg_connections"][cn]["host"],
                                                   configData["pg_connections"][cn]["port"],
                                                   configData["pg_connections"][cn]["user"],
                                                   configData["pg_connections"][cn]["password"])
            #importing stats info
            self.statsInfo = StatsInfo(configData["statsinfo"]["schema"],
                                       configData["statsinfo"]["tmp_schema"],configData["statsinfo"]["connection_id"])
            #path-relevant info
            self.filesystem = FileSystem(configData["filesystem"])
            return 0

        except FileExistsError:
            print("Configuration file does not exists! Exiting.")
            return 1
        except:
            print("Unable to parse file! exiting")




if __name__ == "__main__":
    inFile = "config.json"
    obj = ConfigurationParser(inFile)
    obj.parse()



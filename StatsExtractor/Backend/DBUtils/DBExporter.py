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

    def process(self, outSchema="../../schema.sql", outData="../../data.sql"):
        print("exporting schema")

        #getting poly_stats partition tables and ignore them during export
        ignoreStatPartitionTables = self._cfg.pgConnections[self._cfg.statsInfo.connectionId].fetchQueryResult("""
            SELECT
                --nmsp_parent.nspname AS parent_schema,
                --parent.relname      AS parent,
                nmsp_child.nspname  AS child_schema,
                child.relname       AS child
            FROM pg_inherits
            JOIN pg_class parent            ON pg_inherits.inhparent = parent.oid
            JOIN pg_class child             ON pg_inherits.inhrelid   = child.oid
            JOIN pg_namespace nmsp_parent   ON nmsp_parent.oid  = parent.relnamespace
            JOIN pg_namespace nmsp_child    ON nmsp_child.oid   = child.relnamespace
        WHERE parent.relname='poly_stats';""")

        excludeTables = ["""--exclude-table='"{0}"."{1}"'""".format(row[0], row[1])
                         for row in ignoreStatPartitionTables]
        excludeTables = " ".join(excludeTables)

        cmd = """export PGPASSWORD='{0}' && pg_dump -d {1} -U {2} -h {3} {4} --schema-only  -Fc > {5}""".format(
            self._cfg.pgConnections[self._cfg.statsInfo.connectionId].password,
            self._cfg.pgConnections[self._cfg.statsInfo.connectionId].db,
            self._cfg.pgConnections[self._cfg.statsInfo.connectionId].user,
            self._cfg.pgConnections[self._cfg.statsInfo.connectionId].host,
            excludeTables,
            outSchema
        )

        os.system(cmd)

        print("exporting needed data")
        cmd = """export PGPASSWORD='{0}' && pg_dump -d {1} -U {2} -h {3} \\
        --data-only -t category -t product -t product_file_description -t product_file_variable \\
        -t long_term_anomaly_info -Fc > {4}""".format(
            self._cfg.pgConnections[self._cfg.statsInfo.connectionId].password,
            self._cfg.pgConnections[self._cfg.statsInfo.connectionId].db,
            self._cfg.pgConnections[self._cfg.statsInfo.connectionId].user,
            self._cfg.pgConnections[self._cfg.statsInfo.connectionId].host,
            outData
        )
        os.system(cmd)


def main():
    if len(sys.argv) < 2:
        print("Usage: DBExporter.py config_file")
        return 0
    cfg = sys.argv[1]
    cfg = ConfigurationParser(cfg)
    if cfg.parse() != 1:
        obj = DBExporter(cfg)
        obj.process()


if __name__ == "__main__":
    main()

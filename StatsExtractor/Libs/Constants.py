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

import copyreg, re, types
from Libs.ConfigurationParser import ConfigurationParser

class Constants:
    PRODUCT_INFO={}

    @staticmethod
    def load(cfg):
        try:
            _cfg = ConfigurationParser(cfg)
            _cfg.parse()
            query = """
            WITH unique_dates AS(
                SELECT DISTINCT ps.product_type, ARRAY_AGG(DISTINCT ps.date) dates
	            FROM {0}.poly_stats ps 
	            GROUP BY PS.product_type
            )
            SELECT DISTINCT p.*, ud.dates
            FROM {0}.product p 
            LEFT JOIN unique_dates ud on p.id = ud.product_type
            """.format(_cfg.statsInfo.schema)
            res = _cfg.pgConnections[_cfg.statsInfo.connectionId].getIteratableResult(query)
            if res != 1:
                for row in res:
                    Constants.PRODUCT_INFO[row[1]] = {}
                    Constants.PRODUCT_INFO[row[1]]["PATTERN"] = row[2]
                    Constants.PRODUCT_INFO[row[1]]["TYPES"] = eval(row[3])
                    Constants.PRODUCT_INFO[row[1]]["CREATE_DATE"] = lambda ptr: row[4].format(*ptr)
                    Constants.PRODUCT_INFO[row[1]]["VARIABLE"] = row[5]
                    Constants.PRODUCT_INFO[row[1]]["STYLE"] = row[6]

                    Constants.PRODUCT_INFO[row[1]]["VALUE_RANGE"] = {
                        "low": row[8],
                        "mid": row[9],
                        "high": row[10]
                    }
                    Constants.PRODUCT_INFO[row[1]]["EXTRACTED_DATES"] = row[11]

        except:
            print("Unable to load configuration file!")
            raise RuntimeError

    @staticmethod
    def getImageProduct(img):
        for product in Constants.PRODUCT_INFO:
            expr = re.compile(Constants.PRODUCT_INFO[product]["PATTERN"])
            if (expr.match(img)):
                date = expr.findall(img)
                return [product, Constants.PRODUCT_INFO[product], Constants.PRODUCT_INFO[product]["CREATE_DATE"](date[0])]



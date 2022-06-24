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
import copy
import copyreg, re, types
from Libs.ConfigurationParser import ConfigurationParser

class ProductInfo:
    def __init__(self, row):
        self.productNames = row[0]
        self.productType = row[1]
        self.id = row[2]
        self.pattern = row[3]
        self.types = eval(row[4])
        self._dateptr = row[5]
        self.variable = row[6]
        self.style = row[7]
        self.valueRange = {
            "low": row[9],
            "mid": row[10],
            "high": row[11]
        }
        self.novalColorRamp = row[12]
        self.sparsevalColorRamp = row[13]
        self.midvalColorRamp = row[14]
        self.highvalColorRamp = row[15]
        self.minValue = row[16]
        self.maxValue = row[17]
        self.fileNameCreationPattern = row[19]

    def createDate(self, ptr):
        return self._dateptr.format(*ptr)



class Constants:
    PRODUCT_INFO={}

    @staticmethod
    def load(cfg):
        try:
            _cfg = ConfigurationParser(cfg)
            _cfg.parse()
            query = """
            SELECT p.name, p.type, pfd.*
            FROM {0}.product p 
            LEFT JOIN {0}.product_file_description pfd on p.id = pfd.product_id 
            WHERE (pfd.pattern LIKE '%.nc' OR pfd.pattern LIKE '%.tif') AND p.id IN(1,3,4) ORDER BY p.id""".format(_cfg.statsInfo.schema)
            res = _cfg.pgConnections[_cfg.statsInfo.connectionId].getIteratableResult(query)
            if res != 1:
                for row in res:
                    key = copy.deepcopy(row[2])
                    Constants.PRODUCT_INFO[row[2]] = ProductInfo(row)
        except:
            print("Unable to load configuration file!")
            raise RuntimeError

    @staticmethod
    def getImageProduct(img):
        for product in Constants.PRODUCT_INFO:
            expr = re.compile(Constants.PRODUCT_INFO[product].pattern)
            if (expr.match(img)):
                date = expr.findall(img)
                return [product, Constants.PRODUCT_INFO[product], Constants.PRODUCT_INFO[product].createDate(date[0])]



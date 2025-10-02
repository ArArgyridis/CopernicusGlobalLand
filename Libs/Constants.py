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
import os.path

from Libs.ConfigurationParser import ConfigurationParser

class ProductVariable:
    def __init__(self, row):
        self.id = row["id"]
        self.variable = row["variable"]
        self.style = row["style"]
        self.description = row["description"]
        self.valueRange = {
            "low": row["low_value"],
            "mid": row["mid_value"],
            "high": row["high_value"]
        }
        self.novalColorRamp = row["noval_colors"]
        self.sparsevalColorRamp = row["sparseval_colors"]
        self.midvalColorRamp = row["midval_colors"]
        self.highvalColorRamp = row["highval_colors"]
        self.minProdValue = row["min_prod_value"]
        self.maxProdValue = row["max_prod_value"]
        self.histogramBins = row["histogram_bins"]
        self.minValue = row["min_value"]
        self.maxValue = row["max_value"]

class ProductInfo:
    def __init__(self, row, cfg):
        self.productNames = row[0]
        self.productType = row[1]
        self.id = row[2]
        self.patterns = row[3]
        self.types = eval(row[4])
        self._dateptr = row[5]
        self.fileNameCreationPattern = row[6]
        self.rtFlag = row[7]
        self.satelliteSystemPattern = row[8]
        self.versionPattern = row[9]
        self.firstProductPath = row[10]
        self.variables = {}
        if isinstance(row[11], list):
            for ptrn in row[11]:
                self.variables[ptrn["variable"] ] = ProductVariable(ptrn)


    def createDate(self, ptr):
        return self._dateptr.format(*ptr)

    def getFileNameInfo(self, flName):
        results = []
        ptrId = 0

        if os.path.splitext(flName)[1] != os.path.splitext(self.patterns[0])[1]:
            return None

        while ptrId < len(self.patterns) and len(results) == 0:
            xpr = re.compile(self.patterns[ptrId])
            results = xpr.findall(flName)
            ptrId += 1

        if len(results) == 0:
            return None

        return results[0]

class Constants:
    PRODUCT_INFO={}

    @staticmethod
    def load(cfg):
        try:
            _cfg = ConfigurationParser(cfg)
            _cfg.parse()
            query = """WITH anomalies AS NOT MATERIALIZED (
                    SELECT ltai.raw_product_variable_id, ARRAY_TO_JSON((ARRAY_AGG(ltai.anomaly_product_variable_id)))::jsonb anomalies
                    FROM long_term_anomaly_info ltai
                    GROUP BY ltai.raw_product_variable_id
                ),product_variables as not MATERIALIZED(
                    SELECT pfv.product_file_description_id ,
                    CASE WHEN anom.anomalies IS NOT NULL THEN  array_to_json(ARRAY_AGG(row_to_json(pfv.*)::jsonb|| jsonb_build_object('anomalies',anom.anomalies)))
                    ELSE array_to_json(ARRAY_AGG(row_to_json(pfv.*)))
                    END product_variables
                    FROM product_file_variable pfv
                    LEFT JOIN anomalies anom ON pfv.id = anom.raw_product_variable_id
                    GROUP BY pfv.product_file_description_id,anom.anomalies
                )
                SELECT p.name, p.type, pfd.id, pfd.pattern, pfd."types", pfd.create_date, pfd.file_name_creation_pattern, pfd.rt_flag_pattern, 
                pfd.satellite_system_pattern, pfd.version_pattern,
                productPath.rel_file_path,
                pv.product_variables
                FROM product p
                LEFT JOIN product_file_description pfd on p.id = pfd.product_id --AND pfd.id = 1
                LEFT JOIN product_variables pv on pv.product_file_description_id = pfd.id
                LEFT JOIN LATERAL (
                    SELECT rel_file_path
                    FROM product_file pf
                    WHERE pf.product_file_description_id = pfd.id
                    ORDER BY pf.id
                    LIMIT 1
                ) productPath ON TRUE
                WHERE pfd.pattern is not NULL"""
            if _cfg.enabledProductIds is not None:
                query += " AND p.id IN (" + ",".join([str(id) for id in _cfg.enabledProductIds]) +")"

            query += """ ORDER BY p.id""".format(_cfg.statsInfo.schema)
            res = _cfg.pgConnections[_cfg.statsInfo.connectionId].getIteratableResult(query)

            #print(query)
            if res != 1:
                for row in res:
                    key = copy.deepcopy(row[2])
                    Constants.PRODUCT_INFO[row[2]] = ProductInfo(row, _cfg)
            res = None

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



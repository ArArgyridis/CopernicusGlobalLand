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

import json,os,sys
sys.path.extend(['../../'])
from Libs.ConfigurationParser import ConfigurationParser
from Libs.GenericRequest import GenericRequest
from PointValueExtractor import PointValueExtractor
from osgeo import osr

class StatsRequests(GenericRequest):
    def __init__(self, cfg="../../active_config.json", requestData=None):
        super().__init__(cfg, ConfigurationParser, requestData)

    def __getResponseFromDB(self, query):
        ret = self._config.pgConnections[self._config.statsInfo.connectionId].fetchQueryResult(query)
        if isinstance(ret, list):
            ret = ret[0][0]
        return ret

    def fetchStatsByPolygonAndDateRange(self):
        query = """
        SELECT ARRAY_TO_JSON (ARRAY_AGG(JSON_BUILD_ARRAY( pf.date, ps.{0}) ORDER BY pf.date))
        FROM {1}.poly_stats ps 
        JOIN {1}.product_file pf ON ps.product_file_id = pf.id
        JOIN {1}.product_file_description pfd ON pf.product_description_id = pfd.id
        WHERE ps.poly_id = {2} AND pfd.product_id ={3} AND pf.date BETWEEN '{4}' AND '{5}'
        """.format(self._requestData["options"]["area_type"], self._config.statsInfo.schema, self._requestData["options"]["poly_id"],
                   self._requestData["options"]["product_id"], self._requestData["options"]["date_start"],
                   self._requestData["options"]["date_end"])
        return self.__getResponseFromDB(query)

    def __fetchProductInfo(self):
        query = """
        WITH dt AS( 
        	SELECT distinct p.id, p.name, pfd.description pdescription, pf."date",  s.description sdescription 
	        FROM {0}.poly_stats ps 
	        JOIN {0}.stratification_geom sg ON ps.poly_id = sg.id
	        JOIN {0}.stratification s ON sg.stratification_id = s.id
	        JOIN {0}.product_file pf ON ps.product_file_id = pf.id
                JOIN {0}.product_file_description pfd on pf.product_description_id  = pfd.id
                JOIN {0}.product p ON pfd.product_id = p.id
	        WHERE pf."date" between '{1}' and '{2}'
        )
        SELECT  ARRAY_TO_JSON(ARRAY_AGG(JSON_build_object('id', a.id, 'name', a.name, 'description', 
        a.pdescription, 'dates', a.res)ORDER BY NAME)) 
        FROM(
	        SELECT a.id, a.name, a.pdescription, JSON_OBJECT_AGG(a.date, avail_strats) res 
	        FROM ( 
		        SELECT dt.id, dt.name, dt.pdescription, dt.date, 
		        ARRAY_TO_JSON(array_agg(dt.sdescription order by dt.sdescription)) avail_strats 
		        FROM dt
		        GROUP BY dt.id, dt.name, dt.pdescription, dt.date
	        )a
	        GROUP BY a.id, a.name, a.pdescription
        ) a""".format(self._config.statsInfo.schema, self._requestData["options"]["dateStart"],
              self._requestData["options"]["dateEnd"])

        return self.__getResponseFromDB(query)

    def __fetchStratificationInfo(self):
        query = """
        WITH dt as(
	        SELECT DISTINCT s.*, pf."date", p.name
	        FROM {0}.poly_stats ps 
	        JOIN {0}.stratification_geom sg ON ps.poly_id = sg.id
	        JOIN {0}.stratification s ON sg.stratification_id = s.id
	        JOIN {0}.product_file pf ON ps.product_file_id = pf.id
	        join {0}.product_file_description pfd on pf.product_description_id = pfd.id
	        JOIN {0}.product p ON pfd.product_id = p.id
	        WHERE pf."date" between '{1}' and '{2}' and p.id = {3}
        )
        SELECT ARRAY_TO_JSON(ARRAY_AGG(
         json_build_object('id', a.id, 'name', a.description, 'url', a.tilelayer_url, 'dates', 
        a.res))) 
        FROM(
	        SELECT a.id, a.description, a.tilelayer_url, json_object_agg(a.date, avail_prods) res 
            	FROM ( 
		            SELECT dt.id, dt.description, dt.tilelayer_url, dt.date, 
		            ARRAY_TO_JSON(ARRAY_AGG(dt.name ORDER BY dt.name)) avail_prods 
		            FROM dt
		            GROUP BY dt.id, dt.description, dt.tilelayer_url, dt.date
	        )a
	        GROUP BY a.id, a.description, a.tilelayer_url
        ) a""".format(self._config.statsInfo.schema, self._requestData["options"]["dateStart"],
              self._requestData["options"]["dateEnd"], self._requestData["options"]["product_id"])

        return self.__getResponseFromDB(query)

    def __fetchStratificationDataByProductAndDate(self):
        query = """
        WITH sm AS(
	        SELECT poly_id, ps.id stat_id, ps.noval_area_ha+ps.sparse_area_ha+ps.mid_area_ha+ps.dense_area_ha sum_area
	        FROM  {0}.poly_stats ps 
	        JOIN  {0}.product_file pf ON ps.product_file_id = pf.id
	        JOIN  {0}.product_file_description pfd on pf.product_description_id = pfd.id
	        JOIN  {0}.product p ON pfd.product_id = p.id
	        JOIN  {0}.stratification_geom sg ON sg.id = ps.poly_id
	        JOIN  {0}.stratification s ON s.id = sg.stratification_id
        	WHERE pf.date = '{1}' and s.id ={2} and p.id = {3}
        )
        SELECT JSON_OBJECT_AGG(a.poly_id, res)
        FROM( 
            SELECT ps.poly_id, 
            json_build_object(
                'no_area_perc', round(ps.noval_area_ha/sum_area*100), 
                'noval_color', ps.noval_color::json,
                'sparse_area_perc', round(ps.sparse_area_ha/sum_area*100), 
                'sparseval_color', ps.sparseval_color::json,
                'mid_area_perc', round(ps.mid_area_ha/sum_area*100),
                'midval_color', ps.midval_color::json,
                'dense_area_perc', round(ps.dense_area_ha/sum_area*100),
                'highval_color', ps.highval_color::json
            ) res
            FROM  {0}.poly_stats ps 
            JOIN sm ON ps.poly_id = sm.poly_id and ps.id = sm.stat_id and sm.sum_area > 0
            ORDER BY poly_id
        )a;""".format(self._config.statsInfo.schema, self._requestData["options"]["date"],
                      self._requestData["options"]["stratification_id"], self._requestData["options"]["product_id"])

        return self.__getResponseFromDB(query)

    def __histogramDataByProductAndPolygon(self):
        print(self._requestData)
        query = """
            SELECT JSON_BUILD_OBJECT('histogram', histogram, 'low_value', pfd.min_prod_value , 'high_value', pfd.max_prod_value) 
            FROM {0}.poly_stats ps 
            JOIN {0}.product_file pf ON ps.product_file_id  = pf.id
            JOIN {0}.product_file_description pfd ON pf.product_description_id = pfd.id
            JOIN {0}.product p ON pfd.product_id = p.id
            WHERE p.id = {1} AND pf."date" = '{2}' AND ps.poly_id = {3}
        """.format(self._config.statsInfo.schema, self._requestData["options"]["product_id"],
                   self._requestData["options"]["date"], self._requestData["options"]["poly_id"])
        return self.__getResponseFromDB(query)

    def __getRawTimeSeriesDataForRegion(self):
        if self._config.filesystem.imageryPath[-1] != "/":
            self._config.filesystem.imageryPath += "/"

        query = """
            SELECT  pfd.variable
            ,JSON_OBJECT_AGG( '{0}'||rel_file_path, date ORDER BY date ASC)
            ,pfd.pattern
            ,pfd.types
            ,pfd.create_date
            FROM {1}.product_file pf 
            JOIN {1}.product_file_description pfd ON pf.product_description_id = pfd.id
            JOIN {1}.product p on pfd.product_id =p.id
            WHERE date between  '{2}' and '{3}' and product_id  = {4}
            GROUP BY pfd.variable, pfd.pattern,pfd.types,pfd.create_date
            HAVING pfd.variable != ''
        """.format(self._config.filesystem.imageryPath,
                   self._config.statsInfo.schema, self._requestData["options"]["date_start"],
                   self._requestData["options"]["date_end"], self._requestData["options"]["product_id"])
        data = self._config.pgConnections[self._config.statsInfo.connectionId].fetchQueryResult(query)

        obj = PointValueExtractor(data[0],
                                  self._requestData["options"]["coordinate"][0], self._requestData["options"]["coordinate"][1],
                                  self._requestData["options"]["epsg"])

        res = obj.process()
        return res

    def _processRequest(self):
        ret = None
        if self._requestData["request"] == "fetchhistogrambypolygonanddate":
            ret = self.__histogramDataByProductAndPolygon()
        elif self._requestData["request"] == "fetchstatsbypolygonanddaterange":
            ret = self.fetchStatsByPolygonAndDateRange()
        elif self._requestData["request"] == "fetchproductinfo":
            ret = self.__fetchProductInfo()
        elif self._requestData["request"] == "fetchstratificationinfo":
            ret = self.__fetchStratificationInfo()
        elif self._requestData["request"] == "fetchstratificationinfobyproductanddate":
            ret = self.__fetchStratificationDataByProductAndDate()
        elif self._requestData["request"] == "getrawtimeseriesdataforregion":
            ret = self.__getRawTimeSeriesDataForRegion()
        else:
            raise SystemError
        return ret
def main():
    cfg = "../../config.json"
    """
    req = {
        "request": "fetchstatsfordaterange",
        "options": {
            "date_start": "2019-01-01",
            "date_end": "2022-01-01",
            "poly_id": 10,
            "variable": "BioPar_NDVI300_V2_Global"
        }
    }
    """
    req = {
        "request": "getrawtimeseriesdataforregion",
        "options": {
            "date_start": "2020-01-01",
            "date_end": "2021-12-31",
            "product_id": 1,
            "epsg":"EPSG:3857",
            "coordinate":[ 6883079.514636854, 7063087.438264163]
        }
    }


    obj = StatsRequests(cfg, req)
    print(obj.process())




if __name__ == "__main__":
    main()


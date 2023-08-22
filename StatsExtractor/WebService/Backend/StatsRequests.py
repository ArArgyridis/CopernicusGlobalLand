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
sys.path.extend(['../../../'])
from Libs.ConfigurationParser import ConfigurationParser
from Libs.GenericRequest import GenericRequest
from PointValueExtractor import PointValueExtractor
from osgeo import osr
from multiprocessing import Process, Queue
from datetime import datetime

def productStats(cfg, query, path, requestData, queue, key):
    data = cfg.pgConnections[cfg.statsInfo.connectionId].fetchQueryResult(query)
    res = None
    if len(data) == 0:
        queue.put({key: res})
        return
    
    obj = PointValueExtractor(data[0],
                                  requestData["options"]["coordinate"][0], requestData["options"]["coordinate"][1],
                                  requestData["options"]["epsg"])
    res =  obj.process()
    #res = None
    queue.put({key: res})

class StatsRequests(GenericRequest):
    def __init__(self, cfg="../../active_config.json", requestData=None):
        super().__init__(cfg, ConfigurationParser, requestData)

    def __getResponseFromDB(self, query):
        ret = self._config.pgConnections[self._config.statsInfo.connectionId].fetchQueryResult(query)
        if isinstance(ret, list):
            ret = ret[0][0]
        return ret
    
    def __fetchCategories(self):
        query = """SELECT ARRAY_TO_JSON(ARRAY_AGG(c.* ORDER BY c.id)) response FROM category c;"""
        return self.__getResponseFromDB(query)
    
    def __fetchDashboard(self):
        query =  """
	    WITH geom AS(
		SELECT st_asgeojson(geom3857)::json geom, description, stratification_id
		FROM stratification_geom sg 
		WHERE id = {0}
	),timeline AS(
		SELECT json_object_agg(pf."date", ARRAY_TO_JSON(ARRAY[noval_area_ha, sparse_area_ha, mid_area_ha, dense_area_ha])ORDER BY pf."date" DESC) tml
		FROM poly_stats ps
		JOIN product_file_variable pfv ON ps.product_file_variable_id = pfv.id
		JOIN product_file pf ON ps.product_file_id =pf.id 
                JOIN product_file_description pfd ON pf.product_file_description_id = pfd.id AND pfv.product_file_description_id = pfd.id
		WHERE  ps.poly_id={0} AND pfv.id = {1}
	)
	SELECT json_build_object(
	'type', 'Feature',
	'geometry', geom.geom,
	'properties', json_build_object('timeline', tml, 'description', geom.description, 'strata', s.description))
	FROM geom
	JOIN timeline ON true 
	JOIN stratification s ON geom.stratification_id = s.id
	""".format(self._requestData["options"]["poly_id"], self._requestData["options"]["product_id"])
        return self.__getResponseFromDB(query)

    def __fetchProductInfo(self):
        query = """
             WITH dt AS( 
        	SELECT pfd.id,  p.name[1], p.description, product_file_description_id, CASE WHEN pfd.rt_flag_pattern IS NOT NULL THEN TRUE ELSE FALSE END has_rt,
        	ARRAY_TO_JSON(ARRAY_AGG(row_to_json(pfv.*)::jsonb || jsonb_build_object('anomaly_info', anomaly_info.anomaly_info) ORDER BY pfv.description)) variables
	        FROM product p 
        	JOIN product_file_description pfd ON p.id = pfd.product_id AND p.id != 10
        	JOIN product_file_variable pfv ON pfd.id = pfv.product_file_description_id
        	JOIN LATERAL (
        		SELECT ARRAY_TO_JSON(ARRAY_AGG( jsonb_build_object('name', panom.name[1]) || row_to_json(anompfv.*)::jsonb ))  anomaly_info
        		FROM long_term_anomaly_info ltai
        		JOIN product_file_variable anompfv ON ltai.anomaly_product_variable_id  = anompfv.id
        		JOIN product_file_description pfdanom ON anompfv.product_file_description_id = pfdanom.id
        		JOIN product panom ON pfdanom.product_id = panom.id
        		JOIN product_file pfanom ON pfanom.product_file_description_id = pfdanom.id
        		WHERE ltai.raw_product_variable_id = pfv.id 
        		ORDER BY pfv.id LIMIT 1 
        	) anomaly_info ON TRUE    	
        	WHERE p.category_id = {0} AND p."type"='raw' 
        	GROUP BY p.id,  p.name[1], p.description, pfd.id, pfv.product_file_description_id
        ),dates AS(
        	SELECT id, json_object_agg(rt_flag, dates)dates FROM (
        		SELECT id, rt_flag, ARRAY_TO_JSON(ARRAY_AGG("date" order by "date" desc) )::jsonb dates FROM(
        			SELECT dt.id, pf.date, CASE WHEN pf.rt_flag IS NULL THEN -1 ELSE pf.rt_flag END rt_flag --ARRAY_TO_JSON(ARRAY_AGG("date" order by "date" desc) )::jsonb dates
        			FROM dt 
        			JOIN product_file pf ON dt.product_file_description_id = pf.product_file_description_id
        			WHERE pf."date" BETWEEN '{1}' AND '{2}'        	
        		)a
        		GROUP BY a.id, a.rt_flag
        	)b
                GROUP BY b.id
        )
        SELECT ARRAY_TO_JSON(ARRAY_AGG(json_build_object('id', dt.id, 'name', name, 'description', dt.description, 'rt', dt.has_rt, 'dates', dates.dates, 'variables', dt.variables) ORDER BY dt.description))
        FROM dt        
        JOIN dates ON dt.id = dates.id
       """.format(self._requestData["options"]["category_id"], self._requestData["options"]["dateStart"], self._requestData["options"]["dateEnd"])
        return self.__getResponseFromDB(query)

    def densityStatsByPolygonAndDateRange(self):
        query = """
        SELECT ARRAY_TO_JSON (ARRAY_AGG(JSON_BUILD_ARRAY( pf.date, ps.{0}) ORDER BY pf.date))
        FROM poly_stats ps 
        JOIN product_file_variable pfv ON ps.product_file_variable_id = pfv.id
        JOIN product_file pf ON ps.product_file_id = pf.id
        JOIN product_file_description pfd ON pf.product_file_description_id = pfd.id AND pfv.product_file_description_id = pfd.id
        WHERE ps.poly_id = {1} AND pfv.id ={2} AND pf.date BETWEEN '{3}' AND '{4}'
        """.format(self._requestData["options"]["area_type"], self._requestData["options"]["poly_id"],
                   self._requestData["options"]["product_variable_id"], self._requestData["options"]["date_start"],
                   self._requestData["options"]["date_end"])
        
        if self._requestData["options"]["rt_flag"] >=0:
            query += " AND pf.rt_flag = {0}".format(self._requestData["options"]["rt_flag"])

        return self.__getResponseFromDB(query)
    
    def polygonStatsTimeseries(self):
        query = """
            WITH dt AS NOT MATERIALIZED(
                SELECT pf."date", ps.mean , ps.sd ,psltai.mean meanlts, psltai.sd sdlts 
                FROM poly_stats ps 
                JOIN product_file_variable pfv ON ps.product_file_variable_id = pfv.id
                JOIN product_file pf ON ps.product_file_id = pf.id 
                JOIN product_file_description pfd ON pf.product_file_description_id = pfd.id AND pfv.product_file_description_id = pfd.id
                LEFT JOIN long_term_anomaly_info ltai ON pfv.id = ltai.raw_product_variable_id
                LEFT JOIN product_file_variable pfvltaimean ON ltai.mean_variable_id = pfvltaimean.id
                LEFT JOIN product_file_description pfdltaimean ON pfvltaimean.product_file_description_id = pfdltaimean.id
                LEFT JOIN product_file pfltaimean ON pfdltaimean.id = pfltaimean.product_file_description_id 
                and EXTRACT('doy' FROM pfltaimean."date") between EXTRACT('doy' FROM pf."date") - 2	and EXTRACT('doy' FROM pf."date") +2
                LEFT JOIN poly_stats psltai ON psltai.product_file_id = pfltaimean.id AND psltai.product_file_variable_id = pfvltaimean.id 
                AND psltai.poly_id = ps.poly_id
            WHERE ps.poly_id = {0} AND pf."date" BETWEEN '{1}' AND '{2}' AND pfv.id = {3} AND ps.valid_pixels > 0 
            AND ps.valid_pixels*1.0/ps.total_pixels >= 0.7""".format(self._requestData["options"]["poly_id"], self._requestData["options"]["date_start"], self._requestData["options"]["date_end"], self._requestData["options"]["product_variable_id"])
        
        if self._requestData["options"]["rt_flag"] >=0:
            query += " AND pf.rt_flag = {0}".format(self._requestData["options"]["rt_flag"])
        
        query += """)SELECT ARRAY_TO_JSON(ARRAY_AGG(JSON_BUILD_ARRAY(dt."date", dt.mean, dt.sd, dt.meanlts, dt.sdlts) ORDER BY dt."date")) FROM dt"""
        return self.__getResponseFromDB(query)
        
    def __fetchStratificationDataByProductAndDate(self):
        query = """
        SELECT ARRAY_TO_JSON(ARRAY_AGG(res) ) FROM(
            SELECT jsonb_build_object(
		'id', ps.poly_id,
                'meanval_color', ps.meanval_color::jsonb, 
		'noval_color', ps.noval_color::jsonb,
		'sparseval_color', ps.sparseval_color::jsonb,
		'midval_color', ps.midval_color::jsonb,
		'highval_color', ps.highval_color::jsonb
        ) res
        FROM  poly_stats ps 
        JOIN  product_file pf ON ps.product_file_id = pf.id
        JOIN product_file_variable pfv ON ps.product_file_variable_id = pfv.id
        JOIN  product_file_description pfd ON pf.product_file_description_id = pfd.id
        JOIN  product p ON pfd.product_id = p.id
        JOIN  stratification_geom sg ON sg.id = ps.poly_id
        JOIN  stratification s ON s.id = sg.stratification_id
        WHERE pf.date = '{0}' AND s.id = {1} AND pfv.id = {2} AND ps.valid_pixels > 0 AND ps.valid_pixels*1.0/ps.total_pixels > 0.7 """.format(self._requestData["options"]["date"],
                      self._requestData["options"]["stratification_id"], self._requestData["options"]["product_variable_id"])
        
        if  self._requestData["options"]["rt_flag"] >= 0:
            query += " AND pf.rt_flag = {0}".format(self._requestData["options"]["rt_flag"])
        
        query += ")a"; 
        
        return self.__getResponseFromDB(query)
    
    def __fetchStratificationInfo(self):
        query = """SELECT JSON_OBJECT_AGG(id, info) 
                          FROM( SELECT id, JSON_BUILD_OBJECT('id', id, 'description', description, 'url', tilelayer_url) info
                          FROM stratification s )a"""

        return self.__getResponseFromDB(query)
  
    def __getRawTimeSeriesDataForRegion(self):
        #determine the type of product
        path = self._config.filesystem.imageryPath
        query  = """SELECT type 
                            FROM product_file_description pfd 
                            JOIN product_file_variable pfv ON pfd.id = pfv.product_file_description_id
                            JOIN product p ON pfd.product_id = p.id 
                            WHERE pfv.id = {0}""".format(self._requestData["options"]["product_variable_id"])

        productType = self._config.pgConnections[self._config.statsInfo.connectionId].fetchQueryResult(query)[0][0]
        if productType == "anomaly":
            path = self._config.filesystem.anomalyProductsPath
        
        if path[-1] != "/":
            path += "/"
        
        result = Queue()
        
        query = """
            SELECT  CASE WHEN pfv.variable = ''::text THEN NULL ELSE  pfv.variable END
            ,JSON_OBJECT_AGG('{0}' || rel_file_path, date ORDER BY date ASC)
            ,pfd.pattern
            ,pfd.types
            ,pfd.create_date
            FROM product_file pf 
            JOIN product_file_description pfd ON pf.product_file_description_id = pfd.id
            JOIN product_file_variable pfv ON pfd.id = pfv.product_file_description_id
            JOIN product p on pfd.product_id =p.id
            WHERE date between  '{1}' and '{2}' and pfv.id  = {3}""".format(path, self._requestData["options"]["date_start"], self._requestData["options"]["date_end"], self._requestData["options"]["product_variable_id"])
            
        if  self._requestData["options"]["rt_flag"] >= 0:
            query += " AND pf.rt_flag = {0}".format(self._requestData["options"]["rt_flag"])
            
        query += """ GROUP BY pfv.variable, pfd.pattern,pfd.types,pfd.create_date"""
              
        threads = []
        
        threads.append(Process(target=productStats, args=(self._config, query, path, self._requestData, result, "product")))
        threads[-1].start()
        
        doyStart = datetime.strptime(self._requestData["options"]["date_start"], "%Y-%m-%dT%H:%M:%S.%fZ")
        doyStart = doyStart.utctimetuple().tm_yday
        
        doyEnd = datetime.strptime(self._requestData["options"]["date_end"], "%Y-%m-%dT%H:%M:%S.%fZ")
        doyEnd = doyEnd.utctimetuple().tm_yday
        
        mQuery = """
        SELECT pfvanom.variable meanVar
        ,JSON_OBJECT_AGG( '{0}' || pf.rel_file_path, pf.date ORDER BY pf.date ASC)
        ,pfd.pattern
        ,pfd.types
        ,pfd.create_date
        FROM product_file_variable pfv 
        JOIN long_term_anomaly_info ltai ON ltai.raw_product_variable_id = pfv.id
        
        --mean info
        JOIN product_file_variable pfvanom ON ltai.mean_variable_id = pfvanom.id
        JOIN product_file_description pfd ON pfvanom.product_file_description_id = pfd.id 
        JOIN product_file pf ON pf.product_file_description_id = pfd.id
        WHERE pfv.id = {1}
        GROUP BY pfvanom.variable,pfd.pattern ,pfd.types ,pfd.create_date
        """.format(path, self._requestData["options"]["product_variable_id"])

        threads.append(Process(target=productStats, args=(self._config, mQuery, path, self._requestData, result,  "mean")))
        threads[-1].start()
        
        stdevQuery = """
        SELECT pfvanom.variable meanVar
        ,JSON_OBJECT_AGG( '{0}' || pf.rel_file_path, pf.date ORDER BY pf.date ASC)
        ,pfd.pattern
        ,pfd.types
        ,pfd.create_date
        FROM product_file_variable pfv 
        JOIN long_term_anomaly_info ltai ON ltai.raw_product_variable_id = pfv.id
        
        --stdev info
        JOIN product_file_variable pfvanom ON ltai.stdev_variable_id = pfvanom.id
        JOIN product_file_description pfd ON pfvanom.product_file_description_id = pfd.id 
        JOIN product_file pf ON pf.product_file_description_id = pfd.id
        WHERE pfv.id = {1}
        GROUP BY pfvanom.variable,pfd.pattern ,pfd.types ,pfd.create_date
        """.format(path, self._requestData["options"]["product_variable_id"])
        
        threads.append(Process(target=productStats, args=(self._config, stdevQuery, path, self._requestData, result,  "stdev")))
        threads[-1].start()


        for trd in threads:
            trd.join()
    
        resultDict = {}
        #not working for some reason....
        #for tmp in iter(result.get, None):
        #    resultDict.update(tmp)
        resultDict.update(result.get())
        resultDict.update(result.get())
        resultDict.update(result.get())
        
        #converting mean and stdev dicts to doy        
        ltsStats = {}
        tmpDoys = []
        if productType == "raw" and resultDict["mean"] != None:
            for mn, sd in zip(resultDict["mean"]["raw"], resultDict["stdev"]["raw"]):
                doy = datetime.fromisoformat(mn[0])
                doy = doy.utctimetuple().tm_yday
                ltsStats[doy] = [mn[1], sd[1]]
            tmpDoys = ltsStats.keys()
            tmpDoys = list(tmpDoys)

        response = list(range(len(resultDict["product"]["raw"])))
        
        i = 0
        
        for row in resultDict["product"]["raw"]:
            doy = datetime.fromisoformat(row[0])
            doy = doy.utctimetuple().tm_yday
            stop = False
            response[i] = row[0:2]
            j = 0
            while not stop and j < len(tmpDoys):

                if abs(doy - tmpDoys[j]) < 4 :
                    response[i]+=ltsStats[tmpDoys[j] ]
                    stop = True
                j += 1
            i+=1

        return response
    
    def __histogramDataByProductAndPolygon(self):
        query = """
            SELECT JSON_BUILD_OBJECT('histogram', histogram, 'low_value', pfv.min_value , 'high_value', pfv.max_value) 
            FROM poly_stats ps 
            JOIN product_file_variable pfv ON ps.product_file_variable_id = pfv.id
            JOIN product_file pf ON ps.product_file_id  = pf.id
            JOIN product_file_description pfd ON pf.product_file_description_id = pfd.id AND pfv.product_file_description_id = pfd.id
            JOIN product p ON pfd.product_id = p.id
            WHERE pfv.id = {0} AND pf."date" = '{1}' AND ps.poly_id = {2}
        """.format(self._requestData["options"]["product_variable_id"],
                   self._requestData["options"]["date"], self._requestData["options"]["poly_id"])
        
        if self._requestData["options"]["rt_flag"] >=0:
            query += " AND pf.rt_flag = {0}".format(self._requestData["options"]["rt_flag"])
            
        return self.__getResponseFromDB(query)
    
    def __rankStrataByDensity(self):
        query = """
            SELECT ARRAY_TO_JSON(ARRAY_AGG((JSON_BUILD_OBJECT('id',ps.id, 'description',sg.description, 'area_ha',{0})) ORDER BY {0} DESC)) response
            FROM stratification_geom sg 
            JOIN poly_stats ps ON sg.id =ps.poly_id 
            JOIN product_file pf ON ps.product_file_id =pf.id
            JOIN product_file_description pfd ON pf.product_description_id = pfd.id
            JOIN product_file_variable pfv ON ps.product_file_variable_id = pfv.id
            WHERE sg.stratification_id = {1} AND pf.date='{2}'  AND pfv.id = {3} AND {0} IS NOT NULL""".format(self._requestData["options"]["density"],
                                                                                                                                  self._requestData["options"]["stratification_id"], self._requestData["options"]["date"], self._requestData["options"]["product_id"])
        return self.__getResponseFromDB(query)

    def __pieDataByDateAndPolygon(self):
        query = """
        SELECT row_to_json(a.*) response FROM(
            SELECT ps.noval_area_ha "No value", ps.sparse_area_ha "Sparse", ps.mid_area_ha "Mild", ps.dense_area_ha "Dense"
            FROM poly_stats ps
            JOIN product_file_variable pfv ON ps.product_file_variable_id = pfv.id
            JOIN product_file pf ON ps.product_file_id = pf.id  
            JOIN product_file_description pfd ON pf.product_file_description_id = pfd.id AND pfv.product_file_description_id = pfd.id
            JOIN product p ON pfd.product_id = p.id
            WHERE pfv.id = {0} AND pf."date" ='{1}' AND ps.poly_id = {2}
        """.format(self._requestData["options"]["product_variable_id"],self._requestData["options"]["date"], self._requestData["options"]["poly_id"])
        
        if  self._requestData["options"]["rt_flag"] >= 0:
            query += " AND pf.rt_flag = {0}".format(self._requestData["options"]["rt_flag"])
        query += ") a"
        
        return self.__getResponseFromDB(query)
    
    def polygonDescription(self):
        query = """SELECT json_build_object('description',sg.description, 'strata', s.description) response
                            FROM stratification_geom sg 
                            JOIN stratification s ON sg.stratification_id = s.id WHERE sg.id={0}
                        """.format(self._requestData["options"]["poly_id"])
        return self.__getResponseFromDB(query)
    
    def __productCog(self):
        query = """
        SELECT JSON_OBJECT_AGG(pf.date, wf.rel_file_path)
        FROM product_file pf
        JOIN wms_file wf ON pf.id = wf.product_file_id AND pf.product_file_description_id = {0} AND wf.product_file_variable_id  ={1}
        WHERE pf.date BETWEEN '{2}' AND '{3}' AND {4}= CASE WHEN pf.rt_flag IS NULL THEN -1 ELSE pf.rt_flag END """.format(self._requestData["options"]["product_id"], self._requestData["options"]["product_variable_id"], self._requestData["options"]["date_start"], self._requestData["options"]["date_end"], self._requestData["options"]["rt_flag"])
        return self.__getResponseFromDB(query)

    def _processRequest(self):
        ret = None
        if self._requestData["request"] == "cropbystrata":
            print("Not implemented yet....")
        elif self._requestData["request"] == "categories":
            ret = self.__fetchCategories()
        elif self._requestData["request"] == "dashboard":
            ret = self.__fetchDashboard()
        elif self._requestData["request"] == "densityStatsByPolygonAndDateRange":
            ret = self.densityStatsByPolygonAndDateRange()
        elif self._requestData["request"] == "histogrambypolygonanddate":
            ret = self.__histogramDataByProductAndPolygon()
        elif self._requestData["request"] == "polygonDescription":
            ret = self.polygonDescription()
        elif self._requestData["request"] == "polygonStatsTimeseries":
            ret = self.polygonStatsTimeseries()
        elif self._requestData["request"] == "productinfo":
            ret = self.__fetchProductInfo()
        elif self._requestData["request"] == "productcog":
            ret = self.__productCog()
        elif self._requestData["request"] == "rankstratabydensity":
            ret = self.__rankStrataByDensity()
        elif self._requestData["request"] == "stratificationinfo":
            ret = self.__fetchStratificationInfo()
        elif self._requestData["request"] == "stratificationinfobyproductanddate":
            ret = self.__fetchStratificationDataByProductAndDate()
        elif self._requestData["request"] == "rawtimeseriesdataforregion":
            ret = self.__getRawTimeSeriesDataForRegion()
        elif self._requestData["request"] == "piedatabydateandpolygon":
            ret = self.__pieDataByDateAndPolygon()
        else:
            raise SystemError
        return ret


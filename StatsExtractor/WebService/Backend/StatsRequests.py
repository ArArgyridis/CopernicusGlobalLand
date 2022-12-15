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
		FROM {0}.stratification_geom sg 
		WHERE id = {1}
	),timeline AS(
		SELECT json_object_agg(pf."date", ARRAY_TO_JSON(ARRAY[noval_area_ha, sparse_area_ha, mid_area_ha, dense_area_ha])ORDER BY pf."date" DESC) tml
		FROM {0}.poly_stats ps
		JOIN {0}.product_file pf ON ps.product_file_id =pf.id 
                JOIN {0}.product_file_description pfd on pf.product_description_id = pfd.id
		WHERE pfd.product_id = {2} AND ps.poly_id={1}
	)
	SELECT json_build_object(
	'type', 'Feature',
	'geometry', geom.geom,
	'properties', json_build_object('timeline', tml, 'description', geom.description, 'strata', s.description))
	FROM geom
	JOIN timeline ON true 
	JOIN {0}.stratification s ON geom.stratification_id = s.id
	""".format(self._config.statsInfo.schema, self._requestData["options"]["poly_id"], self._requestData["options"]["product_id"])
        return self.__getResponseFromDB(query)

    def __fetchProductInfo(self):
        query = """
            WITH dt AS( 
        	SELECT distinct p.id, p.name[1], pf.product_description_id , pfd.description pdescription, ARRAY[pfd.min_value, pfd.low_value, pfd.mid_value, pfd.high_value, pfd.max_value] value_ranges,
        	noval_colors, sparseval_colors, midval_colors, highval_colors,style,
        	anomaly_info.anomaly_info
	        FROM product_file pf 
                JOIN product_file_description pfd on pf.product_description_id  = pfd.id
                JOIN product p ON pfd.product_id = p.id
                JOIN(
                	SELECT ltai.current_product_description_id raw_product_id, (ARRAY_TO_JSON(ARRAY_AGG(JSON_BUILD_OBJECT('id', p.id, 'description', pfd.description, 'key', p.name[1], 'stylesld', pfd.style, 'value_ranges', ARRAY[pfd.min_value, pfd.low_value, pfd.mid_value, pfd.high_value, pfd.max_value]) ORDER BY pfd.id )))::jsonb anomaly_info
                	FROM   long_term_anomaly_info ltai
                	JOIN product_file_description pfd ON ltai.anomaly_product_description_id = pfd.id
                	JOIN   product p ON pfd.product_id = p.id
                	GROUP BY  ltai.current_product_description_id            
                ) anomaly_info ON p.id = anomaly_info.raw_product_id
	        WHERE  p.category_id = {0} and (pfd.variable is not null or p."type" ='anomaly')
            ),dates AS(
        	SELECT dt.id, ARRAY_TO_JSON(array_agg("date" order by "date" desc) ) dates
        	FROM dt 
        	JOIN product_file pf ON dt.product_description_id = pf.product_description_id
        	where pf."date" between '{1}' and '{2}'        	
        	GROUP BY dt.id
        )
        SELECT  ARRAY_TO_JSON(ARRAY_AGG(JSON_build_object('id', dt.id, 'name', dt.name, 'description',  dt.pdescription, 'dates', dates.dates, 'value_ranges',dt.value_ranges, 'anomaly_info', dt.anomaly_info, 'stylesld', style,
        'noval_colors', noval_colors, 'sparseval_colors', sparseval_colors, 'midval_colors', midval_colors, 'highval_colors', highval_colors) ORDER BY name)) info
        FROM dt JOIN dates ON dt.id = dates.id""".format(self._requestData["options"]["category_id"], self._requestData["options"]["dateStart"], self._requestData["options"]["dateEnd"])
        return self.__getResponseFromDB(query)

    def densityStatsByPolygonAndDateRange(self):
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
    
    def polygonStatsTimeseries(self):
        query = """
            WITH dt AS NOT MATERIALIZED(
                SELECT pf."date", ps.mean , ps.sd ,psltai.mean meanlts, psltai.sd sdlts 
                FROM poly_stats ps 
                JOIN product_file pf ON ps.product_file_id = pf.id 
                JOIN product_file_description pfd ON pf.product_description_id = pfd.id
                LEFT JOIN long_term_anomaly_info ltai ON pfd.id = ltai.current_product_description_id 
                LEFT JOIN product_file_description pfdltai ON ltai.statistics_product_description_id = pfdltai.id 
                LEFT JOIN product_file pfltai ON pfdltai.id = pfltai.product_description_id and EXTRACT('doy' FROM pfltai."date") between EXTRACT('doy' FROM pf."date") - 2	and EXTRACT('doy' FROM pf."date") +2
                LEFT JOIN poly_stats psltai ON pfltai.id = psltai.product_file_id AND ps.poly_id = psltai.poly_id  
            WHERE ps.poly_id = {0} AND pf."date" BETWEEN '{1}' AND '{2}' AND pfd.product_id = {3} AND ps.valid_pixels > 0 AND ps.valid_pixels*1.0/ps.total_pixels >= 0.7)
            SELECT ARRAY_TO_JSON(ARRAY_AGG(JSON_BUILD_ARRAY(dt."date", dt.mean, dt.sd, dt.meanlts, dt.sdlts) ORDER BY dt."date"))
            FROM dt""".format(self._requestData["options"]["poly_id"], self._requestData["options"]["date_start"], self._requestData["options"]["date_end"], self._requestData["options"]["product_id"])
        print(query)
        return self.__getResponseFromDB(query)
        
    def __fetchStratificationDataByProductAndDate(self):
        query = """
        SELECT ps.poly_id, 
	jsonb_build_object(
		'meanval_color', ps.meanval_color::jsonb, 
		'no_area_perc', round(ps.noval_area_ha/(ps.noval_area_ha+ps.sparse_area_ha+ps.mid_area_ha+ps.dense_area_ha)*100), 
		'noval_color', ps.noval_color::jsonb,
		'sparse_area_perc', round(ps.sparse_area_ha/(ps.noval_area_ha+ps.sparse_area_ha+ps.mid_area_ha+ps.dense_area_ha)*100), 
		'sparseval_color', ps.sparseval_color::jsonb,
		'mid_area_perc', round(ps.mid_area_ha/(ps.noval_area_ha+ps.sparse_area_ha+ps.mid_area_ha+ps.dense_area_ha)*100),
		'midval_color', ps.midval_color::jsonb,
		'dense_area_perc', round(ps.dense_area_ha/(ps.noval_area_ha+ps.sparse_area_ha+ps.mid_area_ha+ps.dense_area_ha)*100),
		'highval_color', ps.highval_color::jsonb
     ) res
     FROM  poly_stats ps 
     JOIN  product_file pf ON ps.product_file_id = pf.id
     JOIN  product_file_description pfd ON pf.product_description_id = pfd.id
    JOIN  product p ON pfd.product_id = p.id
    JOIN  stratification_geom sg ON sg.id = ps.poly_id
    JOIN  stratification s ON s.id = sg.stratification_id
    WHERE pf.date = '{0}' and s.id = {1} and p.id = {2} and ps.valid_pixels > 0 and ps.valid_pixels*1.0/ps.total_pixels > 0.7""".format(self._requestData["options"]["date"],
                      self._requestData["options"]["stratification_id"], self._requestData["options"]["product_id"])
        res = self._config.pgConnections[self._config.statsInfo.connectionId].fetchQueryResult(query)
        ret = {}
        for row in res:
            ret[row[0]]=row[1]
        return ret
    
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
                            JOIN product p ON pfd.product_id = p.id 
                            WHERE p.id = {0}""".format(self._requestData["options"]["product_id"])

        productType = self._config.pgConnections[self._config.statsInfo.connectionId].fetchQueryResult(query)[0][0]
        if productType == "anomaly":
            path = self._config.filesystem.anomalyProductsPath
        
        if path[-1] != "/":
            path += "/"
        
        result = Queue()
        
        query = """
            SELECT  pfd.variable
            ,JSON_OBJECT_AGG('{0}' || rel_file_path, date ORDER BY date ASC)
            ,pfd.pattern
            ,pfd.types
            ,pfd.create_date
            FROM product_file pf 
            JOIN product_file_description pfd ON pf.product_description_id = pfd.id
            JOIN product p on pfd.product_id =p.id
            WHERE date between  '{1}' and '{2}' and p.id  = {3} AND (pfd.variable IS NOT null or p."type"='anomaly')
            GROUP BY pfd.variable, pfd.pattern,pfd.types,pfd.create_date""".format(path, self._requestData["options"]["date_start"], self._requestData["options"]["date_end"], self._requestData["options"]["product_id"])
        
        threads = []
        
        threads.append(Process(target=productStats, args=(self._config, query, path, self._requestData, result, "product")))
        threads[-1].start()
        
        doyStart = datetime.strptime(self._requestData["options"]["date_start"], "%Y-%m-%dT%H:%M:%S.%fZ")
        doyStart = doyStart.utctimetuple().tm_yday
        
        doyEnd = datetime.strptime(self._requestData["options"]["date_end"], "%Y-%m-%dT%H:%M:%S.%fZ")
        doyEnd = doyEnd.utctimetuple().tm_yday
        
        for var in ["mean", "stdev"]:
            queryLTS = """
                SELECT '{0}' 
                ,JSON_OBJECT_AGG('{1}' || rel_file_path, date ORDER BY date ASC)
                ,pfd.pattern
                ,pfd.types
                ,pfd.create_date
                FROM product_file pf 
                JOIN product_file_description pfd ON pf.product_description_id = pfd.id
                JOIN long_term_anomaly_info ltai ON pfd.id = ltai.statistics_product_description_id
                JOIN product_file_description pfdprod ON ltai.current_product_description_id =pfdprod.id
                JOIN product p ON pfdprod.product_id = p.id
                WHERE p.id = {4} AND pfd.variable IS NOT NULL
                GROUP BY pfd.variable, pfd.pattern,pfd.types,pfd.create_date""".format(var, path, doyStart, doyEnd, self._requestData["options"]["product_id"])

            threads.append(Process(target=productStats, args=(self._config, queryLTS, path, self._requestData, result,  var)))
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
        if productType == "raw":
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
            SELECT JSON_BUILD_OBJECT('histogram', histogram, 'low_value', pfd.min_prod_value , 'high_value', pfd.max_prod_value) 
            FROM {0}.poly_stats ps 
            JOIN {0}.product_file pf ON ps.product_file_id  = pf.id
            JOIN {0}.product_file_description pfd ON pf.product_description_id = pfd.id
            JOIN {0}.product p ON pfd.product_id = p.id
            WHERE p.id = {1} AND pf."date" = '{2}' AND ps.poly_id = {3}
        """.format(self._config.statsInfo.schema, self._requestData["options"]["product_id"],
                   self._requestData["options"]["date"], self._requestData["options"]["poly_id"])
        return self.__getResponseFromDB(query)
    
    def __rankStrataByDensity(self):
        query = """
            SELECT ARRAY_TO_JSON(ARRAY_AGG((JSON_BUILD_OBJECT('id',ps.id, 'description',sg.description, 'area_ha',{0})) ORDER BY {0} DESC)) response
            FROM stratification_geom sg 
            JOIN poly_stats ps ON sg.id =ps.poly_id 
            JOIN product_file pf ON ps.product_file_id =pf.id
            WHERE sg.stratification_id = {1} AND pf.date='{2}'  AND pf.product_description_id = {3} AND {0} IS NOT NULL""".format(self._requestData["options"]["density"],
                                                                                                                                  self._requestData["options"]["stratification_id"], self._requestData["options"]["date"], self._requestData["options"]["product_id"])
        return self.__getResponseFromDB(query)

    def __pieDataByDateAndPolygon(self):
        query = """
        SELECT row_to_json(a.*) response FROM(
        SELECT ps.noval_area_ha "No value", ps.sparse_area_ha "Sparse", ps.mid_area_ha "Mild", ps.dense_area_ha "Dense"
        FROM poly_stats ps
        JOIN product_file pf ON ps.product_file_id = pf.id  
        JOIN product_file_description pfd ON pf.product_description_id = pfd.id
        JOIN product p ON pfd.product_id = p.id
        WHERE p.id = {0} AND pf."date" ='{1}' AND ps.poly_id = {2})a
        """.format(self._requestData["options"]["product_id"],self._requestData["options"]["date"], self._requestData["options"]["poly_id"])
        return self.__getResponseFromDB(query)
    
    def polygonDescription(self):
        query = """SELECT json_build_object('description',sg.description, 'strata', s.description) response
                            FROM stratification_geom sg 
                            JOIN stratification s ON sg.stratification_id = s.id WHERE sg.id={0}
                        """.format(self._requestData["options"]["poly_id"])
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

if __name__ == "__main__":
    productId = 1
    polyId = 8
    date = '2021-08-21'
    cfg="../../active_config.json"
    
    from Libs.ConfigurationParser import ConfigurationParser
    _config = ConfigurationParser(cfg)
    _config.parse()

    query = """
    with img AS(
        SELECT rel_file_path from product_file pf     WHERE product_description_id = {0} and date='{1}'
    ),  geom AS(
        SELECT id, st_astext(geom), st_srid(geom) FROM stratification_geom WHERE id = {2}
    )SELECT * 
    FROM img 
    JOIN geom ON true""".format(productId, date, polyId)

    dt = _config.pgConnections[_config.statsInfo.connectionId].fetchQueryResult(query)
    if len(dt) > 0:
        dt = dt[0]
        from osgeo import ogr
        defn = ogr.FeatureDefn()
        defn.SetGeomType(ogr.wkbMultiPolygon)
        dstSRS = osr.SpatialReference()
        dstSRS.ImportFromEPSG(dt[3])

        geom = ogr.CreateGeometryFromWkt(dt[2], dstSRS)
        ft = ogr.Feature(defn)

        ft.SetGeometry(geom)
        ft.SetFID(dt[1])

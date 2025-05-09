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

from concurrent.futures import ProcessPoolExecutor
from datetime import datetime
import numpy as np
from osgeo import osr
from operator import itemgetter

def productStats(imageInfo, requestData):
    obj = PointValueExtractor([imageInfo],
                                  requestData["options"]["coordinate"][0], requestData["options"]["coordinate"][1],
                                  requestData["options"]["epsg"])
    return (imageInfo[0], obj.process())


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
        	ARRAY_TO_JSON(ARRAY_AGG(row_to_json(pfv.*)::jsonb || jsonb_build_object('anomaly_info', anomaly_info.anomaly_info) ORDER BY pfv.id)) variables
	        FROM product p
        	JOIN product_file_description pfd ON p.id = pfd.product_id
        	JOIN product_file_variable pfv ON pfd.id = pfv.product_file_description_id
        	JOIN LATERAL (
        		SELECT ARRAY_TO_JSON(ARRAY_AGG( jsonb_build_object( 'id', pfdanom.id, 'name', panom.name[1] , 'variable', row_to_json(anompfv.*)::jsonb)))  anomaly_info
        		FROM long_term_anomaly_info ltai
        		JOIN product_file_variable anompfv ON ltai.anomaly_product_variable_id  = anompfv.id
        		JOIN product_file_description pfdanom ON anompfv.product_file_description_id = pfdanom.id
        		JOIN product panom ON pfdanom.product_id = panom.id
        		WHERE ltai.raw_product_variable_id = pfv.id
        		ORDER BY pfv.id LIMIT 1
        	) anomaly_info ON TRUE
        	WHERE p.category_id = {0} AND p."type"='raw'
        	GROUP BY p.id,  p.name[1], p.description, pfd.id, pfv.product_file_description_id
        ),dates AS(
        	SELECT id, json_object_agg(rt_flag, dates)dates FROM (
        		SELECT id, rt_flag, ARRAY_TO_JSON(ARRAY_AGG("date" order by "date" desc) )::jsonb dates FROM(
        			SELECT dt.id, pf.date, CASE WHEN pf.rt_flag IS NULL THEN -1 ELSE pf.rt_flag END rt_flag
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
                SELECT pf."date", ROUND(ps.mean::numeric,4) mean, ROUND(ps.sd::numeric,5) sd, ROUND(psltai.mean::numeric,4) meanlts, ROUND(psltai.sd::numeric,5) sdlts
                FROM poly_stats ps
                JOIN product_file_variable pfv ON ps.product_file_variable_id = pfv.id
                JOIN product_file pf ON ps.product_file_id = pf.id AND CASE WHEN {0} = -1 THEN TRUE ELSE pf.rt_flag = {0} END
                JOIN product_file_description pfd ON pf.product_file_description_id = pfd.id AND pfv.product_file_description_id = pfd.id
                LEFT JOIN long_term_anomaly_info ltai ON pfv.id = ltai.raw_product_variable_id
                LEFT JOIN product_file_variable pfvltaimean ON ltai.mean_variable_id = pfvltaimean.id
                LEFT JOIN product_file_description pfdltaimean ON pfvltaimean.product_file_description_id = pfdltaimean.id
                LEFT JOIN product_file pfltaimean ON pfdltaimean.id = pfltaimean.product_file_description_id AND CASE WHEN {0} = -1 THEN TRUE ELSE pfltaimean.rt_flag = {0} END
                and EXTRACT('doy' FROM pfltaimean."date") between EXTRACT('doy' FROM pf."date") - 2	and EXTRACT('doy' FROM pf."date") +2
                LEFT JOIN poly_stats psltai ON psltai.product_file_id = pfltaimean.id AND psltai.product_file_variable_id = pfvltaimean.id
                AND psltai.poly_id = ps.poly_id
            WHERE ps.poly_id = {1} AND pf."date" BETWEEN '{2}' AND '{3}' AND pfv.id = {4} AND ps.valid_pixels > 0
            AND ps.valid_pixels*1.0/ps.total_pixels >= 0.7 """.format(self._requestData["options"]["rt_flag"], self._requestData["options"]["poly_id"], self._requestData["options"]["date_start"], self._requestData["options"]["date_end"], self._requestData["options"]["product_variable_id"])

        if self._requestData["options"]["rt_flag"] >=0:
            query += " AND pf.rt_flag = {0}".format(self._requestData["options"]["rt_flag"])

        query += """)SELECT ARRAY_TO_JSON(ARRAY_AGG(JSON_BUILD_ARRAY(dt."date", dt.mean, dt.sd, dt.meanlts, dt.sdlts) ORDER BY dt."date")) FROM dt"""
        return self.__getResponseFromDB(query)

    def __fetchStratificationDataByProductAndDate(self):
        query = """
       SELECT ARRAY_TO_JSON(ARRAY_AGG(res) ) FROM(
            SELECT jsonb_build_object(
		'id', sg.id,
        'meanval_color', CASE WHEN ps.valid_pixels*1.0/ps.total_pixels > 0.7 THEN ps.meanval_color::jsonb ELSE NULL END,
		'noval_color', CASE WHEN ps.valid_pixels*1.0/ps.total_pixels > 0.7 THEN ps.noval_color::jsonb ELSE NULL END,
		'sparseval_color', CASE WHEN ps.valid_pixels*1.0/ps.total_pixels > 0.7 THEN ps.sparseval_color::jsonb ELSE NULL END,
		'midval_color', CASE WHEN ps.valid_pixels*1.0/ps.total_pixels > 0.7 THEN ps.midval_color::jsonb ELSE NULL END,
		'highval_color',CASE WHEN ps.valid_pixels*1.0/ps.total_pixels > 0.7 THEN  ps.highval_color::jsonb ELSE NULL END
        ) res
        FROM  poly_stats ps
        JOIN  product_file pf ON ps.product_file_id = pf.id
        JOIN  product_file_variable pfv ON ps.product_file_variable_id = pfv.id
        JOIN  product_file_description pfd ON pf.product_file_description_id = pfd.id
        JOIN  product p ON pfd.product_id = p.id
        JOIN  stratification_geom sg ON sg.id = ps.poly_id
        JOIN  stratification s ON s.id = sg.stratification_id
        WHERE pf.date = '{0}' AND s.id = {1} AND pfv.id = {2} AND ps.valid_pixels > 0""".format(self._requestData["options"]["date"],
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
        query  = """SELECT type
                            FROM product_file_description pfd
                            JOIN product_file_variable pfv ON pfd.id = pfv.product_file_description_id
                            JOIN product p ON pfd.product_id = p.id
                            WHERE pfv.id = {0}""".format(self._requestData["options"]["product_variable_id"])

        productType = self._config.pgConnections[self._config.statsInfo.connectionId].fetchQueryResult(query)[0][0]

        path = self._config.filesystem.imageryPath
        if productType == "anomaly":
            path = self._config.filesystem.anomalyProductsPath

        if path[-1] != "/":
            path += "/"

        statsPath = self._config.filesystem.ltsPath
        if statsPath [-1] != "/":
            statsPath  += "/"

        #load all environment variables
        """
        if self._config.mapserver.virtualPrefix is not None:
            for key in self._config.mapserver.configOption:
                print(key)
                os.environ[key] = "{0}".format(self._config.mapserver.configOption[key])
            path            = self._config.mapserver.virtualPrefix + path
            statsPath   = self._config.mapserver.virtualPrefix + statsPath
       """

        query = """
        SELECT 'mean', pfvanom.variable meanVar
        , '{0}' || pf.rel_file_path, pf.date
        ,pfd.pattern
        ,pfd.types
        ,pfd.create_date
        FROM product_file_variable pfv
        JOIN long_term_anomaly_info ltai ON ltai.raw_product_variable_id = pfv.id

        --mean info
        JOIN product_file_variable pfvanom ON ltai.mean_variable_id = pfvanom.id
        JOIN product_file_description pfd ON pfvanom.product_file_description_id = pfd.id
        JOIN product_file pf ON pf.product_file_description_id = pfd.id
        WHERE  pfv.id = {4} UNION

        SELECT 'stdev',pfvanom.variable meanVar
        ,'{0}' || pf.rel_file_path, pf.date
        ,pfd.pattern
        ,pfd.types
        ,pfd.create_date
        FROM product_file_variable pfv
        JOIN long_term_anomaly_info ltai ON ltai.raw_product_variable_id = pfv.id

        --stdev info
        JOIN product_file_variable pfvanom ON ltai.stdev_variable_id = pfvanom.id
        JOIN product_file_description pfd ON pfvanom.product_file_description_id = pfd.id
        JOIN product_file pf ON pf.product_file_description_id = pfd.id
        WHERE pfv.id = {4} UNION

        SELECT  'raw', CASE WHEN pfv.variable = ''::text THEN NULL ELSE  pfv.variable END
            ,'{1}' || rel_file_path, date
            ,pfd.pattern
            ,pfd.types
            ,pfd.create_date
            FROM product_file pf
            JOIN product_file_description pfd ON pf.product_file_description_id = pfd.id
            JOIN product_file_variable pfv ON pfd.id = pfv.product_file_description_id
            JOIN product p on pfd.product_id =p.id
            WHERE date between  '{2}' and '{3}' AND pfv.id = {4}""".format(statsPath, path, self._requestData["options"]["date_start"], self._requestData["options"]["date_end"], self._requestData["options"]["product_variable_id"])

        if  self._requestData["options"]["rt_flag"] >= 0:
            query += " AND pf.rt_flag = {0}".format(self._requestData["options"]["rt_flag"])



        images = self._config.pgConnections[self._config.statsInfo.connectionId].fetchQueryResult(query)
        ret = {
            "raw": [],
            "mean": [],
            "stdev": []
        }

        with ProcessPoolExecutor(max_workers=4) as executor:
            #processing computations
            for result in executor.map(productStats, images, [self._requestData]*len(images)):
                if result[0] in ["mean", "stdev"]:
                    #convert date to doy
                    result[1][0][0] = result[1][0][0].utctimetuple().tm_yday

                if result[1][0][1] is not None:
                    ret[result[0]].append([result[1][0][0], np.round(result[1][0][1],6)])

            ret["raw"].sort(key = lambda x: x[0])
            #appending mean, sd to raw
            for row in ret["raw"]:
                #convert to doy:
                rawDoy = row[0].utctimetuple().tm_yday
                row[0] = row[0].isoformat()
                stop = False

                if len(ret["mean"]) == 0:
                    continue

                tmpId = 0
                while not stop:
                    if abs(rawDoy - ret["mean"][tmpId][0]) < 4:
                        stop =True
                        row += list([ret["mean"][tmpId][1], ret["stdev"][tmpId][1]])

                    tmpId += 1

        return ret["raw"]

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

    def __insertOrder(self):
        checkQuery = """
        WITH tmp as(
            SELECT EXTRACT (EPOCH FROM now() AT time ZONE ('utc') - po.date_created) > 120 deltacheck
            FROM  product_order po
            WHERE po.email ='{0}'
            ORDER BY po.date_created DESC LIMIT 1
        )
        SELECT  a.existscheck, tmp.*
        FROM(
            SELECT NOT EXISTS(SELECT * FROM tmp) existscheck ) a
            FULL OUTER JOIN tmp ON TRUE;""".format(self._requestData["options"]["email"])

        ret = self._config.pgConnections[self._config.statsInfo.connectionId].fetchQueryResult(checkQuery)
        print(ret)
        if(not ret[0][0] and not ret[0][1]):
            return {"result": "Error", "message": "Unable to process. You need to wait at least 2 minutes before submitting a new data request"}
        
        insertQuery = """
            WITH tmp AS (
                SELECT '{0}'::json AS dt
            ),polys AS(
                SELECT (feat->'properties'->'id')::text::int AS id,
                ST_SetSRID(ST_MakeValid(ST_Force2D(ST_Multi(ST_GeomFromGeoJSON(feat->>'geometry')))),3857) AS geom
                FROM (
                    SELECT JSON_ARRAY_ELEMENTS(dt->'features') AS feat
                    FROM tmp
                ) AS a
            ),insert_order AS(
                INSERT INTO product_order (email, aoi, request_data)
                SELECT '{1}'::TEXT, ST_Envelope(st_Extent(geom)), '{2}'::JSONB
                FROM polys 
                RETURNING id
            )
            INSERT INTO product_order_geom(product_order_id, poly_id, geom)
            SELECT io.id, polys.id, polys.geom
            FROM insert_order io
            JOIN polys ON true""".format(self._requestData["options"]["aoi"],self._requestData["options"]["email"],json.dumps(self._requestData["options"]["request_data"]))
        print(insertQuery)
        self._config.pgConnections[self._config.statsInfo.connectionId].executeQueries([insertQuery,])
        return {"result": "OK", "message": "Your request has been submitted successfully. You will receive an email when the data are available"}

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

    def __terraMeterIndicator(self):
        query = """
        SELECT json_build_object('raw_mean', psraw.mean , 'lts_mean', pslts.mean , 'lts_sd', pslts.sd )
        FROM long_term_anomaly_info ltai
        JOIN poly_stats psraw ON ltai.raw_product_variable_id = psraw.product_file_variable_id
        JOIN product_file pfraw ON psraw.product_file_id = pfraw.id
        JOIN poly_stats pslts ON ltai.mean_variable_id = pslts.product_file_variable_id AND psraw.poly_id = pslts.poly_id
        JOIN product_file pflts ON pslts.product_file_id = pflts.id

        WHERE ltai.raw_product_variable_id = {0} AND psraw.poly_id = {1} AND pfraw.date = '{2}'
        AND date_part('month', pfraw.date) = date_part('month', pflts.date)
        AND date_part('day', pfraw.date) = date_part('day', pflts.date) ;
        """.format(self._requestData["options"]["product_variable_id"], self._requestData["options"]["poly_id"],
                   self._requestData["options"]["date"])

        if self._requestData["options"]["rt_flag"] >= 0:
            query += " AND pfraw.rt_flag = {0} AND pflts.rt_flag = pfraw.rt_flag".format(self._requestData["options"]["rt_flag"])

        return self.__getResponseFromDB(query)

    def polygonDescription(self):
        query = """SELECT json_build_object('description',sg.description, 'strata', s.description) response
                            FROM stratification_geom sg
                            JOIN stratification s ON sg.stratification_id = s.id WHERE sg.id={0}
                        """.format(self._requestData["options"]["poly_id"])
        return self.__getResponseFromDB(query)

    def __productFiles(self):
        query = """
                WITH tmp  AS NOT MATERIALIZED (
            SELECT pf.date,  CASE WHEN pf.rt_flag IS NULL THEN -1 ELSE pf.rt_flag END, wf.rel_file_path, pf.rel_file_path raw_file_path
            FROM product_file pf
            JOIN wms_file wf ON pf.id = wf.product_file_id AND wf.product_file_variable_id  = {0}
            WHERE pf.date between '{1}' AND '{2}'
        ),tmp2 AS NOT MATERIALIZED (
            SELECT tmp.rt_flag, JSON_OBJECT_AGG(tmp.date, ARRAY_TO_JSON(array[tmp.rel_file_path, tmp.raw_file_path]) ) AS info
            FROM tmp
            GROUP BY tmp.rt_flag
        )SELECT JSON_OBJECT_AGG(rt_flag, info) FROM tmp2""".format(self._requestData["options"]["product_variable_id"],
                    self._requestData["options"]["date_start"], self._requestData["options"]["date_end"])
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
        elif self._requestData["request"] == "insertOrder":
            ret = self.__insertOrder()
        elif self._requestData["request"] == "polygonDescription":
            ret = self.polygonDescription()
        elif self._requestData["request"] == "polygonStatsTimeseries":
            ret = self.polygonStatsTimeseries()
        elif self._requestData["request"] == "productinfo":
            ret = self.__fetchProductInfo()
        elif self._requestData["request"] == "productfiles":
            ret = self.__productFiles()
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
        elif self._requestData["request"] == "terraMeterIndicator":
            ret = self.__terraMeterIndicator()
        else:
            raise SystemError
        return ret

/*
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
*/

#include <iostream>
#include <sstream>

#include "Constants.h"
std::map<std::size_t, ProductInfo::SharedPtr> Constants::productInfo;
std::map<std::size_t, ProductVariable::SharedPtr> Constants::variableInfo;

Constants::Constants() {}

unsigned short Constants::load(Configuration::SharedPtr cfg) {
    std::string query =  R""""(
                WITH anomalies AS NOT MATERIALIZED (
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
                SELECT p.name, p.type, pfd.id, pfd.pattern, pfd."types", pfd.create_date, pfd.file_name_creation_pattern, pfd.rt_flag_pattern, productPath.rel_file_path,
                pv.product_variables
                FROM product p
                LEFT JOIN product_file_description pfd on p.id = pfd.product_id
                LEFT JOIN product_variables pv on pv.product_file_description_id = pfd.id
                LEFT JOIN LATERAL (
                    SELECT rel_file_path
                    FROM product_file pf
                    WHERE pf.product_file_description_id = pfd.id
                    ORDER BY pf.id
                    LIMIT 1
                ) productPath ON TRUE
                WHERE pfd.pattern is not NULL)"""";

    if (cfg->enabledProductIds.size() > 0) {
        query += " AND p.id IN (";
        for (auto &id:cfg->enabledProductIds){
           query += std::to_string(id) +=",";
        }
        query.resize(query.size()-1);
        query +=")";
    }
    query += " ORDER BY p.id;";

    PGPool::PGConn::UniquePtr cn = PGPool::PGConn::New(Configuration::connectionIds[cfg->statsInfo.connectionId]);
    PGPool::PGConn::PGRes res = cn->fetchQueryResult(query, "");

    for (size_t i = 0; i < res.size(); i++) {
        Constants::productInfo.insert(std::make_pair<size_t, ProductInfo::SharedPtr>(res[i][2].as<size_t>(),
                                      ProductInfo::New(PGPool::PGConn::PGRow(res[i]), cfg)));

        for(auto& variable: Constants::productInfo[res[i][2].as<size_t>()]->variables)
           Constants::variableInfo[variable.second->id] = variable.second;

    }
    return 0;
}


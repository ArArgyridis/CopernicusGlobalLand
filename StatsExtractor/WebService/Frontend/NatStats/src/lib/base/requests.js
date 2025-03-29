/*
   Copyright (C) 2024  Argyros Argyridis arargyridis at gmail dot com
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

import axios from 'axios';
import options from './options.js';

export default {
	categories() {
		let postParams = {};
		postParams["request"] = "categories";
		postParams["options"] = null;
		return axios.post(options.endpointURL, postParams);
	},
	fetchDashboard(polyId, productId, dateStart, dateEnd) {
		let postParams = {};
		postParams["request"] = "dashboard";
		postParams["options"] = {
			poly_id: polyId,
			product_id: productId,
			date_start: dateStart,
			date_end: dateEnd
		};
		return axios.post(options.endpointURL, postParams);
	},
	fetchHistogramByPolygonAndDate(polyId, date, productVariableID, rtFlag) {
		let postParams = {};

		postParams["request"] = "histogrambypolygonanddate";
		postParams["options"] = {
			poly_id: polyId,
			date: date,
			product_variable_id: productVariableID,
			rt_flag: rtFlag
		}
		return axios.post(options.endpointURL, postParams);
	},
	fetchProductInfo(dateStart, dateEnd, categoryId) {
		let postParams = {};
		postParams["request"] = "productinfo";
		postParams["options"] = {
			dateStart: dateStart,
			dateEnd: dateEnd,
			category_id: categoryId
		}
		return axios.post(options.endpointURL, postParams);
	},
	productFiles(productVariableID, dateStart, dateEnd) {
		let postParams = {};
		postParams["request"] = "productfiles";
		postParams["options"] = {
			product_variable_id: productVariableID,
			date_start: dateStart,
			date_end: dateEnd
		}
		return axios.post(options.endpointURL, postParams);
	},
	densityStatsByPolygonAndDateRange(polyId, dateStart, dateEnd, productVariableID, rtFlag, area_type = "noval_area_ha") {
		let postParams = {};
		postParams["request"] = "densityStatsByPolygonAndDateRange";
		postParams["options"] = {
			poly_id: polyId,
			product_variable_id: productVariableID,
			rt_flag: rtFlag,
			date_start: dateStart,
			date_end: dateEnd,
			area_type: area_type
		}
		return axios.post(options.endpointURL, postParams);
	},
	fetchBoundaryInfo() {
		let postParams = {};
		postParams["request"] = "stratificationinfo";
		postParams["options"] = null;
		return axios.post(options.endpointURL, postParams);
	},
	fetchBoundaryDataByProductAndDate(date, variableID, rtFlag, boundaryId) {
		let postParams = {};
		postParams["request"] = "stratificationinfobyproductanddate"
		postParams["options"] = {
			date: date,
			product_variable_id: variableID,
			rt_flag: rtFlag,
			stratification_id: boundaryId
		}
		return axios.post(options.endpointURL, postParams);
	},
	getPieDataByDateAndPolygon(productVariableID, rtFlag, date, polyId) {
		let postParams = {};
		postParams["request"] = "piedatabydateandpolygon";
		postParams["options"] = {
			product_variable_id: productVariableID,
			rt_flag: rtFlag,
			date: date,
			poly_id: polyId
		}
		return axios.post(options.endpointURL, postParams);
	},
	getPolygonDescription(polyId) {
		let postParams = {};
		postParams["request"] = "polygonDescription";
		postParams["options"] = {
			poly_id: polyId
		};
		return axios.post(options.endpointURL, postParams);
	},
	getRawTimeSeriesDataForRegion(dateStart, dateEnd, productVariableID, rtFlag, coordInfo, epsg) {
		let postParams = {};
		postParams["request"] = "rawtimeseriesdataforregion";
		postParams["options"] = {
			date_start: dateStart,
			date_end: dateEnd,
			product_variable_id: productVariableID,
			rt_flag: rtFlag,
			coordinate: coordInfo,
			epsg: epsg
		};
		return axios.post(options.endpointURL, postParams);
	},
	insertOrder(orderData) {
		let postParams = {};
		postParams["request"] = "insertOrder";
		postParams["options"] = orderData;
		return axios.post(options.endpointURL, postParams);
	},
	polygonStatsTimeSeries(polyId, dateStart, dateEnd, productVariableID, rtFlag) {
		let postParams = {};
		postParams["request"] = "polygonStatsTimeseries";
		postParams["options"] = {
			date_start: dateStart,
			date_end: dateEnd,
			product_variable_id: productVariableID,
			poly_id: polyId,
			rt_flag: rtFlag
		};
		return axios.post(options.endpointURL, postParams);
	},
	rankStratabyAreaDensity(productId, date, stratification, density) {
		let postParams = {};
		postParams["request"] = "rankstratabydensity";
		postParams["options"] = {
			product_id: productId,
			date: date,
			stratification_id: stratification,
			density: density
		};
		return axios.post(options.endpointURL, postParams);
	},
	terraMeterIndicator(polyId, date, productVariableID, rtFlag) {
		let postParams = {};
		postParams["request"] = "terraMeterIndicator";
		postParams["options"] = {
			date: date,
			poly_id: polyId,
			product_variable_id: productVariableID,
			rt_flag: rtFlag
		}
		return axios.post(options.endpointURL, postParams);
	}
};

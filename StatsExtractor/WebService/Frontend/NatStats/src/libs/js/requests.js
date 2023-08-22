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
			poly_id:polyId,
			product_id: productId,
			date_start: dateStart,
			date_end: dateEnd
		};
		return axios.post(options.endpointURL, postParams); 
	},
	fetchHistogramByPolygonAndDate(polyId, date, productVariableID, rtFlag) {
		let postParams  = {};

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
			dateStart:dateStart,
			dateEnd:dateEnd,
			category_id: categoryId
		}
		return axios.post(options.endpointURL, postParams);
	},
	productCog(productId, productVariableID, rtFlag, dateStart, dateEnd) {
		let postParams = {};
		postParams["request"] = "productcog";
		postParams["options"] = {
			product_id:productId,
			product_variable_id: productVariableID,
			rt_flag: rtFlag,
			date_start: dateStart,
			date_end: dateEnd
		}
		return axios.post(options.endpointURL, postParams);
	},
	densityStatsByPolygonAndDateRange(polyId, dateStart, dateEnd, productVariableID, rtFlag, area_type="noval_area_ha"){
		let postParams={};
		postParams["request"] = "densityStatsByPolygonAndDateRange";
		postParams["options"]={
			poly_id: polyId,
			product_variable_id: productVariableID,
			rt_flag: rtFlag,
			date_start: dateStart,
			date_end: dateEnd,
			area_type: area_type
		}
		return axios.post(options.endpointURL, postParams);
	},		
	fetchStratificationInfo() {
		let postParams = {};
		postParams["request"] = "stratificationinfo";
		postParams["options"] = null;
		return axios.post(options.endpointURL, postParams);
	},
	fetchStratificationDataByProductAndDate(date, variableID, rtFlag, stratification) {
		let postParams = {};
		postParams["request"] = "stratificationinfobyproductanddate"
		postParams["options"] = {
			date: date,
			product_variable_id: variableID,
			rt_flag: rtFlag,
			stratification_id: stratification
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
	getRawTimeSeriesDataForRegion(dateStart, dateEnd, productVariableID, rtFlag, coordInfo) {
		let postParams = {};
		postParams["request"] = "rawtimeseriesdataforregion";
		postParams["options"] = {
			date_start: dateStart,
			date_end: dateEnd,
			product_variable_id: productVariableID,
			rt_flag: rtFlag
		};
		postParams["options"] = {...postParams["options"], ...coordInfo};
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
			rt_flag:rtFlag
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
	}
};

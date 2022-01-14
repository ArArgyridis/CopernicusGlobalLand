import axios from 'axios';
import options from './options.js';

export default {
	fetchHistogramByPolygonAndDate(polyId, date, productId) {
		let postParams  = {};
		postParams["request"] = "fetchhistogrambypolygonanddate";
		postParams["options"] = {
			poly_id: polyId,
			date: date,
			product_id: productId
		}
		return axios.post(options.endpointURL, postParams); 
	},
	fetchProductInfo(dateStart, dateEnd) {
		let postParams = {};
		postParams["request"] = "fetchproductinfo";
		postParams["options"] = {
			dateStart:dateStart,
			dateEnd:dateEnd
		}
		return axios.post(options.endpointURL, postParams);
	},
	fetchStatsByPolygonAndDateRange(polyId, dateStart, dateEnd, productId, area_type="noval_area_ha"){
		let postParams={};
		postParams["request"] = "fetchstatsbypolygonanddaterange";
		postParams["options"]={
			poly_id: polyId,
			product_id: productId,
			date_start: dateStart,
			date_end: dateEnd,
			area_type: area_type
		}
		return axios.post(options.endpointURL, postParams);
	},		
	fetchStratificationInfo(dateStart, dateEnd, productId) {
		let postParams = {};
		postParams["request"] = "fetchstratificationinfo";
		postParams["options"] = {
			dateStart: dateStart,
			dateEnd: dateEnd,
			product_id: productId
		}
		return axios.post(options.endpointURL, postParams);
	},
	fetchStratificationDataByProductAndDate(date, product, stratification) {
		let postParams = {};
		postParams["request"] = "fetchstratificationinfobyproductanddate"
		postParams["options"] = {
			date: date,
			product_id: product,
			stratification_id: stratification
		}
		return axios.post(options.endpointURL, postParams);
	},
	getRawTimeSeriesDataForRegion(dateStart, dateEnd, productId, coordInfo) {
		let postParams = {};
		postParams["request"] = "getrawtimeseriesdataforregion";
		postParams["options"] = {
			date_start: dateStart,
			date_end: dateEnd,
			product_id: productId
		};
		postParams["options"] = {...postParams["options"], ...coordInfo};
		return axios.post(options.endpointURL, postParams);
	}
};

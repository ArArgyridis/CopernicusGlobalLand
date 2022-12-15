import { createStore } from "vuex";
import proj4 from "proj4";

import {areaDensityOptions, Categories, StratificationProps, ProductViewProps, ProductsProps, initProduct} from "./libs/js/constructors.js";
import utils from "./libs/js/utils.js";


let projections = [
	{ title: null, epsg: "EPSG:4326", proj: "+proj=longlat +datum=WGS84 +no_defs" },
	{ title: "Global (Web Mercator)", epsg: "EPSG:3857", proj: "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs" }
]

projections.forEach(function (item) {
	proj4.defs(item.epsg, item.proj);
});

let dateEnd = new Date();
let dateStart = new Date();
dateStart.setDate(dateStart.getDate() - 200);
//dateStart = new Date("2020-01-01 00:00:00");

export default{
	buildStore() {
		return createStore({
			state: {
				proj4: proj4,
				dateEnd: dateEnd,
				dateStart: dateStart,
				stratifiedOrRaw: 0,
				categories: new Categories(),
				stratifications: new StratificationProps()		
			},
			mutations: {
				appendToProductsAnomaliesWMSLayers(state, dt) {
					let tmp = state.categories.current.products.current.properties.anomalies.current.layers.info;
					tmp = tmp.concat(dt);
				state.categories.current.products.current.properties.anomalies.current.layers.info = tmp.sort(utils.sort);
				state.categories.current.products.current.properties.anomalies.current.layers.current = state.categories.current.products.current.properties.anomalies.current.layers.info[0];
			},
			appendToProductsWMSLayers(state, dt) {
				state.categories.current.products.current.properties.raw.wms.layers = state.categories.current.products.current.properties.raw.wms.layers.concat(dt);
				state.categories.current.products.current.properties.raw.wms.layers.sort(utils.sort);
				state.categories.current.products.current.properties.raw.wms.current = state.categories.current.products.current.properties.raw.wms.layers[0];
			},
			changeCategory(state, dt) {
				if (!state.categories.current == null)
					state.categories.current.active = false;
			
				state.categories.previous = state.categories.current;
				state.categories.current = dt;
				state.categories.current.active = true;
				state.categories.previous.active = false;
			},
			clearProducts(state) {
				state.categories.info.forEach(category => {
					category.products = null;
				});
			},
			clearProductsWMSLayers(state) {
				if(state.categories.products[state.categories.current].info != null && state.categories.products[state.categories.current].current in state.categories.products[state.categories.current].info)
					state.categories.products[state.categories.current].info[state.categories.products[state.categories.current].current].raw.wms = new ProductViewProps.raw.wms;
			},
			clearProductsAnomalyWMSLayers(state) {
				if(state.categories.products[state.categories.current].info != null && state.categories.products[state.categories.current].current in state.categories.products[state.categories.current].info)
					state.categories.products[state.categories.current].info[state.categories.products[state.categories.current].current].anomalies = new ProductViewProps.anomalies;
			},
			clickedCoordinates(state, dt) {
				state.stratifications.current.clickedCoordinates = dt;
			},
			setCategoryProducts(state, dt) {
				state.categories.current.products = new ProductsProps();
				if (dt == null)
					return;
				
				dt.forEach(prod => {
					new initProduct(prod);
				});
			
				state.categories.current.products.info = dt;
				state.categories.current.products.current = dt[0];
			},
			selectedPolygon(state, dt) {
				state.stratifications.current.selectedPolygonId = dt;
			},
			setCategoryInfo(state, dt) {
				state.categories.info = dt;
				for (let i = 0; i < state.categories.info.length; i++) {
					if (state.categories.info[i].active) 
						state.categories.current = state.categories.info[i];
				}
			},
			setProduct(state, dt) {			
				new initProduct(dt);
				state.categories.current.products.current = dt;
			},
			setProductAnomaly(state, dt) {
				state.categories.current.products.current.properties.anomalies.previous = state.categories.current.products.current.properties.anomalies.current;
				state.categories.current.products.current.properties.anomalies.current = dt;
			},
			setStratifiedOrRaw(state, dt) {
				state.stratifiedOrRaw = dt;
			},
			setStratificationAreaDensity(state, dt) {
				state.categories.current.products.current.properties.raw.density = dt;
				state.categories.current.products.current.properties.raw.stratificationInfo.colorCol = dt.color_col;
			},
			setStratificationViewOptions(state, dt) {
				if(state.categories.current.products.current.properties.statisticsViewMode == 0) 
					state.categories.current.products.current.properties.raw.stratificationInfo = dt;
				else if (state.categories.current.products.current.properties.statisticsViewMode == 1)
					state.categories.current.products.current.properties.anomalies.current.stratificationInfo = dt;
			},
			setDateStart(state, dt) {
				state.dateStart = dt;
			},
			setDateEnd(state, dt) {
				state.dateEnd = dt;
			},
			setProductAnomalyWMSLayer(state, dt) {
				state.categories.current.products.current.properties.anomalies.current.layers.previous = state.categories.current.products.current.properties.anomalies.current.layers.current;
				state.categories.current.products.current.properties.anomalies.current.layers.current = dt;
			},
			setProductStatisticsViewMode(state, dt) {
				state.categories.current.products.current.properties.previousStatisticsViewMode
				state.categories.current.products.current.properties.statisticsViewMode = dt;
			},
			setProductWMSLayer(state, dt) {
				state.categories.current.products.current.properties.raw.wms.previous =state.categories.current.products.current.properties.raw.wms.current;
				state.categories.current.products.current.properties.raw.wms.current = dt;
			},
			setCurrentStratification(state, dt) {
				state.stratifications.previous = state.stratifications.current;
				state.stratifications.current = dt;
			},	
			setCurrentDate(state, dt) {
				state.categories.current.products.current.properties.currentDate = dt;
			},
			setStratifications(state, dt) {
				Object.keys(dt).forEach( key => {
					dt[key] = {...dt[key], ...{maxZoom: 14, layerId: null, 	selectedPolygonId: null}};
				});
				state.stratifications.info = dt;
				state.stratifications.current = state.stratifications.info[1];
			}
		},
		getters: {
			areaDensityOptions: (state) => {
				let tmp = state.categories.current.products.current.value_ranges; 
			
				let ret = new areaDensityOptions();
				for (let i = 0; i < ret.length; i++) 
					ret[i].description = utils.computeDensityDescription(ret[i].description, tmp[i], tmp[i+1]);
				return ret;
			},		
			dateEnd:(state)=>{
				return state.dateEnd;
			},
			dateStart:(state) => {
				return state.dateStart;
			},
			activeCategory: (state) => {
				return state.categories.current;
			},		
			areaDensity: (state) => {
				if (state.categories == null || state.categories.current == null || state.categories.current.products == null || state.categories.current.products.current == null)
					return null;
			
				return state.categories.current.products.current.properties.raw.density;
			},
			allCategories: (state) => {
				if (state.categories.current == null || state.categories.current.products == null)
					return null;
				return state.categories.info;
			},
			categories: (state) => {
				return state.categories.info;
			},
			clickedCoordinates: (state) => {
				if (state.stratifications == null || state.stratifications.current == null)
					return null;

				return state.stratifications.current.clickedCoordinates;
			},
			stratificationViewOptions: (state) => {
				let viewOptions = null;
			
				if (state.categories.current.products.current.properties.statisticsViewMode == 0)
					viewOptions = state.categories.current.products.current.properties.raw.stratificationInfo;
				else if (state.categories.current.products.current.properties.statisticsViewMode == 1)
					viewOptions = state.categories.current.products.current.properties.anomalies.current.stratificationInfo;
				return viewOptions;
			},
			product: (state) =>{
				if (state.categories.info == null || state.categories.current == null ||  state.categories.current.products == null)
					return null;
				return state.categories.current.products.current;
			},
			productAnomalies: (state) => {
				if (state.categories.current.products == null)
					return null;
			
				return state.categories.current.products.current.anomaly_info
			},
			productAnomaly: (state) => {
				if (state.categories == null || state.categories.current == null || state.categories.current.products == null)
					return null;
				return state.categories.current.products.current.properties.anomalies.current;
			},
			productAnomalyWMSLayer: (state) => {
				return state.categories.current.products.current.properties.anomalies.current.layers.current
			},
			productPreviousStatisticsViewMode: (state) => {
				if (state.categories.current == null || state.categories.current.products == null)
					return null;
				return state.categories.current.products.current.properties.previousStatisticsViewMode;
			},
			productStatisticsViewMode: (state) => {
				if (state.categories.current == null || state.categories.current.products == null || state.categories.current.products.current == null)
					return null;
				return state.categories.current.products.current.properties.statisticsViewMode;
			},
			productWMSLayer: (state) => {
				if (state.categories.info == null || state.stratifications == null)
					return null;
				return state.categories.current.products.current.properties.raw.wms.current;
			},
			currentStratification: (state)=> {
				return state.stratifications.current;
			},
			currentDate: (state) => {
				if (state.categories.info == null || state.categories.current.products == null)
					return null;
			
				return state.categories.current.products.current.properties.currentDate;
			},
			productDates: (state) => {
				if (state.categories.info == null || state.categories.current.products == null)
					return null;
			
				return state.categories.current.products.current.dates;
			},
			stratifiedOrRaw: (state) => {
				return state.stratifiedOrRaw;
			},
			previousProduct:(state) => {
				return state.categories.current.products.previous;			
			},
			previousProductAnomalyWMSLayer: (state) => {
				return state.categories.current.products.current.properties.anomalies.current.layers.previous;
			},
			previousProductWMSLayer: (state) => {
				return state.categories.current.products.current.properties.raw.wms.previous;
			},
			previousStratification: (state) => {
				return state.stratifications.previous;
			},
			productWMSLayers: (state) => {
				return state.categories.current.products.current.properties.raw.wms.layers;
			},
			productAnomalyWMSLayers: (state) => {
				return state.categories.current.products.current.properties.anomalies.current.layers.info;
			},
			selectedPolygon: (state) => {
				if ( state.stratifications.current == null)
					return null;
				return state.stratifications.current.selectedPolygonId;
			},
			stratifications: (state) => {
				return state.stratifications;
			}
		}
	});
}
}

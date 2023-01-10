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
					state.categories.current.products.current.properties.anomalies.current.layers.info = {...state.categories.current.products.current.properties.anomalies.current.layers.info, ...dt};
					let date = state.categories.current.products.current.properties.currentDate;
					if (date != null)
						state.categories.current.products.current.properties.anomalies.current.layers.current = state.categories.current.products.current.properties.anomalies.current.layers.info[date];
				},
				appendToProductsWMSLayers(state, dt) {
					state.categories.current.products.current.properties.raw.wms.layers = {...state.categories.current.products.current.properties.raw.wms.layers, ...dt};
					let date = state.categories.current.products.current.properties.currentDate;
					if (date != null)
						state.categories.current.products.current.properties.raw.wms.current = state.categories.current.products.current.properties.raw.wms.layers[date];
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
					console.log(state.stratifications);
				},
				setCategoryProducts(state, dt) {
					state.categories.current.products = new ProductsProps();
					if (dt == null)
						return;
				
					dt.forEach(prod => {
						initProduct(prod);
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
					initProduct(dt);
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
					state.categories.current.products.current.properties.raw.wms.previous = state.categories.current.products.current.properties.raw.wms.current;
					state.categories.current.products.current.properties.raw.wms.current = dt;
				},
				setCurrentStratification(state, dt) {
					state.stratifications.previous = state.stratifications.current;
					state.stratifications.current = dt;
				},	
				setCurrentDate(state, dt) {
					state.categories.current.products.current.properties.currentDate = dt;
					state.categories.current.products.current.properties.raw.wms.previous = state.categories.current.products.current.properties.raw.wms.current;
			
					if (dt in state.categories.current.products.current.properties.raw.wms.layers) {
						state.categories.current.products.current.properties.raw.wms.previous = state.categories.current.products.current.properties.raw.wms.current;
						state.categories.current.products.current.properties.raw.wms.current = state.categories.current.products.current.properties.raw.wms.layers[dt];
					}
					
					if (dt in state.categories.current.products.current.properties.anomalies.current.layers.info) {
						state.categories.current.products.current.properties.anomalies.current.layers.previous = state.categories.current.products.current.properties.anomalies.current.layers.current;
						state.categories.current.products.current.properties.anomalies.current.layers.current = state.categories.current.products.current.properties.anomalies.current.layers.info[dt];
					}
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
				try{
					return state.categories.current;
				}
				catch{
					return null;
				}
			},		
			areaDensity: (state) => {
				try {
					return state.categories.current.products.current.properties.raw.density;
				}
				catch {
					return null;
				}
			},
			allCategories: (state) => {
				try {
					return state.categories.info;
				}
				catch {
					return null;
				}

				
			},
			categories: (state) => {
				try {
					return state.categories.info;
				}
				catch{
					return null;
				}
			},
			clickedCoordinates: (state) => {
				try {
					return state.stratifications.current.clickedCoordinates;
				}
				catch {
					return null;
				}
			},
			stratificationViewOptions: (state) => {
				try {
					let viewOptions = null;
			
					if (state.categories.current.products.current.properties.statisticsViewMode == 0)
						viewOptions = state.categories.current.products.current.properties.raw.stratificationInfo;
					else if (state.categories.current.products.current.properties.statisticsViewMode == 1)
						viewOptions = state.categories.current.products.current.properties.anomalies.current.stratificationInfo;
					return viewOptions;
				}
				catch{
					return null;
				}
			},
			product: (state) =>{
				try{
					return state.categories.current.products.current;
				}
				catch{
					return null;
				}
				
			},
			productAnomalies: (state) => {
				try {
					return state.categories.current.products.current.anomaly_info
				}
				catch{
					return null;
				}
			},
			productAnomaly: (state) => {
				try{
					return state.categories.current.products.current.properties.anomalies.current;
				}
				catch{
					return null;
				}
			},
			productAnomalyWMSLayer: (state) => {
				try{
					return state.categories.current.products.current.properties.anomalies.current.layers.current;
				}
				catch{
					return null;
				}
			},
			products: (state) => {
				try{
					return state.categories.current.products.info;
				}
				catch {
					return null;
				}
			},
			productPreviousStatisticsViewMode: (state) => {
				try {
					return state.categories.current.products.current.properties.previousStatisticsViewMode;
				}
				catch{
					return null;
				}
			},
			productStatisticsViewMode: (state) => {
				try {
					return state.categories.current.products.current.properties.statisticsViewMode;
				}
				catch{
					return null;
				}
			},
			productWMSLayer: (state) => {
				try{
					return state.categories.current.products.current.properties.raw.wms.current;
				}
				catch{
					return null;
				}
			},
			currentStratification: (state)=> {
				try{
					return state.stratifications.current;
				}
				catch{
					return null;
				}
			},
			currentDate: (state) => {
				try{
					return state.categories.current.products.current.properties.currentDate;
				}
				catch {
					return null;
				}
			},
			productDates: (state) => {
				try {
					return state.categories.current.products.current.dates;
				}
				catch {
					return null;
				}
			},
			stratifiedOrRaw: (state) => {
				return state.stratifiedOrRaw;
			},
			previousProduct:(state) => {
				try{
					return state.categories.current.products.previous;			
				}
				catch{
					return null;
				}
			},
			previousProductAnomalyWMSLayer: (state) => {
				try {
					return state.categories.current.products.current.properties.anomalies.current.layers.previous;
				}
				catch{
					return null;
				}
			},
			previousProductWMSLayer: (state) => {
				try{
					return state.categories.current.products.current.properties.raw.wms.previous;
				}
				catch{
					return null;
				}
			},
			previousStratification: (state) => {
				try{
					return state.stratifications.previous;
				}
				catch{
					return null;
				}
			},
			productWMSLayers: (state) => {
				try {
					return state.categories.current.products.current.properties.raw.wms.layers;
				}
				catch{
					return null;
				}
			},
			productAnomalyWMSLayers: (state) => {
				try {
					return state.categories.current.products.current.properties.anomalies.current.layers.info;
				}
				catch{
					return null;
				}
				
			},
			selectedPolygon: (state) => {
				try {
					return state.stratifications.current.selectedPolygonId;
				}
				catch{
					return null;
				}
			},
			stratifications: (state) => {
				return state.stratifications;
			}
		}
	});
}
}

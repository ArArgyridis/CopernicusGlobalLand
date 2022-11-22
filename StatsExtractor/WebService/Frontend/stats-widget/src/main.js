//css
import "bootstrap/dist/css/bootstrap.min.css"

import { createApp } from 'vue'
import { createStore } from 'vuex'
import proj4 from "proj4"
import "bootstrap"


import App from './App.vue'
import utils from "./libs/js/utils.js"

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

let productsProps = {
	currentProduct: null,
	info:[],
	viewInfo:{}
}

let productViewProps = {
	anomalies: {
		current: null,
		previous: null,
		next: null,
		algorithm: null,
		info: [],
		layers:[]
	},
	clickedCoordinates: null, 
	density: null,
	rawWMS: {
		current: null,
		previous: null,
		next: null,
		layers:[]
	},
	stratification: {
		current: null,
		previous: null,
		next:null,
		info: [],
		selectedPolygonId: null,
		layers:[]
	}
};

const store = createStore({
	state: {
		proj4: proj4,
		dateEnd: dateEnd,
		dateStart: dateStart,
		currentView: 0,
		areaDensityOptions:{
			options:[
				{
					id: 0,
					col: "noval_area_ha",
					description: "No value",
					color_col: "noval_color",
					palette_col: "noval_colors"
				},
				{
					id: 1,
					col:"sparse_area_ha",
					description:"Sparse",
					color_col: "sparseval_color",
					palette_col:"sparseval_colors"
				},
				{
					id: 2,
					col:"mid_area_ha",
					description:"Mild",
					color_col: "midval_color",
					palette_col:"midval_colors"
				},
				{
					id: 3,
					col:"dense_area_ha",
					description:"Dense",
					color_col: "highval_color",
					palette_col:"highval_colors"
				}
			]
		},
		categories: {
			info: null,
			current: null,
			previous: null,
			products:[]
		}
	},
	mutations: {
		appendToProductsAnomaliesWMSLayers(state, dt) {
			let layers = state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].anomalies.layers;
			layers = layers.concat(dt);
			state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].anomalies.layers = layers.sort( function(a, b) {
				let keyA = a.title,
				keyB = b.title;
				if (keyA < keyB) return 1;
				if (keyA > keyB) return -1;
				return 0;
			});
		},
		appendToProductsWMSLayers(state, dt) {
			state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].rawWMS.layers = state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].rawWMS.layers.concat(dt);
			state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].rawWMS.layers = state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].rawWMS.layers.sort( function(a, b) {
				let keyA = a.title, keyB = b.title;
				if (keyA < keyB) return 1;
				if (keyA > keyB) return -1;
				return 0;
			});
		},
		changeCategory(state, dt) {
			state.categories.info[state.categories.current].active = false;
			state.categories.previous = state.categories.current;
			state.categories.current = dt;
			state.categories.info[state.categories.current].active = true;
		},
		clearProducts(state) {
			state.categories.products[state.categories.current].info=[];
			state.categories.products[state.categories.current].currentProduct=null;
			state.categories.products[state.categories.current].viewInfo = {};
		},
		clearProductsWMSLayers(state) {
			if(state.categories.products[state.categories.current].info != null && state.categories.products[state.categories.current].currentProduct in state.categories.products[state.categories.current].info)
				state.categories.products[state.categories.current].info[state.categories.products[state.categories.current].currentProduct].rawWMS = JSON.parse(JSON.stringify(productViewProps.rawWMS));
		},
		clearProductsAnomalyWMSLayers(state) {
			if(state.categories.products[state.categories.current].info != null && state.categories.products[state.categories.current].currentProduct in state.categories.products[state.categories.current].info)
				state.categories.products[state.categories.current].info[state.categories.products[state.categories.current].currentProduct].anomalies = JSON.parse(JSON.stringify(productViewProps.anomalies));
			
		},
		clickedCoordinates(state, dt) {
			state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].stratification.clickedCoordinates = dt;
		},
		selectedPolygon(state, dt) {
			state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].stratification.selectedPolygonId = dt;
		},
		setCategoryInfo(state, dt) {
			state.categories.info = dt;
			for (let i = 0; i < dt.length; i++) {
				if (dt[i].active) 
					state.categories.current = i;
				state.categories.products[i] =  JSON.parse(JSON.stringify(productsProps));
			}
		},
		setCurrentProduct(state, dt) {
			state.categories.products[state.categories.current].currentProduct = dt;
			if ( !(dt in state.categories.products[state.categories.current].viewInfo))
				state.categories.products[state.categories.current].viewInfo[dt] = JSON.parse(JSON.stringify(productViewProps));
		},
		setCurrentProductAnomaly(state, dt) {
			state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].anomalies.algorithm = dt;
		},
		setCurrentView(state, dt) {
			state.currentView = dt;
		},
		setStratificationAreaDensity(state, dt) {
			state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].density = dt;
		},
		setDateStart(state, dt) {
			state.dateStart = dt;
		},
		setDateEnd(state, dt) {
			state.dateEnd = dt;
		},
		setCurrentProductAnomalyWMSLayer(state, dt) {
			state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].anomalies.previous = state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].anomalies.current;
			state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].anomalies.current = dt;
		},
		setCurrentProductWMSLayer(state, dt) {
			state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].rawWMS.previous = state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].rawWMS.current;
			state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].rawWMS.current = dt;		
		},
		setCurrentStratification(state, dt) {
			state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].stratification.previous = state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].stratification.current;
			state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].stratification.current = dt;		
		},	
		setCurrentStratificationDate(state, dt) {
			let stratification = state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].stratification;
			stratification.info[stratification.current].date = dt;
			
		},
		
		setCategoryProducts(state, dt) {
			state.categories.products[state.categories.current].info = dt;
		},		
		setStratifications(state, dt) {
			let ret = [];
			dt.forEach((stratification) => {
					ret.push({...stratification, ...{maxZoom: 14, layerId: null, date: 0}});
			});
			state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].stratification.info = ret;
		}
	},
	getters: {
		areaDensityOptions: (state) => {
			let tmp = state.categories.products[state.categories.products[state.categories.current].currentProduct].info[0].value_ranges;
			let ret = JSON.parse(JSON.stringify(state.areaDensityOptions.options));
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
			return state.categories.info[state.categories.current];
		},		
		areaDensity: (state) => {
			if (state.categories.products[state.categories.current].info == null || !(state.categories.products[state.categories.current].currentProduct in state.categories.products[state.categories.current].info))
				return null;
			
			//let tmp = state.categories.products[state.categories.products[state.categories.current].currentProduct].info[0].value_ranges;
			return state.areaDensityOptions.options[state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].density];
		},
		allProductsData:(state) => {
			return state.categories.products;
		},		
		categories: (state) => {
			return state.categories.info;
		},
		clickedCoordinates: (state) => {
			return state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].stratification.clickedCoordinates;
		},
		currentProductAnomaly: (state) => {
			let anomalies   = state.categories.products[state.categories.current].info[state.categories.products[state.categories.current].currentProduct].anomaly_info;
			let current        = state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].anomalies.algorithm;
			return anomalies[current];
		},
		currentProduct: (state) =>{
			if (state.categories.info == null || (state.categories.products[state.categories.current].currentProduct == null))
				return null;
			return state.categories.products[state.categories.current].info[state.categories.products[state.categories.current].currentProduct];
		},
		currentProductAnomalies: (state) => {
			return state.categories.products[state.categories.current].info[state.categories.products[state.categories.current].currentProduct].anomaly_info;
		},
		currentProductAnomalyWMSLayer: (state) => {
			let anomalies =  state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].anomalies;
			return  anomalies.layers[ anomalies.current];
		},
		currentProductWMSLayer: (state) => {
			if (state.categories.info == null || !(state.categories.products[state.categories.current].currentProduct in state.categories.products[state.categories.current].info))
				return null;
			
			let rawWMS = state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].rawWMS;
			return rawWMS.layers[rawWMS.current];
		},
		currentStratification: (state)=> {
			if (state.categories.info == null || !(state.categories.products[state.categories.current].currentProduct in state.categories.products[state.categories.current].info))
				return null;
			
			let stratification = state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].stratification;
			return stratification.info[stratification.current];
		},
		currentStratificationDate: (state) => {
			if (state.categories.info == null)
				return null;
			let stratification = state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].stratification;
			
			if (stratification.current == null)
				return null;
			return stratification.info[stratification.current].dates[stratification.info[stratification.current].date];
		},
		currentView: (state) => {
			return state.currentView;
		},
		previousProductAnomalyWMSLayer: (state) => {
			let anomalies =  state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].anomalies;
			return  anomalies.layers[ anomalies.previous];
		},
		previousProductWMSLayer: (state) => {
			let rawWMS = state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].rawWMS;
			return rawWMS.layers[rawWMS.previous];
		},
		previousStratification: (state) => {
			let stratification = state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].stratification;
			return stratification.info[stratification.previous];
		},
		products:(state)=> {
			if (state.categories.products.length == 0 )
				return null;
			return state.categories.products[state.categories.current].info;
		},
		productsWMSLayers: (state) => {
			return state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].rawWMS.layers;
		},
		productsAnomaliesWMSLayers: (state) => {
			return state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].anomalies.layers;
		},
		selectedPolygon: (state) => {
			return state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].stratification.selectedPolygonId;
		},
		stratifications: (state) => {
			return state.categories.products[state.categories.current].viewInfo[state.categories.products[state.categories.current].currentProduct].stratification.info;
		}
	}
});

const app = createApp(App);
app.use(store);
app.mount('#app')

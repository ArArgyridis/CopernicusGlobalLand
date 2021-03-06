//css
import "bootstrap/dist/css/bootstrap.min.css"

import { createApp } from 'vue'
import { createStore } from 'vuex'
import proj4 from "proj4"
import "bootstrap"


import App from './App.vue'


let projections = [
	{ title: null, epsg: "EPSG:4326", proj: "+proj=longlat +datum=WGS84 +no_defs" },
	{ title: "Global (Web Mercator)", epsg: "EPSG:3857", proj: "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs" }
]

projections.forEach(function (item) {
	proj4.defs(item.epsg, item.proj);
});

let dateEnd = new Date();
let dateStart = new Date();
//dateStart.setDate(dateStart.getDate() - 200);
dateStart = new Date("2020-01-01 00:00:00");
// Create a new store instance.
function computeDescription(str, val1, val2) {
	if (str == "No value")
		return "No value (less than " + val2 +  ")";
	else if (str =="Sparse")
		return "Sparse (" + val1 + ", " + val2 + ")";
	else if (str =="Mild")
		return "Mild (" + val1 + ", " + val2 + ")";
	else 
		return "Dense (greater than " + val1 +  ")";
}


const store = createStore({
	state: {
		proj4: proj4,
		dateEnd: dateEnd,
		dateStart: dateStart,
		areaDensityOptions:{
			options:[
				{
					col: "noval_area_ha",
					description: "No value",
					color_col: "noval_color"
				},
				{
					col:"sparse_area_ha",
					description:"Sparse",
					color_col:"sparseval_color"
				},
				{
					col:"mid_area_ha",
					description:"Mild",
					color_col: "midval_color"
				},
				{
					col:"dense_area_ha",
					description:"Dense",
					color_col: "highval_color"
				}
			],
			areaDensity: null
		},
		categories: {
			info: null,
			current: null,
			previous: null
		},
		products: {
			currentProduct: null,
			currentProductWMSLayer:null,
			info:null,
			previousProductWMSLayer:null,
			wmsLayers:[],
			anomalies: {
				currentWMSLayer: null,
				previouWMSLayer: null,
				wmsLayers: []
			}
		},
		stratifications:{
			currentStratification: null,
			currentStratificationDate:null,
			info:null,
			previousStratification: null
		}
	},
	mutations: {
		appendToProductsAnomaliesWMSLayers(state, dt) {
			state.products.anomalies.wmsLayers = state.products.anomalies.wmsLayers.concat(dt);
			state.products.anomalies.wmsLayers = state.products.anomalies.wmsLayers.sort( function(a, b) {
				let keyA = a.title,
				keyB = b.title;
				if (keyA < keyB) return 1;
				if (keyA > keyB) return -1;
				return 0;
			});
		},		
		appendToProductsWMSLayers(state, dt) {
			state.products.wmsLayers = state.products.wmsLayers.concat(dt);
			state.products.wmsLayers = state.products.wmsLayers.sort( function(a, b) {
				let keyA = a.title,
				keyB = b.title;
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
			state.products.info=null;
			state.products.currentProduct=null;
		},
		clearProductsWMSLayers(state) {
			state.products.wmsLayers = [];		
			state.products.currentProductWMSLayer = null;
			state.products.previousProductWMSLayer = null;
		},
		clearProductsAnomalyWMSLayers(state) {
			state.products.anomalies.wmsLayers = [];
			state.products.anomalies.currentWMSLayer = null;
			state.products.anomalies.previousWMSLayer = null;
		},
		clearStratifications(state) {
			state.stratifications.currentStratification = null;
			state.stratifications.currentStratificationDate = null;
			state.stratifications.info = null;
			state.stratifications.previousStratification = null;
			state.areaDensityOptions.currentDensity = null;
		},
		setCategoryInfo(state, dt) {
			state.categories.info = dt;
			let cont = true;
			for (let i = 0; i < dt.length && cont; i++)
				if (dt[i].active) {
					state.categories.current = i;
					cont = false;
				}
		},
		setCurrentProduct(state, dt) {
			state.products.currentProduct = dt;
		},
		setStratificationAreaDensity(state, dt) {
			state.areaDensityOptions.currentDensity = dt;
		},
		setDateStart(state, dt) {
			state.dateStart = dt;
		},
		setDateEnd(state, dt) {
			state.dateEnd = dt;
		},
		setCurrentProductAnomalyWMSLayer(state, dt) {
			state.products.anomalies.previousWMSLayer = state.products.anomalies.currentWMSLayer;
			state.products.anomalies.currentWMSLayer = dt;
		},
		setCurrentProductWMSLayer(state, dt) {
			state.products.previousProductWMSLayer = state.products.currentProductWMSLayer;
			state.products.currentProductWMSLayer = dt;			
		},
		setCurrentStratification(state, dt) {
			state.stratifications.previousStratification = state.stratifications.currentStratification;
			state.stratifications.currentStratification = dt;
		},	
		setCurrentStratificationDate(state, dt) {
			state.stratifications.currentStratificationDate = dt;
		},
		setProducts(state, dt) {
			state.products.info = dt;
		},
		setStratifications(state, dt) {
			let ret = [];
			dt.forEach((stratification) => {
					ret.push({...stratification, ...{maxZoom: 14, layerId: null}});
			});
			state.stratifications.info = ret;
		}

	},
	getters: {
		areaDensityOptions: (state) => {
			let tmp = [-0.08, 0.225, 0.45, 0.75, 0.92];
			let ret = JSON.parse(JSON.stringify(state.areaDensityOptions.options));
			for (let i = 0; i < ret.length; i++) {
				ret[i].description = computeDescription(ret[i].description, tmp[i], tmp[i+1]);
			}
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
			if (state.areaDensityOptions.currentDensity == null)
				return null;
			return state.areaDensityOptions.options[state.areaDensityOptions.currentDensity];
		},
		categories: (state) => {
			return state.categories.info;
		},
		currentProduct: (state) =>{
			if (state.products.currentProduct == null)
				return null;
			return state.products.info[state.products.currentProduct];
		},
		currentProductAnomalyWMSLayer: (state) => {
			if (state.products.anomalies.currentWMSLayer == null)
				return null;
			return state.products.anomalies.wmsLayers[state.products.anomalies.currentWMSLayer];
		},
		currentProductWMSLayer: (state) => {
			if(state.products.currentProductWMSLayer == null)
				return null;
			return state.products.wmsLayers[state.products.currentProductWMSLayer];
		},
		currentStratification: (state)=> {
			if(state.stratifications.currentStratification == null)
				return null;
			return state.stratifications.info[state.stratifications.currentStratification];
		},
		currentStratificationDate: (state) => {
			return state.stratifications.currentStratificationDate;
		},
		previousProductAnomalyWMSLayer: (state) => {
			if (state.products.anomalies.previousWMSLayer == null)
				return null;
			return state.products.anomalies.wmsLayers[state.products.anomalies.previousWMSLayer];
		},
		previousProductWMSLayer: (state) => {
			if (state.products.previousProductWMSLayer == null)
				return null;
			return state.products.wmsLayers[state.products.previousProductWMSLayer];
		},
		previousStratification: (state) => {
			if(state.stratifications.previousStratification == null)
				return null;
			return state.stratifications.info[state.stratifications.previousStratification];
		},
		products:(state)=> {
			return state.products.info;
		},
		productsWMSLayers: (state) => {
			return state.products.wmsLayers;
		},
		productsAnomaliesWMSLayers: (state) => {
			return state.products.anomalies.wmsLayers;
		},
		stratifications: (state) => {
			return state.stratifications.info;
		}
	}
});

const app = createApp(App);
app.use(store);
app.mount('#app')

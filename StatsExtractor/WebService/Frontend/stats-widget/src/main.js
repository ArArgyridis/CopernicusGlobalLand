//css
import "bootstrap/dist/css/bootstrap.min.css"

import { createApp } from 'vue'
import { createStore } from 'vuex'
import proj4 from "proj4"
import "bootstrap"


import App from './App.vue'
import utils from "./libs/js/utils.js"
import options from "./libs/js/options.js";

var areaDensityOptions = [
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
	];

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

function Categories() {
	this.info= null;
	this.current = null;
	this.previous = null;
}

function AnomaliesProps(product) {
	this.info = product.anomaly_info;
	this.current = this.info[0];
	this.previous = null;
	this.next = null;
	
	this.info.forEach( anomaly => {
		
		anomaly.urls = new Set();
		anomaly.layers = {
			current: null,
			previous: null,
			info: []
		};
		
		anomaly.stratificationInfo = {
			viewMode: 0,
			colorCol:"meanval_color"
		};
		anomaly.style = new styleBuilder(anomaly.stylesld);
		
		product.dates.forEach(date =>{
			let splitDate = date.split("-");
			let url = options.anomaliesWMSURL + anomaly.key + "/" + splitDate[0] +"/" +splitDate[1];
			anomaly.urls.add(url);
		});
	});
}

function styleBuilder(style) {
	let parser = new DOMParser();
	let xmlDoc = parser.parseFromString(style, "text/xml");
	let colors = xmlDoc.getElementsByTagName("sld:ColorMapEntry");
	let colorsArr = [];
	if (colors.length < 10) {
		for (let i = 0; i < colors.length; i++) {
			let tmp = colors[i];
			colorsArr.push(tmp.getAttribute("color"));
		}
	}
	else {
		let step = Math.floor((colors.length-3)/4);
		colorsArr = [
			colors[0].getAttribute("color"),
			colors[step].getAttribute("color"),
			colors[2*step].getAttribute("color"),
			colors[3*step].getAttribute("color"),
			colors[colors.length-1].getAttribute("color")
		];
	}
	return colorsArr; 
}

function ProductViewProps(product) {
	this.anomalies = new AnomaliesProps(product);
	let valueRanges = product.value_ranges;
	let tmpDensity = JSON.parse(JSON.stringify(areaDensityOptions[2]));
	tmpDensity.description = utils.computeDensityDescription(tmpDensity.description, valueRanges[2], valueRanges[3]);
	this.density = areaDensityOptions[2];
	this.rawWMS = new RawWMSProps(product);
	this.statisticsViewMode = 0;
	this.previousStatisticsViewMode = null;
	this.currentDate = product.dates[0],
	this.stratificationInfo = {
		viewMode: 0,
		colorCol:"meanval_color"
	};
	this.style = styleBuilder(product.stylesld);
	product.style = null;
}

function ProductsProps() {
	this.previous = null;
	this.current = null;
	this.info = [];
}

function RawWMSProps(product) {
	this.current = null;
	this.previous = null;
	this.next = null;
	this.urls = new Set();
	this.layers = [];

	product.dates.forEach(date =>{
		let splitDate = date.split("-");
		let url = options.wmsURL + product.name + "/" + splitDate[0] +"/" +splitDate[1];
		this.urls.add(url);
	});
}

function sort(a, b) {
	let keyA = a.title, keyB = b.title;
	if (keyA < keyB) return 1;
	if (keyA > keyB) return -1;
	return 0;
}

function StratificationProps() {
	this.current = null;
	this.previous = null;
	this.next = null;
	this.info = [];
	this.clickedCoordinates = null;
}

function initProduct(product) {
	if (product.viewInfo == null) 
		product.viewInfo = new ProductViewProps(product);
}


const store = createStore({
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
			let tmp = state.categories.current.products.current.viewInfo.anomalies.current.layers.info;
			tmp = tmp.concat(dt);
			state.categories.current.products.current.viewInfo.anomalies.current.layers.info = tmp.sort(sort);
			state.categories.current.products.current.viewInfo.anomalies.current.layers.current = state.categories.current.products.current.viewInfo.anomalies.current.layers.info[0];
		},
		appendToProductsWMSLayers(state, dt) {
			state.categories.current.products.current.viewInfo.rawWMS.layers = state.categories.current.products.current.viewInfo.rawWMS.layers.concat(dt);
			state.categories.current.products.current.viewInfo.rawWMS.layers.sort(sort);
			state.categories.current.products.current.viewInfo.rawWMS.current = state.categories.current.products.current.viewInfo.rawWMS.layers[0];
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
				state.categories.products[state.categories.current].info[state.categories.products[state.categories.current].current].rawWMS = JSON.parse(JSON.stringify(ProductViewProps.rawWMS));
		},
		clearProductsAnomalyWMSLayers(state) {
			if(state.categories.products[state.categories.current].info != null && state.categories.products[state.categories.current].current in state.categories.products[state.categories.current].info)
				state.categories.products[state.categories.current].info[state.categories.products[state.categories.current].current].anomalies = JSON.parse(JSON.stringify(ProductViewProps.anomalies));
			
		},
		clickedCoordinates(state, dt) {
			state.stratifications.current.clickedCoordinates = dt;
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
			state.categories.current.products.current.viewInfo.anomalies.previous = state.categories.current.products.current.viewInfo.anomalies.current;
			state.categories.current.products.current.viewInfo.anomalies.current = dt;
		},
		setStratifiedOrRaw(state, dt) {
			state.stratifiedOrRaw = dt;
		},
		setStratificationAreaDensity(state, dt) {
			state.categories.current.products.current.viewInfo.density = dt;
			state.categories.current.products.current.viewInfo.stratificationInfo.colorCol = dt.color_col;
		},
		setStratificationViewOptions(state, dt) {
			if(state.categories.current.products.current.viewInfo.statisticsViewMode == 0) 
				state.categories.current.products.current.viewInfo.stratificationInfo = dt;
		},
		setDateStart(state, dt) {
			state.dateStart = dt;
		},
		setDateEnd(state, dt) {
			state.dateEnd = dt;
		},
		setProductAnomalyWMSLayer(state, dt) {
			state.categories.current.products.current.viewInfo.anomalies.current.layers.previous = state.categories.current.products.current.viewInfo.anomalies.current.layers.current;
			state.categories.current.products.current.viewInfo.anomalies.current.layers.current = dt;
		},
		setProductStatisticsViewMode(state, dt) {
			state.categories.current.products.current.viewInfo.previousStatisticsViewMode
			state.categories.current.products.current.viewInfo.statisticsViewMode = dt;
		},
		setProductWMSLayer(state, dt) {
			state.categories.current.products.current.viewInfo.rawWMS.previous =state.categories.current.products.current.viewInfo.rawWMS.current;
			state.categories.current.products.current.viewInfo.rawWMS.current = dt;
		},
		setCurrentStratification(state, dt) {
			state.stratifications.previous = state.stratifications.current;
			state.stratifications.current = dt;
		},	
		setCurrentStratificationDate(state, dt) {
			state.categories.current.products.current.viewInfo.stratificationInfo.date = dt;
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

			let ret = JSON.parse(JSON.stringify(areaDensityOptions));
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
			
			return state.categories.current.products.current.viewInfo.density;
		},
		allProductsData:(state) => {
			return state.categories.products;
		},		
		categories: (state) => {
			return state.categories.info;
		},
		clickedCoordinates: (state) => {
			return state.stratifications.current.clickedCoordinates;
		},
		stratificationViewOptions: (state) => {
			let viewOptions = null;

			if(state.stratifiedOrRaw == 0) 
				viewOptions = state.categories.current.products.current.viewInfo.stratificationInfo;
			else if (state.stratifiedOrRaw == 1) 
				viewOptions = state.categories.current.products.current.viewInfo.anomalies.current.stratificationInfo;
			
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
			return state.categories.current.products.current.viewInfo.anomalies.current;
		},
		productAnomalyWMSLayer: (state) => {
			return state.categories.current.products.current.viewInfo.anomalies.current.layers.current
		},
		productPreviousStatisticsViewMode: (state) => {
			if (state.categories.current == null || state.categories.current.products == null)
				return null;
			return state.categories.current.products.current.viewInfo.previousStatisticsViewMode;
		},
		productStatisticsViewMode: (state) => {
			if (state.categories.current == null || state.categories.current.products == null || state.categories.current.products.current == null)
				return null;
			return state.categories.current.products.current.viewInfo.statisticsViewMode;
		},
		productWMSLayer: (state) => {
			if (state.categories.info == null || state.stratifications == null)
				return null;

			return state.categories.current.products.current.viewInfo.rawWMS.current;
		},
		currentStratification: (state)=> {
			return state.stratifications.current;
		},
		currentDate: (state) => {
			if (state.categories.info == null || state.categories.current.products == null)
				return null;

			return state.categories.current.products.current.viewInfo.currentDate;
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
			return state.categories.current.products.current.viewInfo.anomalies.current.layers.previous;
		},
		previousProductWMSLayer: (state) => {
			return state.categories.current.products.current.viewInfo.rawWMS.previous;
		},
		previousStratification: (state) => {
			return state.stratifications.previous;
		},
		products:(state)=> {
			if (state.categories.current == null || state.categories.current.products == null)
				return null;
			return state.categories.current.products.info;
		},
		productWMSLayers: (state) => {
			return state.categories.current.products.current.viewInfo.rawWMS.layers;
		},
		productAnomalyWMSLayers: (state) => {
			return state.categories.current.products.current.viewInfo.anomalies.current.layers.info;
		},
		selectedPolygon: (state) => {
			return state.stratifications.current.selectedPolygonId;
		},
		stratifications: (state) => {
			return state.stratifications;
		}
	}
});

const app = createApp(App);
app.use(store);
app.mount('#app')

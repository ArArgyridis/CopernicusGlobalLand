<!---
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
--->
<template>
<div class="base">
	<div> <!--class="border border-4 rounded"-->
		<div class="row position-relative">
			<div class="position-absolute"><h2>Settings</h2></div>
			<div class="text-end raise" ><div class="btn" v-on:click="closeLeftPanel"><a>x</a></div></div>
		</div>
		<div class="border border-2 rounded">
			<div class="m-3 border border-2 rounded">
				<div class="container">
					<h4> Select Date Range</h4>
					<div class="row">
						<div class ="col text-end align-middle">Starting Date:</div>
						<div class ="col text-start"><Datepicker v-model="dateStart" :format="dateFormat" autoApply :enableTimePicker="false"/></div>
					</div>
				</div>
				<div class="container">
					<div class="row">
						<div class ="col text-end align-middle">Ending Date:</div>
						<div class ="col text-start"><Datepicker class="form-text" v-model="dateEnd" :format="dateFormat" autoApply :enableTimePicker="false"/></div>
					</div>
				</div>
			</div>
			<!-- CLMS PRODUCT CATEGORIES-->
			<div class="row nav nav-tabs">
				<button v-for="nav, idx in categories" v-bind:key="nav.id" class="col-sm nav-link text-muted text-center" v-bind:class="{active: nav.active}" v-on:click="switchActive(idx)" v-bind:id="'chart_'+nav.id">
			{{nav.title}}
		</button>
			</div>	
			<div class="dropdown mt-3">
				<!--<h4> Product Selection</h4>-->
				Current Product: <button class="btn btn-secondary btn-block dropdown-toggle " type="button" id="productDropdownButton" data-bs-toggle="dropdown" aria-expanded="false">{{currentProductDescription}}</button>
				<ul id="productDropdown" class="dropdown-menu scrollable" aria-labelledby="dropdownMenuButton1">
					<li v-for ="(product, key) in products" v-bind:key="key" v-bind:value="key"  v-on:click="setCurrentProduct(key)"><a class="dropdown-item">{{product.description}}</a></li>
				</ul>
			</div>
		</div>
		<div class = "container mt-3" v-if="currentProduct != null">
			<h4>Select Mode</h4>
			<div class="row gap-2">
				<div class="col btn btn-secondary" v-bind:class="{ disabled: viewStratification ==0 }" id="showStratificationButton" v-on:click=showProductOption(0)>
					Stratification-driven Statistics
				</div>
				<div class ="col btn btn-secondary" v-bind:class="{ disabled: viewStratification ==1}" id="showRawDataButton" v-on:click=showProductOption(1)>
					Raw Data Visaulization
				</div>
				<div class ="col btn btn-secondary " v-bind:class="{ disabled: viewStratification ==2 }" id="showProductAnomalyButton" v-on:click=showProductOption(2)>
					Product Anomalies
				</div>
			</div>
			<div class = "mt-3" v-if="viewStratification==0">			
				<!--STRATIFICATION -->
				<div>
					Current stratification: <button class="btn btn-secondary btn-block dropdown-toggle " type="button" id="stratificationDropdownButton" data-bs-toggle="dropdown" aria-expanded="false">{{currentStratificationName}}</button>
					<ul id="stratificationDropdown" class="dropdown-menu scrollable" aria-labelledby="dropdownMenuButton1">
					<li v-for ="(stratification, key) in stratifications" v-bind:key="key" v-bind:value="key"  v-on:click="setCurrentStratification(key)"><a class="dropdown-item">{{stratification.name}}</a></li>
					</ul>
				</div>
				
				<!-- STRATIFICATION DATE-->
				<div class="mt-2" v-if="currentStratificationName != 'Select stratification'">Select date: <button class="btn btn-secondary btn-block dropdown-toggle " type="button" id="wmsLayersDropdownButton" data-bs-toggle="dropdown" aria-expanded="false">{{currentStratificationDate.substring(0,10)}} </button>
					<ul id="wmsLayersDropdown" class="dropdown-menu scrollable" aria-labelledby="dropdownMenuButton1" v-if="currentStratification != null">
					<li v-for ="(date, key) in stratificationDates" v-bind:key="key" v-bind:value="key"  v-on:click="setCurrentStratificationDate(date)"><a class="dropdown-item">{{date.substring(0,10)}}</a></li>
					</ul>
				</div>
				
				<!-- AREA DENSITY-->
				<div class="mt-2" v-if="currentStratificationDate != 'Select date'">
					Area Density <button class="btn btn-secondary btn-block dropdown-toggle " type="button" id="areaDropdownButton" data-bs-toggle="dropdown" aria-expanded="false">{{currentAreaDensity}}</button>
					<ul id="currentAreaDropdown" class="dropdown-menu" aria-labelledby="dropdownMenuButton1">
						<li v-for ="(densityType, key) in areaDensityTypes" v-bind:key="key" v-bind:value="key"  v-on:click="setStratificationAreaDensity(key)"><a class="dropdown-item">{{densityType.description}}</a></li>
					</ul>
				</div>
			</div>		
			
			<!-- WMS RAW DATA LAYER-->
			<div class= "mt-3" v-if="viewStratification==1">
				Current WMS Layer: <button class="btn btn-secondary btn-block dropdown-toggle " type="button" id="wmsLayersDropdownButton" data-bs-toggle="dropdown" aria-expanded="false">{{currentProductWMSLayer}}</button>
				<ul id="wmsDropdown" class="dropdown-menu scrollable" aria-labelledby="dropdownMenuButton1">
					<li v-for ="(wms, key) in wmsLayers" v-bind:key="key" v-bind:value="key"  v-on:click="setCurrentWMS(key)"><a class="dropdown-item">{{wms.title}}</a></li>
				</ul>
			</div>
			
			<!-- WMS ANOMALY DATA LAYER-->
			<div class= "mt-3" v-if="viewStratification==2">
				<div>
				Anomaly Algorithm: <button class="btn btn-secondary btn-block dropdown-toggle " type="button" id="anomalyWMSLayersDropdownButton" data-bs-toggle="dropdown" aria-expanded="false">{{currentProductAnomaly}}</button>
				<ul id="wmsDropdown" class="dropdown-menu scrollable" aria-labelledby="dropdownMenuButton1">
					<li v-for ="(anomaly, key) in currentProductAnomalies" v-bind:key="key" v-bind:value="key"  v-on:click="setCurrentProductAnomaly(key)"><a class="dropdown-item">{{anomaly.description}}</a></li>
				</ul>
				</div>
			
			
				
				Current Anomaly WMS Layer: <button class="btn btn-secondary btn-block dropdown-toggle " type="button" id="anomalyWMSLayersDropdownButton" data-bs-toggle="dropdown" aria-expanded="false">{{currentProductAnomalyWMSLayer}}</button>
				<ul id="wmsDropdown" class="dropdown-menu scrollable" aria-labelledby="dropdownMenuButton1">
					<li v-for ="(wms, key) in wmsAnomalyLayers" v-bind:key="key" v-bind:value="key"  v-on:click="setCurrentAnomalyWMS(key)"><a class="dropdown-item">{{wms.title}}</a></li>
				</ul>
			</div>
			
		</div>
	</div>
</div>

</template>


<script>
import Datepicker from '@vuepic/vue-datepicker';
import '@vuepic/vue-datepicker/dist/main.css';
import requests from '../libs/js/requests.js';

export default {
	name: 'Left Panel',
	components: {
		Datepicker
	},
	props: {},
	computed: {
		areaDensityTypes:{
			get() {
				return this.$store.getters.areaDensityOptions;
			}
		},
		categories() {
			return this.$store.getters.categories;
		},
		currentProductDescription: {
			get() {
				if (this.currentProduct == null)
					return "Select Product";
				return this.$store.getters.currentProduct.description;
			}
		},
		currentProduct:{
			get() {
				return this.$store.getters.currentProduct;
			},
			set(val){
				this.$store.commit("setCurrentProduct", val);
				this.$emit("currentProductChange");
			}
		},
		currentProductAnomaly: {
			get() {
				if (this.$store.getters.currentProductAnomaly == null)
					return "No Anomaly Selected";
				return  this.$store.getters.currentProductAnomaly.description;
			},
			set(val) {
				this.$store.commit("setCurrentProductAnomaly",val);
			}
		},
		currentProductAnomalies: {
			get() {
				return this.$store.getters.currentProductAnomalies;
			}
		},
		currentProductAnomalyWMSLayer: {
			get() {
				if (this.$store.getters.currentProductAnomalyWMSLayer == null)
					return "No Layer Selected";
				return this.$store.getters.currentProductAnomalyWMSLayer.title;
			},
			set(val) {
				this.$store.commit("setCurrentProductAnomalyWMSLayer",val);
			}
		},
		currentProductWMSLayer: {
			get() {
				if (this.$store.getters.currentProductWMSLayer == null)
					return "No Layer Selected";
				return this.$store.getters.currentProductWMSLayer.title;
			},
			set(val) {
				this.$store.commit("setCurrentProductWMSLayer",val);
			}
		},
		currentAreaDensity: {
			get() {
				if (this.$store.getters.areaDensity == null)
					return "Select Area Density";
				return this.$store.getters.areaDensity.description;
			},
			set(val) {
				this.$store.commit("setStratificationAreaDensity",val);
			}
		},		
		currentStratificationName: {
			get() {
				if (this.currentStratification == null)
					return "Select stratification";
				return this.$store.getters.currentStratification.name;
			}
		},
		currentStratificationDate: {
			get() {
				if(this.$store.getters.currentStratificationDate == null)
					return "Select date";
				return this.$store.getters.currentStratificationDate;
			},
			set(val) {
				this.$store.commit("setCurrentStratificationDate", val);
				this.$emit("stratificationDateChange");
			}
		},		
		currentStratification: {
			get() {
				return this.$store.getters.currentStratification;
			},
			set(val) {
				this.$store.commit("setCurrentStratification", val);
				this.$emit("stratificationChange");
			}
		},
		dateStart: {
			get() {
				return this.$store.getters.dateStart;
			},
			set(date) {
				this.$store.commit("setDateStart", date);
				this.$emit("updateProducts");
			}			
		},
		dateEnd: {
			get() {
				return this.$store.getters.dateEnd;
			},
			set(date) {
				this.$store.commit("setDateEnd", date);
				this.$emit("updateProducts");
			}
		},
		products: {
			get() {
				return this.$store.getters.products;
			}
		},
		stratifications: {
			get(){
				return this.$store.getters.stratifications;
			}
		},
		stratificationDates:{
			get() {
				let tmpDates = Object.keys(this.$store.getters.currentStratification.dates);
				tmpDates.sort( function(a, b) {
					let keyA = a.title,
					keyB = b.title;
					if (keyA < keyB) return -1;
					if (keyA > keyB) return 1;
					return 0;
				});
				tmpDates.reverse();
				return tmpDates;
			}
		},
		wmsAnomalyLayers: {
			get() {
				return this.$store.getters.productsAnomaliesWMSLayers;
			}
		},
		wmsLayers:{
			get() {
				return this.$store.getters.productsWMSLayers;
			}		
		},
		viewStratification: {
			set(val) {
				this.$store.commit("setCurrentView",val);
			},
			get() {
				return this.$store.getters.currentView;
			}
		}
	},
	data() {
		return {
			dateFormat: "dd MMM yyyy"
		}
	},
	methods: {
		init() {
			requests.categories().then((response) => {
				this.$store.commit("setCategoryInfo", response.data.data);
				this.$emit("updateProducts");
			});
		},
		closeLeftPanel() {
			this.$emit("closeLeftPanel");
		},
		getProduct(key) {
			return this.products[key];
		},
		getStratification(key) {
			return this.stratifications[key];
		},
		setCurrentProduct(key) {
			this.currentProduct = key;
		},
		setCurrentProductAnomaly(key) {
			this.currentProductAnomaly = key;
			this.$emit("currentProductAnomalyChange");
		},
		setCurrentStratification(key) {
			this.currentStratification = key;
		},
		setStratificationAreaDensity(key) {
			this.currentAreaDensity = key;
			this.$emit("stratificationAreaDensityChange");
		},
		setCurrentStratificationDate(key) {
			this.currentStratificationDate = key;
		},
		setCurrentAnomalyWMS(key) {
			this.currentProductAnomalyWMSLayer = key;
			this.$emit("anomalyWMSChange");
		},
		setCurrentWMS(key) {
			this.currentProductWMSLayer = key;
			this.$emit("rawWMSChange");
		},
		showProductOption(val) {
			this.viewStratification = val;
			this.$emit("switchViewMode", {id:val});
		},
		switchActive(id) {
			if (id == null)
				return;
			this.$store.commit("changeCategory", id);
			
			if (this.$store.getters.products==null || this.$store.getters.products.length == 0)
				this.$emit("updateProducts");
		}
	},
	mounted() {
		this.init();
	}
}
</script>

<style scoped>
.base {
	background-color: rgb(234, 234, 218, 0.7);
	height: 100vh;
	color: black;
}
h3 {
	display:inline-block;
}
.h2border {
	position: absolute;
}


.halfWidth {
	width:50%;
}

.raise{
	z-index:1;
}
.roundBorder {
	border-radius: 5px;
}

.scrollable {
	max-height:30vh;
	overflow-y: scroll;
}

</style>

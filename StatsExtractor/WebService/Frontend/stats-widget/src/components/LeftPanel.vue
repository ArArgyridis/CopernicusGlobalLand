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
	<div>
		<div class="row mb-2">
			<div class="mt-2"><h5>Copernicus Global Land Monitoring Service Product Categories</h5></div>
			<!--<div class="text-end raise" ><div class="btn" v-on:click="closeLeftPanel"><a>x</a></div></div>-->
		</div>
	
		<div class="row nav nav-tabs mt-3 mb-3">
			<button v-for="nav in categories" v-bind:key="nav.id" class="col-sm nav-link text-muted text-center" v-bind:class="{active: nav.active}" v-on:click="switchActiveCategory(nav)" v-bind:id="'chart_'+nav.id">{{nav.title}}</button>
		</div>
		
		<div class="row mt-1">
			<div class="col d-flex justify-content-end my-auto">Current Product: </div>
			<div class="col d-flex justify-content-start"><button class="btn btn-secondary btn-block dropdown-toggle " type="button" id="productDropdownButton" data-bs-toggle="dropdown" aria-expanded="false">{{productDescription}}</button>
				<ul id="productDropdown" class="dropdown-menu scrollable" aria-labelledby="dropdownMenuButton1">
					<li v-for ="(product, key) in products" v-bind:key="key" v-bind:value="key"  v-on:click="setProduct(product)"><a class="dropdown-item">{{product.description}}</a></li></ul></div>
		</div>
		
		<div class="row mt-1" v-if="product != null">
			<div class="col d-flex justify-content-end my-auto">Current Variable: </div>
			<div class="col d-flex justify-content-start"><button class="btn btn-secondary btn-block dropdown-toggle " type="button" id="productDropdownButton" data-bs-toggle="dropdown" aria-expanded="false">{{product.currentVariable.description}}</button>
				<ul id="productDropdown" class="dropdown-menu scrollable" aria-labelledby="dropdownMenuButton1">
					<li v-for ="(variable, key) in product.variables" v-bind:key="key" v-bind:value="key"  v-on:click="setVariable(variable)"><a class="dropdown-item">{{variable.description}}</a></li></ul></div>
		</div>
		
		<div class = "container mt-3 ml-3 mr-3" v-if="product != null">
			<h5>View Options</h5>
			
			<div class="row nav nav-tabs">
				<button v-for="nav, idx in stratifiedOrRawViewModes" v-bind:key="idx" class="col-sm nav-link text-muted text-center" v-bind:class="{active: stratifiedOrRaw == idx}" v-on:click="stratifiedOrRaw=idx" v-bind:id="'stratifiedOrRawViewModes_'+idx">{{nav}}</button>
			</div>	
			
			<div  class="mt-3"><!--STRATIFICATION -->
				<div class="row">
					<div class="col d-flex justify-content-end my-auto">Stratification:</div>
					<div class="col d-flex justify-content-start">
						<button class="btn btn-secondary btn-block dropdown-toggle " type="button" id="stratificationDropdownButton" data-bs-toggle="dropdown" aria-expanded="false">{{currentStratificationName}}</button>
						<ul id="stratificationDropdown" class="dropdown-menu scrollable" aria-labelledby="dropdownMenuButton1">
							<li v-for ="(stratification, key) in stratifications.info" v-bind:key="key" v-bind:value="key"  v-on:click=" currentStratification = stratification"><a class="dropdown-item">{{stratification.description}}</a></li>
						</ul>
					</div>
				</div>
			</div>
			
			<div class="row mt-2" v-if="currentStratificationName != 'Select stratification'">
				<div class="col d-flex justify-content-end my-auto">Date:</div>
				<div class="col d-flex justify-content-start">
					<button class="btn btn-secondary btn-block dropdown-toggle " type="button"  data-bs-toggle="dropdown" aria-expanded="false">{{currentDate.substring(0,10)}} </button>
					<ul id="wmsLayersDropdown" class="dropdown-menu scrollable" aria-labelledby="dropdownMenuButton1" v-if="currentStratification != null">
						<li v-for ="(date, idx) in productDates" v-bind:key="idx" v-bind:value="idx"  v-on:click="currentDate=date"><a class="dropdown-item">{{date.substring(0,10)}}</a></li>
					</ul>
				</div>
			</div>
				
			<div class="row mt-2" v-if="product != null">
				<div class="col d-flex justify-content-end my-auto">Statistics Mode:</div>
				<div class="col d-flex justify-content-start">
					<button class="btn btn-secondary btn-block dropdown-toggle " type="button"  data-bs-toggle="dropdown" aria-expanded="false">{{ currentStatisticsViewMode}} </button>
					<ul id="wmsLayersDropdown" class="dropdown-menu scrollable" aria-labelledby="dropdownMenuButton1" v-if="currentStratification != null">
					<li v-for ="(md, idx) in statisticsViewMode" v-bind:key="idx" v-bind:value="idx"  v-on:click="statisticsViewSelectedMode=idx"><a class="dropdown-item">{{md}}</a></li>
						</ul>
				</div>
			</div>
			<div class= "row mt-2" v-if="statisticsViewSelectedMode==1" >
				<div class="col d-inline-flex justify-content-end my-auto">Anomaly Algorithm:</div>
				<div class="col d-flex justify-content-start">
					<button class="btn btn-secondary btn-block dropdown-toggle " type="button" id="anomalyWMSLayersDropdownButton" data-bs-toggle="dropdown" aria-expanded="false">{{currentAnomaly.description}}</button>
					<ul id="wmsDropdown" class="dropdown-menu scrollable" aria-labelledby="dropdownMenuButton1">
						<li v-for ="(anomaly, key) in currentAnomalies" v-bind:key="key" v-bind:value="key"  v-on:click="setProductAnomaly(anomaly)"><a class="dropdown-item">{{anomaly.description}}</a></li>
					</ul>
				</div>
			</div>
	
			<div v-bind:hidden="(statisticsViewSelectedMode == 1 ||  stratifiedOrRaw == 1)">
				<div class="row nav nav-tabs mt-2" >
					<button v-for="nav, idx in polygonViewMode" v-bind:key="idx" class="col-sm nav-link text-muted text-center" v-bind:class="{active: stratificationViewOptions.viewMode == idx}" v-on:click="stratificationViewOptions = idx" v-bind:id="'polygonviewmode_'+idx">{{nav}}</button>
				</div>
				
				<div v-if="productDates != 'Select date' && stratifiedOrRaw == 0 && stratificationViewOptions.viewMode == 1">
					<div class="row mt-2">
						<div class="col d-flex justify-content-end my-auto">Region Coverage Percentage for Density:</div>
						<div class="col d-flex justify-content-start">
							<button class="btn btn-secondary btn-block dropdown-toggle " type="button" id="areaDropdownButton" data-bs-toggle="dropdown" aria-expanded="false">{{currentAreaDensity}}</button>
							<ul id="currentAreaDropdown" class="dropdown-menu" aria-labelledby="dropdownMenuButton1">
								<li v-for ="(densityType, key) in areaDensityTypes" v-bind:key="key" v-bind:value="key"  v-on:click="setStratificationAreaDensity(densityType)"><a class="dropdown-item">{{densityType.description}}</a></li>
							</ul>
						</div>
					</div>
				</div>
			</div>
			<Legend class="mt-3" ref="legend" v-bind:mode="legendMode"/>
			
			<div>
				<div class="m-3 border border-2 rounded">
					<div class="container mt-3">
						<h5>Analysis Date Range</h5>
						<div class="row">
							<div class ="col text-end my-auto">Starting Date:</div>
							<div class ="col text-start"><Datepicker v-model="dateStart" :format="dateFormat" autoApply :enableTimePicker="false"/></div>
						</div>
					</div>
					<div class="container mb-3">
						<div class="row">
							<div class ="col text-end my-auto">Ending Date:</div>
							<div class ="col text-start"><Datepicker class="form-text" v-model="dateEnd" :format="dateFormat" autoApply :enableTimePicker="false"/></div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>

</template>


<script>
import Datepicker from '@vuepic/vue-datepicker';
import '@vuepic/vue-datepicker/dist/main.css';
//import requests from '../libs/js/requests.js';
import Legend from "./libs/Legend.vue";

export default {
	name: 'Left Panel',
	components: {
		Datepicker,
		Legend
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
		currentStatisticsViewMode() {
			if (this.statisticsViewSelectedMode == null)
				return "Select Statistics View Mode";
			
			return this.statisticsViewMode[this.statisticsViewSelectedMode];
		},
		productDescription: {
			get() {
				if (this.product == null)
					return "Select Product";

				return this.$store.getters.product.description;
			}
		},
		legendMode() {
			let mode = null;
			if (this.statisticsViewSelectedMode == 0) {
				if (this.stratifiedOrRaw == 0) {
					if (this.stratificationViewOptions.viewMode == 0) 
						mode = "Raw"
					
					else if (this.stratificationViewOptions.viewMode == 1) 
						mode = "Density";
				}
				else if (this.stratifiedOrRaw == 1) {
					mode = "Raw"
				}
			}
			else if (this.statisticsViewSelectedMode == 1) {
				mode = "Anomalies";
			}
			return mode;
		},		
		product:{
			get() {
				return this.$store.getters.product;
			},
			set(val){
				this.$store.commit("setProduct", val);
				this.$store.commit("currentWMSByDateAndMode");
				this.$emit("updateView");
			}
		},
		variable: {
			get() {
				return this.$store.getters.variable;
			},
			set(val) {
				this.$store.commit("setVariable", val);
				this.$store.commit("currentWMSByDateAndMode");
				this.$emit("updateView");
			}
		},
		currentAnomaly: {
			get() {
				if (this.$store.getters.currentAnomaly == null)
					return {description: "No Algorithm Selected"};
				return  this.$store.getters.currentAnomaly;
			},
			set(val) {
				this.$store.commit("setProductAnomaly",val);
			}
		},
		currentAnomalies: {
			get() {
				return this.$store.getters.currentAnomalies;
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
				return this.$store.getters.currentStratification.description;
			}
		},
		productDates: {
			get() {
				if(this.$store.getters.productDates == null)
					return "Select date";
				return this.$store.getters.productDates;
			}
		},		
		currentStratification: {
			get() {
				return this.$store.getters.currentStratification;
			},
			set(val) {
				this.$store.commit("setCurrentStratification", val);
				this.$emit("stratificationChanged");
			}
		},
		currentDate:{
			get() {
				if (this.$store.getters.currentDate == null)
					return "Select Date";
				return this.$store.getters.currentDate;
			}
			,set(val) {
				this.$store.commit("setCurrentDate", val);
				this.$store.commit("currentWMSByDateAndMode");
				this.$emit("dateChanged");
			}
		},
		dateStart: {
			get() {
				return this.$store.getters.dateStart;
			},
			set(date) {
				this.$store.commit("setDateStart", date);
				this.stratifiedOrRaw = 0;
				this.$emit("resetProducts");
			}			
		},
		dateEnd: {
			get() {
				return this.$store.getters.dateEnd;
			},
			set(date) {
				this.$store.commit("setDateEnd", date);
				this.stratifiedOrRaw = 0;
				this.$emit("resetProducts");
			}
		},
		products: {
			get() {
				return this.$store.getters.products;
			}
		},
		stratifications: {
			get() {
				return this.$store.getters.stratifications;
			}
		},
		stratificationViewOptions: {
			get() {
				return this.$store.getters.stratificationViewOptions;
			},
			set(dt) {
				let colorCol = "meanval_color";
				if (dt == 1)
					colorCol = this.$store.getters.areaDensity.color_col;

				let commit = {
					colorCol: colorCol,
					viewMode: dt
				};
				
				this.$store.commit("setStratificationViewOptions", commit);
				this.$emit("stratificationViewOptionsChanged");
				
			}
		},
		statisticsViewSelectedMode: {
			get() {
				return this.$store.getters.productStatisticsViewMode;
			}
			,set(val) {
				this.$store.commit("setProductStatisticsViewMode", val);
				this.$store.commit("currentWMSByDateAndMode");
				this.$emit("statisticsViewModeChanged");
				
			}
		},
		stratifiedOrRaw: {
			get() {
				return this.$store.getters.stratifiedOrRaw;
			},
			set(val) {
				this.$store.commit("setStratifiedOrRaw",val);
				this.$emit("stratifiedOrRawChanged");
			}
		},
		wmsLayers:{
			get() {
				let wms = this.$store.getters.productWMSLayers;
				if (this.statisticsViewSelectedMode == 1)
					wms = this.$store.getters.productAnomalyWMSLayers;
				return wms;
			}		
		}

	},
	data() {
		return {
			dateFormat: "dd MMM yyyy",
			stratifiedOrRawViewModes: ["Statistics By Stratification", "Raw Data"],
			polygonViewMode: ["Mean values", "Density-driven"],
			statisticsViewMode: ["Product Values", "Anomalies"],
		}
	},
	methods: {
		init() {},
		getProduct(key) {
			return this.products[key];
		},
		getStratification(key) {
			return this.stratifications[key];
		},
		setProduct(key) {
			this.product = key;
		},
		setVariable(key) {
			this.variable = key;
		},
		setProductAnomaly(key) {
			this.productAnomaly = key;
			this.$emit("updateView");
		},
		setCurrentStratification(key) {
			this.currentStratification = key;
		},
		setStratificationAreaDensity(key) {
			this.currentAreaDensity = key;
			
			this.$emit("stratificationDensityChanged");
		},
		switchActiveCategory(id) {
			if (id == null)
				return;
			this.$store.commit("changeCategory", id);
			
			if (this.$store.getters.products==null || this.$store.getters.products.length == 0)
				this.$emit("getCategoryProducts");
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

.legend{
	width: 100%;
	height: 100px;
	position: relative;

}
.legendColor {
	background-image: linear-gradient(to right, #F7FCF5 0%, #C9EAC2 25%, #7BC77C 50%, #2A924B 75%, #00441B 100%);
}
.legendColor:empty::after{
	content: ".";
	visibility:hidden;
}



</style>

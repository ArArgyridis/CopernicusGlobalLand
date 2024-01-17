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
	<div class="container">
		<div class="row mb-2 panelHeader align-items-center">
			<div class="col mt-2"><span class="align-middle"><h5>NatStats</h5></span>
				<span>An Anomalies and Statistics Analysis Tool for Copernicus GLMS</span>
			</div>		
		</div>
		<div class="row nav nav-tabs mt-3 mb-3">
			<button v-for="nav in categories" v-bind:key="nav.id" class="col-sm nav-link text-muted text-center" v-bind:class="{active: nav.active}" v-on:click="switchActiveCategory(nav)" v-bind:id="'chart_'+nav.id">{{nav.title}}</button>
		</div>
		
		<div class="row">
			<div class="container mt-1 ml-2 mr-2">
				<h5>Time Range for Timeseries Analysis</h5>
				<div class=row>
					<div class="col">From Date</div>
					<div class="col">To Date</div>
					<div class="col">Displayed</div>
					<div class="col-1"></div>
				</div>
				<div class="row mb-3 align-items-center">
					<div class ="col d-flex text-justify"><Datepicker class="dp__theme_dark" v-model="dateStart" :format="dateFormat" autoApply :enableTimePicker="false" v-bind:clearable="false" dark/></div>
					<div class ="col d-flex text-justify"><Datepicker v-model="dateEnd" :format="dateFormat" autoApply :enableTimePicker="false" class="dp__theme_dark"  dark v-bind:clearable="false"/></div>
					<div class="col d-flex justify-content-center">
						<button class="btn btn-secondary btn-block dropdown-toggle " type="button"  data-bs-toggle="dropdown" aria-expanded="false">{{ new Date(currentDate).toDateString().substring(3,15) }} </button>
						<ul id="wmsLayersDropdown" class="dropdown-menu scrollable" aria-labelledby="dropdownMenuButton1" v-if="currentStratification != null">
							<li v-for ="(date, idx) in productDates" v-bind:key="idx" v-bind:value="idx"  v-on:click="currentDate=date"><a class="dropdown-item">{{new Date(date).toDateString().substring(3,15)}}</a></li>
						</ul>
					</div>
					<div class="col-1">
						<div class="dropdown show">
							<a class="btn btn-secondary btn-circle dropdown-toggle"  href="#" role="button" data-bs-toggle="dropdown" id="downloadMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="true"> <!--v-bind:href="downloadDataPath"-->
								<FontAwesomeIcon icon="download"  size="1x" />
							</a>
							<div class="dropdown-menu" aria-labelledby="downloadMenuButton">
								<a class="dropdown-item" v-bind:href="downloadDataPath">Download Current Data</a>
								<a class="dropdown-item" href="#" v-on:click="showDownloadPanel=true">Retrieve from Archive...</a>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
		
		<h5>Product Options</h5>
		<div class="accordion accordion-flush overflow-auto mb-2" id="productOptions" v-if="product != null">
			<div class="accordion-item" id="acc1">
				<h2 class="accordion-header" id="headingTwenty">
					<button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#collapseProductOptions" aria-expanded="true" aria-controls="collapseProductOptions"> <b>Product:&nbsp;</b>{{productDescription}} </button>
				</h2>
				
				<div id="collapseProductOptions" class="accordion-collapse collapse show overflow-auto" aria-labelledby="headingTwenty" data-bs-parent="#productOptions">
					<div class="accordion-body">
						<select class="form-select" size="4" aria-label="size 3 select example">
							<option v-for ="(prd, key) in products" v-bind:key="key" v-bind:value="key"  v-on:click="product=prd" v-bind:selected="product.id == prd.id">{{prd.description}}</option>
						</select>
					</div>
				</div>
			</div>
			<div class="accordion-item">
				<h2 class="accordion-header" id="headingTwentyOne">
					<button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapseProductOptionsOne" aria-expanded="false" aria-controls="collapseProductOptionsOne"> <b>Variable: &nbsp;</b> {{variable.description}} </button>
				</h2>
				<div id="collapseProductOptionsOne" class="accordion-collapse collapse" aria-labelledby="headingTwentyOne" data-bs-parent="#productOptions">
					<div class="accordion-body">
						<select class="form-select" size="4" aria-label="size 3 select example">
							<option v-for ="(vrd, key) in product.variables" v-bind:key="key" v-bind:value="key"  v-on:click="setVariable(vrd)" v-bind:selected="variable.id==vrd.id">{{vrd.description}}</option>
						</select>
					</div>
				</div>
			</div>                
			<div class="accordion-item">
				<h2 class="accordion-header" id="headingTwentyTwo">
					<button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapseProductOptionsTwo" aria-expanded="false" aria-controls="collapseProductOptionsOne"> <b> Consolidation Period:</b>&nbsp;{{product.rtFlag.description}} </button>
				</h2>
				<div id="collapseProductOptionsTwo" class="accordion-collapse collapse" aria-labelledby="headingTwentyTwo" data-bs-parent="#productOptions">
					<div class="accordion-body">
						<select class="form-select" size="4" aria-label="size 3 select example">
							<option v-for ="(rtPeriod, key) in consolidationPeriods" v-bind:key="key" v-bind:value="key"  v-on:click="setConsolidationPeriod(rtPeriod)" v-bind:selected="product.rtFlag.id == rtPeriod.id"><a class="dropdown-item">{{rtPeriod.description}}</a></option>
						</select>
					</div>
				</div>
			</div>
		</div>

		<h5>Display Options</h5>
		<div class="accordion accordion-collapse collapse show overflow-auto" id="viewOptions" v-if="product != null">
			<div class="accordion-item">
				<h2 class="accordion-header" id="headingTwentyOne">
					<button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapseViewOptionsThree" aria-expanded="false" aria-controls="collapseViewOptionsThree"> <b>Boundary Selection: &nbsp;</b> {{currentStratificationName}} </button>
				</h2>
				<div id="collapseViewOptionsThree" class="accordion-collapse collapse" aria-labelledby="headingTwentyOne" data-bs-parent="#viewOptions">
					<div class="accordion-body">
						<select class="form-select" size="4" aria-label="size 3 select example">
							<option v-for ="(stratification, key) in stratifications.info" v-bind:key="key" v-bind:value="key"  v-on:click=" currentStratification = stratification" v-bind:selected="currentStratification.id == stratification.id"><a class="dropdown-item">{{stratification.description}}</a></option>
						</select>
					</div>
				</div>
			</div>
		
			<div class="accordion-item" id="acc4">
				<h2 class="accordion-header" id="headingTwenty2">
					<button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapseViewOptions2" aria-expanded="true" aria-controls="collapseViewOptions2"> <b>Data Values Selection:&nbsp;</b>{{viewModeTitle}} </button>
				</h2>
				
				<div id="collapseViewOptions2" class="accordion-collapse collapse overflow-auto" aria-labelledby="headingTwenty2" data-bs-parent="#viewOptions">
					<div class="accordion-body">
					<select class="form-select" size="2" aria-label="size 3 select example">
						<option v-for="nav, idx in stratifiedOrRawViewModes" v-bind:key="idx" v-on:click="stratifiedOrRaw=idx" v-bind:id="'stratifiedOrRawViewModes_'+idx">{{nav}}</option>
					</select>
					</div>
					<div class="row mt-2">
						<div class="col d-flex justify-content-end my-auto">Visualized Mean Values:</div>
						<div class="col d-flex justify-content-start">
								<button class="btn btn-secondary btn-block dropdown-toggle " type="button" id="areaDropdownButton" data-bs-toggle="dropdown" aria-expanded="false"  v-bind:disabled="(statisticsViewSelectedMode == 1 ||  stratifiedOrRaw == 1)">{{polygonViewMode[stratificationViewOptions.viewMode]}}</button>
								<ul id="currentAreaDropdown" class="dropdown-menu" aria-labelledby="dropdownMenuButton1">
								<li v-for ="(nav, idx) in polygonViewMode" v-bind:key="idx" v-bind:value="idx"  v-on:click="stratificationViewOptions=idx"><a class="dropdown-item">{{nav}}</a></li>
								</ul>
							</div>
					</div>
					<div class="row mt-2">
						<div class="col d-flex justify-content-end my-auto">Value Range:</div>
						<div class="col d-flex justify-content-start">
							<button class="btn btn-secondary btn-block dropdown-toggle " type="button" id="areaDropdownButton" data-bs-toggle="dropdown" aria-expanded="false" v-bind:disabled="(stratifiedOrRaw == 0 && this.stratificationViewOptions.viewMode == 0) || stratifiedOrRaw == 1">{{currentAreaDensity}}</button>
							<ul id="currentAreaDropdown" class="dropdown-menu" aria-labelledby="dropdownMenuButton1">
								<li v-for ="(densityType, idx) in areaDensityTypes" v-bind:key="idx" v-bind:value="idx"  v-on:click="setStratificationAreaDensity(densityType)" v-bind:selected="idx == stratifiedOrRaw"><a class="dropdown-item">{{densityType.description}}</a></li>
							</ul>
						</div>
					</div>
				</div>
			</div>
			<div class="accordion-item">
				<h2 class="accordion-header" id="headingTwentyOne">
					<button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapseViewOptionsOne" aria-expanded="false" aria-controls="collapseViewOptionsOne"> <b>Analysis Mode: &nbsp;</b> {{statisticsViewMode[statisticsViewSelectedMode]}} </button>
				</h2>
				<div id="collapseViewOptionsOne" class="accordion-collapse collapse" aria-labelledby="headingTwentyOne" data-bs-parent="#viewOptions">
					<div class="accordion-body">
						<select class="form-select" size="2" aria-label="size 3 select example" >
							<option v-for ="(md, idx) in statisticsViewMode" v-bind:key="idx" v-bind:value="idx"  v-on:click="statisticsViewSelectedMode=idx" v-bind:disabled="variable.anomaly_info == null" v-bind:selected="idx == statisticsViewSelectedMode"><a class="dropdown-item">{{md}}</a></option>
						</select>
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
import { library } from '@fortawesome/fontawesome-svg-core';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { faDownload} from '@fortawesome/free-solid-svg-icons'
import Legend from "./libs/Legend.vue";
import {consolidationPeriods} from "../libs/js/constructors.js";

library.add(faDownload);

export default {
	name: 'Left Panel',
	components: {
		Datepicker,
		Legend,
		FontAwesomeIcon
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
		consolidationPeriods() {
			let tmpPeriods = new consolidationPeriods(this.product.rt);
			let retPeriods = new Array();
			tmpPeriods.forEach(period => {
				if (period.id in this.product.dates)
					retPeriods.push(period);
			});
			return retPeriods;
		},
		currentStatisticsViewMode() {
			if (this.statisticsViewSelectedMode == null)
				return "Select Statistics View Mode";
			
			return this.statisticsViewMode[this.statisticsViewSelectedMode];
		},
		downloadDataPath() {
			if(this.$store.getters.currentCogLayer == null)
				return null;
			return this.$store.getters.currentCogLayer.raw;


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
				this.$store.commit("currentCogByDateAndMode");
				this.$emit("updateView");
			}
		},
		variable: {
			get() {
				return this.$store.getters.variable;
			},
			set(val) {
				this.$store.commit("setVariable", val);
				this.$store.commit("currentCogByDateAndMode");
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
				return  this.$store.getters.currentDate;
			}
			,set(val) {
				this.$store.commit("setCurrentDate", val);
				this.$store.commit("currentCogByDateAndMode");
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
		showDownloadPanel: {
			get() {
				return this.$store.getters.showDownloadPanel;
			},
			set(dt) {
				this.$store.commit("showDownloadPanel", dt);
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
				this.$store.commit("currentCogByDateAndMode");
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
		viewModeTitle(){
			let ret = this.stratifiedOrRawViewModes[this.stratifiedOrRaw];
			if (this.stratifiedOrRaw == 0) {
				ret += " (" +this.polygonViewMode[this.stratificationViewOptions.viewMode] +")";
			}
			return ret;
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
			dateFormat: "MMM dd yyyy",
			stratifiedOrRawViewModes: ["Mean Values per Region's Polygon", "Pixel View"],
			polygonViewMode: ["Raw data Mean Values", "Area Percentage with Values in Range"],
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
		setConsolidationPeriod(rtPeriod) {
			this.$store.commit("setConsolidationPeriod", rtPeriod);
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

<style >
.accordion-button {
	background-color: rgba(240, 240, 240, 0.3);
}
.accordion-button:not(.collapsed) {
	background-color:rgba(172, 184, 38, 0.3);
}

.accordion-body {
	background-color: rgb(240, 240, 240, 0.7);
}

.accordion-header {
	background-color:rgb(240, 240, 240, 0.7);
}

.base {
	background-color: rgba(234, 234, 218, 0.7);
	height: 100vh;
	color: rgba(234, 234, 218, 0.7);
}

.btn-circle {
	width: 30px;
	height: 30px;
	text-align: center;
	padding: 6px 0;
	font-size: 12px;
	border-radius: 15px;
}
.btn-circle.btn-lg {
	width: 50px;
	height: 50px;
	padding: 10px 16px;
	font-size: 18px;
	line-height: 1.33;
	border-radius: 25px;
}
.btn-circle.btn-xl {
	width: 70px;
	height: 70px;
	padding: 10px 16px;
	font-size: 24px;
	line-height: 1.33;
	border-radius: 35px;
}


.dp__theme_dark {
	--dp-border-color: #6C757D;
	--dp-menu-border-color: #6C757D;
	--dp-background-color: #6C757D;
	--dp-icon-color: white;
}

.form-select {
	background-color:  rgb(240, 240, 240, 0.1);
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

.panelHeader{
	height: 10vh;
	background-color: rgba(172, 184, 38, 0.6);
}


</style>

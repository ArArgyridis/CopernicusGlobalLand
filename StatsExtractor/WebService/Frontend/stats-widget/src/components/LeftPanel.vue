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
			<div class="dropdown">
				<h4> Product Selection</h4>
				Current Product: <button class="btn btn-secondary btn-block dropdown-toggle " type="button" id="productDropdownButton" data-bs-toggle="dropdown" aria-expanded="false">{{currentProductDescription}}</button>
				<ul id="productDropdown" class="dropdown-menu" aria-labelledby="dropdownMenuButton1">
					<li v-for ="(product, key) in products" v-bind:key="key" v-bind:value="key"  v-on:click="setCurrentProduct(key)"><a class="dropdown-item">{{product.description}}</a></li>
				</ul>
			</div>
		</div>
		<div class = "container mt-3" v-if="currentProduct != null">
			<h4>Select Mode</h4>
			<div class="row gap-2">
				<div class="col btn btn-secondary disabled" id="showStratificationButton" v-on:click=showStratificationMenu(true)>
					Stratified Information
				</div>
				<div class ="col btn btn-secondary" id="showRawDataButton" v-on:click=showStratificationMenu(false)>
					Raw Data
				</div>				
			</div>
			<div class = "mt-3" v-if="viewStratification==true">
			
				<!--STRATIFICATION -->
				<div>
					Current stratification: <button class="btn btn-secondary btn-block dropdown-toggle " type="button" id="stratificationDropdownButton" data-bs-toggle="dropdown" aria-expanded="false">{{currentStratificationName}}</button>
					<ul id="stratificationDropdown" class="dropdown-menu" aria-labelledby="dropdownMenuButton1">
					<li v-for ="(stratification, key) in stratifications" v-bind:key="key" v-bind:value="key"  v-on:click="setCurrentStratification(key)"><a class="dropdown-item">{{stratification.name}}</a></li>
					</ul>
				</div>
				
				<!-- STRATIFICATION DATE-->
				<div class="mt-2" v-if="currentStratificationName != 'Select stratification'">Select date: <button class="btn btn-secondary btn-block dropdown-toggle " type="button" id="wmsLayersDropdownButton" data-bs-toggle="dropdown" aria-expanded="false">{{currentStratificationDate}} </button>
					<ul id="wmsLayersDropdown" class="dropdown-menu" aria-labelledby="dropdownMenuButton1" v-if="currentStratification != null">
					<li v-for ="(date, key) in stratificationDates" v-bind:key="key" v-bind:value="key"  v-on:click="setCurrentStratificationDate(date)"><a class="dropdown-item">{{date}}</a></li>
					</ul>
				</div>	
				<!--v-if="currentAreaDensity != 'Select Area Density'"-->
				<!-- AREA DENSITY-->
				<div class="mt-2" v-if="currentStratificationDate != 'Select date'">
					Area Density <button class="btn btn-secondary btn-block dropdown-toggle " type="button" id="areaDropdownButton" data-bs-toggle="dropdown" aria-expanded="false">{{currentAreaDensity}}</button>
					<ul id="currentAreaDropdown" class="dropdown-menu" aria-labelledby="dropdownMenuButton1">
						<li v-for ="(densityType, key) in areaDensityTypes" v-bind:key="key" v-bind:value="key"  v-on:click="setStratificationAreaDensity(key)"><a class="dropdown-item">{{densityType.description}}</a></li>
					</ul>
				</div>
			</div>
			
			<!-- WMS RAW DATA LAYER-->
			<div class= "mt-3" v-if="viewStratification==false">
				Current WMS Layer: <button class="btn btn-secondary btn-block dropdown-toggle " type="button" id="wmsLayersDropdownButton" data-bs-toggle="dropdown" aria-expanded="false">{{currentProductWMSLayer}}</button>
				<ul id="wmsDropdown" class="dropdown-menu" aria-labelledby="dropdownMenuButton1">
					<li v-for ="(wms, key) in wmsLayers" v-bind:key="key" v-bind:value="key"  v-on:click="setCurrentWMS(key)"><a class="dropdown-item">{{wms.title}}</a></li>
				</ul>
			</div>
		</div>
	</div>
</div>

</template>


<script>
import Datepicker from 'vue3-date-time-picker';
import 'vue3-date-time-picker/dist/main.css';

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
				this.$emit("dateChange");
			}			
		},
		dateEnd: {
			get() {
				return this.$store.getters.dateEnd;
			},
			set(date) {
				this.$store.commit("setDateEnd", date);
				this.$emit("dateChange");
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
				return tmpDates.sort( function(a, b) {
					let keyA = a.title,
					keyB = b.title;
					if (keyA < keyB) return -1;
					if (keyA > keyB) return 1;
					return 0;
				});
			}
		},
		wmsLayers:{
			get() {
				return this.$store.getters.productsWMSLayers;
			}		
		}
	},
	data() {
		return {
			dateFormat: "dd MMM yyyy",
			viewStratification: true,
		}
	},
	methods: {
		init() {},
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
		setCurrentWMS(key) {
			this.currentProductWMSLayer = key;
			this.$emit("rawWMSChange");
		},
		showStratificationMenu(val) {
			this.viewStratification = val;
			document.getElementById("showStratificationButton").classList.toggle("disabled");
			document.getElementById("showRawDataButton").classList.toggle("disabled");
			this.$emit("switchViewMode");
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

</style>

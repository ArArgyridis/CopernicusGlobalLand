<template>
	<div>
	<!-- template for the modal component -->
	<div class="modal-mask" id="downloadRoot">
		<div class="modal-wrapper">
			<div class="modal-container">
				<div class="modal-header" >
					<div class="container">
						<div class="row">
							<div class="col"><h4>Products Downloader</h4></div>
						</div>
					</div>
				</div>
				<div class="modal-body">
					<div class="mt-2">
						<div class="row">
							<div class="col-8 border border-secondary position-relative">
								<OLMap id="aoiMap" v-bind:center="[0,0]" v-bind:zoom=1 v-bind:bingKey=bingKey v-bind:epsg=mapProjection ref="aoiMap" class="aoiMap" />
								<div class="aoiToolbar aoiToolbar">
									<button type = "button" class = "btn btn-secondary aoiToolbarButton" v-bind:class="{active: aoiMode =='maxExtentAOI'}" data-bs-toggle="tooltip"  title="Set AOI To Maximum Extent" v-on:click = "__setToMaxExtent()" ref ="maxExtentAOI"><FontAwesomeIcon icon="globe"  size="1x" :style="{ color: '#eaeada'}"/></button>
									<button class = "btn btn-secondary aoiToolbarButton" v-bind:class="{active: aoiMode =='drawAOI'}" data-bs-toggle="tooltip" data-bs-placement="top" title="Draw Custom AOI" v-on:click = "__drawAOI()" ref ="customAOI"> <FontAwesomeIcon icon="draw-polygon"  size="1x" :style="{ color: '#eaeada'}" /></button>
									<button class = "btn btn-secondary aoiToolbarButton" v-bind:class="{active: aoiMode =='uploadAOI'}" data-bs-toggle="tooltip" data-bs-placement="top" title="Upload AOI from KML" v-on:click = "__uploadAOI()" ref ="uploadAOI"> <FontAwesomeIcon icon="upload"  size="1x" :style="{ color: '#eaeada'}" /></button>
									<button class = "btn btn-secondary aoiToolbarButton" data-bs-toggle="tooltip" data-bs-placement="top" title="Clear AOI" v-on:click = "__eraseAOI()" ref ="eraseAOI"><FontAwesomeIcon icon="eraser"  size="1x" :style="{ color: '#eaeada'}" /></button>
									<input type="file" ref="kmlUpload" accept=".kml" style="display:none" v-on:change="__onKMLChange($event)"/>
								</div>
							</div>
							<div class="col border">
								<div class="container">
									<div class="row">
										<div class="col"> Select Date Range</div>

									</div>
									<div class="row">
										<div class ="col-6 my-auto mt-2">Date Start</div>
											<div class ="col d-flex text-justify"><Datepicker class="dp__theme_dark" v-model="dateStart" :format="dateFormat" autoApply :enableTimePicker="false" v-bind:clearable="false" dark/>
										</div>
									</div>
									<div class="row mt-2">
										<div class ="col-6 my-auto">Date End</div>
											<div class ="col d-flex text-justify"><Datepicker class="dp__theme_dark" v-model="dateEnd" :format="dateFormat" autoApply :enableTimePicker="false" v-bind:clearable="false" dark/>
										</div>
									</div>
									<div class="row mt-3">
										<div class="col">
											Select Data to Download
										</div>
									</div>
									<div class="row mt-2">
										<div class = "col d-flex justify-content-start" v-for="(obj, idx) in statisticsGetModes">
											<div class="form-check">
												<input class="form-check-input" type="radio" name="selectDataType" v-bind:id="obj.elId" v-bind:checked="statisticsGetMode.id == obj.id" v-on:click="statisticsGetMode=obj">
												<label class="form-check-label" for="rawDataFetch">{{obj.description}}</label>
											</div>
										</div>
									</div>
									<div class="row mt-3">
										<div class ="col-4 d-flex justify-content-end"><p > Email(*)</p></div>
										<div class="col"><input type="email" class="form-control" v-on:keyup="__validateEmail()" placeholder="Enter email" ref="emailForm"></div>
									</div>
								</div>

							</div>
						</div>
						<div class="row">
							<div class="col-2 border border-secondary">
								<div class="accordion-body">
									<select class="form-select" size="4" aria-label="size 3 select example">
										<option v-for ="(cat, key) in categories" v-bind:key="key" v-bind:value="key" v-on:click="__updateSelection({type:'category', value:cat})" v-bind:selected="cat.id == selectedCategory.id">{{cat.title}}</option>
									</select>
								</div>
							</div>
							<div class="col-3 border border-secondary">
								<div class="accordion-body">
									<select class="form-select" size="4" aria-label="size 3 select example" v-if="selectedCategory.products!=null">
										<option v-for ="(prd, key) in selectedCategory.products.info" v-bind:key="key" v-bind:value="key" v-on:click="__updateSelection({type:'product', value:prd})" v-bind:selected="prd.id == selectedProduct.id">{{prd.description}}</option>
									</select>
								</div>
							</div>
							<div class="col-3 border border-secondary">
								<div class="accordion-body">
									<select class="form-select" size="4" aria-label="size 3 select example"  v-if="selectedCategory.products!=null">
										<option v-for ="(rt, key) in consolidationPeriods" v-bind:key="key" v-bind:value="key" v-on:click="__updateSelection({type:'rt', value:rt})" v-bind:selected="rt.id == selectedRT.id">{{rt.description}}</option>
									</select>
								</div>
							</div>

							<div class="col border border-secondary">
								<div class="accordion-body">
									<select class="form-select" size="4" aria-label="size 3 select example"  v-if="selectedCategory.products!=null">
										<option v-for ="(vrbl, key) in selectedProduct.variables" v-bind:key="key" v-bind:value="key" v-on:click="__updateSelection({type:'variable', value:vrbl})" v-bind:selected="vrbl.id == selectedVariable.id">{{vrbl.description}}</option>
									</select>
								</div>
							</div>
						</div>
						<div class="row mt-3">
							<div class="col">
								<button class="btn btn-secondary" v-on:click="__appendToDownloadList()">Add to Download List <FontAwesomeIcon icon="download"  size="1x" :style="{ color: '#eaeada'}"/></button>
							</div>
						</div>
						<div class="row mt-3">
							<div class="col">
								<select class="form-select" size="4" aria-label="size 8 select example" ref="downloadOptions">
								</select>
							</div>
						</div>
					</div>
				</div>
				<div class="modal-footer" id="footer">
					<button class="btn btn-secondary modal-default-button" v-on:click="showDownloadPanel = false">OK</button>
					<button class="btn btn-primary modal-default-button aoiToolbarButton"> Submit</button>
				</div>
			</div>
		</div>
	</div>
</div>
</template>

<script>
import axios from 'axios';
import 'bootstrap';
import Datepicker from '@vuepic/vue-datepicker';
import { Tooltip } from 'bootstrap';
import requests from "../libs/js/requests.js";
import OLMap from "./libs/OLMap.vue";
import DateTime from "./libs/DateTime.vue";
import options from "../libs/js/options.js";
import utils from "../libs/js/utils.js";
import {Fill, Stroke, Style, Text} from 'ol/style';
import GeoJSON from 'ol/format/GeoJSON';
import KML from 'ol/format/KML';
import {consolidationPeriods} from "../libs/js/constructors.js";
import { library } from '@fortawesome/fontawesome-svg-core';
import { faDrawPolygon, faEraser, faGlobe, faDownload, faUpload } from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

library.add(faDrawPolygon);
library.add(faEraser);
library.add(faGlobe);
library.add(faDownload);
library.add(faUpload);

const statisticsGetModeOptions = [
	{id:0, description: "Raw Data", elId: "rawDataFetch"},
	{id:1, description: "Anomalies", elId: "anomaliesFetch"},
	{id:2, description: "Raw Data and Anomalies", elId: "bothDatasetsFetch"}
];

export default {
	name: "DownloadPanel",
	components: {
		DateTime,
		Datepicker,
		FontAwesomeIcon,
		OLMap
	},
	computed: {
		activeCategory() {
			return this.$store.getters.activeCategory;
		},
		bingKey() {
			return options.bingKey;
		},
		categories() {
			return this.$store.getters.categories;
		},
		consolidationPeriods() {
			let tmpPeriods = new consolidationPeriods(this.selectedProduct.rt);
			let retPeriods = new Array();
			tmpPeriods.forEach(period => {
				if (period.id in this.selectedProduct.dates)
					retPeriods.push(period);
			});
			return retPeriods;
		},
		currentDate() {
			let tmpDate = new Date(Date.parse(this.$store.getters.currentDate));
			return tmpDate.toDateString();
		},
		dateStart: {
			get() {
				let tmpDate = new Date(Date.parse(this.dtStart));
				return tmpDate.toDateString();
			},
			set(dt){
				this.dtStart = dt;
			}
		},
		dateEnd: {
			get() {
				let tmpDate = new Date(Date.parse(this.dtEnd));
				return tmpDate.toDateString();
			},
			set(dt){
				this.dtEnd = dt;
			}
		},
		product() {
			return this.$store.getters.product;
		},
		productDescription() {
			if (this.$store.getters.product == null)
				return "Dummy Product";
			return this.$store.getters.product.description;
		},
		showDownloadPanel: {
			get() {
				return this.$store.getters.showDownloadPanel;
			},
			set(dt) {
				this.$store.commit("showDownloadPanel", dt);
			}
		},
		statisticsGetModes() {
			return statisticsGetModeOptions;
		}
	},
	data() {
		return{
			bingId: null,
			aoiOLOptions: {
				layer: null
			},
			aoiMode:null,
			dateFormat: "MMM dd yyyy",
			downloadOptions: {},
			dtStart: this.$store.getters.dateStart,
			dtEnd: this.$store.getters.dateEnd,
			emailRegex:/^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/,
			mapProjection: "EPSG:3857",
			selectedCategory: this.$store.getters.activeCategory,
			selectedProduct: this.$store.getters.product,
			selectedVariable: this.$store.getters.variable,
			statisticsGetMode: statisticsGetModeOptions[this.$store.getters.productStatisticsViewMode],
			selectedRT: this.$store.getters.product.rtFlag,
			drawStyle: new Style({
						stroke: new Stroke({
						color: 'rgba(200, 0, 0, 0.6)',
						width: 3
					}),
					fill: new Fill({
						color: 'rgba(226, 226, 226, 0.3)'
					})
				}),
			showStyle:  new Style({
						stroke: new Stroke({
						color: 'rgba(255, 0, 0, 1.0)',
						width: 3
					}),
					fill: new Fill({
						color: 'rgba(226, 226, 226, 0.6)'
					})
				}),
			tooltips: []
		}
	},
	methods: {
		init() {
			this.bingId = this.$refs.aoiMap.addBingLayerToMap("aerial", true, 0);
			this.$refs.aoiMap.setVisibility(this.bingId, true);
			this.aoiOLOptions = this.$refs.aoiMap.addDrawInteraction({
				type:"Polygon",
				style: this.drawStyle
			});
			this.$refs.aoiMap.setVisibility(this.aoiOLOptions.layer, true);
			this.$refs.aoiMap.updateLayerStyle(this.aoiOLOptions.layer, this.showStyle);
			this.aoiOLOptions.draw.setActive(false);

			//setting aoi to max extent by default
			this.__setToMaxExtent();

			Array.from(document.querySelectorAll('button[data-bs-toggle="tooltip"]')).forEach(tooltipNode =>
			new Tooltip(tooltipNode, {
				animated : 'fade',
				container:document.getElementById("downloadRoot"),
				delay: { "show": 200, "hide": 100 },
				trigger:"hover"})
			);

		},
		__appendToDownloadList() {
			if(this.selectedVariable.id in this.downloadOptions) {
				console.log("Product already exists, please remove the old entry and append it again");
				return 1;
			}


			this.downloadOptions[this.selectedVariable.id] = {
				dateStart: this.dtStart,
				dateEnd: this.dateEnd,
				dataFlag: document.getElementById("rawDataFetch").checked*0 + document.getElementById("anomaliesFetch").checked*1 + document.getElementById("bothDatasetsFetch").checked*2,
				rtFlag: this.selectedRT.id
			};

			let description = "Examination Period: [" + this.dtStart.toDateString() + " to " +this.dtEnd.toDateString() +"]/Variable: " + this.selectedVariable.description + " (" + this.statisticsGetMode.description + ")";





			if(this.selectedRT.id > -1)
				description += "/Consolidation: " + this.selectedRT.id + " dekads";


			console.log(description);
			let option = document.createElement("option");
			option.text = description;
			option.value = this.selectedVariable.id;
			this.$refs.downloadOptions.appendChild(option);

		},
		__drawAOI() {
			this.__eraseAOI();
			this.aoiMode = "drawAOI";
			this.aoiOLOptions.draw.setActive(true);
			this.aoiOLOptions.draw.on("drawend", () => {
				this.aoiOLOptions.draw.setActive(false);
			});

		},
		__eraseAOI() {
		this.aoiMode = "eraseAOI";
			this.$refs.aoiMap.clearVectorLayer(this.aoiOLOptions.layer);
		},
		__onKMLChange(evt) {
			let file = evt.target.files[0];
			let reader = new FileReader();
			reader.readAsText(file);
			reader.onload = (e => {
				let features = new KML().readFeatures(e.target.result);
				features.forEach(ft =>{
					ft.getGeometry().transform("EPSG:4326", this.mapProjection);
					ft.setStyle(this.showStyle);
				});

				this.$refs.aoiMap.addFeaturesToLayer(this.aoiOLOptions.layer, features);
			});
		},
		__setToMaxExtent() {
			//pressing the button down...
			this.aoiMode = "maxExtentAOI";
			this.__eraseAOI();
			axios.get(options.maxAOIBounds3857URL).then((response) => {
				let features = new GeoJSON().readFeatures(response.data);
				this.$refs.aoiMap.addFeaturesToLayer(this.aoiOLOptions.layer, features);
			});

		},
		__updateSelection(dt) {
			if(dt.type == "category") {
				this.selectedCategory = dt.value;
				if ( this.selectedCategory.products == null) {
					this.selectedProduct = null;
					this.selectedVariable = null;
					this.selectedRT = null;
					return;
				}
				this.selectedProduct = this.selectedCategory.products.current;
				this.selectedVariable = this.selectedProduct.currentVariable;
				this.selectedRT = this.selectedProduct.rtFlag;
			}
			else if (dt.type == "product") {
				this.selectedProduct = dt.value;
				this.selectedVariable = this.selectedProduct.currentVariable;
				this.selectedRT = this.selectedProduct.rtFlag;
			}
			else if (dt.type == "variable") {
				this.selectedVariable = dt.value;
				this.selectedRT = this.selectedProduct.rtFlag;
			}
			else if(dt.type =="rt") {
				this.selectedRT = dt.value;
			}
		},
		__uploadAOI() {
			this.aoiMode = "uploadAOI";
			this.__eraseAOI();
			this.$refs.kmlUpload.value = "";
			this.$refs.kmlUpload.click();

		},
		__validateEmail() {
			if (this.$refs.emailForm.value.match(this.emailRegex))
				return true;
			return false;
		}

	},
	mounted() {
		this.init();
	}

}

</script>

<style scoped>

.modal-mask {
	position: fixed;
	z-index: 9998;
	top: 0;
	left: 0;
	width: 100%;
	height: 100%;
	background-color: rgba(0, 0, 0, 0.5);
	display: table;
}

.modal-wrapper {
	display: table-cell;
	vertical-align: middle;
}

.aoiMap {
	height:500px;
	z-index: 10;
	width:100%;
}

@media(min-width:901px) {
	.modal-container {
		width: 90%;
		height: 85%;
		margin: 0px auto;
		padding: 20px 30px;
		background-color: #fff;
		border-radius: 2px;
		box-shadow: 0 2px 8px rgba(0, 0, 0, 0.33);
		font-family: Helvetica, Arial, sans-serif;
	}
}

@media(max-width:900px) {
	.modal-container {
		width: 100%;
		margin: 0px auto;
		padding: 20px 30px;
		background-color: #fff;
		border-radius: 2px;
		box-shadow: 0 2px 8px rgba(0, 0, 0, 0.33);
		font-family: Helvetica, Arial, sans-serif;
	}
}

.modal-header h2 {
	text-align:center;
	width:100%;
}

.modal-header h3 {
	text-align:center;
	width:100%;
}

.modal-body {
	margin: 1px 0;
}

.modal-default-button {
	display: block;
	margin-top: 1rem;
}

.modal-enter-active,
.modal-leave-active {
	transition: opacity 0.5s ease;
}

.modal-enter-from,
.modal-leave-to {
	opacity: 0;
}

.aoiToolbar {
	position:absolute;
	top:2%;
	right: 3%;
}

.aoiToolbarButton {
	margin-left:5px;
}

.position-relative {
	position:relative;
}


.invalid{
	color:red;
}

.valid{
	color:green;
}

</style>




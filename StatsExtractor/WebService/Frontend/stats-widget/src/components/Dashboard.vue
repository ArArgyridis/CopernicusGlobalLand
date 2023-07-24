<template>
	<div v-show="showModal">
	<!-- template for the modal component -->
	<div class="modal-mask">
		<div class="modal-wrapper">
			<div class="modal-container" id="dashboardContainer" >
				<div class="modal-header" >
					<div class="container">
						<div class="row">
							<div class="col"><h4>Examined Region: {{region}} ({{strata}})</h4></div>
						</div>
						<div class="row">
							<div class="col"><h5>Selected Product: {{productDescription}}</h5></div>
						</div>
						<div class="row">
							<div class="col"><h6>Examination Period: {{dateStart }} / {{dateEnd}}, Selected Date: {{currentDate}}</h6></div>
						</div>
					</div>
				</div>
				<div class="modal-body">
					<div class="container mt-2" v-if="product != null">
						<div class="row">
							<div class="col-sm border border-secondary">
								<OLMap id="map2raw" v-bind:center="[0,0]" v-bind:zoom=2 v-bind:bingKey=bingKey epsg="EPSG:3857" ref="map2raw" class="dashboardMap" />
								<Legend class="mt-3" ref="legend" mode="Raw"/>
							</div>
							<div class="col-sm border border-secondary">
								<OLMap id="map2anom" v-bind:center="[0,0]" v-bind:zoom=2 v-bind:bingKey=bingKey epsg="EPSG:3857" ref="map2anom" class="dashboardMap" />
								<Legend class="mt-3" ref="legend" mode="Anomalies"/>
							</div>
							
						</div>
					</div>
				</div>
				<div class="modal-footer">
					<!--<p>default footer</p>-->
					<button class="btn btn-secondary modal-default-button" v-on:click="setVisibility(false)">OK</button>
					<button class="btn btn-primary modal-default-button" v-on:click="print()"> Print</button>
				</div>
			</div>
		</div>
	</div>
	<!--printed element-->
	<div class="dashboardPrintArea" ref="dashboardPrintArea" id="dashboardPrintArea" hidden v-if="product != null">
		<div class="dashboardPrintInnerArea">
			<div class="modal-header" >
				<div class="container">
					<div class="row">
						<div class="col"><h4>Examined Region: {{region}} ({{strata}})</h4></div>
					</div>
					<div class="row">
						<div class="col"><h5>Selected Product: {{productDescription}}</h5></div>
					</div>
					<div class="row">
						<div class="col"><h6>Examination Period: {{dateStart }} / {{dateEnd}}, Selected Date: {{currentDate}}</h6></div>
					</div>
				</div>
			</div>
			
			<div class="container mt-2">
				<div class="row">
					<div class="col-sm border border-secondary">
						<OLMap id="map3raw" v-bind:center="[0,0]" v-bind:zoom=2 v-bind:bingKey=bingKey epsg="EPSG:3857" ref="map3raw" class="dashboardMap" />
						<Legend class="mt-3" ref="legend" mode="Raw"/>
					</div>
					<div class="col-sm border border-secondary">
						<OLMap id="map3anom" v-bind:center="[0,0]" v-bind:zoom=2 v-bind:bingKey=bingKey epsg="EPSG:3857" ref="map3anom" class="dashboardMap" />
						<Legend class="mt-3" ref="legend" mode="Anomalies"/>
					</div>
				</div>
				<div class="row mt-1">
					<div class="col-sm border border-secondary"><PointTimeSeries ref="PointTimeSeriesRaw" mode="Raw" class="dashboardPrintDiagram" /></div>
					<div class="col-sm border border-secondary"><PointTimeSeries ref="PointTimeSeriesAnomalies" mode="Anomalies" class="dashboardPrintDiagram" /></div>
				</div>
				<div class="row">
					<div class="col-sm border border-secondary"><PolygonTimeSeries ref="PolygonTimeSeriesRaw" mode="Raw" class="dashboardPrintDiagram" /></div>
					<div class="col-sm border border-secondary"><PolygonTimeSeries ref="PolygonTimeSeriesAnomalies" mode="Anomalies" class="dashboardPrintDiagram" /></div>					
				</div>
				<div class="row">
					<div class="col-sm border border-secondary"><PolygonAreaDensityPieChart ref="PolygonAreaDensityPieChart" class="dashboardPrintDiagram" /></div>
					<div class="col-sm border border-secondary"><PolygonHistogramData ref="PolygonHistogramData" class="dashboardPrintDiagram" /></div>
				</div>
			</div>
		</div>
	</div>
</div>
</template>

<script>
import html2canvas from 'html2canvas';

import requests from "../libs/js/requests.js";
import OLMap from "./libs/OLMap.vue";
//import DateTime from "./libs/DateTime.vue";
import options from "../libs/js/options.js";
import utils from "../libs/js/utils.js";
import PointTimeSeries from "./charts/PointTimeSeries.vue";
import PolygonAreaDensityPieChart from "./charts/PolygonAreaDensityPieChart.vue";
import PolygonHistogramData from "./charts/PolygonHistogramData.vue";
import PolygonTimeSeries from "./charts/PolygonTimeSeries.vue";
import {Icon } from 'ol/style';
import {Stroke, Style } from 'ol/style';
import Legend from "./libs/Legend.vue";

export default {
	name: "Dashboard",
	components: {
		//DateTime,
		Legend,
		OLMap,
		PointTimeSeries,
		PolygonAreaDensityPieChart,
		PolygonHistogramData,
		PolygonTimeSeries
	},
	computed: {
		currentDate() {
			let tmpDate = new Date(Date.parse(this.$store.getters.currentDate));
			return tmpDate.toDateString();
		},
		dateStart() {
			let tmpDate = new Date(Date.parse(this.$store.getters.dateStart));
			return tmpDate.toDateString();
		},
		dateEnd() {
			let tmpDate = new Date(Date.parse(this.$store.getters.dateEnd));
			return tmpDate.toDateString();
		},
		product() {
			return this.$store.getters.product;
		},
		productDescription() {
			if (this.$store.getters.product == null)
				return "Dummy Product";
			return this.$store.getters.product.description;
		}
	},
	data() {
		return{
			showModal: false,
			printDashboard: false,
			bingIdDashboard: null,
			bingIdPrintArea: null,
			bingKey: options.bingKey,
			projectEPSG: "EPSG:3857",
			printVectorLayer: {},
			pointLayerZIndex: 4,
			vectorLayerZIndex: 3,
			productWMSLayerZIndex:2,
			renderTimeOut: null,
			printTimeOut: null,
			region: "region",
			strata: "strata",
			diagramRefs: ["PointTimeSeriesRaw", "PointTimeSeriesAnomalies", "PolygonTimeSeriesRaw", "PolygonTimeSeriesAnomalies", "PolygonAreaDensityPieChart", "PolygonHistogramData"],
			keys:  ["map2", "map3"],
			types:["raw", "anom"],
			reportMapLoads: [true, true]
		}
	},
	methods: {
		print() {
			document.getElementById("dashboardPrintArea").removeAttribute("hidden");
			for (let i = 0; i < 2; i++) { 

				let tmpKey = "map3"+this.types[i];
				console.log("hereee");
				//registering end render event for report maps
				this.$refs[tmpKey].addMapEvent("rendercomplete", ()=>{
					this.reportMapLoads[i] = false;
				});
				this.$refs[tmpKey].fitToLayerExtent(this.printVectorLayer[tmpKey]);
			}
			
			//updating chart data
			this.diagramRefs.forEach((dg) => {
				this.$refs[dg].updateChartData();
			});

			this.printTimeOut = setInterval(() => {
				let stop = false;
				
				//checking diagram rendering
				this.diagramRefs.forEach((dg) => {
					stop = stop || this.$refs[dg].loads();
				});

				this.reportMapLoads.forEach( (load)=>{
					stop = stop || load;
				});
				
				//still execution needs to take place...
				if (stop) {
					return;
				}

				this.diagramRefs.forEach((dg) => {
					this.$refs[dg].resizeChart();
				});
	
				//convert html to canvas and create output png image
				this.__print();
				clearInterval(this.printTimeOut);
			}, 1000 );
		},
		__print() {
			setTimeout(() => {
				html2canvas(document.getElementById("dashboardPrintArea")).then(canvas => {
					let tmpEl = document.createElement('a');
					tmpEl.href= canvas.toDataURL("image/png").replace("image/png", "image/octet-stream");
					tmpEl.download= this.region+".png";
					document.body.appendChild(tmpEl);
					tmpEl.click();
					document.body.removeChild(tmpEl);
					document.getElementById("dashboardPrintArea").setAttribute("hidden", true);
				});
			}, 250);
		},
		refreshRender() {
			this.keys.forEach((key) => {
				this.types.forEach((type) =>{
					let tmpKey = key+type;
					document.getElementById("dashboardPrintArea").removeAttribute("hidden");
					this.$refs[tmpKey].getMap().updateSize();
					document.getElementById("dashboardPrintArea").setAttribute("hidden", true);
				});
			});

			this.diagramRefs.forEach((dg) => {
				this.$refs[dg].resizeChart();
			});
		},
		refreshData() {
			let polyId = this.$store.getters.selectedPolygon;
			if (polyId == null)
				return;
			
			this.keys.forEach((key) => {
				this.types.forEach((type) =>{
					let tmpKey = key+type;
					//cleaning up 
					this.$refs[tmpKey].clearAllLayers();
					
					let bingIdDashboard = this.$refs[tmpKey].addBingLayerToMap("aerial",  true, 0);
					this.$refs[tmpKey].setVisibility(bingIdDashboard, true);
				});
			});
			this.printVectorLayer = {};

			requests.fetchDashboard(polyId, this.$store.getters.product.id, this.$store.getters.dateStart, this.$store.getters.dateEnd).then( (response) => {
				
				let clickedCoords = this.$store.getters.clickedCoordinates;
				let iconProps = utils.markerProperties();
				
				let polyStyle = new Style({
					fill:null,
					stroke: new Stroke({
						color:  "rgb(255,0,0)",
						width: 2,
					})
				});
				
				this.keys.forEach((key) => {
					this.types.forEach((type) =>{
						let tmpKey = key+type;
						//polygon
						this.printVectorLayer[tmpKey]= this.$refs[tmpKey].createGEOJSONLayerFromString(response.data.data, this.vectorLayerZIndex);
						this.$refs[tmpKey].setVisibility(this.printVectorLayer[tmpKey], true);
						let vectorLayerObj = this.$refs[tmpKey].getLayerObject(this.printVectorLayer[tmpKey]);
						vectorLayerObj.setStyle(polyStyle);
						this.$refs[tmpKey].fitToLayerExtent(this.printVectorLayer[tmpKey]);

						//wms product (raw or anomalies)
						let product = this.$store.getters.product;
						let variable = product.currentVariable;
						if (type == "anom") 						
							variable		= this.$store.getters.currentAnomaly;
							
						if (variable.wms.current is null)
							continue

						let layerProps = {
							url: variable.wms.current.url,
							projection: variable.wms.current.projection,
							wmsParams: {
								LAYERS: variable.wms.current.title,
								WIDTH:256,
								HEIGHT:256
							},
							serverType: "mapserver",
							crossOrigin: "anonymous",
							zIndex: this.productWMSLayerZIndex
						};

						//product raw/anomalies Data
						let wmsLayerId = this.$refs[tmpKey].addCustomWMSLayerToMap(layerProps);

						this.$refs[tmpKey].setVisibility(wmsLayerId, true);
						this.$refs[tmpKey].cropWMSByGeoJSON(wmsLayerId, response.data.data);
						
						//pointlayer
						let pointLayer = this.$refs[tmpKey].createEmptyVectorLayer(this.pointLayerZIndex);
						this.$refs[tmpKey].addPointToLayer(pointLayer, 2, clickedCoords.coordinate[0], clickedCoords.coordinate[1],  {icon: new Icon(iconProps)} );
						this.$refs[tmpKey].setVisibility(pointLayer, true);

					});
				});
				this.region = response.data.data.properties.description;
				this.strata = response.data.data.properties.strata;
			});
		}
		,setVisibility(vis) {
			this.showModal  = vis;
		},
	},
	unmount() {
		console.log("unmounting dashboard");
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

.dashboardMap {
	height:370px;
	z-index: 10;
	width:100%;
}

@media(min-width:901px) {
	.modal-container {
		width: 901px;
		height: 800px;
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
	margin: 15px 0;
}

.modal-default-button {
	display: block;
	margin-top: 1rem;
}

.dashboardPrintArea {
	padding: 1%;
	margin: 100% auto;
	z-index: 9998;
	width: 1240px;
	height: 1754px;
	border:2px solid red;
}

.dashboardPrintInnerArea {
	margin: 2.5%;
	box-sizing: border-box;
	padding: 2.5%;
	border:1px solid black;
	height: 97.5%;
}

.modal-enter-active,
.modal-leave-active {
	transition: opacity 0.5s ease;
}

.modal-enter-from,
.modal-leave-to {
	opacity: 0;
}

.dashboardPrintDiagram {
	height:300px;
}

</style>




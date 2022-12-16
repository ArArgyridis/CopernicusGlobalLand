<template>
	<div v-show="showModal">
	<!-- template for the modal component -->
	<div class="modal-mask">
		<div class="modal-wrapper">
			<div class="modal-container" id="dashboardContainer" >
				<div class="modal-header" >
					<div class="container">
						<div class="row">
							<div class="col"><h4>{{region}} ({{strata}})</h4></div>
						</div>
						<div class="row">
							<div class="col"><h5>{{productDescription}}</h5></div>
						</div>
						<div class="row">
							<div class="col"><h6>Analysis Period: {{dateStart }} / {{dateEnd}}</h6></div>
						</div>
					</div>
				</div>
				<div class="modal-body">
					<OLMap id="map2" v-bind:center="[0,0]" v-bind:zoom=2 v-bind:bingKey=bingKey epsg="EPSG:3857" ref="map2" class="dashboardMap" />
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
	<div class="dashboardPrintArea" ref="dashboardPrintArea" id="dashboardPrintArea">
		<div class="dashboardPrintInnerArea">
			<div class="modal-header" >
				<div class="container">
					<div class="row">
						<div class="col"><h4>{{region}} ({{strata}})</h4></div>
					</div>
					<div class="row">
						<div class="col"><h5>{{productDescription}}</h5></div>
					</div>
					<div class="row">
						<div class="col"><h6>Analysis Period: {{dateStart }} / {{dateEnd}}</h6></div>
					</div>
				</div>
			</div>
			<div><OLMap id="map3" v-bind:center="[0,0]" v-bind:zoom=2 v-bind:bingKey=bingKey epsg="EPSG:3857" ref="map3" class="dashboardMap" /></div>
			<div class="container mt-2">
				<div class="row">
					<div class="col-sm"><PointTimeSeries ref="PointTimeSeriesRaw" mode="Raw" /></div>
					<div class="col-sm"><PointTimeSeries ref="PointTimeSeriesAnomalies" mode="Anomalies" /></div>
				</div>
				<div class="row">
					<div class="col-sm"><PolygonTimeSeries ref="PolygonTimeSeriesRaw" mode="Raw"/></div>
					<div class="col-sm"><PolygonTimeSeries ref="PolygonTimeSeriesAnomalies" mode="Anomalies"/></div>					
				</div>
				<div class="row">
					<div class="col-sm"><PolygonAreaDensityPieChart ref="PolygonAreaDensityPieChart" class="col-sm"/></div>
					<div class="col-sm"><PolygonHistogramData ref="PolygonHistogramData"/></div>
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

export default {
	name: "Dashboard",
	components: {
		//DateTime,
		OLMap,
		PointTimeSeries,
		PolygonAreaDensityPieChart,
		PolygonHistogramData,
		PolygonTimeSeries
	},
	computed: {
		dateStart() {
			let tmpDate = new Date(Date.parse(this.$store.getters.dateStart));
			return tmpDate.toDateString();
		},
		dateEnd() {
			let tmpDate = new Date(Date.parse(this.$store.getters.dateEnd));
			return tmpDate.toDateString();
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
			vectorLayer: null,
			renderTimeOut: null,
			printTimeOut: null,
			region: "region",
			strata: "strata",
			diagramRefs: ["PointTimeSeriesRaw", "PointTimeSeriesAnomalies", "PolygonTimeSeriesRaw", "PolygonTimeSeriesAnomalies", "PolygonAreaDensityPieChart", "PolygonHistogramData"]
		}
	},
	methods: {
		init() {
			this.renderTimeOut = setTimeout(this.refreshRender, 200);
			
			this.bingIdDashboard = this.$refs.map2.addBingLayerToMap("aerial",  true, 0);
			this.$refs.map2.setVisibility(this.bingIdDashboard, true);
			
			this.bingIdPrintArea = this.$refs.map3.addBingLayerToMap("aerial",  true, 0);
			this.$refs.map3.setVisibility(this.bingIdPrintArea, true);
			
			/*
			this.diagramRefs.forEach((dg) => {
				this.$refs[dg].updateChartData();
			});
			*/
		},
		print() {
			this.printTimeOut = setInterval(() => {			
				let stop = false;
				this.diagramRefs.forEach((dg) => {
					stop = stop || this.$refs[dg].loads();
				});
				if (stop)
					return;
					
				this.diagramRefs.forEach((dg) => {
					this.$refs[dg].resizeChart();
				});
	
				this.__print();
				clearInterval(this.printTimeOut);
			}, 1 );
		},
		__print() {
			this.$refs.map3.getMap().setView(this.$refs.map2.getMap().getView());
			this.refreshRender();
			document.getElementById("dashboardPrintArea").removeAttribute("hidden");
			setTimeout(() => {
				html2canvas(document.getElementById("dashboardPrintArea")).then(canvas => {
					let tmpEl = document.createElement('a');
					tmpEl.href= canvas.toDataURL("image/png").replace("image/png", "image/octet-stream");
					tmpEl.download= "dashboard.png";
					document.body.appendChild(tmpEl);
					tmpEl.click();
					document.body.removeChild(tmpEl);
					document.getElementById("dashboardPrintArea").setAttribute("hidden", true);
				});
			}, 250);
		},
		refreshRender() {
			this.$refs.map2.getMap().updateSize();
			document.getElementById("dashboardPrintArea").removeAttribute("hidden");
			
			this.$refs.map3.getMap().updateSize();
			document.getElementById("dashboardPrintArea").setAttribute("hidden", true);
			
			this.diagramRefs.forEach((dg) => {
				this.$refs[dg].resizeChart();
			});
		},
		refreshData() {
			let polyId = this.$store.getters.selectedPolygon;
			if (polyId == null)
				return;
				
			requests.fetchDashboard(polyId, this.$store.getters.product.id, this.$store.getters.dateStart, this.$store.getters.dateEnd).then( (response) => {
				let keys = ["map2", "map3"];
				let clickedCoords = this.$store.getters.clickedCoordinates;
				let iconProps = utils.markerProperties();
				keys.forEach((key) => {
					let vectorLayer = this.$refs[key].createGEOJSONLayerFromString(response.data.data);
					this.$refs[key].setVisibility(vectorLayer, true);
					this.$refs[key].fitToLayerExtent(vectorLayer);
					let pointLayer = this.$refs[key].createEmptyVectorLayer();
					this.$refs[key].addPointToLayer(pointLayer, 2, clickedCoords.coordinate[0], clickedCoords.coordinate[1],  {icon:	new Icon(iconProps)} );
					this.$refs[key].setVisibility(pointLayer, true);
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
	height:350px;
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
	margin: 3%;
	box-sizing: border-box;
	padding: 3%;
	border:1px solid black;
	height: 96%;
}

.modal-enter-active,
.modal-leave-active {
	transition: opacity 0.5s ease;
}

.modal-enter-from,
.modal-leave-to {
	opacity: 0;
}
</style>




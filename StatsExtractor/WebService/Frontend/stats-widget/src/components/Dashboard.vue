<template>
	<div v-show="showModal">
	<!-- template for the modal component -->
	<div class="modal-mask">
		<div class="modal-wrapper">
			<div class="modal-container" id="dashboardContainer" >
				<div class="modal-header" >
					<h3>{{region}} <br>({{strata}})</h3>
				</div>
				<div class="modal-body">
					<OLMap id="map2" v-bind:center="[0,0]" v-bind:zoom=2 v-bind:bingKey=bingKey epsg="EPSG:3857" ref="map2" class="dashboardMap" />
				</div>
				<!--<div class="hexagon"><span></span></div>-->
				<div class="container">
					<div class="row">
						<h3>Examination Period</h3>
					</div>
					<div class="row">
						<div class="col-sm d-flex justify-content-center">
							<DateTime v-bind:date=dateStart />
						</div>
						<div class="col-sm d-flex justify-content-center">
							<DateTime v-bind:date=dateEnd />
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
	<div class="dashboardPrintArea" ref="dashboardPrintArea" id="dashboardPrintArea">
		<div class="dashboardPrintInnerArea">
			<div class="modal-header" >
				<h3>{{region}} <br>({{strata}})</h3>
			</div>
			<div><OLMap id="map3" v-bind:center="[0,0]" v-bind:zoom=2 v-bind:bingKey=bingKey epsg="EPSG:3857" ref="map3" class="dashboardMap" /></div>
			<div class="container mt-2">
				<div class="row">
					<div class="col-sm"><PointTimeSeries ref="PointTimeSeries" /></div>
					<div class="col-sm"><PolygonAreaDensityPieChart ref="PolygonAreaDensityPieChart" class="col-sm"/></div>
				</div>
				<div class="row">
					<div class="col-sm"><PolygonHistogramData ref="PolygonHistogramData"/></div>
					<div class="col-sm"><PolygonTimeSeries ref="PolygonTimeSeries"/></div>
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
import DateTime from "./libs/DateTime.vue";
import options from "../libs/js/options.js";
import PointTimeSeries from "./charts/PointTimeSeries.vue";
import PolygonAreaDensityPieChart from "./charts/PolygonAreaDensityPieChart.vue";
import PolygonHistogramData from "./charts/PolygonHistogramData.vue";
import PolygonTimeSeries from "./charts/PolygonTimeSeries.vue";


export default {
	name: "Dashboard",
	components: {
		DateTime,
		OLMap,
		PointTimeSeries,
		PolygonAreaDensityPieChart,
		PolygonHistogramData,
		PolygonTimeSeries
	},
	computed: {
		dateStart() {
			return this.$store.getters.dateStart;
		},
		dateEnd() {
			return this.$store.getters.dateEnd;
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
			diagramRefs: ["PointTimeSeries", "PolygonAreaDensityPieChart", "PolygonHistogramData", "PolygonTimeSeries"]
		}
	},
	methods: {
		init() {
			this.renderTimeOut = setTimeout(this.refreshRender, 200);
			
			this.bingIdDashboard = this.$refs.map2.addBingLayerToMap("aerial",  true, 0);
			this.$refs.map2.setVisibility(this.bingIdDashboard, true);
			
			this.bingIdPrintArea = this.$refs.map3.addBingLayerToMap("aerial",  true, 0);
			this.$refs.map3.setVisibility(this.bingIdPrintArea, true);

			this.diagramRefs.forEach((dg) => {
				this.$refs[dg].updateChartData();
			});
		},
		print() {
			this.printTimeOut = setInterval(() => {			
				if (this.$refs.PointTimeSeries.loads() || this.$refs.PolygonAreaDensityPieChart.loads() || this.$refs.PolygonHistogramData.loads() || this.$refs.PolygonTimeSeries.loads())
					return;

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
		},
		refreshData() {
			let polyId = this.$store.getters.selectedPolygon;
			if (polyId == null)
				return;
				
			requests.fetchDashboard(polyId, this.$store.getters.product.id, this.$store.getters.dateStart, this.$store.getters.dateEnd).then( (response) => {
				let keys = ["map2", "map3"];
				keys.forEach((key) => {
					let vectorLayer = this.$refs[key].createGEOJSONLayerFromString(response.data.data);
					this.$refs[key].setVisibility(vectorLayer, true);
					this.$refs[key].fitToLayerExtent(vectorLayer);
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

.modal-header h3 {
	text-align:center;
	width:100%;
}

.modal-body {
	margin: 20px 0;
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

.hexagon {
  position: relative;
  width: 150px; 
  height: 86.60px;
  background-color: #64C7CC;
  margin: 43.30px 0;
  box-shadow: 0 0 20px rgba(0,0,0,0.8);
  border-left: solid 2px #333333;
  border-right: solid 2px #333333;
}

.hexagon:before,
.hexagon:after {
  content: "";
  position: absolute;
  z-index: 1;
  width: 106.07px;
  height: 106.07px;
  -webkit-transform: scaleY(0.5774) rotate(-45deg);
  -ms-transform: scaleY(0.5774) rotate(-45deg);
  transform: scaleY(0.5774) rotate(-45deg);
  background-color: inherit;
  left: 19.9670px;
  box-shadow: 0 0 20px rgba(0,0,0,0.8);
}

.hexagon:before {
  top: -53.0330px;
  border-top: solid 2.8284px #333333;
  border-right: solid 2.8284px #333333;
}

.hexagon:after {
  bottom: -53.0330px;
  border-bottom: solid 2.8284px #333333;
  border-left: solid 2.8284px #333333;
}

/*cover up extra shadows*/
.hexagon span {
  display: block;
  position: absolute;
  top:1.1547005383792515px;
  left: 0;
  width:146px;
  height:84.2931px;
  z-index: 2;
  background: inherit;
}





/*
 * The following styles are auto-applied to elements with
 * transition="modal" when their visibility is toggled
 * by Vue.js.
 *
 * You can easily play with the modal transition by editing
 * these styles.
 */

.modal-enter-active,
.modal-leave-active {
	transition: opacity 0.5s ease;
}

.modal-enter-from,
.modal-leave-to {
	opacity: 0;
}
</style>




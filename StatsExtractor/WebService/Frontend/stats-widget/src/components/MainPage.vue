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
<Dashboard v-show="showTheDashboard==true" ref="dashboard" region="my region" strata="strata stratoula"/>
<div class="container-fluid fixed-top">
	<div class="row">
		<div id="leftPanel" class="noPadding hiddenBar raise hidden sidenav leftnav" >
			<LeftPanel v-on:closeSideMenu="toggleLeft()" 
					v-on:dateChange="updateProducts()"
					v-on:currentProductChange="updateAll()"
					v-on:rawWMSChange="updateProductWMSVisibility()" 
					v-on:stratificationChange="updateStratificationLayerVisibility()"
					v-on:switchViewMode="toggleCurrentLayersVisibility($event)"
					v-on:stratificationDateChange="refreshStratificationInfo()"
					v-on:stratificationAreaDensityChange="updateStratificationLayerStyle()"
					v-on:closeLeftPanel="toggleLeft()"
					v-on:anomalyWMSChange="updateProductAnomalyWMSVisibility()"
			/>
		</div>
		<div class="noPadding hidden">
		<!--<button class="btn btn-secondary mt-3" v-on:click="showDashboard()"> Show Region Dashboard</button>-->
			<MapApp ref="mapApp" 
			v-on:featureClicked="updateStratificationPolygonInfo($event)"
			v-on:mapCoordinate="updateRawDataChart($event)"
			/>
			<div class="d-flex">
				<div class="btn position-relative fixed-top burger raise transition d-inline" id="menuButton">
					<FontAwesomeIcon icon="bars"  size="3x" :style="{ color: '#eaeada' }" v-on:click="toggleLeft()"/>
				</div>
			</div>
			<div class="d-flex logo relative"><img alt="Copernicus LMS" src="../assets/copernicus_land_monitoring.png"></div>
		</div>		
		<div id="rightPanel" class="transition noPadding hiddenBar raise hidden sidenav rightnav">
			<TimeseriesCharts v-bind:polyId=currentStratificationPolygonId ref="chartPanel" v-on:closeTimechartsPanel="closeRightPanel()" v-on:showDashboard="showDashboard()"/>
		</div>
	</div>
</div>
</template>

<script> 
import MapApp from "./MapApp.vue";
import LeftPanel from "./LeftPanel.vue";
import Dashboard from "./Dashboard.vue";
import TimeseriesCharts from "./TimeseriesCharts.vue";
import { library } from '@fortawesome/fontawesome-svg-core'
import { faUserSecret, faEye, faBars } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import requests from "../libs/js/requests.js";

library.add(faUserSecret)
library.add(faEye);
library.add(faBars);

export default {
	name: 'MainPage',
	components: {
		MapApp,
		LeftPanel,
		FontAwesomeIcon,
		TimeseriesCharts,
		Dashboard
	},
	data() {
		return {
			currentStratificationPolygonId: null,
			showRightPanel: false,
			activateClickOnMap: false,
			showTheDashboard: false
		}
	},
	methods: {
		init() {
			this.updateProducts();
			//hack to properly resize right panel timechart
			document.getElementById("rightPanel").addEventListener('transitionend', () => {
				this.$refs.chartPanel.resizeChart();
			});
		},
		closeRightPanel() {
			this.setRightPanelVisibility(false);
			this.currentStratificationPolygonId = null;
			this.refreshStratificationInfo();
			this.$refs.mapApp.clearPolygonSelection();
		},
		refreshStratificationInfo() {
			this.$refs.chartPanel.updatePolygonTimeseriesChart(this.currentStratificationPolygonId);
			this.$refs.chartPanel.updateHistogramChart(this.currentStratificationPolygonId);
			this.updateStratificationLayerStyle();
		},
		//hiding right panel
		setRightPanelVisibility(status) {
			if(this.showRightPanel != status) {
				this.togglePanelClasses("rightPanel");
				this.showRightPanel = status;
			}
		},
		showDashboard() {
			this.showTheDashboard = true;
			this.$refs.dashboard.init();
			this.$refs.dashboard.setVisibility(true);
			this.$refs.dashboard.refreshData(this.currentStratificationPolygonId);
		},
		toggleCurrentLayersVisibility(evt) {
			if (this.$store.getters.currentStratification != null)
				this.$refs.mapApp.setLayerVisibility(this.$store.getters.currentStratification.layerId, evt.id==0);
			
			if (this.$store.getters.currentProductWMSLayer != null) 
				this.$refs.mapApp.setLayerVisibility(this.$store.getters.currentProductWMSLayer.layerId, evt.id==1);
			
			if (this.$store.getters.currentProductAnomalyWMSLayer != null) 
				this.$refs.mapApp.setLayerVisibility(this.$store.getters.currentProductAnomalyWMSLayer.layerId, evt.id==2);

			this.setRightPanelVisibility(false);
			this.$refs.chartPanel.resetAllCharts();
		},
		togglePanelClasses(id){
			document.getElementById(id).classList.toggle("hiddenBar");
			document.getElementById(id).classList.toggle("shownBar");
		},		
		toggleLeft() {
			this.togglePanelClasses("leftPanel");
			document.getElementById("menuButton").classList.toggle("offsetButton");
		},
		updateProductInfo() {
			this.$store.commit("clearProducts");
			requests.fetchProductInfo(this.$store.getters.dateStart, this.$store.getters.dateEnd).then((response)=>{
				this.$store.commit("setProducts", response.data.data);
			});
		},
		updateStratificationAreaType() {
			/*
			this.$refs.mapApp.refreshCurrentStratificationStyle();
			if (this.currentStratificationPolygonId != null)
				this.$refs.chartPanel.updatePolygonTimeseriesChart(this.currentStratificationPolygonId);
			*/
		},
		updateStratificationInfo() {
			this.$refs.mapApp.clearStratifications();
			requests.fetchStratificationInfo(this.$store.getters.dateStart, this.$store.getters.dateEnd, this.$store.getters.currentProduct.id).then((response)=>{
				this.$store.commit("setStratifications", response.data.data);
				this.$refs.mapApp.refreshStratifications();
			});
		},		
		updateStratificationPolygonInfo(evt) {
			if (evt != null)
				this.currentStratificationPolygonId = evt.getId();
			else
				this.currentStratificationPolygonId = null;
				
			this.refreshStratificationInfo();
		},
		updateProductWMSVisibility() {
			this.setRightPanelVisibility(false);
			this.$refs.mapApp.updateProductWMSVisibility();
		},
		updateProductAnomalyWMSVisibility() {
			this.setRightPanelVisibility(false);
			this.$refs.mapApp.updateProductAnomalyWMSVisibility();
		},
		updateStratificationLayerStyle(){
			this.$refs.mapApp.updateStratificationLayerStyle();
			this.$refs.chartPanel.updatePolygonTimeseriesChart(this.currentStratificationPolygonId);
		},
		updateStratificationLayerVisibility() {
			this.setRightPanelVisibility(false);
			this.$refs.mapApp.updateStratificationLayerVisibility();
			/*
			if (this.currentStratificationPolygonId != null) {
				this.$refs.chartPanel.updateHistogramChart(this.currentStratificationPolygonId);
				this.setRightPanelVisibility(true);
			}
			*/
		},
		updateAll() {
			this.setRightPanelVisibility(false);
			this.updateStratificationInfo();
			this.updateWMSLayers();
		},
		updateProducts() {
			this.setRightPanelVisibility(false);
			this.$refs.mapApp.clearStratifications();
			this.$refs.mapApp.clearWMSLayers();
			this.$refs.chartPanel.resetAllCharts();
			this.updateProductInfo();
			if (!this.activateClickOnMap) {
				this.$refs.mapApp.toggleClickOnMap();
				this.activateClickOnMap = true;
			}
		},
		updateRawDataChart(evt) {
			if (this.$store.getters.currentProduct == null) 
				return;
			
			this.$refs.chartPanel.updateRawTimeSeriesChart(evt);
			this.setRightPanelVisibility(true);
			
		},
		updateWMSLayers() {
			this.$refs.mapApp.clearWMSLayers();
			this.$refs.mapApp.updateWMSLayers();
		},
		__updatePolygonChartData() {
			this.$refs.chartPanel.updatePolygonTimeseriesChart(this.currentStratificationPolygonId);
			this.$refs.chartPanel.updateHistogramChart(this.currentStratificationPolygonId);
			
			if (this.currentStratificationPolygonId != null)
				this.setRightPanelVisibility(true);
			else
				this.setRightPanelVisibility(false);		
		}
	},
	mounted() {
		this.init();
	}
}

</script>


<style scoped>
@import "../libs/css/myStyles.css";
.burger {
	top: -99.6vh;
}
.rightnav {
	right: 0;
}
.leftnav {
	left: 0;
}

.sidenav {
	height: 100%; 
	width: 0; 
	position: fixed; 
	top: 0;   
	overflow-x: hidden; 
	transition: 0.5s; 
}

@media(max-width: 900px) {
	.shownBar {
		width: 100%;
	}
	
	.offsetButton {
		left:100%;
	}
	
	.logo  {
		justify-content:center;
		position: fixed;
		bottom: 0px;
		width: 100%;
		height:10%;
	}
}

@media(min-width:901px) {
	.shownBar {
		width: 500px;
	}	
	.offsetButton {
		left:500px;
	}	
	.logo {
		justify-content:end;
		position: fixed;
		bottom: 0px;
		right: 0px;
		height:8%;
	}
}

.transition {
	transition:0.5s;
}


</style>

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
<Dashboard v-show="showTheDashboard==true" ref="dashboard"/>
<div class="container-fluid fixed-top">
	<div class="row">
		<div id="leftPanel" class="noPadding hiddenBar raise hidden sidenav leftnav" >
			<LeftPanel v-on:closeSideMenu="toggleLeft()" 
					v-on:updateProducts="updateProducts()"
					v-on:currentProductChange="updateAll()"
					v-on:rawWMSChange="updateProductWMSVisibility()" 
					v-on:stratificationChange="updateStratificationLayerVisibility()"
					v-on:switchViewMode="toggleCurrentLayersVisibility($event)"
					v-on:stratificationDateChange="refreshStratificationInfo()"
					v-on:stratificationAreaDensityChange="updateStratificationLayerStyle()"
					v-on:closeLeftPanel="toggleLeft()"
					v-on:anomalyWMSChange="updateProductAnomalyWMSVisibility()"
			/><!--- v-on:currentProductAnomalyChange=""-->
		</div>
		<div class="noPadding hidden">
		<!--<button class="btn btn-secondary mt-3" v-on:click="showDashboard()"> Show Region Dashboard</button>-->
			<MapApp ref="mapApp" 
			v-on:featureClicked="refreshStratificationInfo()"
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
			<RightPanel ref="rightPanel" v-on:closeTimechartsPanel="closeRightPanel()" v-on:showDashboard="showDashboard()"/>
		</div>
	</div>
</div>
</template>

<script> 
import MapApp from "./MapApp.vue";
import LeftPanel from "./LeftPanel.vue";
import Dashboard from "./Dashboard.vue";
import RightPanel from "./RightPanel.vue";
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
		RightPanel,
		Dashboard
	},
	computed: {
		clickedCoordinates: {
			get() {

				return this.$store.getters.clickedCoordinates();
			},
			set(dt) {
				this.$store.commit("clickedCoordinates", dt);
			}
		},
		currentStratificationPolygonId: {
			get() {
				return this.$store.getters.selectedPolygon;
			},
			set(dt) {
				this.$store.commit("selectedPolygon", dt);
			}
		}

	},
	data() {
		return {
			showRightPanel: false,
			activateClickOnMap: false,
			showTheDashboard: false,
		}
	},
	methods: {
		init() {
			//this.updateProducts();
			//this.showDashboard();
			//hack to properly resize right panel timechart
			document.getElementById("rightPanel").addEventListener('transitionend', () => {
				this.$refs.rightPanel.resizeChart();
			});
		},
		closeRightPanel() {
			this.setRightPanelVisibility(false);
			this.refreshStratificationInfo();
			this.$refs.mapApp.clearPolygonSelection();
		},
		refreshStratificationInfo() {
			this.$refs.rightPanel.loadStratificationCharts();
			this.$refs.rightPanel.loadLocationCharts();
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
			this.$refs.dashboard.refreshData();
		},
		toggleCurrentLayersVisibility(evt) {
			if (this.$store.getters.currentStratification != null)
				this.$refs.mapApp.setLayerVisibility(this.$store.getters.currentStratification.layerId, evt.id==0);
			
			if (this.$store.getters.currentProductWMSLayer != null) 
				this.$refs.mapApp.setLayerVisibility(this.$store.getters.currentProductWMSLayer.layerId, evt.id==1);
			
			if (this.$store.getters.currentProductAnomalyWMSLayer != null) 
				this.$refs.mapApp.setLayerVisibility(this.$store.getters.currentProductAnomalyWMSLayer.layerId, evt.id==2);

			this.setRightPanelVisibility(false);
			this.$refs.rightPanel.resetAllCharts();
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
			requests.fetchProductInfo(this.$store.getters.dateStart, this.$store.getters.dateEnd, this.$store.getters.activeCategory.id).then((response)=>{
				this.$store.commit("setProducts", response.data.data);
				if (this.$store.getters.products != null) {
					this.$store.commit("setCurrentProduct", 0);
					this.updateAll();
					this.$store.commit("setCurrentProductWMSLayer", 0);
				}
			});
		},
		updateStratificationInfo() {
			this.$refs.mapApp.clearStratifications();
			requests.fetchStratificationInfo(this.$store.getters.dateStart, this.$store.getters.dateEnd, this.$store.getters.currentProduct.id).then((response)=>{
				this.$store.commit("setStratifications", response.data.data);
				this.$refs.mapApp.refreshStratifications();
				if (this.$store.getters.currentStratification == null)
					this.$store.commit("setCurrentStratification", 0);
					
				this.updateStratificationLayerVisibility();
				
				if (this.$store.getters.currentStratification.dates != null) {
					if (this.$store.getters.currentStratificationDate == null) {
						let tmpDates = Object.keys(this.$store.getters.currentStratification.dates).reverse();
						this.$store.commit("setCurrentStratificationDate", tmpDates[0]);
					}
					/*
					if (this.$store.getters.areaDensity == null)
						this.$store.commit("setStratificationAreaDensity",2);
					this.updateStratificationLayerStyle();
					*/
				}
			});
		},/*
		updateStratificationPolygonInfo(evt) {				
			this.refreshStratificationInfo();
		},*/
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
			this.$refs.rightPanel.loadStratificationCharts(this.currentStratificationPolygonId);
		},
		updateStratificationLayerVisibility() {
			this.setRightPanelVisibility(false);
			this.$refs.mapApp.updateStratificationLayerVisibility();
			this.updateStratificationLayerStyle();
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
			this.$refs.rightPanel.resetAllCharts();
			this.updateProductInfo();
			if (!this.activateClickOnMap) {
				this.$refs.mapApp.toggleClickOnMap();
				this.activateClickOnMap = true;
			}
		},
		updateRawDataChart(evt) {
			if (this.$store.getters.currentProduct == null) 
				return;
			
			this.clickedCoordinates = evt;
			this.$refs.rightPanel.loadLocationCharts();
			this.setRightPanelVisibility(true);
		},
		updateWMSLayers() {
			this.$refs.mapApp.clearWMSLayers();
			this.$refs.mapApp.updateWMSLayers();
		},
		__updatePolygonChartData() {
			this.$refs.rightPanel.updatePolygonTimeseriesChart(this.currentStratificationPolygonId);
			this.$refs.rightPanel.updateHistogramChart(this.currentStratificationPolygonId);
			
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
		width: 700px;
	}	
	.offsetButton {
		left:700px;
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

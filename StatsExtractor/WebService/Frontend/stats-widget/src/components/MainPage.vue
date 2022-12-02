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
		<div id="leftPanel" class="noPadding shownBar raise hidden sidenav leftnav" >
			<LeftPanel 
			v-on:closeLeftPanel="toggleLeft()"
			v-on:closeSideMenu="toggleLeft()" 
			v-on:dateChanged="updateStratificationLayerStyle()"
			v-on:getCategoryProducts="getCategoryProducts()"
			v-on:resetProducts="resetProducts()"
			v-on:stratificationViewOptionsChanged="updateStratificationLayerStyle()"
			v-on:statisticsViewModeChanged="statisticsViewModeUpdate()"
			v-on:stratificationChanged="updateStratificationLayerVisibility()"
			v-on:stratificationDensityChanged = "updateStratificationLayerStyle()"
			v-on:stratifiedOrRawChanged="setCurrentLayersVisibilityByViewMode()"
			v-on:updateWMSLayer="updateWMSVisibility()"
			/>
		</div>
		<div class="noPadding hidden">
			<MapApp ref="mapApp" 
			v-on:featureClicked="refreshStratificationInfo()"
			v-on:mapCoordinate="updateRawDataChart($event)"
			/>
			<div class="d-flex">
				<div class="btn position-relative fixed-top raise transition d-inline offsetButton" id="menuButton">
					<FontAwesomeIcon icon="bars"  size="3x" :style="{ color: '#eaeada' }" v-on:click="toggleLeft()"/>
				</div>
			</div>
			<div class="d-flex logo relative"><img alt="Copernicus LMS" src="/assets/copernicus_land_monitoring.png"></div>
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
		},
		currentWMSLayer: {
			get() {
				let ret = this.$store.getters.productWMSLayer;
				if (this.$store.getters.productStatisticsViewMode == 1)
					ret = this.$store.getters.productAnomalyWMSLayer;
				return ret;
			},
			set(dt) {
				if (this.$store.getters.productStatisticsViewMode == 0)
					this.$store.commit("setProductWMSLayer", dt);
				else if (this.$store.getters.productStatisticsViewMode == 1)
					this.$store.commit("setAnomalyProductWMSLayer", dt);
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
			//hack to properly resize right panel timechart
			document.getElementById("rightPanel").addEventListener('transitionend', () => {
				this.$refs.rightPanel.resizeChart();
			});
			this.updateStratificationInfo();
		},
		closeRightPanel() {
			this.setRightPanelVisibility(false);
			this.refreshStratificationInfo();
			this.$refs.mapApp.clearPolygonSelection();
		},
		getCategoryProducts() {
			if (this.$store.getters.products == null)
				this.getProductInfo();
			//console.log("GET CATEGORY PRODUCTS!!!!!!!!");
		},
		getProductInfo() {

			if (this.$store.getters.dateStart == null || this.$store.getters.dateEnd == null || this.$store.getters.activeCategory == null)
				return;
			
			requests.fetchProductInfo(this.$store.getters.dateStart, this.$store.getters.dateEnd, this.$store.getters.activeCategory.id).then((response)=>{
				this.$store.commit("setCategoryProducts", response.data.data);
				this.updateAll();
			});
		},
		refreshStratificationInfo() {
			this.$refs.rightPanel.loadStratificationCharts();
			this.$refs.rightPanel.loadLocationCharts();
			this.updateStratificationLayerStyle();
		},
		resetProducts() {
			this.setRightPanelVisibility(false);
			this.$refs.mapApp.clearWMSLayers();
			this.$refs.rightPanel.resetAllCharts();
			this.$store.commit("clearProducts");
			this.getProductInfo();
			if (!this.activateClickOnMap) {
				this.$refs.mapApp.toggleClickOnMap();
				this.activateClickOnMap = true;
			}
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
		statisticsViewModeUpdate() {
			let statsViewMode =  this.$store.getters.productStatisticsViewMode;
			let stratifiedOrRaw = this.$store.getters.stratifiedOrRaw;
			this.$refs.mapApp.setLayerVisibility(this.$store.getters.currentStratification.layerId, this.$store.getters.stratifiedOrRaw == 0);
			this.updateStratificationLayerStyle();
			this.setCurrentLayersVisibilityByViewMode();
			this.$refs.mapApp.setLayerVisibility( this.$store.getters.productWMSLayer.layerId,   stratifiedOrRaw == 1 && statsViewMode == 0);
			this.$refs.mapApp.setLayerVisibility( this.$store.getters.productAnomalyWMSLayer.layerId, stratifiedOrRaw == 1 && statsViewMode== 1);
		},
		setCurrentLayersVisibilityByViewMode() {
			console.log("asdsadsa")
			if (this.$store.getters.currentStratification != null)
				this.$refs.mapApp.setLayerVisibility(this.$store.getters.currentStratification.layerId, this.$store.getters.stratifiedOrRaw == 0);
		
			if (this.currentWMSLayer != null) 
				this.$refs.mapApp.setLayerVisibility(this.currentWMSLayer.layerId, this.$store.getters.stratifiedOrRaw == 1);
			
			
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
		updateStratificationInfo() {
			this.$refs.mapApp.clearStratifications();
			requests.fetchStratificationInfo().then((response)=>{
				this.$store.commit("setStratifications", response.data.data);
				this.$refs.mapApp.refreshStratifications();
					
				this.updateStratificationLayerVisibility();
				this.updateStratificationLayerStyle();
			});
		},
		updateWMSVisibility() {
			this.setRightPanelVisibility(false);
			if (this.$store.getters.productStatisticsViewMode == 0) 
				this.$refs.mapApp.updateProductWMSVisibility();			
			else if (this.$store.getters.productStatisticsViewMode == 1) 
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
			this.updateStratificationLayerStyle();
			this.setRightPanelVisibility(false);
			this.updateWMSLayers();
		},
		updateRawDataChart(evt) {
			if (this.$store.getters.product == null) 
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

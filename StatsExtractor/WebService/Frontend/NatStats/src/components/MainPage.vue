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
		<div id="leftPanel" class="noPadding raise sidenav leftnav" v-bind:class="{shownBar: leftPanelVisibility, hiddenBar: !leftPanelVisibility}">
			<LeftPanel 
				v-on:dateChanged="setCurrentLayersVisibilityByViewMode($event)"
				v-on:resetProducts="resetProducts()"
				v-on:stratificationViewOptionsChanged="updateStratificationLayerStyle()"
				v-on:statisticsViewModeChanged="setCurrentLayersVisibilityByViewMode($event)"
				v-on:stratificationChanged="updateStratificationLayerVisibility()"
				v-on:stratificationDensityChanged = "updateStratificationLayerStyle()"
				v-on:stratifiedOrRawChanged="setCurrentLayersVisibilityByViewMode($event)"
				v-on:updateWMSLayer="updateWMSVisibility()"
				v-on:updateView="setCurrentLayersVisibilityByViewMode($event)"
			/>
		</div>
		<div class="noPadding">
			<div id="mapView">
				
				<MapApp ref="mapApp"
					v-on:featureClicked="refreshStratificationInfo()"
					v-on:mapCoordinate="updateRawDataChart($event)"
				/>
				<Legend class="d-fleg relative legend" ref="legend" v-bind:mode="legendMode"/>

				<div class="d-flex logo relative"><img alt="Copernicus LMS" src="/assets/copernicus_land_monitoring.png"></div>
			</div>
			<div class="d-flex">
				<div class="btn position-relative fixed-top raise transition d-inline" id="menuButton" v-bind:class="{offsetButton: leftPanelVisibility}">
					<FontAwesomeIcon icon="bars"  size="3x" :style="{ color: '#eaeada' }" v-on:click="leftPanelVisibility = !leftPanelVisibility"/>
				</div>
			</div>
			
		</div>		
		<div id="rightPanel" class="transition noPadding hiddenBar raise sidenav rightnav">
			<RightPanel ref="rightPanel" 
			v-on:closeTimechartsPanel="closeRightPanel()" 
			v-on:exportCurrentView="exportCurrentView()"
			v-on:showDashboard="showDashboard()"
			
			/>
		</div>
	</div>
</div>
</template>

<script> 
import html2canvas from 'html2canvas';
import MapApp from "./MapApp.vue";
import LeftPanel from "./LeftPanel.vue";
import Dashboard from "./Dashboard.vue";
import RightPanel from "./RightPanel.vue";
import { library } from '@fortawesome/fontawesome-svg-core'
import { faUserSecret, faEye, faBars } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import requests from "../libs/js/requests.js";
import Legend from "./libs/Legend.vue";

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
		Dashboard,
		Legend
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
				return this.$store.getters.currentWMSLayer;
			},
			set(dt) {
				this.$store.commit("currentWMS", dt);
			}
		},
		leftPanelVisibility: {
			get() {
				return this.$store.getters.leftPanelVisibility;
			},
			set(dt) {
				this.$store.commit("leftPanelVisibility", dt);
			}
			
		},
		legendMode() {
			let mode = null;
			if (this.$store.getters.productStatisticsViewMode == 0) {
				if (this.$store.getters.stratifiedOrRaw == 0) {
					if (this.$store.getters.stratificationViewOptions.viewMode == 0) 
						mode = "Raw"
					
					else if (this.$store.getters.stratificationViewOptions.viewMode == 1) 
						mode = "Density";
				}
				else if (this.$store.getters.stratifiedOrRaw == 1) {
					mode = "Raw"
				}
			}
			else if (this.$store.getters.productStatisticsViewMode == 1) {
				mode = "Anomalies";
			}
			return mode;
			
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
			//this.updateStratificationInfo();
		},
		closeRightPanel() {
			this.setRightPanelVisibility(false);
			this.refreshStratificationInfo();
			this.$refs.mapApp.clearPolygonSelection();
		},
		exportCurrentView() {
			html2canvas(document.getElementById("mapView"), {width: this.$refs.mapApp.$el.clientWidth, height: this.$refs.mapApp.$el.clientHeight} ).then(canvas => {
				let tmpEl = document.createElement('a');
				tmpEl.href= canvas.toDataURL("image/png").replace("image/png", "image/octet-stream");
				tmpEl.download= "current_view.png";
				document.body.appendChild(tmpEl);
				tmpEl.click();
				document.body.removeChild(tmpEl);
			});
		},
		getCategoryProducts() {
			if (this.$store.getters.products == null)
				this.getProductInfo();
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
			this.updateStratificationLayerStyle();
		},
		resetProducts() {
			this.setRightPanelVisibility(false);
			this.$refs.mapApp.clearWMSLayers();
			this.$store.commit("clearProducts");
			this.getProductInfo();
		},
		//hiding right panel
		setRightPanelVisibility(status) {
			if(this.showRightPanel != status) {
				this.togglePanelClasses("rightPanel");
				this.showRightPanel = status;
			}
			if(status)
				this.$refs.rightPanel.updateCurrentChart();
		},
		showDashboard() {
			this.showTheDashboard = true;
			this.$refs.dashboard.setVisibility(true);
			this.$refs.dashboard.refreshData();
		},
		setCurrentLayersVisibilityByViewMode(evt) {
			if (evt)
				evt.preventDefault();
		
			if (this.$store.getters.currentStratification != null)
				this.updateStratificationLayerStyle();
			
			this.$refs.mapApp.updateWMSVisibility();
		},
		togglePanelClasses(id){
			document.getElementById(id).classList.toggle("hiddenBar");
			document.getElementById(id).classList.toggle("shownBar");
		},		
		updateStratificationInfo() {
			this.$refs.mapApp.clearStratifications();
			
		},
		updateWMSVisibility() {
			if (this.$store.getters.stratifiedOrRaw == 0)
				return;
			this.$refs.mapApp.updateWMSVisibility();
		},
		updateStratificationLayerStyle(){
			this.$refs.mapApp.updateStratificationLayerStyle();
			if(this.showRightPanel)
				this.$refs.rightPanel.updateCurrentChart();
		},
		updateStratificationLayerVisibility() {
			this.setRightPanelVisibility(false);
			this.$refs.mapApp.updateStratificationLayerVisibility();
			this.$refs.mapApp.moveMarker(null);
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
			this.setRightPanelVisibility(true);
		},
		updateProductView() {
			this.updateStratificationLayerStyle();
			this.setRightPanelVisibility(false);
			this.$refs.mapApp.updateWMSLayers();
		},
		updateWMSLayers() {
			this.$refs.mapApp.clearWMSLayers();
			this.$refs.mapApp.updateWMSLayers();
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

.legend{
	width: 500px;
	height: 100px;
	position: fixed;
	justify-content:end;
	top:2%;
	right:1vh;

}
.legendColor {
	background-image: linear-gradient(to right, #F7FCF5 0%, #C9EAC2 25%, #7BC77C 50%, #2A924B 75%, #00441B 100%);
}
.legendColor:empty::after{
	content: ".";
	visibility:hidden;
}

</style>

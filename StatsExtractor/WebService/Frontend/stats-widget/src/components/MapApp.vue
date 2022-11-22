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
	<OLMap id="map1" v-bind:center=[0,0] v-bind:zoom=2 v-bind:bingKey=bingKey v-bind:epsg=projectEPSG  ref="map1" class="map" 
		v-on:featureClicked="updateSelectedPolygon($event)"
		v-on:mapCoordinate="moveMarker($event)"
	/>
</template>

<script>
import OLMap from './libs/OLMap.vue';
import requests from '../libs/js/requests.js';
import options from "../libs/js/options.js";
import {Fill, Stroke, Style, Icon } from 'ol/style';

export default {
	name: 'MapApp'
	,data() {
		return {
			activeWMSLayer: null,
			bingId: null,
			clickedPointLayerId: null,
			pointerLayerId: null,
			bingKey: options.bingKey,
			projectEPSG: "EPSG:3857",
			productZIndex: 1,
			stratificationZIndex: 2,
			anomaliesZIndex: 3,
			markerZIndex: 4,
		}
	},	
	props: {},
	components: {
		OLMap
	},
	computed: {
	},
	methods: {
		init() {
			//cartographic background
			this.bingId = this.$refs.map1.addBingLayerToMap("aerial",  true, 0);
			this.$refs.map1.setVisibility(this.bingId, true);
		},
		activateLayer(key) {
			if (this.activeWMSLayer != null)
				this.$refs.map1.setVisibility(this.wmsLayers[this.activeWMSLayer].layerId, false);
				
			this.$refs.map1.setVisibility( this.wmsLayers[key].layerId, true);
			this.activeWMSLayer = key;
		},
		clearStratifications() {
			if (this.$store.getters.currentProduct == null || this.$store.getters.stratifications == null)
				return;
			
			this.$store.getters.allProductsData.forEach((product) => {
				Object.keys((product.viewInfo)).forEach( (prodId) => {
						product.viewInfo[prodId].stratification.info.forEach((stratification) => {
							this.$refs.map1.removeLayer(stratification.layerId);
						});
				});
			});

		},
		clearPolygonSelection() {
			this.$refs.map1.clearCurrentPolygonSelection();
			this.$store.commit("selectedPolygon", null);
		},
		clearWMSLayers(){
			if (this.$store.getters.currentProduct == null)
				return;

			//remove wms layers from map
			this.$store.getters.allProductsData.forEach((product) => {
				Object.keys((product.viewInfo)).forEach( (prodId) => {
						product.viewInfo[prodId].rawWMS.layers.forEach((wms) => {
							this.$refs.map1.removeLayer(wms.layerId);
						});
				});
			});
			
			//removing anomaly wms layers from map
			this.$store.getters.allProductsData.forEach((product) => {
				Object.keys((product.viewInfo)).forEach( (prodId) => {
						product.viewInfo[prodId].anomalies.layers.forEach((wms) => {
							this.$refs.map1.removeLayer(wms.layerId);
						});
				});
			});
		},
		emit(eventName, data) {
			this.$emit(eventName, data);
		},
		moveMarker(evt) {
			if(this.clickedPointLayerId == null)
				this.clickedPointLayerId = this.$refs.map1.createEmptyVectorLayer(this.markerZIndex);
			
			this.$refs.map1.setVisibility(this.clickedPointLayerId, true);
			this.$refs.map1.clearVectorLayer(this.clickedPointLayerId);
			this.$refs.map1.addPointToLayer(this.clickedPointLayerId, 2, evt.coordinate[0], evt.coordinate[1],  {icon:	new Icon({
					anchor: [0.3, 1.0],
						anchorXUnits: 'fraction',
						anchorYUnits: 'fraction',
						src: "/assets/marker.png",
						scale: 0.02
					})
			});
		},
		refreshCurrentStratificationStyle(){
			this.$refs.map1.getLayerObject(this.$store.getters.currentStratification.layerId).changed();
		},		
		refreshStratifications() {
			this.$store.getters.stratifications.forEach((strat) => {
				strat.layerId = this.$refs.map1.createVectorTileLayer({
					url: strat.url,
					maxZoom:strat.maxZoom,
					zIndex: this.stratificationZIndex
				});
				this.$refs.map1.setVisibility(strat.layerId, false);
			});
		},
		setLayerVisibility(id, val) {
			if(id != null)
				this.$refs.map1.setVisibility(id, val);
		},
		updateWMSLayers() {
			//requested years from users
			let requestedYears= [];
			for(let i = this.$store.getters.dateStart.getFullYear(); i <= this.$store.getters.dateEnd.getFullYear(); i++)
				requestedYears.push(i);
			
			//available years from db 
			if (this.$store.getters.currentProduct == null)
				return;

			let curDate = new Date(Date.UTC(this.$store.getters.dateStart.getFullYear(),this.$store.getters.dateStart.getMonth(), 1));
			let productName = this.$store.getters.currentProduct.name;
			
			let productCapabilitiesURLs= new Set();
			for (let i = 0; curDate < this.$store.getters.dateEnd; i++) {
				let splitDate = curDate.toISOString().split("-");
				let year = splitDate[0];
				let month = splitDate[1];
				productCapabilitiesURLs.add(options.wmsURL + productName + "/" + year +"/" +month);
				curDate =  new Date(Date.UTC(this.$store.getters.dateStart.getFullYear(),this.$store.getters.dateStart.getMonth()+i, 1));
			}
			productCapabilitiesURLs.forEach( (url) => {
				this.$refs.map1.getAvailableWMSLayers(url, this.productZIndex).then((data) => {
					this.$store.commit("appendToProductsWMSLayers",data);
				});
			});
			this.$store.commit("setCurrentProductWMSLayer", 0);

			this.$store.getters.currentProductAnomalies.forEach( (anomaly) => {
				let curDate = new Date(Date.UTC(this.$store.getters.dateStart.getFullYear(),this.$store.getters.dateStart.getMonth(), 1));
				let anomaliesCapabilitiesURLS = new Set();

				for (let i = 0; curDate < this.$store.getters.dateEnd; i++) {
					let splitDate = curDate.toISOString().split("-");
					let year = splitDate[0];
					let month = splitDate[1];
					
					anomaliesCapabilitiesURLS.add(options.anomaliesWMSURL + anomaly.key + "/" + year +"/" +month);
					curDate =  new Date(Date.UTC(this.$store.getters.dateStart.getFullYear(),this.$store.getters.dateStart.getMonth()+i, 1));
				}
				
				anomaliesCapabilitiesURLS.forEach( (url) => {
					this.$refs.map1.getAvailableWMSLayers(url, this.anomaliesZIndex).then((data) => {
						this.$store.commit("appendToProductsAnomaliesWMSLayers",data);
					});
				});
				this.$store.commit("setCurrentProductAnomaly", 0);
				this.$store.commit("setCurrentProductAnomalyWMSLayer", 0);
			});
		},
		toggleClickOnMap() {
			this.$refs.map1.toggleGetMapCoordinates();
		},
		toggleLayerVisibility(id) {
			if(id != null)
				this.$refs.map1.toggleLayerVisibility(id);
		},
		updateProductWMSVisibility() {
			if (this.$store.getters.previousProductWMSLayer != null)
				this.$refs.map1.setVisibility(this.$store.getters.previousProductWMSLayer.layerId, false);
			this.$refs.map1.setVisibility( this.$store.getters.currentProductWMSLayer.layerId, true);
		},
		updateProductAnomalyWMSVisibility() {
			if (this.$store.getters.previousProductAnomalyWMSLayer != null)
				this.$refs.map1.setVisibility(this.$store.getters.previousProductAnomalyWMSLayer.layerId, false);
			this.$refs.map1.setVisibility( this.$store.getters.currentProductAnomalyWMSLayer.layerId, true);
		},
		updateSelectedPolygon(evt) {
			let id = null;
			if (evt != null)
				id = evt.getId();
			this.$store.commit("selectedPolygon", id);
		},		
		updateStratificationLayerStyle() {
			if (this.$store.getters.areaDensity == null)
				return;
			
			requests.fetchStratificationDataByProductAndDate(this.$store.getters.currentStratificationDate,			
			this.$store.getters.currentProduct.id,
			this.$store.getters.currentStratification.id
			).then((response)=>{
				this.dt = response.data.data;
				this.res = 0;
				let tmpLayer = this.$refs.map1.getLayerObject(this.$store.getters.currentStratification.layerId);
				let areaDensityCol = JSON.parse(JSON.stringify(this.$store.getters.areaDensity.color_col));

				tmpLayer.setStyle( (ft) => {
					let id = JSON.parse(JSON.stringify(ft.getId()));
					//let id = ft.getId();
					let color = response.data.data[id];
					if (color == null)
						return null;
						
					color = color[areaDensityCol];
					if (color == null)
						return null;
						
					let fillColor = null;
					let strokeColor = null;
					
					fillColor = "rgba(" + color.join() + ",0.7)";
					strokeColor = "rgba(" + color.join() + ",1.0)";

					return new Style({
						fill: new Fill({
							color: fillColor,
						}),
						stroke: new Stroke({
							color:  strokeColor,
							width: 1,
						})
					});
				});
				
			});
		},
		updateStratificationLayerVisibility() {
			if (this.$store.getters.previousStratification != null)
				this.$refs.map1.setVisibility( this.$store.getters.previousStratification.layerId, false);

			this.$refs.map1.setVisibility( this.$store.getters.currentStratification.layerId, true);
			this.$refs.map1.highlightOnLayer(this.$store.getters.currentStratification.layerId);
		}
	},
	mounted() {
		this.init();
	}
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>

.map {
	width: 100%;
	height: 100vh;
	position: absolute;
}
</style>

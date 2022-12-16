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
import utils from "../libs/js/utils.js"
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
			initCmp: true,
			projectEPSG: "EPSG:3857",
			productZIndex: 1,
			stratificationZIndex: 2,
			anomaliesZIndex: 3,
			markerZIndex: 4,
			stratificationColorData: {},
			stratificationViewProps: {
				stratID: null,
				productID: null,
				date: null,
				statisticsViewMode: null,
				currentStyles:{}
			}
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
			if (this.$store.getters.product == null || this.$store.getters.stratifications == null)
				return;
		},
		clearPolygonSelection() {
			this.$refs.map1.clearCurrentPolygonSelection();
			this.$store.commit("selectedPolygon", null);
		},
		clearWMSLayers() {
			if (this.initCmp) {
				this.initCmp = false;
				//return;
			}
			if (this.$store.getters.product == null || this.$store.getters.allCategories == null)
				return;

			//remove wms layers from map
			this.$store.getters.allCategories.forEach( (category) => {
				if(category.products != null) {
					category.products.info.forEach( (product) => {
						product.properties.raw.wms.layers.forEach( (layerId) => {
							this.$refs.map1.removeLayer(layerId);
						});
						product.properties.anomalies.info.forEach( (anomaly) => {
							anomaly.layers.info.forEach( (layer) => {
								this.$refs.map1.removeLayer(layer.layerId);
							});
						});
					});
				}
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
			let iconProps = utils.markerProperties();
			this.$refs.map1.addPointToLayer(this.clickedPointLayerId, 2, evt.coordinate[0], evt.coordinate[1],  {icon:	new Icon(iconProps)} );
		},
		refreshCurrentStratificationStyle(){
			this.$refs.map1.getLayerObject(this.$store.getters.currentStratification.layerId).changed();
		},		
		refreshStratifications() {
			let stratifications = this.$store.getters.stratifications;
			if (stratifications == null)
				return;

			Object.keys(stratifications.info).forEach((strat) => {
				//need to be in-store mutation!!!
				stratifications.info[strat].layerId = this.$refs.map1.createVectorTileLayer({
					url: stratifications.info[strat].url,
					maxZoom:stratifications.info[strat].maxZoom,
					zIndex: this.stratificationZIndex
				});
				this.$refs.map1.setVisibility(stratifications.info[strat].layerId, false);
			});
		},
		setLayerVisibility(id, val) {
			if(id != null)
				this.$refs.map1.setVisibility(id, val);
		},
		updateWMSLayers() {
			//no product available or the wms layers have been already fetched
			if (this.$store.getters.product == null || this.$store.getters.productWMSLayer != null) 
				return;

			this.$store.getters.product.properties.raw.wms.urls.forEach(url => {
				this.$refs.map1.getAvailableWMSLayers(url, this.productZIndex).then((data) => {
					this.$store.commit("appendToProductsWMSLayers",data);
				}).catch(error => {
					console.log(error);
				});
			});
			
			this.$store.getters.product.properties.anomalies.current.urls.forEach(url => {
				this.$refs.map1.getAvailableWMSLayers(url, this.anomaliesZIndex).then((data) => {
					this.$store.commit("appendToProductsAnomaliesWMSLayers", data);
				}).catch(error => {
					console.log(error);
				});
			});
		},
		toggleClickOnMap() {
			this.$refs.map1.toggleGetMapCoordinates();
		},
		toggleLayerVisibility(id) {
			if(id != null)
				this.$refs.map1.toggleLayerVisibility(id);
		},
		toggleRawAnomaliesWMSView() {
			this.$refs.map1.setVisibility( this.$store.getters.productWMSLayer.layerId,  this.$store.getters.productStatisticsViewMode == 0);
			this.$refs.map1.setVisibility( this.$store.getters.productAnomalyWMSLayer.layerId,  this.$store.getters.productStatisticsViewMode == 1);
		},
		updateProductWMSVisibility() {
			if (this.$store.getters.previousProductWMSLayer != null)
				this.$refs.map1.setVisibility(this.$store.getters.previousProductWMSLayer.layerId, false);
			this.$refs.map1.setVisibility( this.$store.getters.productWMSLayer.layerId, true);
		},
		updateProductAnomalyWMSVisibility() {
			if (this.$store.getters.previousProductAnomalyWMSLayer != null) {
				this.$refs.map1.setVisibility(this.$store.getters.previousProductAnomalyWMSLayer.layerId, false);
			}

			this.$refs.map1.setVisibility( this.$store.getters.productAnomalyWMSLayer.layerId, true);
		},
		updateWMSVisibility() {
			
		},
		
		updateSelectedPolygon(evt) {
			let id = null;
			if (evt != null)
				id = evt.getId();
			this.$store.commit("selectedPolygon", id);
		},		
		updateStratificationLayerStyle() {
			if  ( this.$store.getters.currentStratification == null || this.$store.getters.product == null || this.$store.getters.currentDate == null)
				return;
				
			//if no change, stop
			if (this.stratificationViewProps.stratID == this.$store.getters.currentStratification.id && this.stratificationViewProps.date == this.$store.getters.currentDate && 
			this.stratificationViewProps.productID == this.$store.getters.product.id && this.$store.getters.productStatisticsViewMode == this.statisticsViewMode)
				return;
			
			this.stratificationViewProps.stratID = this.$store.getters.currentStratification.id;
			this.stratificationViewProps.date = this.$store.getters.currentDate;
			this.stratificationViewProps.productID = this.$store.getters.product.id;
			if (this.$store.getters.productStatisticsViewMode == 1) //seeing anomalies
				this.stratificationViewProps.productID = this.$store.getters.productAnomaly.id;
				
			if (! (this.stratificationViewProps.stratID in this.stratificationColorData))
				this.stratificationColorData[this.stratificationViewProps.stratID] = {};
			
			if (! (this.stratificationViewProps.productID in this.stratificationColorData[this.stratificationViewProps.stratID]))
				this.stratificationColorData[this.stratificationViewProps.stratID][this.stratificationViewProps.productID] = {};
			
			if (!(this.stratificationViewProps.date in this.stratificationColorData[this.stratificationViewProps.stratID][this.stratificationViewProps.productID])) {
				requests.fetchStratificationDataByProductAndDate(this.stratificationViewProps.date, this.stratificationViewProps.productID, this.stratificationViewProps.stratID).then((response)=>{
					this.stratificationColorData[this.stratificationViewProps.stratID][this.stratificationViewProps.productID][this.stratificationViewProps.date] = response.data.data;
					this.setStratificationStyle(this.stratificationColorData[this.stratificationViewProps.stratID][this.stratificationViewProps.productID][this.stratificationViewProps.date]);
				});
			} else 
				this.setStratificationStyle(this.stratificationColorData[this.stratificationViewProps.stratID][this.stratificationViewProps.productID][this.stratificationViewProps.date]);
		},
		setStratificationStyle(data) {
			if (data == null)
				return;

			this.stratificationViewProps.currentStyles = {};
			let tmpLayer = this.$refs.map1.getLayerObject(this.$store.getters.currentStratification.layerId);
			let colorCol = this.$store.getters.stratificationViewOptions.colorCol;

			tmpLayer.setStyle( (ft) => {

				let id = ft.getId();
				let style = this.stratificationViewProps.currentStyles[id];
				if (style == null) {
					let color = data[id];
					if (color == null)
						return null;
					
					color = color[colorCol];
					if (color == null)
						return null;
						
					let joinedColor = color.join();
					this.stratificationViewProps.currentStyles[id] = new Style({
						fill: new Fill({
							color: "rgba(" + joinedColor + ",0.7)",
						}),
						stroke: new Stroke({
							color:  "rgba(" + joinedColor + ",1.0)",
							width: 1,
						})
					});
					style = this.stratificationViewProps.currentStyles[id];
				}
				return style;
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

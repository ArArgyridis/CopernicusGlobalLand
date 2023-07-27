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
import utils from "../libs/js/utils.js";
import {areaDensityOptions, consolidationPeriods} from "../libs/js/constructors.js";

import {Fill, Stroke, Style, Icon } from 'ol/style';

function noRTWMS(dt, url, data) {
	data.forEach(lyr => {
		lyr["url"] = url;
		dt[-1][lyr.datetime] = lyr;
	});
}

function rtWMS(dt, url, data) {
	data.forEach(lyr => {
		lyr["url"] = url;
		//this is the product's RT
		let rt = lyr.name.substring(lyr.name.length-1, lyr.name.length);
		let obj = {}
		obj[lyr.datetime] = lyr;
		dt[parseInt(rt)] = {...dt[parseInt(rt)], ...obj}
	});
}

export default {
	name: 'MapApp',
	computed: {
		product(){
			return this.$store.getters.product;
		},
		stratification(){
			return this.$store.getters.currentStratification;
		}
	},
	data() {
		return {
			activeWMSLayer: null,
			bingId: null,
			clickedPointLayerId: null,
			pointerLayerId: null,
			bingKey: options.bingKey,
			initCmp: true,
			projectEPSG: "EPSG:3857",
			productVariableZIndex: 1,
			stratificationZIndex: 3,
			anomaliesZIndex: 2,
			markerZIndex: 4,
			stratificationColorData: {},
			stratificationViewProps: {
				stratID: null,
				variableID: null,
				rtFlag: {id: null},
				date: null,
				statisticsViewMode: null,
				stratifiedOrRaw: null,
				currentStyles:{},
				styleWMS: new Style({
					fill: new Fill({color: "rgb(54, 102, 142, 0.0)"}),
					stroke: new Stroke({
						color:  "rgb(54, 102, 142, 0.6)",
						width: 1.5,
					})
				})
			}
		}
	},	
	props: {},
	components: {
		OLMap
	},
	methods: {
		init() {
			//cartographic background
			this.bingId = this.$refs.map1.addBingLayerToMap("aerial", true, 0);
			this.$refs.map1.setVisibility(this.bingId, true);
			
			requests.categories().then((response) => {
				this.$store.commit("setCategoryInfo", response.data.data);
				this.fetchProductInfo();
				this.toggleClickOnMap();
			});
		},
		activateLayer(key) {
			if (this.activeWMSLayer != null)
				this.$refs.map1.setVisibility(this.wmsLayers[this.activeWMSLayer].layerId, false);
				
			this.$refs.map1.setVisibility( this.wmsLayers[key].layerId, true);
			this.activeWMSLayer = key;
		},
		clearStratifications() {
			if (this.product == null || this.$store.getters.stratifications == null)
				return;
		},
		clearPolygonSelection() {
			this.$refs.map1.clearCurrentPolygonSelection();
			this.$store.commit("selectedPolygon", null);
		},
		clearWMSLayers() {
			if (this.product == null || this.$store.getters.allCategories == null)
				return;

			//remove wms layers from map
			this.$store.getters.allCategories.forEach( (category) => {
				if(category.products != null) {
					category.products.info.forEach( (product) => {
						product.variables.forEach((variable) =>{						
							//removing raw variable wms
							Object.keys(variable.wms.layers).forEach( (key) => {
								this.$refs.map1.removeLayer(variable.wms.layers[key].layerId);
							});
							
							//removing anomalies wms
							if(variable.anomaly_info != null)
								variable.anomaly_info.forEach( (anomaly) => {
									Object.keys(anomaly.wms.layers).forEach( (key) => {
										this.$refs.map1.removeLayer(anomaly.wms.layers[key].layerId);
									});
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
			
			if (evt ==null) {
				this.$refs.map1.clearVectorLayer(this.clickedPointLayerId);
				return;
			}
			
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
		fetchProductInfo() {
			if(this.$store.getters.activeCategory.products != null)
				return;
				
			requests.fetchProductInfo(this.$store.getters.dateStart, this.$store.getters.dateEnd, this.$store.getters.activeCategory.id).then((response)=>{
				this.$store.commit("setCategoryProducts", response.data.data);
				this.updateWMSLayers();
				requests.fetchStratificationInfo().then((response)=>{
					this.$store.commit("setStratifications", response.data.data);
					if(this.initCmp) {
						this.initCmp = false;
						this.refreshStratifications();
						this.updateStratificationLayerVisibility();
						this.updateStratificationLayerStyle();
					}
				});
			});
		},
		setLayerVisibility(id, val) {
			if(id != null)
				this.$refs.map1.setVisibility(id, val);
		},
		updateWMSLayers(displayFirst = false) {
			//no product available or the wms layers have been already fetched
			if (this.product == null || this.$store.getters.productWMSLayer != null) 
				return;
			
			let dt = {};
			var processWMS;// = noRTWMS;
			if (!this.product.rt) {
				dt[-1] = {}
				processWMS = noRTWMS;
			}
			else {
				let consPers = consolidationPeriods(this.product.rt);
				consPers.forEach(period => {
					dt[period.id] = {}
					processWMS = rtWMS;
				});
				
			}
			
			
			this.$store.getters.product.currentVariable.wms.urls.forEach( url => {
				console.log(url)
				this.$refs.map1.getAvailableWMSLayers(url, this.productVariableZIndex).then((data) => {
					processWMS(dt, url, data);
				
				this.$store.commit("appendToCurrentVariableWMSLayers",dt);
				if(displayFirst)
					this.updateWMSVisibility();
					
				}).catch(error => {
					console.log(error);
				});
			});
			
			if(this.$store.getters.product.currentVariable.currentAnomaly == null)
				return;
			
			this.$store.getters.product.currentVariable.currentAnomaly.wms.urls.forEach(url => {
				this.$refs.map1.getAvailableWMSLayers(url, this.anomaliesZIndex).then((data) => {
					let dt = {};
					data.forEach(lyr => {
						lyr["url"] = url;
						dt[lyr.datetime] = lyr;
					});
					this.$store.commit("appendToProductsAnomaliesWMSLayers", dt);
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
			this.$refs.map1.setVisibility( this.$store.getters.currentAnomalyWMSLayer.layerId,  this.$store.getters.productStatisticsViewMode == 1);
		},
		updateProductWMSVisibility() {
			if (this.$store.getters.previousProductWMSLayer != null)
				this.$refs.map1.setVisibility(this.$store.getters.previousProductWMSLayer.layerId, false);
			this.$refs.map1.setVisibility( this.$store.getters.productWMSLayer.layerId, true);
		},
		updatecurrentAnomalyWMSVisibility() {
			if (this.$store.getters.previouscurrentAnomalyWMSLayer != null) {
				this.$refs.map1.setVisibility(this.$store.getters.previouscurrentAnomalyWMSLayer.layerId, false);
			}

			this.$refs.map1.setVisibility( this.$store.getters.currentAnomalyWMSLayer.layerId, true);
		},
		updateWMSVisibility() {
			if (this.$store.getters.previousWMS != null) 
				this.$refs.map1.setVisibility(this.$store.getters.previousWMS.layerId, false);
			console.log(this.$store.getters.currentWMSLayer);
			if(this.$store.getters.currentWMSLayer == null) { //wms layers have not been initialized for current product, so do so
				this.updateWMSLayers(true);
			
			}
				else
					this.$refs.map1.setVisibility(this.$store.getters.currentWMSLayer.layerId, this.$store.getters.stratifiedOrRaw == 1);
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
			
			console.log(this.$store.getters.product.rtFlag.id, this.stratificationViewProps.rtFlag.id)
			//if no change, stop
			if (this.stratificationViewProps.stratID == this.$store.getters.currentStratification.id && this.stratificationViewProps.date == this.$store.getters.currentDate && 
			this.stratificationViewProps.variableID == this.$store.getters.product.currentVariable.id && this.$store.getters.productStatisticsViewMode == this.statisticsViewMode && this.$store.getters.stratifiedOrRaw == this.stratificationViewProps.stratifiedOrRaw && this.$store.getters.product.rtFlag.id == this.stratificationViewProps.rtFlag.id)
				return;
			
			this.stratificationViewProps.stratID 			= this.$store.getters.currentStratification.id;
			this.stratificationViewProps.date 			= this.$store.getters.currentDate;
			this.stratificationViewProps.variableID 		= this.$store.getters.product.currentVariable.id;
			this.stratificationViewProps.stratifiedOrRaw 	= this.$store.getters.stratifiedOrRaw;
			this.stratificationViewProps.rtFlag 			= this.$store.getters.product.rtFlag;

			if (this.$store.getters.productStatisticsViewMode == 1 && this.$store.getters.currentAnomaly != null) //seeing anomalies
				this.stratificationViewProps.variableID = this.$store.getters.currentAnomaly.id;
						
			if (this.stratificationViewProps.stratifiedOrRaw == 1) {
				let tmpLayer = this.$refs.map1.getLayerObject(this.$store.getters.currentStratification.layerId);
				tmpLayer.setStyle(this.stratificationViewProps.styleWMS);
				return;
			}
			

			if (! (this.stratificationViewProps.stratID in this.stratificationColorData))
				this.stratificationColorData[this.stratificationViewProps.stratID] = {};
			
			if (!(this.stratificationViewProps.rtFlag.id in  this.stratificationColorData[this.stratificationViewProps.stratID]))
				this.stratificationColorData[this.stratificationViewProps.stratID][this.stratificationViewProps.rtFlag.id] = {}
			
			if (! (this.stratificationViewProps.variableID in this.stratificationColorData[this.stratificationViewProps.stratID][this.stratificationViewProps.rtFlag.id]))
				this.stratificationColorData[this.stratificationViewProps.stratID][this.stratificationViewProps.rtFlag.id][this.stratificationViewProps.variableID] = {};

			if (!(this.stratificationViewProps.date in this.stratificationColorData[this.stratificationViewProps.stratID][this.stratificationViewProps.rtFlag.id][this.stratificationViewProps.variableID])) {
				this.$refs.map1.activateSpinner();
				requests.fetchStratificationDataByProductAndDate(this.stratificationViewProps.date, this.stratificationViewProps.variableID, this.stratificationViewProps.rtFlag.id, this.stratificationViewProps.stratID).then((response)=>{
					this.$refs.map1.activateSpinner();
					let styles = {};

					let areaDensityInfo = new areaDensityOptions();
					areaDensityInfo.forEach(density => {
						styles[density.color_col] = {};
					});
					styles["meanval_color"] = {}
					for (let idx = 0; idx < response.data.data.length; idx++) {
						let rec = response.data.data[idx];
						let id = rec.id;
						Object.keys(styles).forEach(colorCol => {
							let color = rec[colorCol];
							styles[colorCol][id] = new Style();
							if (color != null) {
								let joinedColor = color.join();
								styles[colorCol][id] = new Style({
									fill: new Fill({
										color: "rgba(" + joinedColor + ",0.7)",
									}),
									stroke: new Stroke({
										color:  "rgba(" + joinedColor + ",1.0)",
									width: 1.2,
									})
								});
							}
						});
					}
				
					this.stratificationColorData[this.stratificationViewProps.stratID][this.stratificationViewProps.rtFlag.id][this.stratificationViewProps.variableID][this.stratificationViewProps.date] = styles;
					this.setStratificationStyle();
				});
			} 
			else 
				this.setStratificationStyle();
		},
		setStratificationStyle() {
			this.$refs.map1.activateSpinner();
			let tmpLayer = this.$refs.map1.getLayerObject(this.$store.getters.currentStratification.layerId);
			let colorCol = this.$store.getters.stratificationViewOptions.colorCol;
			tmpLayer.setStyle( (ft) => {
				//console.log("hereeee");
				return this.stratificationColorData[this.stratificationViewProps.stratID][this.stratificationViewProps.rtFlag.id][this.stratificationViewProps.variableID][this.stratificationViewProps.date][colorCol][ft.getId()];
			});
			this.$refs.map1.deactivateSpinner();
		},
		updateStratificationLayerVisibility() {
			if (this.$store.getters.previousStratification != null)
				this.$refs.map1.setVisibility( this.$store.getters.previousStratification.layerId, false);

			if (this.$store.getters.currentStratification != null) {
				this.$refs.map1.setVisibility( this.$store.getters.currentStratification.layerId, true);
				this.$refs.map1.highlightOnLayer(this.$store.getters.currentStratification.layerId);
			}
		}
	},
	mounted(){
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

	.logo {
		justify-content:end;
		position: fixed;
		bottom: 0px;
		right: 0px;
		height:8%;
	}
</style>

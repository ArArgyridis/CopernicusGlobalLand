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
	<OLMap id="map1" v-bind:center=[0,0] v-bind:zoom=2 bingKey="Aiq5aNY4e4kv_7oWzzn9m2zdnfBjabNG8Lc39kAnE-SuAYaeDWruOiRrk1RhIGYl" v-bind:epsg=projectEPSG  ref="map1" class="map" />
</template>

<script>
import OLMap from './libs/OLMap.vue';
import requests from '../libs/js/requests.js';
import options from "../libs/js/options.js";
import {Fill, Stroke, Style } from 'ol/style';

export default {
	name: 'MapApp'
	,data() {
		return {
			activeWMSLayer: null,
			bingId: null,
			projectEPSG: "EPSG:3857",
			productZIndex: 1,
			stratificationZIndex: 2
		}
	},	
	props: {},
	components: {
		OLMap
	},
	computed: {},
	methods: {
		init() {
			//cartographic background
			this.bingId = this.$refs.map1.addBingLayerToMap("aerial",  true, 0);
			this.$refs.map1.setVisibility(this.bingId, true);
			//initializing stratifications			
		},
		activateLayer(key) {
			if (this.activeWMSLayer != null)
				this.$refs.map1.setVisibility(this.wmsLayers[this.activeWMSLayer].layerId, false);
				
			this.$refs.map1.setVisibility( this.wmsLayers[key].layerId, true);
			this.activeWMSLayer = key;
		},
		clearStratifications() {
			if (this.$store.getters.stratifications != null)
				this.$store.getters.stratifications.forEach( (key) =>{
					this.$refs.map1.removeLayer(key.layerId);
				});
			
			this.$store.commit("clearStratifications");
		},
		clearPolygonSelection() {
			this.$refs.map1.clearCurrentPolygonSelection();
		},
		clearWMSLayers(){
			//remove wms layers from map
			this.$store.getters.productsWMSLayers.forEach( (key) => {
				this.$refs.map1.removeLayer(key.layerId );
			}); 
			
			//clearing existing wmsLayers from store
			this.$store.commit("clearProductsWMSLayers");
			
			//clearing stratification style
			if (this.$store.getters.currentStratification != null)
				this.$refs.map1.getLayerObject(this.$store.getters.currentStratification.layerId).setStyle();
			
		},
		emit(eventName, data) {
			this.$emit(eventName, data);
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
		updateWMSLayers() {
			//requested years from users
			let requestedYears= [];
			for(let i = this.$store.getters.dateStart.getFullYear(); i <= this.$store.getters.dateEnd.getFullYear(); i++)
				requestedYears.push(i);
			
			//available years from db 
			let availableYears = [];
			if (this.$store.getters.currentProduct == null)
				return;

			Object.keys(this.$store.getters.currentProduct.dates).forEach((date) => {
				date = new Date(date);
				let tmpYear = date.getFullYear();
				if (!availableYears.includes(tmpYear))
					availableYears.push(tmpYear);
			});
			requestedYears.forEach(year =>{
				if (availableYears.includes(year)) {
					let productName = this.$store.getters.currentProduct.name;
					this.$refs.map1.getAvailableWMSLayers(options.wmsURL + productName + "/" + year, this.productZIndex).then((data) => {
						this.$store.commit("appendToProductsWMSLayers",data);
					});			
				}
			});
		},
		toggleClickOnMap(){
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
		updateStratificationLayerStyle(){
			if (this.$store.getters.areaDensity == null)
				return;
				
			requests.fetchStratificationDataByProductAndDate(this.$store.getters.currentStratificationDate,			
			this.$store.getters.currentProduct.id,
			this.$store.getters.currentStratification.id
			).then((response)=>{
				this.dt = response.data.data;
				this.res = 0;
				let tmpLayer = this.$refs.map1.getLayerObject(this.$store.getters.currentStratification.layerId);
				tmpLayer.setStyle( (ft) => {
					let id = ft.getId();
					if( id in response.data.data) {
						//console.log(this.$store.getters.areaDensity);
						let color = response.data.data[id][this.$store.getters.areaDensity.color_col];
						return new Style({
							fill: new Fill({
								color:  "rgba(" + color.join() + ",0.7)",
							}),
							stroke: new Stroke({
								color: "rgba(" + color.join() + ",1.0)",
								width: 1,
							})
						});
					}
					
					return null;
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
}
</style>

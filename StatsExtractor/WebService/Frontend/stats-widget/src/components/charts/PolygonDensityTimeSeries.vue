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
	<highcharts ref="diagram" id="diagram" :options="diagramOptions"/>
</template>

<script>

import requests from "../../libs/js/requests.js";
import {Chart} from 'highcharts-vue';
import Highcharts from 'highcharts'
import column from 'highcharts/modules/exporting';

column(Highcharts);
export default {
	name: "PolygonDensityTimeSeries",
	props:{},
	components: {
		highcharts: Chart
	},
	computed:{
		diagramOptions() {
			//this.updateChartData();
			return this.__computeChartOptions();
		},
		diagramTitle() {
			if (this.$store.getters.product == null || this.$store.getters.areaDensity == null)
				return "Dummy Title";
			return "Region Density Timeseries for raw Product (" + this.$store.getters.areaDensity.description +")";
		},
		noData() {
			return  [null];
		}
	},
	data(){
		return{
			isLoading: true,
			diagramData: this.noData,
			polygonId: null,
			areDensity: {id: null},
			productVariable: {id: null}		
		}
	},
	methods: {
		loads() {
			return this.isLoading;
		},
		updateChartData() {
			this.isLoading = true;
			
			//checking if data should be fetched
			//data availability
			if (this.$store.getters.product == null || this.$store.getters.selectedPolygon == null || this.$store.getters.areaDensity == null)
				return;

			//data similarity
			if (this.productVariable.id == this.$store.getters.product.id && this.polygonId == this.$store.getters.selectedPolygon && this.areaDensity.id == this.$store.getters.areaDensity.id)
				return;
			
			this.polygonId= this.$store.getters.selectedPolygon;
			this.productVariable = this.$store.getters.product.currentVariable;
			this.areaDensity = this.$store.getters.areaDensity;
			
			requests.densityStatsByPolygonAndDateRange(this.polygonId, this.$store.getters.dateStart, this.$store.getters.dateEnd, this.productVariable.id,  this.productVariable.rtFlag.id, this.areaDensity.col).then((response) =>{
				if (response.data.data != null) {
					response.data.data.forEach((pair)=>{
						pair[0] = (new Date(pair[0])).getTime();
					});
					this.diagramData = response.data.data;
					this.isLoading = false;
					this.resizeChart();
				}
			}).catch(() =>{
				this.diagramData = this.noData;
			});
		},
		reset() {
			this.diagramData = this.noData;
		},
		resizeChart() {
			if (this.diagramTitle != "Dummy Title")
				this.$refs.diagram.chart.reflow();
		},
		__computeChartOptions() {
			return {
				credits:{
					enabled:false
				},
				title:{
					text: this.diagramTitle,
					style: {
						fontSize: '15px' 
					}
				},
				series: [{
					data: this.diagramData
				}],
				yAxis:{
					title:{
						enabled:true,
						text:"Area (ha)"
					}
				},
				xAxis: {
					type: "datetime",
					dateTimeLabelFormats: {
						month: '%e/%m/%y'
					},
					title:{
						enabled:true,
						text:"Date",
					},
					plotBands: [{ // mark the weekend
						color: 'rgba(255,145,71,0.9)',
						from:  Date.parse(this.$store.getters.currentDate ) -86400*4,
						to:  Date.parse(this.$store.getters.currentDate ) + 86400*4,
						id: 'pltbnd1'
					}]
				},
				legend:{
					enabled: false
				}
			}
		}
	}
}

</script>


<style scoped>
</style>

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
	name: "PolygonTimeSeries",
	props:{
		mode: String
	},
	components: {
		highcharts: Chart
	},
	computed:{
		diagramTitle() {
			if (this.$store.getters.product == null)
				return "Dummy Title";
			return "Product Time Series for Region (" + this.mode + ")";
		},
		diagramOptions() {
			let polyId = this.$store.getters.selectedPolygon;
			let product = this.$store.getters.product;
			if (this.mode == "Anomalies")
				product = this.$store.getters.productAnomaly;
			let valueRange  = [0, 1.5];
			if (product !=null) 
				valueRange = product.value_ranges;
			
			this.updateChartData(polyId, product, valueRange);			
			let step = (valueRange[valueRange.length-1] - valueRange[0])/valueRange.length;
			
			let tmpDt = this.diagramData;
			if (tmpDt == null)
				tmpDt = this.noData;
			this.resizeChart();
			return this.__computeChartOptions(tmpDt, valueRange, step);
		},
		noData() {
			let ret = [null, null, null, null];
			return ret;
		}
	},
	data(){
		return{
			diagramData: this.noData,
			isLoading: true,
			previousPolyId: null,
			product: {id:null}
		}
	},
	methods:{
		loads() {
			return this.isLoading;
		},
		updateChartData(polyId, product) {
			if (product == null || polyId == null)
				return;
			
			if(this.product.id == product.id && this.previousPolyId ==polyId)
				return;
			
			this.isLoading = true;
			this.product = product;			
			this.previousPolyId = polyId;			
			
			if(polyId != null && product != null) { 
				requests.polygonStatsTimeSeries(polyId, this.$store.getters.dateStart, this.$store.getters.dateEnd, product.id)
				.then((response) =>{
					if (response.data.data != null) {
					
						let diagramData = null;
						
						if (this.mode == "Raw") {
							diagramData = [
								new Array(response.data.data.length),
								new Array(response.data.data.length),
								new Array(response.data.data.length),
								new Array(response.data.data.length)
							];
							for (let i = 0; i < response.data.data.length; i++ ) {							
								let it = response.data.data[i];
								it[0] =  (new Date(it[0])).getTime();
							
								diagramData[0][i] = [ it[0], it[3]-2*it[4], it[3]+2*it[4]];
								diagramData[1][i] = [ it[0], it[1] ];
								diagramData[2][i] = [ it[0], it[1] - it[2], it[1]+it[2] ];
								diagramData[3][i] = [ it[0], it[3] ];
							}
						} else if (this.mode == "Anomalies") {
							diagramData = [
								null,
								new Array(response.data.data.length),
								new Array(response.data.data.length),
								null
							];
							for (let i = 0; i < response.data.data.length; i++ ) {
								let it = response.data.data[i];
								it[0] =  (new Date(it[0])).getTime();
								diagramData[1][i] = [ it[0], it[1] ];
								diagramData[2][i] = [ it[0], it[1] - it[2], it[1]+it[2] ];
							}
						}
						
						this.diagramData= diagramData;
						this.isLoading = false;
					}
				})
				.catch(() =>{
					this.diagramData = this.noData;
				});
			}
			else
				this.diagramData = this.noData;
		},
		reset() {
			this.diagramData = this.noData;
		},
		resizeChart() {
			if (this.diagramTitle != "Dummy Title" && this.$refs.diagram != null)
				this.$refs.diagram.chart.reflow();
		},
		__computeChartOptions(tmpDt=this.noData, valueRange=[0,1.5], step=0.2) {
			return {
				credits:{
					enabled:false
				},
				title:{
					text: this.diagramTitle
				},
				series: [
					{
						name:"valid range",
						type:"arearange",
						data: tmpDt[0],
						showInLegend: false,
						color:"rgba(201, 201, 201, 0.7)",
						marker: {
							enabled:false
						},
					},
					{	
						name: "Polygon Mean Values",
						data: tmpDt[1]
					},
					{
						type: 'errorbar',
						data: tmpDt[2]
					},
					{
						name: "Polygon Long-Term Mean Value",
						data: tmpDt[3],
						color: '#EB603F',
						marker: {
							enabled:false
						},
						dashStyle: 'dot',
						showInLegend: this.mode == "Raw"
					}
				],
				yAxis:{
					min: valueRange[0] - step,
					max: valueRange[valueRange.length-1]+step,
					title:{
						enabled:true,
						text:"Product value",
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
						from:  Date.parse(this.$store.getters.currentDate) - 86400*34,
						to:  Date.parse(this.$store.getters.currentDate) + 86400*34,
						id: 'pltbnd1'
					}]
				},
				legend:{
					enabled: true
				}
			};
		
		}
	}
}

</script>


<style scoped>
</style>

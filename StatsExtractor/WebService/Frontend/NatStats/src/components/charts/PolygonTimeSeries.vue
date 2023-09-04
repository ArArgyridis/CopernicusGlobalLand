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
	<highcharts ref="diagram" v-if="product !=null" id="diagram" :options="diagramOptions"/>
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
			if (this.product == null)
				return "Dummy Title";
			return "Polygon Time Series for Product (" + this.mode + ")";
		},
		diagramOptions() {
			if (this.product == null)
				return;
			
			let variable = this.product.currentVariable;
			
			if (this.mode == "Anomalies")
				variable = this.$store.getters.currentAnomaly;
			let valueRange  = [0, 1.5];
			if (variable !=null) 
				valueRange = variable.valueRanges;
			
			let step = (valueRange[valueRange.length-1] - valueRange[0])/valueRange.length;

			this.resizeChart();
			return this.__computeChartOptions(valueRange, step);
		},
		noData() {
			let ret = [null, null, null, null];
			return ret;
		},
		product() {
			return this.$store.getters.product;
		}
	},
	data(){
		return{
			diagramData: this.noData,
			isLoading: true,
			previousPolyId: null,
			curProductVariable: {id:null},
			rtFlag:{id:-1}
		}
	},
	methods:{
		loads() {
			return this.isLoading;
		},
		updateChartData() {
			let productVariable = this.$store.getters.product.currentVariable;
			if(this.mode == "Anomalies")
				productVariable = this.$store.getters.currentAnomaly;
			
			let polyId = this.$store.getters.selectedPolygon;
			if (productVariable == null || polyId == null)
				return;

			if(this.curProductVariable.id == productVariable.id && this.previousPolyId ==polyId && this.$store.getters.product.rtFlag.id == this.rtFlag.id)
				return;
			
			this.isLoading = true;
			this.curProductVariable = productVariable;			
			this.previousPolyId = polyId;		
			this.rtFlag = this.$store.getters.product.rtFlag;
			
			if(polyId != null && productVariable != null) { 
				requests.polygonStatsTimeSeries(polyId, this.$store.getters.dateStart, this.$store.getters.dateEnd, productVariable.id, this.rtFlag.id)
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

						this.isLoading = false;
						try {
							this.diagramData= diagramData;
						} catch (e) {
							console.log(e); // Logs the error
						}
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
		__computeChartOptions(valueRange=[0,1.5], step=0.2) {		
			let tmpDt = this.diagramData;
			if (tmpDt == null)
				tmpDt = this.noData;
				
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

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
	<highcharts ref="diagram" :options="diagramOptions"/> 	
</template>

<script>
import {Chart} from 'highcharts-vue';
import Highcharts from 'highcharts';
import column from 'highcharts/modules/exporting';
import highchartsMore from 'highcharts/highcharts-more'
import requests from "../../libs/js/requests.js";

column(Highcharts);
highchartsMore(Highcharts);

export default {
	name: "PointTimeSeries",
	components: {
		highcharts: Chart
	},
	props: {
		mode: String
	},
	computed: {
		currentCoordinates() {
			return this.$store.getters.clickedCoordinates;
		},
		diagramTitle() {
			if (this.$store.getters.product == null)
				return "Dummy Title";
				
			return   "Location Time Series (" + this.mode + ")";
		},
		diagramOptions() {
			let product = this.$store.getters.product;
			if (this.mode == "Anomalies")
				product = this.$store.getters.productAnomaly;
			
			let coords =this.$store.getters.clickedCoordinates;
			if (coords != null)
				coords = JSON.parse(JSON.stringify(coords));
			let dateStart = JSON.parse(JSON.stringify(this.$store.getters.dateStart));
			let dateEnd = JSON.parse(JSON.stringify(this.$store.getters.dateEnd));
			
			this.updateChartData(product, coords, dateStart, dateEnd);
			
			let tmpDt = this.diagramData;
			if (tmpDt == null)
				tmpDt = this.noData;
			
			let valueRange  = [0, 1.5];
			
			if (product !=null) {
				valueRange = product.value_ranges;
			}
			
			let step = (valueRange[valueRange.length-1] - valueRange[0])/valueRange.length;
			return this.__computeChartOptions(tmpDt, valueRange, step);
		},
		noData() {
			return  [null, null, null];
		}
	},
	data() {
		return {
			previousCoordinates: {coordinate:[-NaN, -NaN]},
			previousDateStart: null,
			previousDateEnd: null,
			isLoading: true,
			diagramData: this.noData,
			product:{id:null}
		}
	},
	methods: {
		loads() {
			console.log("hereee", this.isLoading);
			return this.isLoading;
		},
		updateChartData(product, coords, dateStart, dateEnd) {
			//checking if data should be fetched
			if (product == null || coords == null || dateStart == null || dateEnd == null)
				return;
			
			if (this.product.id == product.id && this.previousCoordinates.coordinate[0] == coords.coordinate[0] && this.previousCoordinates.coordinate[1] == coords.coordinate[1]  && this.previousDateStart ==dateStart && this.previousDateEnd == dateEnd)
				return;
			
			this.isLoading = true;
			this.previousCoordinates 	= coords;
			this.previousDateStart 	= dateStart;
			this.previousDateEnd 	= dateEnd;
			this.product = product;

			requests.getRawTimeSeriesDataForRegion(dateStart, dateEnd, product.id, coords).then((response) => {
				let diagramData = null;
				if (this.mode == "Raw") {
					diagramData = [
						new Array(response.data.data.length),
						new Array(response.data.data.length),
						new Array(response.data.data.length)
					];
					
					for (let i = 0; i < response.data.data.length; i++) {
						let row = response.data.data[i];
						let tm = new Date(row[0]).getTime();
						diagramData[0][i] = [tm, row[2] - 2*row[3],  row[2] +2*row[3]];
						diagramData[1][i] = [tm, row[1]];
						diagramData[2][i] = [tm, row[2]];
					}
				}
				else if (this.mode == "Anomalies") {
					diagramData = [
						null,
						new Array(response.data.data.length),
						null
					];
					
					for (let i = 0; i < response.data.data.length; i++) {
						let row = response.data.data[i];
						let tm = new Date(row[0]).getTime();
						diagramData[1][i] = [tm, row[1]];
					}
				}
				
				this.diagramData = diagramData;
				this.$refs.diagram.chart.hideLoading();
				this.resizeChart();
				this.isLoading = false;		
1			}).catch(() =>{
				this.diagramData = this.noData;
				this.$refs.diagram.chart.hideLoading();
			});
			this.$refs.diagram.chart.showLoading();
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
					},{
						name: "Product value",
						data: tmpDt[1], 
						color: '#0F602C'
					},{
						name: "Long-Term Value",
						data: tmpDt[2],
						color: '#EB603F',
						showInLegend: this.mode == "Raw",
						marker: {
							enabled:false
						},
						dashStyle: 'dot',
					}
				],
				yAxis:{
					min: valueRange[0] - step,
					max: valueRange[valueRange.length-1] + step,
					title:{
						enabled:true,
						text:"Variable Value"
					}
				},
				xAxis:{
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
						from:  Date.parse(this.$store.getters.currentDate) - 86400*4,
						to:  Date.parse(this.$store.getters.currentDate) + 86400*4,
						id: 'pltbnd1'
					}]
				},
				legend:{
					enabled: true
				}
			}
		}
	}
}




</script>


<style scoped>
</style>

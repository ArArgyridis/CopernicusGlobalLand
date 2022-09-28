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
import Highcharts from 'highcharts'
import column from 'highcharts/modules/exporting';
import requests from "../../libs/js/requests.js";

column(Highcharts);
export default {
	name: "PointTimeSeries",
	components: {
		highcharts: Chart
	},
	props: {},
	computed: {
		currentCoordinates() {
			return this.$store.getters.clickedCoordinates;
		},
		diagramTitle() {
			if (this.$store.getters.currentProduct == null)
				return "Dummy Title";
				
			return "Raw " + this.$store.getters.currentProduct.description;
		},
		diagramData: {
			get() {
				return this.rawTimeSeries.series[0].data;
			},
			set(dt) {
				this.$refs.diagram.chart.series[0].setData(dt[0], true);
				this.$refs.diagram.chart.series[1].setData(dt[1], true);
			}
		}
	},
	data() {
		return {
			isLoading: true,
			diagramOptions:{
				credits:{
					enabled:false
				},
				title:{
					text: this.diagramTitle
				},
				series: [{data: null},{data: null}],
				yAxis:{
					min: 0,
					max: 0.9,
					title:{
						enabled:true,
						text:"Raw Value"
					},
					plotBands: [{ // mark the weekend
						color: 'rgba(0,0,0,1)',
						from:  Date.UTC(2021, 0, 2, 8),
						to:  Date.UTC(2021, 0, 2, 14),
						id: 'pltbnd1'
					}]
				},
				xAxis:{
					type: "datetime",
					dateTimeLabelFormats: {
						month: '%e/%m/%y'
					},
					title:{
						enabled:true,
						text:"Date",
					}
				},
				legend:{
					enabled: false
				}
			}
		}
	},
	methods: {
		loads() {
			return this.isLoading;
		},
		displayCurrentDate() {
			if (this.$store.getters.currentStratificationDate == null)
				return;
				
			let tmpDt =  Date.parse(this.$store.getters.currentStratificationDate );

			let dtStart = tmpDt - 86400*4;
			let dtEnd = tmpDt + 86400*4;
			this.$refs.diagram.chart.xAxis[0].removePlotBand('pltbnd1');
			this.$refs.diagram.chart.xAxis[0].addPlotBand({ // mark the weekend
				color: 'rgba(255,145,71,0.9)',
				from:  dtStart,
				to:  dtEnd,
				id: 'pltbnd1'
			});
		},
		updateChartData() {
			//if (this.currentCoordinates == null || this.currentCoordinates.coordinate[0] != coordInfo.coordinate[0] || this.currentCoordinates.coordinate[1] != coordInfo.coordinate[1]) {
			if (this.currentCoordinates == null)
				return;
				
			this.isLoading = true;
			let tmpProdId = this.$store.getters.currentProduct.id;
			this.$refs.diagram.chart.yAxis[0].options.min = 0;
			this.$refs.diagram.chart.yAxis[0].options.max = 0.9;
			if (this.$store.getters.currentView == 2) {
				tmpProdId = this.$store.getters.currentAnomaly;
				if (tmpProdId == null)
					return
				tmpProdId = tmpProdId.id;
				
				this.$refs.diagram.chart.yAxis[0].options.min = 0;
				this.$refs.diagram.chart.yAxis[0].options.max = 7;
			}
				
			requests.getRawTimeSeriesDataForRegion(this.$store.getters.dateStart, this.$store.getters.dateEnd, tmpProdId, this.currentCoordinates).then((response) =>{
				response.data.data.raw.forEach((pair)=>{
					pair[0] = (new Date(pair[0])).getTime();
				});
				response.data.data.filtered.forEach((pair)=>{
					pair[0] = (new Date(pair[0])).getTime();
				});
				this.diagramData = [response.data.data.raw, response.data.data.filtered];
				this.$refs.diagram.chart.setTitle({text:this.diagramTitle}, true);
			
				this.updateChartCurrentDate();				
				this.$refs.diagram.chart.hideLoading();
				this.isLoading = false;
			}).catch(() =>{
				this.diagramData = [null, null];
				this.$refs.diagram.chart.hideLoading();
			});
			this.$refs.diagram.chart.showLoading();
			this.updateChartCurrentDate();
		},
		updateChartCurrentDate() {
			if (this.$store.getters.currentStratificationDate == null)
				return;
				
			let tmpDt =  Date.parse(this.$store.getters.currentStratificationDate );

			let dtStart = tmpDt - 86400*4;
			let dtEnd = tmpDt + 86400*4;
			this.$refs.diagram.chart.xAxis[0].removePlotBand('pltbnd1');
			this.$refs.diagram.chart.xAxis[0].addPlotBand({ // mark the weekend
				color: 'rgba(255,145,71,0.9)',
				from:  dtStart,
				to:  dtEnd,
				id: 'pltbnd1'
			});
		},
		reset() {
			this.diagramData = [null, null];
		},
		resizeChart() {
			//if (this.diagramTitle != "Dummy Title")
				this.$refs.diagram.chart.reflow();
		}
	}
}




</script>


<style scoped>
</style>

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
	props:{},
	components: {
		highcharts: Chart
	},
	computed:{
		diagramTitle() {
			if (this.$store.getters.product == null || this.$store.getters.areaDensity == null)
				return "Dummy Title";
			return this.$store.getters.product.description + " Timeseries (Density: " + this.$store.getters.areaDensity.description +")";
		},
		diagramData:{
			get() {
				return this.diagramOptions.series[0].data;
			},
			set(dt) {
				this.$refs.diagram.chart.series[0].setData(dt, true);
				this.$refs.diagram.chart.setTitle({text:this.diagramTitle}, false);
			}
		}
	},
	data(){
		return{
			isLoading: true,
			diagramOptions:{
				credits:{
					enabled:false
				},
				title:{
					text:"Dummy Title"
				},
				series: [{
					data: null
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
						color: 'rgba(0,0,0,1)',
						from:  Date.UTC(2021, 0, 2, 8),
						to:  Date.UTC(2021, 0, 2, 14),
						id: 'pltbnd1'
					}]
				},
				legend:{
					enabled: false
				}
			}
		}
	},
	methods:{
		loads() {
			return this.isLoading;
		},
		updateChartCurrentDate() {
			if (this.$store.getters.currentDate == null)
				return;
				
			let tmpDt =  Date.parse(this.$store.getters.currentDate );

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
			this.isLoading = true;
			let polyId = this.$store.getters.selectedPolygon;
			let product = this.$store.getters.product;
			let areaDensity = this.$store.getters.areaDensity;
			
			if(polyId != null && product != null &&  areaDensity != null) { 
				requests.fetchStatsByPolygonAndDateRange(polyId, this.$store.getters.dateStart, this.$store.getters.dateEnd, product.id, areaDensity.col)
				.then((response) =>{
					if (response.data.data != null) {
						response.data.data.forEach((pair)=>{
							pair[0] = (new Date(pair[0])).getTime();
						});
						this.diagramData = response.data.data;
						this.updateChartCurrentDate();
						this.isLoading = false;
					}
				})
				.catch(() =>{
					this.diagramData = null;
				});
			}
			else
				this.diagramData = null;

		},
		reset() {
			this.diagramData = null;
		},
		resizeChart() {
			if (this.diagramTitle != "Dummy Title")
				this.$refs.diagram.chart.reflow();
		}
	}
}

</script>


<style scoped>
</style>

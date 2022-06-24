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
<div class="base">
	<div class="row position-relative d-flex flex-center">
	<!--<div class="col position-absolute">-->
	<div class="nav nav-tabs" v-on:click="switchActive(evt)">
		<button v-for="nav in navBarOptions" v-bind:key="nav.id" class=" col center nav-link text-muted text-center" v-bind:class="{active: nav.active}" v-on:click="switchActive(nav.id)" v-bind:id="'chart_'+nav.id">
			{{nav.content}}
		</button>
	</div>
	<div>
		<div class="text-end raise" ><div class="btn" v-on:click="closePanel"><a>x</a></div></div>
	</div>
	</div>
	
	<highcharts ref="rawTimeSeriesChart" v-show="getActiveDiagram == 0 && navBarOptions[0].condition() " id="rawTimeSeriesChart" :options="rawTimeSeries"/> 
	<highcharts ref="stratificationTimeSeriesChart" v-show="getActiveDiagram == 1 && navBarOptions[1].condition()" id="stratificationTimeSeriesChart" :options="stratificationTimeSeries"/>
	<highcharts ref="pieDatePolygonChart" v-show="getActiveDiagram == 2 && navBarOptions[2].condition()" id="datePieChart" :options="datePolygonPie"/>
	<highcharts ref="histogramChart" v-show="getActiveDiagram == 3 && navBarOptions[3].condition()" id="histogramChart" :options="stratificationHistogram"/>
	<button class="btn btn-secondary mt-3" v-on:click="this.$emit('showDashboard')"> Show Region Dashboard</button>
</div>
</template>

<script>
import requests from "../libs/js/requests.js";
import {Chart} from 'highcharts-vue';
import Highcharts from 'highcharts'
import column from 'highcharts/modules/exporting';
column(Highcharts);

export default {
	name:"TimeseriesCharts",
	components:{
		highcharts: Chart
	},
	props:{},
	computed: {		
		getActiveDiagram() {
			for (let i = 0; i < this.navBarOptions.length; i++)
				if (this.navBarOptions[i].active)
					return this.navBarOptions[i].id;
			return -1;

		},	
		stratificationHistogramTitle() {
			if (this.$store.getters.currentProduct == null || this.$store.getters.currentStratificationDate == null)
				return "Dummy Title";
				
			return this.$store.getters.currentProduct.description + " (" + this.$store.getters.currentStratificationDate.substring(0, 10)+")";
		},
		stratificationHistogramData:{
			get() {
				return this.$refs.histogramChart.chart.series[0].data;
			},
			set(dt) {
				this.$refs.histogramChart.chart.series[0].setData(dt[0], true);
				this.$refs.histogramChart.chart.axes[0].setCategories(dt[1],true);
				this.$refs.histogramChart.chart.setTitle({text:this.stratificationHistogramTitle}, true);
				this.$refs.histogramChart.chart.reflow();
			}
		},
		stratificationTimeSeriesTitle() {
			if (this.$store.getters.currentProduct == null)
				return "Dummy Title";
			return this.$store.getters.currentProduct.description + " Timeseries (Density: " + this.$store.getters.areaDensity.description +")"
		},
		timeSeriesStratificationData:{
			get() {
				return this.stratificationTimeSeries.series[0].data;
			},
			set(dt) {
				this.$refs.stratificationTimeSeriesChart.chart.series[0].setData(dt, true);
				this.$refs.stratificationTimeSeriesChart.chart.setTitle({text:this.stratificationTimeSeriesTitle}, false);
				this.$refs.stratificationTimeSeriesChart.chart.reflow();
			}
		},
		pieDatePolygonTitle() {
			console.log("pie title!!!", this.$store.getters.currentStratificationDate);
			if (this.$store.getters.currentProduct == null || this.$store.getters.currentStratificationDate == null) {
				console.log("return dummy!!!");
				return "Dummy Title";
			}
			console.log("here");
			return "Density Distribution for " + this.$store.getters.currentStratificationDate;
		}, 
		pieDatePolygonData: {
			get() {
				return this.$refs.pieDatePolygonChart.chart.series[0].data;
			},
			set(dt) {
				this.$refs.pieDatePolygonChart.chart.series[0].setData(dt, true);
			}
		},
		rawTimeSeriesTitle() {
			if (this.$store.getters.currentProduct == null)
				return "Dummy Title";
				
			return "Raw " + this.$store.getters.currentProduct.description;
		},
		
		rawTimeSeriesData: {
			get() {
				return this.rawTimeSeries.series[0].data;
			},
			set(dt) {
				this.$refs.rawTimeSeriesChart.chart.series[0].setData(dt[0], true);
				this.$refs.rawTimeSeriesChart.chart.series[1].setData(dt[1], true);
				this.$refs.rawTimeSeriesChart.chart.setTitle({text:this.rawTimeSeriesTitle}, true);
				this.$refs.rawTimeSeriesChart.chart.reflow();
			}
		}
	},
	data() {
		return {
			navBarOptions: [
				{
					id: 0,
					content: "Point Timeseries",
					active: true,
					condition: () => { return this.$store.getters.currentProduct !== null && this.$store.getters.dateStart != null && this.$store.getters.dateEnd != null;}
				},
				{	
					id: 1,
					content: "Density-Driven Polygon Timeseries",
					active: false,
					condition: () => {return this.$store.getters.currentProduct !== null && this.$store.getters.dateStart != null && this.$store.getters.dateEnd != null && this.$store.getters.areaDensity != null;}
					
				},
				{
					id: 2,
					content: "Density Distribution",
					active: false,
					condition: () => {return this.$store.getters.currentProduct !== null && this.$store.getters.currentStratificationDate != null }
				},
				{
					id: 3,
					content: "Polygon Histogram Values",
					active: false,
					condition: () => {return this.$store.getters.currentProduct !== null && this.$store.getters.currentStratificationDate != null;}
				}
			],
			stratificationTimeSeries:{
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
				
			},
			rawTimeSeries:{
				credits:{
					enabled:false
				},
				title:{
					text: this.rawTimeSeriesTitle
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
			},
			datePolygonPie: {
				credits:{
					enabled:false
				},
				chart: {
					plotBackgroundColor: null,
					plotBorderWidth: null,
					plotShadow: false,
					type: 'pie'
				},
				title: {
					text: this.pieDatePolygonTitle
				},
				tooltip: {
					pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
				},
				accessibility: {
					point: {
						valueSuffix: '%'
					}
				},
				plotOptions: {
					pie: {
						allowPointSelect: true,
						cursor: 'pointer',
						dataLabels: {
							enabled: true,
								format: '<b>{point.name}</b>:  {point.percentage:.1f} % '
							}
					}
				},
					series: [{
						name: 'Density',
						colorByPoint: true,
						data: []
					}]
			},
			stratificationHistogram:{
				credits:{
					enabled:false
				},
				title:{
					text: "Dummy Title"
				},
				plotOptions: {
					column: {
						pointPadding: 0,
						borderWidth: 1,
						groupPadding: 0,
						shadow: false
					}
				},
				series: [{
					name: "Histogram",
					type: "column",
					data: null
				}],
				yAxis:{
					title:{
						enabled:true,
						text:"Number of Pixels"
					}
				},
				xAxis:{
					categories: [
						"0 - 25",
						"25-50",
						"50-75",
						"75-100",
						"100-125",
						"125-150",
						"150-175",
						"175-200",
						"200-225",
						"225-250"
					],
					title:{
						enabled:true,
						text:"Frequency",
					}
				},
				legend:{
					enabled: false
				}
			}
		}
	},
	methods: {
		switchActive(id) {
			if (id == null)
				return;
			this.navBarOptions.forEach((nav) => {
				nav.active = (nav.id == id && nav.condition());
				console.log(nav.id, nav.condition());
			});
		},
		closePanel(){
			this.resetAllCharts();
			this.$emit("closeTimechartsPanel");
		},
		updateRawTimeSeriesChart(coordInfo) {
			requests.getRawTimeSeriesDataForRegion(this.$store.getters.dateStart, this.$store.getters.dateEnd, this.$store.getters.currentProduct.id, coordInfo)
			.then((response) =>{
				response.data.data.raw.forEach((pair)=>{
					pair[0] = (new Date(pair[0])).getTime();
				});
				response.data.data.filtered.forEach((pair)=>{
					pair[0] = (new Date(pair[0])).getTime();
				});
				this.rawTimeSeriesData = [response.data.data.raw, response.data.data.filtered];
				this.rawTimeSeries.title.text = this.rawTimeSeriesTitle;
				this.$refs.rawTimeSeriesChart.chart.hideLoading();
			})
			.catch(() =>{
				this.rawTimeSeriesData = [null, null];
				this.$refs.rawTimeSeriesChart.chart.hideLoading();
			});
			this.$refs.rawTimeSeriesChart.chart.showLoading();
			
		},
		updateChartCurrentDate() {
			if (this.$store.getters.currentStratificationDate == null)
				return;
				
			let tmpDt =  Date.parse(this.$store.getters.currentStratificationDate );

			let dtStart = tmpDt - 86400*4;

			let dtEnd = tmpDt + 86400*4;
			["stratificationTimeSeriesChart", "rawTimeSeriesChart"].forEach( (type) => {
				this.$refs[type].chart.xAxis[0].removePlotBand('pltbnd1');
				this.$refs[type].chart.xAxis[0].addPlotBand({ // mark the weekend
						color: 'rgba(255,145,71,0.9)',
						from:  dtStart,
						to:  dtEnd,
						id: 'pltbnd1'
					});
			});
		},
		updatePolygonTimeseriesChart(polyId) {
			let currentProduct = this.$store.getters.currentProduct;
			let areaDensity = this.$store.getters.areaDensity;
			let date = this.$store.getters.currentStratificationDate;
			if(polyId != null && currentProduct != null &&  areaDensity != null) { 
				requests.fetchStatsByPolygonAndDateRange(polyId, this.$store.getters.dateStart, this.$store.getters.dateEnd, currentProduct.id, areaDensity.col)
				.then((response) =>{
					if (response.data.data != null) {
						response.data.data.forEach((pair)=>{
							pair[0] = (new Date(pair[0])).getTime();
						});
						this.timeSeriesStratificationData = response.data.data;
						this.updateChartCurrentDate();
					}
				})
				.catch(() =>{
					this.timeSeriesStratificationData = null;
				});
			}
			else
				this.timeSeriesStratificationData = null;
			
			if (polyId != null && currentProduct != null && date != null)
				requests.getPieDataByDateAndPolygon(currentProduct.id, date, polyId).then((response) => {
					let dt = [];
					Object.keys(response.data.data).forEach( key  => {
						console.log(key);
						dt.push({name: key, y: response.data.data[key]});
					});
					this.pieDatePolygonData = dt;
					console.log(response.data.data);
				});
			
		},
		updateHistogramChart(polyId) {
		
			if (polyId == null || this.$store.getters.currentStratificationDate == null) {
				this.stratificationHistogramData = [null, null];
				return
			}
			requests.fetchHistogramByPolygonAndDate(polyId, this.$store.getters.currentStratificationDate, this.$store.getters.currentProduct.id).then((response) =>{
				let barWidth = (response.data.data.high_value-response.data.data.low_value)/response.data.data.histogram.length;
				let xAxisCategories = [];
				let prev = 0;
				let next = barWidth;
				for (let i = 0; i < response.data.data.histogram.length; i++) {
					xAxisCategories.push(prev.toString() +"-" + next.toString());
					prev += barWidth;
					next += barWidth;
				}
				this.stratificationHistogramData = [response.data.data.histogram, xAxisCategories];
				
			}).catch( ()=> {
				this.stratificationHistogramData = [null, null];			
			});
		},
		resetAllCharts() {
			this.rawTimeSeriesData = [null, null];
			this.timeSeriesStratificationData = null;
			this.stratificationHistogramData = [null, null];
		},
		resizeChart() {
			if (this.stratificationTimeSeriesTitle != "Dummy Title")
				this.$refs.stratificationTimeSeriesChart.chart.reflow();
				
			if (this.stratificationHistogramTitle != "Dummy Title")
				this.$refs.histogramChart.chart.reflow();
		
			if (this.rawTimeSeriesTitle != "Dummy Title")
				this.$refs.rawTimeSeriesChart.chart.reflow();
			
			if (this.pieDatePolygonTitle != "Dummy Title")
				this.$refs.pieDatePolygonChart.chart.reflow();
			
		}
	},
	mounted() {}
}
</script>

<style scoped>
.base {
	background-color: rgb(234, 234, 218, 0.7);
	height: 100vh;
}
</style>

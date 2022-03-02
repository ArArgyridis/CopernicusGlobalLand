<template>
<div class="base">
	<div class="row position-relative">
	<div class="col-11 position-absolute">
	<ul class="nav nav-tabs" v-on:click="switchActive(evt)">
		<li v-for="nav in navBarOptions" v-bind:key="nav.id" class="nav-item" v-on:click="switchActive(nav.id)">
			<a v-bind:class="{active: nav.active}" class="nav-link text-muted" href="#">{{nav.content}}</a>
		</li>
	</ul>
	</div>
	<div>
		<div class="text-end raise" ><div class="btn" v-on:click="closePanel"><a>x</a></div></div>
	</div>
	</div>

	<highcharts ref="stratificationTimeSeriesChart" v-show="getActiveDiagram == 0 && stratificationTimeSeriesTitle !== 'Dummy Title'" id="stratificationTimeSeriesChart" :options="stratificationTimeSeries"/>
	<highcharts ref="rawTimeSeriesChart" v-show="getActiveDiagram == 1 && rawTimeSeriesTitle !== 'Dummy Title' " id="rawTimeSeriesChart" :options="rawTimeSeries"/> 
	<highcharts ref="histogramChart" v-show="getActiveDiagram == 2 && stratificationHistogramTitle !== 'Dummy Title'" id="histogramChart" :options="stratificationHistogram"/> <!-- -->

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
			return 0;

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
			return this.$store.getters.currentProduct.description;
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
					content: "Area (ha)",
					active: false,
					condition: this.timeSeriesStratificationData !== null
				},
				{
					id: 1,
					content: "Location Timeseries",
					active: true,
					condition: this.rawTimeSeriesData !== null
				},				
				{
					id: 2,
					content: "Region Histogram",
					active: false,
					condition: this.stratificationHistogramData !== null
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
						text:"Area having the specified density value"
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
					}
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
					}
				},
				legend:{
					enabled: false
				}
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
				nav.active = (nav.id == id && nav.condition);
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
		updatePolygonTimeseriesChart(polyId){
			let currentProduct = this.$store.getters.currentProduct;
			let areaDensity = this.$store.getters.areaDensity;

			if(polyId != null && currentProduct != null &&  areaDensity != null) { 
				requests.fetchStatsByPolygonAndDateRange(polyId, this.$store.getters.dateStart, this.$store.getters.dateEnd, currentProduct.id, areaDensity.col)
				.then((response) =>{
					if (response.data.data != null) {
						response.data.data.forEach((pair)=>{
							pair[0] = (new Date(pair[0])).getTime();
						});
						this.timeSeriesStratificationData = response.data.data;
						this.stratificationTimeSeries.title.text = currentProduct.description;
					}
				})
				.catch(() =>{
					this.timeSeriesStratificationData = null;
				});
			}
			else
				this.timeSeriesStratificationData = null;
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

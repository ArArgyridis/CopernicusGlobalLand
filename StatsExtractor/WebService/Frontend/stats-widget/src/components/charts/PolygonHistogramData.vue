<template>
		<highcharts ref="diagram"  :options="diagramOptions"/>
</template>


<script>
import requests from "../../libs/js/requests.js";
import {Chart} from 'highcharts-vue';
import Highcharts from 'highcharts'
import column from 'highcharts/modules/exporting';
column(Highcharts);

export default {
	name: "PolygonHistogramData",
	props:{},	
	components: {
		highcharts: Chart
	},
	computed: {
		diagramTitle() {
			if (this.$store.getters.product == null || this.$store.getters.currentDate == null)
				return "Dummy Title";
				
			return this.$store.getters.product.description + " (" + this.$store.getters.currentDate.substring(0, 10)+")";
		},
		diagramData:{
			get() {
				return this.$refs.diagram.chart.series[0].data;
			},
			set(dt) {
				this.$refs.diagram.chart.series[0].setData(dt[0], true);
				this.$refs.diagram.chart.axes[0].setCategories(dt[1],true);
				this.$refs.diagram.chart.setTitle({text:this.diagramTitle}, true);
				this.$refs.diagram.chart.reflow();
			}
		},	
	},
	data() {
		return {	
			isLoading: true,
			diagramOptions:{
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
		loads() {
			return this.isLoading;
		},
		updateChartData() {
			this.isLoading = true;
			let polyId = this.$store.getters.selectedPolygon;
			if (polyId == null || this.$store.getters.currentDate == null) {
				this.diagramData = [null, null];
				return
			}
			requests.fetchHistogramByPolygonAndDate(polyId, this.$store.getters.currentDate, this.$store.getters.product.id).then((response) =>{
				
				let xAxisCategories = [];
				for (let i = 0; i < response.data.data.histogram.y.length; i++) {
					xAxisCategories.push(response.data.data.histogram.x[i].toString() +"-" + response.data.data.histogram.x[i+1].toString());
				}
				this.diagramData = [response.data.data.histogram.y, xAxisCategories];
				this.isLoading = false;
			}).catch( ()=> {
				this.diagramData = [null, null];			
			});
		},
		reset() {
			this.diagramData = [null, null];
		},
		resizeChart() {
			if (this.diagramTitle != "Dummy Title")
				this.$refs.diagram.chart.reflow();
		}	
	}
}
</script>


<style>
</style>

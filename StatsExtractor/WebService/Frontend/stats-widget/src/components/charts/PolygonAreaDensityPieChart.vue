<template>
	<highcharts ref="diagram" :options="diagramOptions"/>
</template>

<script>
import requests from "../../libs/js/requests.js";
import {Chart} from 'highcharts-vue';
import Highcharts from 'highcharts'
import column from 'highcharts/modules/exporting';
column(Highcharts);

export default {
	name: "PolygonAreaDensityPieChart",
	props:{},
	components: {
		highcharts: Chart
	},
	computed: {
		diagramOptions() {
			this.updateChartData();
			return this.__computeChartOptions();
		},
		diagramTitle() {
			if (this.$store.getters.product == null || this.$store.getters.currentDate == null) 
				return "Dummy Title";
			
			let tmpDate = new Date(Date.parse(this.$store.getters.currentDate));
			return "Density Distribution for " + tmpDate.toDateString();
		},
		noData() {
			return null;
		}
	},
	data() {
		return {
			isLoading: true,
			diagramData: this.noData,
			product: {id: null},
			date: null,
			polygonId: null
		}	
	},
	methods: {
		loads() {
			return this.isLoading;
		},
		updateChartData() {
			if (this.$store.getters.product == null || this.$store.getters.currentDate == null || this.$store.getters.selectedPolygon == null)
				return;
			
			if(this.$store.getters.product.id == this.product.id && this.date == this.$store.getters.currentDate && this.$store.getters.selectedPolygon == this.polygonId)
				return;
	
			this.isLoading 	= true;
			this.product 	= this.$store.getters.product;
			this.date 		= this.$store.getters.currentDate;
			this.polygonId 	= this.$store.getters.selectedPolygon

			requests.getPieDataByDateAndPolygon(this.product.id, this.date, this.polygonId).then((response) => {
				let dt = [];
				Object.keys(response.data.data).forEach( key  => {
					dt.push({name: key, y: response.data.data[key]});
				});
				this.diagramData = dt;
				this.isLoading = false;
			}).catch(() =>{
				this.diagramData = null;
				console.log("Unable to fetch Pie chart (by polygon and date) data");
			});
		},
		reset() {
			this.diagramData = null;
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
				chart: {
					plotBackgroundColor: null,
					plotBorderWidth: null,
					plotShadow: false,
					type: 'pie'
				},
				title: {
					text: this.diagramTitle
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
						data: this.diagramData
					}]
			}
		}
	}
}
</script>

<style scoped>
</style>

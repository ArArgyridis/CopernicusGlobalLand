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
		diagramTitle() {
			if (this.$store.getters.currentProduct == null || this.$store.getters.currentStratificationDate == null) 
				return "Dummy Title";
				
			return "Density Distribution for " + this.$store.getters.currentStratificationDate;
		}, 
		diagramData: {
			get() {
				return this.$refs.diagram.chart.series[0].data;
			},
			set(dt) {
				this.$refs.diagram.chart.series[0].setData(dt, true);
			}
		},
		polyId() {
			return this.$store.getters.selectedPolygon;
		}
	},
	data() {
		return {
			isLoading: true,
			diagramOptions: {
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
						data: []
					}]
			}		
		}	
	},
	methods: {
		loads() {
			return this.isLoading;
		},
		updateChartData() {
			this.isLoading = true;
			let currentProduct = this.$store.getters.currentProduct;
			let date = this.$store.getters.currentStratificationDate;

			if (this.polyId != null && currentProduct != null && date != null) {
				requests.getPieDataByDateAndPolygon(currentProduct.id, date, this.polyId).then((response) => {
					let dt = [];
					Object.keys(response.data.data).forEach( key  => {
						dt.push({name: key, y: response.data.data[key]});
					});
					this.diagramData = dt;
					this.$refs.diagram.chart.setTitle({text:this.diagramTitle}, true);
					this.isLoading = false;
				}).catch(() =>{
					this.diagramData = null;
					console.log("Unable to fetch Pie chart (by polygon and date) data");
				});
			}		
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

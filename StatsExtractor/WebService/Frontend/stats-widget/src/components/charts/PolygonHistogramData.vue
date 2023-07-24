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
		diagramData: {
			get() {
				if (this.dgDt == null)
					return this.noData;
				return this.dgDt;
			},
			set(dt) {
				this.dgDt = dt;
			}
		},
		diagramOptions(){
			//this.updateChartData();
			return this.__computeChartOptions();
		},
		diagramTitle() {
			if (this.$store.getters.product == null || this.$store.getters.currentDate == null)
				return "Dummy Title";
			
			let tmpDate = new Date(Date.parse(this.$store.getters.currentDate));
			return "Region Histogram for raw Product (" + tmpDate.toDateString() + ")";
		},
		noData() {
			return [null, null];
		}
	},
	data() {
		return {	
			isLoading: true,
			dgDt: this.noData,
			polygonId: null,
			product:{id: null},
			date: null
		}
	},
	methods: {
		loads() {
			return this.isLoading;
		},
		updateChartData() {
			
			if (this.$store.getters.product == null || this.$store.getters.currentDate == null || this.$store.getters.selectedPolygon ==null)
				return;
			
			if (this.product.id == this.$store.getters.product.id && this.polygonId == this.$store.getters.selectedPolygon && this.date == this.$store.getters.currentDate)
				return;

			this.isLoading = true;
			this.product = this.$store.getters.product.currentVariable;
			this.date = this.$store.getters.currentDate;
			this.polygonId = this.$store.getters.selectedPolygon;
			requests.fetchHistogramByPolygonAndDate(this.polygonId, this.date, this.product.id).then((response) =>{
				this.resizeChart();
				let xAxisCategories = [];
				for (let i = 0; i < response.data.data.histogram.y.length; i++) {
					xAxisCategories.push(response.data.data.histogram.x[i].toString() +"-" + response.data.data.histogram.x[i+1].toString());
				}
				this.diagramData = [response.data.data.histogram.y, xAxisCategories];
				this.isLoading = false;
			}).catch( ()=> {
				this.diagramData = this.noData;
			});
		},
		reset() {
			this.diagramData = this.noData;
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
				title:{
					text: this.diagramTitle,
					style: {
						fontSize: '15px' 
					}
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
					data: this.diagramData[0]
				}],
				yAxis:{
					title:{
						enabled:true,
						text:"Number of Pixels"
					}
				},
				xAxis:{
					categories: this.diagramData[1],
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
	}
}
</script>


<style scoped>
</style>

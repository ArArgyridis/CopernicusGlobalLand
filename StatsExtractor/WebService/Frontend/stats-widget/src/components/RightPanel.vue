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
	<div>
		<div class="text-end raise" ><div class="btn" v-on:click="closePanel"><a>x</a></div></div>
	</div>
	<div class="row position-relative d-flex flex-center">
		<div class="nav nav-tabs" v-on:click="switchActive(evt)">
			<button v-for="nav in navBarOptions" v-bind:key="nav.id" class=" col center nav-link text-muted text-center" v-bind:class="{active: nav.id == curActiveDiagramId}" v-on:click="switchActive(nav.id)" v-bind:id="'chart_'+nav.id">
				{{nav.content}}
			</button>
		</div>
	</div>
	<PointTimeSeries v-show="curActiveDiagramId == 0 && navBarOptions[0].condition() " ref="PointTimeSeries" />
	<PolygonAreaDensityPieChart  v-show="curActiveDiagramId == 1 && navBarOptions[1].condition()" ref="PolygonAreaDensityPieChart"/>
	<PolygonHistogramData v-show="curActiveDiagramId == 2 && navBarOptions[2].condition()" ref="PolygonHistogramData"/>
	<PolygonTimeSeries v-show="curActiveDiagramId == 3 && navBarOptions[3].condition()" ref="PolygonTimeSeries"/>

	<button class="btn btn-secondary mt-3" v-on:click="this.$emit('showDashboard')"> Show Region Dashboard</button>

</div>
</template>

<script>
import PointTimeSeries from "./charts/PointTimeSeries.vue";
import PolygonAreaDensityPieChart from "./charts/PolygonAreaDensityPieChart.vue";
import PolygonHistogramData from "./charts/PolygonHistogramData.vue";
import PolygonTimeSeries from "./charts/PolygonTimeSeries.vue";

export default {
	name:"RightPanel",
	components:{
		PointTimeSeries,
		PolygonTimeSeries,
		PolygonAreaDensityPieChart,
		PolygonHistogramData
	},
	props:{},
	computed: {},
	data() {
		return {
			refs: ["PointTimeSeries",  "PolygonAreaDensityPieChart", "PolygonTimeSeries", "PolygonHistogramData"],
			curActiveDiagramId: 0,
			navBarOptions: [
				{
					id: 0,
					content: "Point Timeseries",
					condition: () => { return this.$store.getters.product !== null && this.$store.getters.dateStart != null && this.$store.getters.dateEnd != null;}
				},
				{
					id: 1,
					content: "Density Distribution",
					condition: () => {return this.$store.getters.product !== null && this.$store.getters.currentDate != null }
				},
				{
					id: 2,
					content: "Polygon Histogram Values",
					condition: () => {return this.$store.getters.product !== null && this.$store.getters.currentDate != null;}
				},
				{	
					id: 3,
					content: "Density-Driven Polygon Timeseries",
					condition: () => {return this.$store.getters.product !== null && this.$store.getters.dateStart != null && this.$store.getters.dateEnd != null && this.$store.getters.areaDensity != null;}
				},

			],

		}
	},
	methods: {
		loadLocationCharts(evt) {
			this.$refs.PointTimeSeries.updateChartData(evt);
		},
		loadStratificationCharts() {
			let polyId = this.$store.getters.selectedPolygon;
			if (polyId == null)
				return;
				
			this.$refs.PolygonTimeSeries.updateChartData(polyId);
			this.$refs.PolygonAreaDensityPieChart.updateChartData();
			this.$refs.PolygonHistogramData.updateChartData(polyId);
		},
		switchActive(id) {
			if (id == null)
				return;
				
			let newActive = null;
			for(let i = 0; i < this.navBarOptions.length; i++) {
				if (this.navBarOptions[i].id == id && this.navBarOptions[i].condition() )
					newActive = i;
			}
			if (newActive != null) 
				this.curActiveDiagramId = newActive;	
		},
		closePanel(){
			this.resetAllCharts();
			this.$emit("closeTimechartsPanel");
		},
		resetAllCharts() {
			this.refs.forEach( (ref) => {
				this.$refs[ref].reset();
			});
		},
		resizeChart() {
			this.refs.forEach( (ref) => {
				this.$refs[ref].resizeChart();
			});
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

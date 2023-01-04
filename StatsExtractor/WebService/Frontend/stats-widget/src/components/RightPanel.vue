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

	<div class="container-fluid">
		<div class="row">
			<div class="col text-end raise"><div class="btn" v-on:click="closePanel"><a>x</a></div></div>
		</div>
		<nav class="navbar navbar-dark bg-secondary" >
			<div class="container-fluid">
				<a class="navbar-brand" href="#">Active Diagram: {{ navBarOptions[curActiveDiagramId].content }}</a>
				
				<button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
					<span class="navbar-toggler-icon"></span>
				</button>
				
				<div class="collapse navbar-collapse" id="navbarNav">
					<ul class="navbar-nav">
						<li class="nav-item"  v-bind:class="{active: nav.id == curActiveDiagramId}"   v-for="nav in navBarOptions"  v-bind:key="nav.id">
							<a class="nav-link" aria-current="page" href="#" v-on:click="switchActive(nav.id)">{{nav.content}}</a>
						</li>
					</ul>
				</div>
			</div>
		</nav>
	</div>
	<div class="row mt-3">
		<div class="col">
			<PointTimeSeries v-show="curActiveDiagramId == 0 && navBarOptions[0].condition() " v-bind:ref="refs[0]" mode="Raw"/>
			<PointTimeSeries v-show="curActiveDiagramId == 1 && navBarOptions[1].condition() " v-bind:ref="refs[1]" mode="Anomalies"/>
			<PolygonTimeSeries v-show="curActiveDiagramId == 2 && navBarOptions[2].condition() " v-bind:ref="refs[2]" mode="Raw"/>
			<PolygonTimeSeries v-show="curActiveDiagramId == 3 && navBarOptions[3].condition() " v-bind:ref="refs[3]" mode="Anomalies"/>
			<PolygonAreaDensityPieChart  v-show="curActiveDiagramId == 4 && navBarOptions[4].condition()" v-bind:ref="refs[4]"/>
			<PolygonHistogramData v-show="curActiveDiagramId == 5 && navBarOptions[5].condition()" v-bind:ref="refs[5]"/>
			<PolygonDensityTimeSeries v-show="curActiveDiagramId == 6 && navBarOptions[6].condition()" v-bind:ref="refs[6]"/>
		</div>
	</div>
	<button class="btn btn-secondary mt-3 mx-3" v-on:click="this.$emit('showDashboard')" > Show Region Dashboard</button>
	<button class="btn btn-secondary mt-3 mx-3" v-on:click="this.$emit('exportCurrentView')"> Export Curent View As Image</button>
</div>
</template>

<script>

import PointTimeSeries from "./charts/PointTimeSeries.vue";
import PolygonAreaDensityPieChart from "./charts/PolygonAreaDensityPieChart.vue";
import PolygonHistogramData from "./charts/PolygonHistogramData.vue";
import PolygonDensityTimeSeries from "./charts/PolygonDensityTimeSeries.vue";
import PolygonTimeSeries from "./charts/PolygonTimeSeries.vue";


export default {
	name:"RightPanel",
	components:{
		PointTimeSeries,
		PolygonDensityTimeSeries,
		PolygonTimeSeries,
		PolygonAreaDensityPieChart,
		PolygonHistogramData
	},
	props:{},
	computed: {},
	data() {
		return {
			refs: ["PointTimeSeriesRaw", "PointTimeSeriesAnomalies", "StratificationTimeSeriesRaw",  "StratificationTimeSeriesAnomalies", "PolygonAreaDensityPieChart", "PolygonTimeSeries", "PolygonHistogramData"],
			curActiveDiagramId: 0,
			navBarOptions: [
				{
					id: 0,
					content: "Raw Timeseries on selected Point",
					condition: () => { return this.$store.getters.product !== null && this.$store.getters.dateStart != null && this.$store.getters.dateEnd != null;}
				},
				{
					id: 1,
					content: "Anomalies Timeseries on selected Point",
					condition: () => { return this.$store.getters.product !== null && this.$store.getters.dateStart != null && this.$store.getters.dateEnd != null;}
				},
				{
					id: 2,
					content: "Polygon Raw Timeseries",
					condition: () => { return this.$store.getters.product !== null && this.$store.getters.dateStart != null && this.$store.getters.dateEnd != null;}
				},
				{
					id: 3,
					content: "Polygon Anomalies Timeseries",
					condition: () => { return this.$store.getters.product !== null && this.$store.getters.dateStart != null && this.$store.getters.dateEnd != null;}
				},
				{
					id: 4,
					content: "Product Density Distribution for Polygon",
					condition: () => {return this.$store.getters.product !== null && this.$store.getters.currentDate != null;}
				},
				{
					id: 5,
					content: "Histogram Values for Polygon/Date",
					condition: () => {return this.$store.getters.product !== null && this.$store.getters.currentDate != null;}
				},
				{	
					id: 6,
					content: " Current Product Density Timeseries for Polygon",
					condition: () => {return this.$store.getters.product !== null && this.$store.getters.dateStart != null && this.$store.getters.dateEnd != null && this.$store.getters.areaDensity != null ;}
				}
			],

		}
	},
	methods: {
		switchActive(id) {
			if (id == null)
				return;
				
			let newActive = null;
			for(let i = 0; i < this.navBarOptions.length; i++) {
				if (this.navBarOptions[i].id == id )
					newActive = i;
			}
			if (newActive != null) 
				this.curActiveDiagramId = newActive;	
		},
		closePanel() {
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

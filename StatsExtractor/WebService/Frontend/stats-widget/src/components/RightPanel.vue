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
				<a class="navbar-brand" href="#">{{ diagramTitle(navBarOptions[curActiveDiagramId].ref) }}</a>
				<button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
					<span class="navbar-toggler-icon"></span>
				</button>
				
				<div class="collapse navbar-collapse" id="navbarNav">
					<ul class="navbar-nav">
						<li class="nav-item"  v-bind:class="{active: key == curActiveDiagramId}"   v-for="(nav, key) in navBarOptions"  v-bind:key="key" v-bind:id="'navbar_'+navBarOptions[key].ref">
							<a class="nav-link" aria-current="page" href="#" v-on:click="switchActive(key)" v-bind:class="nav.class">{{diagramTitle(nav.ref)}}</a>
						</li>
					</ul>
				</div>
			</div>
		</nav>
	</div>
	<div class="row mt-3">
		<div class="col">
			<PointTimeSeries v-show="curActiveDiagramId == 0 && navBarOptions[0].condition() " v-bind:ref="navBarOptions[0].ref" mode="Raw"/>
			<PointTimeSeries v-show="curActiveDiagramId == 1 && navBarOptions[1].condition() " v-bind:ref="navBarOptions[1].ref" mode="Anomalies"/>
			<PolygonTimeSeries v-show="curActiveDiagramId == 2 && navBarOptions[2].condition() " v-bind:ref="navBarOptions[2].ref" mode="Raw"/>
			<PolygonTimeSeries v-show="curActiveDiagramId == 3 && navBarOptions[3].condition() " v-bind:ref="navBarOptions[3].ref" mode="Anomalies"/>
			<PolygonAreaDensityPieChart  v-show="curActiveDiagramId == 4 && navBarOptions[4].condition()" v-bind:ref="navBarOptions[4].ref"/>
			<PolygonHistogramData v-show="curActiveDiagramId == 5 && navBarOptions[5].condition()" v-bind:ref="navBarOptions[5].ref"/>
			<PolygonDensityTimeSeries v-show="curActiveDiagramId == 6 && navBarOptions[6].condition()" v-bind:ref="navBarOptions[6].ref"/>
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
	computed: {
	curActiveDiagramId: {
		set(k) {
			this.curDiagId = k;
		},
		get() {
			return this.curDiagId;
		}
	}
	},
	data() {
		return {
			curDiagId: 0,
			panelOpen: false,
			navBarOptions: [
				{
					ref: "PointTimeSeriesRaw",
					condition: () => { return this.$store.getters.product !== null && this.$store.getters.dateStart != null && this.$store.getters.dateEnd != null;},
					class: "text-dark"
				},
				{
					ref: "PointTimeSeriesAnomalies",
					condition: () => { return this.$store.getters.product !== null && this.$store.getters.dateStart != null && this.$store.getters.dateEnd != null;},
					class: "text-dark"
				},
				{
					ref: "StratificationTimeSeriesRaw",
					condition: () => { return this.$store.getters.product !== null && this.$store.getters.dateStart != null && this.$store.getters.dateEnd != null;},
					class: "text-white"
				},
				{
					ref: "StratificationTimeSeriesAnomalies",
					condition: () => { return this.$store.getters.product !== null && this.$store.getters.dateStart != null && this.$store.getters.dateEnd != null;},
					class: "text-white"
				},
				{
					ref: "PolygonAreaDensityPieChart",
					condition: () => {return this.$store.getters.product !== null && this.$store.getters.currentDate != null;},
					class: "text-white"
				},
				{
					ref: "PolygonTimeSeries",
					condition: () => {return this.$store.getters.product !== null && this.$store.getters.currentDate != null;},
					class: "text-white"
				},
				{	
					ref: "PolygonHistogramData",
					condition: () => {return this.$store.getters.product !== null && this.$store.getters.dateStart != null && this.$store.getters.dateEnd != null && this.$store.getters.areaDensity != null ;},
					class: "text-white"
				}
			],

		}
	},
	methods: {
		diagramTitle(ref) {
			if(this.$refs[ref] == null)
				return "No Diagram";
			return this.$refs[ref].diagramTitle;
		},	
		switchActive(id) {
			if (id == null)
				return;
			document.getElementById("navbar_"+this.navBarOptions[id].ref).classList.add("selected");
			this.curActiveDiagramId = id;
			this.updateCurrentChart();
		},
		closePanel() {
			this.resetAllCharts();
			this.$emit("closeTimechartsPanel");
			this.panelOpen = false;
		},
		resetAllCharts() {
			this.navBarOptions.forEach( (diag) => {
				this.$refs[diag.ref].reset();
			});
		},
		resizeChart() {
			this.navBarOptions.forEach( (diag) => {
				this.$refs[diag.ref].resizeChart();
			});
		},
		updateCurrentChart() {
			if (!this.panelOpen) {
				this.panelOpen = true;
				if(this.$store.getters.stratifiedOrRaw == 0) {
					if ( this.$store.getters.productStatisticsViewMode == 0)
						this.curActiveDiagramId = 2;
					else if (this.$store.getters.productStatisticsViewMode == 1)
						this.curActiveDiagramId = 3;
				}
				else if(this.$store.getters.stratifiedOrRaw == 1) {
					if ( this.$store.getters.productStatisticsViewMode == 0)
						this.curActiveDiagramId = 0;
					else if (this.$store.getters.productStatisticsViewMode == 1)
						this.curActiveDiagramId = 1;
				}
			}
			this.$refs[this.navBarOptions[this.curActiveDiagramId].ref].updateChartData();
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

.text-dark:hover {
	background-color: #bdc1c6;
}

.regionDiagramTitle {
	color:#404040;
}

.text-white:hover {
    background-color: #bdc1c6;
}
</style>

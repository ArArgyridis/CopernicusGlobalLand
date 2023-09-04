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
	<!--
	<div class="container-fluid">
		<div class="row">
			<div class="col text-end raise"><div class="btn" v-on:click="closePanel"><a>x</a></div></div>
		</div>
	</div>
	-->
	<div class="accordion" id="locationCharts" v-if="variable != null">
		
		<!-- location time series raw -->
		<div class="accordion-item" v-bind:id="'id'+navBarOptions[0].ref">
			<h2 class="accordion-header" v-bind:id="'header'+navBarOptions[0].ref">
				<button v-bind:id="'btn'+navBarOptions[0].ref" class="accordion-button collapsed" type="button" data-bs-toggle="collapse" v-bind:data-bs-target="'#collapse'+navBarOptions[0].ref" aria-expanded="false" aria-controls="locationTimeSeries" v-on:click="switchActive(0)">{{ navBarOptions[0].title }}</button>
			</h2>
			<div v-bind:id="'collapse'+navBarOptions[0].ref" class="accordion-collapse collapse" v-bind:aria-labelledby="'header'+navBarOptions[0].ref" data-bs-parent="#locationCharts">
				<div class="accordion-body">
					<PointTimeSeries v-bind:ref="navBarOptions[0].ref" mode="Raw" />
				</div>
			</div>
		</div>
		
		<!-- location time series anomalies -->

		<div class="accordion-item" v-bind:id="'id'+navBarOptions[1].ref" >
			<h2 class="accordion-header" v-bind:id="'header'+navBarOptions[1].ref">
				<button v-bind:id="'btn'+navBarOptions[1].ref" class="accordion-button collapsed" type="button" data-bs-toggle="collapse" v-bind:data-bs-target="'#collapse'+navBarOptions[1].ref" aria-expanded="false" aria-controls="locationTimeSeries" v-on:click="switchActive(1)">{{ navBarOptions[1].title }}</button>
			</h2>
			<div v-bind:id="'collapse'+navBarOptions[1].ref" class="accordion-collapse collapse" v-bind:aria-labelledby="'header'+navBarOptions[1].ref" data-bs-parent="#locationCharts">
				<div class="accordion-body">
					<PointTimeSeries v-bind:ref="navBarOptions[1].ref" mode="Anomalies"/>
				</div>
			</div>
		</div>
		<!--polygon time series raw -->
		<div class="accordion-item" v-bind:id="'id'+navBarOptions[2].ref">
			<h2 class="accordion-header" v-bind:id="'header'+navBarOptions[2].ref">
				<button v-bind:id="'btn'+navBarOptions[2].ref" class="accordion-button collapsed" type="button" data-bs-toggle="collapse" v-bind:data-bs-target="'#collapse'+navBarOptions[2].ref" aria-expanded="false" aria-controls="locationTimeSeries" v-on:click="switchActive(2)">{{ navBarOptions[2].title }}</button>
			</h2>
			<div v-bind:id="'collapse'+navBarOptions[2].ref" class="accordion-collapse collapse" v-bind:aria-labelledby="'header'+navBarOptions[2].ref" data-bs-parent="#locationCharts">
				<div class="accordion-body">
					<PolygonTimeSeries v-bind:ref="navBarOptions[2].ref" mode="Raw"/>
				</div>
			</div>
		</div>
		<!--polygon time series anomalies -->
		<div class="accordion-item" v-bind:id="'id'+navBarOptions[3].ref">
			<h2 class="accordion-header" v-bind:id="'header'+navBarOptions[3].ref">
				<button v-bind:id="'btn'+navBarOptions[3].ref" class="accordion-button collapsed disabled" type="button" data-bs-toggle="collapse" v-bind:data-bs-target="'#collapse'+navBarOptions[3].ref" aria-expanded="false" aria-controls="locationTimeSeries" v-on:click="switchActive(3)">{{ navBarOptions[3].title }}</button>
			</h2>
			<div v-bind:id="'collapse'+navBarOptions[3].ref" class="accordion-collapse collapse" v-bind:aria-labelledby="'header'+navBarOptions[3].ref" data-bs-parent="#locationCharts">
				<div class="accordion-body">
					<PolygonTimeSeries v-bind:ref="navBarOptions[3].ref" mode="Anomalies"/>
				</div>
			</div>
		</div>
		
		<!--Polygon density in range -->
		<div class="accordion-item" v-bind:id="'id'+navBarOptions[4].ref">
			<h2 class="accordion-header" v-bind:id="'header'+navBarOptions[4].ref">
				<button v-bind:id="'btn'+navBarOptions[4].ref" class="accordion-button collapsed" type="button" data-bs-toggle="collapse" v-bind:data-bs-target="'#collapse'+navBarOptions[4].ref" aria-expanded="false" aria-controls="locationTimeSeries" v-on:click="switchActive(4)">{{ navBarOptions[4].title }}</button>
			</h2>
			<div v-bind:id="'collapse'+navBarOptions[4].ref" class="accordion-collapse collapse" v-bind:aria-labelledby="'header'+navBarOptions[4].ref" data-bs-parent="#locationCharts">
				<div class="accordion-body">
					<PolygonAreaDensityPieChart  v-bind:ref="navBarOptions[4].ref"/>
				</div>
			</div>
		</div>
		<!--polygon Histogram Data -->
		<div class="accordion-item" v-bind:id="'id'+navBarOptions[5].ref">
			<h2 class="accordion-header" v-bind:id="'header'+navBarOptions[5].ref">
				<button v-bind:id="'btn'+navBarOptions[5].ref" class="accordion-button collapsed" type="button" data-bs-toggle="collapse" v-bind:data-bs-target="'#collapse'+navBarOptions[5].ref" aria-expanded="false" aria-controls="locationTimeSeries" v-on:click="switchActive(5)">{{ navBarOptions[5].title }}</button>
			</h2>
			<div v-bind:id="'collapse'+navBarOptions[5].ref" class="accordion-collapse collapse" v-bind:aria-labelledby="'header'+navBarOptions[5].ref" data-bs-parent="#locationCharts">
				<div class="accordion-body">
					<PolygonHistogramData v-bind:ref="navBarOptions[5].ref"/>
				</div>
			</div>
		</div>
		<!--polygon density time series for range-->
		<div class="accordion-item" v-bind:id="'id'+navBarOptions[6].ref">
			<h2 class="accordion-header" v-bind:id="'header'+navBarOptions[6].ref">
				<button v-bind:id="'btn'+navBarOptions[6].ref" class="accordion-button collapsed" type="button" data-bs-toggle="collapse" v-bind:data-bs-target="'#collapse'+navBarOptions[6].ref" aria-expanded="false" aria-controls="locationTimeSeries" v-on:click="switchActive(6)">{{ navBarOptions[6].title }}</button>
			</h2>
			<div v-bind:id="'collapse'+navBarOptions[6].ref" class="accordion-collapse collapse" v-bind:aria-labelledby="'header'+navBarOptions[6].ref" data-bs-parent="#locationCharts">
				<div class="accordion-body">
					<PolygonDensityTimeSeries v-bind:ref="navBarOptions[6].ref"/>
				</div>
			</div>
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
				this.prevDiagId = this.curDiagId;
				this.curDiagId = k;
			},
			get() {
				return this.curDiagId;
			}
		},
		panelOpen:{
			get(){
				return this.$store.getters.rightPanelVisibility;
			},
			set(dt) {
				this.$store.commit("rightPanelVisibility", dt);
			}
		},
		variable() {
			return this.$store.getters.variable;
		}
	},
	data() {
		return {
			curDiagId: null,
			firstOpen: true,
			prevDiagId: null,
			navBarOptions: [
				{
					ref: "PointTimeSeriesRaw",
					condition: () => { return this.$store.getters.product !== null && this.$store.getters.dateStart != null && this.$store.getters.dateEnd != null;},
					title: "Dummy Diagram"
				},
				{
					ref: "PointTimeSeriesAnomalies",
					condition: () => { return this.$store.getters.product !== null && this.$store.getters.dateStart != null && this.$store.getters.dateEnd != null;},
					title: "Dummy Diagram"
				},
				{
					ref: "StratificationTimeSeriesRaw",
					condition: () => { return this.$store.getters.product !== null && this.$store.getters.dateStart != null && this.$store.getters.dateEnd != null;},
					title: "Dummy Diagram"
				},
				{
					ref: "StratificationTimeSeriesAnomalies",
					condition: () => { return this.$store.getters.product !== null && this.$store.getters.dateStart != null && this.$store.getters.dateEnd != null;},
					title: "Dummy Diagram"
				},
				{
					ref: "PolygonAreaDensityPieChart",
					condition: () => {return this.$store.getters.product !== null && this.$store.getters.currentDate != null;},
					title: "Dummy Diagram"
				},
				{
					ref: "PolygonTimeSeries",
					condition: () => {return this.$store.getters.product !== null && this.$store.getters.currentDate != null;},
					title: "Dummy Diagram"
				},
				{	
					ref: "PolygonHistogramData",
					condition: () => {return this.$store.getters.product !== null && this.$store.getters.dateStart != null && this.$store.getters.dateEnd != null && this.$store.getters.areaDensity != null ;},
					title: "Dummy Diagram"
				}
			],

		}
	},
	methods: {
		switchActive(id) {
			if (typeof id === 'undefined'|| id == null)
				return;
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
				if (this.$refs[diag.ref] == null)
					return;
				this.$refs[diag.ref].reset();
			});
			this.firstOpen = true;
		},
		resizeChart() {
			this.navBarOptions.forEach( (diag) => {
				if (this.$refs[diag.ref] == null)
					return;
				this.$refs[diag.ref].resizeChart();
			});
		},
		updateCurrentChart() {
			//checking if a polygon or point is selected
			if (this.$store.getters.selectedPolygon == null && this.$store.getters.clickedCoordinates == null)
				return;
			
			if (!this.panelOpen) 
				this.panelOpen = true;
			
			if (this.firstOpen) {
				this.firstOpen = false;
			
				if (this.curActiveDiagramId == null) {
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

					let newBtn = document.getElementById('btn'+this.navBarOptions[this.curActiveDiagramId].ref);
					let newCollapsible = document.getElementById("collapse"+this.navBarOptions[this.curActiveDiagramId].ref);
			
					newBtn.classList.remove("collapsed");
					newBtn.setAttribute("aria-expanded", true);
				
					newCollapsible.classList.add("show");
					newCollapsible.setAttribute("aria-expanded", true);
				}
			}
			this.$refs[this.navBarOptions[this.curActiveDiagramId].ref].updateChartData();
		}
	},
	mounted() {
		this.tmpArray= {};
		this.navBarOptions.forEach( nav => {
			this.tmpArray[nav.ref] = setInterval( () =>{
				if (this.$refs[nav.ref] !== undefined && this.$store.getters.product !== null) {
					nav.title = this.$refs[nav.ref].diagramTitle;
					//clearInterval(this.tmpArray[nav.ref]);
				}
			}, 1000);
		} );
		
		
	
	
	}
}
</script>

<style scoped>
.base {
	background-color: rgb(234, 234, 218, 0.7);
	height: 100vh;
}
</style>

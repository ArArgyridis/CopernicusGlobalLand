<template>
	<div>
	<!-- template for the modal component -->
	<div class="modal-mask">
		<div class="modal-wrapper">
			<div class="modal-container">
				<div class="modal-header" >
					<div class="container">
						<div class="row">
							<div class="col"><h4>Select Products to Download</h4></div>
						</div>
					</div>
				</div>
				<div class="modal-body">
					<div class="container mt-2">
						<div class="row">
							<div class="col-lg border border-secondary">
								<OLMap id="aoiMap" v-bind:center="[0,0]" v-bind:zoom=1 v-bind:bingKey=bingKey epsg="EPSG:3857" ref="aoiMap" class="aoiMap" />
								<button class = "btn btn-secondary" v-on:click = "drawAOI"> Set AOI </button>
							</div>
						</div>
						<div class="row">
							<div class="col border border-secondary">
								<div class="accordion-body">
									<select class="form-select" size="4" aria-label="size 3 select example">
										<option v-for ="(cat, key) in categories" v-bind:key="key" v-bind:value="key" v-on:click="__updateSelection({type:'category', value:cat})" v-bind:selected="cat.id == selectedCategory.id">{{cat.title}}</option>
									</select>
								</div>
							</div>
							<div class="col border border-secondary">
								<div class="accordion-body">
									<select class="form-select" size="4" aria-label="size 3 select example" v-if="selectedCategory.products!=null">
										<option v-for ="(prd, key) in selectedCategory.products.info" v-bind:key="key" v-bind:value="key" v-on:click="__updateSelection({type:'product', value:prd})" v-bind:selected="prd.id == selectedProduct.id">{{prd.description}}</option>
									</select>
								</div>
							</div>
							<div class="col border border-secondary">
								<div class="accordion-body">
									<select class="form-select" size="4" aria-label="size 3 select example"  v-if="selectedCategory.products!=null">
										<option v-for ="(vrbl, key) in selectedProduct.variables" v-bind:key="key" v-bind:value="key" v-on:click="__updateSelection({type:'variable', value:vrbl})" v-bind:selected="vrbl.id == selectedVariable.id">{{vrbl.description}}</option>
									</select>
								</div>
							</div>
							<div class="col border border-secondary">
								<div class="accordion-body">
									<select class="form-select" size="4" aria-label="size 3 select example"  v-if="selectedCategory.products!=null">
										<option v-for ="(rt, key) in consolidationPeriods" v-bind:key="key" v-bind:value="key" v-on:click="__updateSelection({type:'rt', value:rt})" v-bind:selected="rt.id == selectedRT.id">{{rt.description}}</option>
									</select>
								</div>
							</div>
						</div>
					</div>
				</div>
				<div class="modal-footer">
					<button class="btn btn-secondary modal-default-button" v-on:click="showDownloadPanel = false">OK</button>
					<button class="btn btn-primary modal-default-button"> Submit</button>
				</div>
			</div>
		</div>
	</div>
</div>
</template>

<script>
import html2canvas from 'html2canvas';

import requests from "../libs/js/requests.js";
import OLMap from "./libs/OLMap.vue";
import DateTime from "./libs/DateTime.vue";
import options from "../libs/js/options.js";
import utils from "../libs/js/utils.js";
import {Fill, Circle, Stroke, Style, Text} from 'ol/style';
import {consolidationPeriods} from "../libs/js/constructors.js";


export default {
	name: "DownloadPanel",
	components: {
		DateTime,
		OLMap
	},
	computed: {
		activeCategory() {
			return this.$store.getters.activeCategory;
		},
		bingKey() {
			return options.bingKey;
		},
		categories() {
			return this.$store.getters.categories;
		},
		consolidationPeriods() {
			let tmpPeriods = new consolidationPeriods(this.selectedProduct.rt);
			let retPeriods = new Array();
			tmpPeriods.forEach(period => {
				if (period.id in this.selectedProduct.dates)
					retPeriods.push(period);
			});
			return retPeriods;
		},
		currentDate() {
			let tmpDate = new Date(Date.parse(this.$store.getters.currentDate));
			return tmpDate.toDateString();
		},
		dateStart() {
			let tmpDate = new Date(Date.parse(this.$store.getters.dateStart));
			return tmpDate.toDateString();
		},
		dateEnd() {
			let tmpDate = new Date(Date.parse(this.$store.getters.dateEnd));
			return tmpDate.toDateString();
		},
		product() {
			console.log(this.$store.getters.product);
			return this.$store.getters.product;
		},
		productDescription() {
			if (this.$store.getters.product == null)
				return "Dummy Product";
			return this.$store.getters.product.description;
		},
		showDownloadPanel: {
			get() {
				return this.$store.getters.showDownloadPanel;
			},
			set(dt) {
				this.$store.commit("showDownloadPanel", dt);
			}
		}
	},
	data() {
		return{
			bingId: null,
			aoiOLOptions: null,
			selectedCategory: this.$store.getters.activeCategory,
			selectedProduct: this.$store.getters.product,
			selectedVariable: this.$store.getters.variable,
			selectedRT: this.$store.getters.product.rtFlag,
			drawStyle: new Style({
						stroke: new Stroke({
						color: 'rgba(200, 0, 0, 0.6)',
						width: 3
					}),
					fill: new Fill({
						color: 'rgba(226, 226, 226, 0.3)'
					})
				}),
			showStyle:  new Style({
						stroke: new Stroke({
						color: 'rgba(255, 0, 0, 1.0)',
						width: 3
					}),
					fill: new Fill({
						color: 'rgba(226, 226, 226, 0.6)'
					})
				}),
		}
	},
	methods: {
		drawAOI() {
			this.$refs.aoiMap.clearVectorLayer(this.aoiOLOptions.layer);
			this.aoiOLOptions.draw.setActive(true);
			
			this.aoiOLOptions.draw.on("drawend", () => {
				this.aoiOLOptions.draw.setActive(false);
			});
			
		},
		init() {
			this.bingId = this.$refs.aoiMap.addBingLayerToMap("aerial", true, 0);
			this.$refs.aoiMap.setVisibility(this.bingId, true);
			this.aoiOLOptions = this.$refs.aoiMap.addDrawInteraction({
				type:"Polygon",
				style: this.drawStyle
			});
			this.$refs.aoiMap.setVisibility(this.aoiOLOptions.layer, true);
			this.$refs.aoiMap.updateLayerStyle(this.aoiOLOptions.layer, this.showStyle);
			this.aoiOLOptions.draw.setActive(false);
			console.log(this.selectedCategory.products.info);
		},
		__updateSelection(dt) {
			if(dt.type == "category") {
				this.selectedCategory = dt.value;
				if ( this.selectedCategory.products == null) {
					this.selectedProduct = null;
					this.selectedVariable = null;
					this.selectedRT = null;
					return;
				}
				this.selectedProduct = this.selectedCategory.products.current;
				this.selectedVariable = this.selectedProduct.currentVariable;
				this.selectedRT = this.selectedProduct.rtFlag;
			}
			else if (dt.type == "product") {
				this.selectedProduct = dt.value;
				this.selectedVariable = this.selectedProduct.currentVariable;
				this.selectedRT = this.selectedProduct.rtFlag;
			}
			else if (dt.type == "variable") {
				this.selectedVariable = dt.value;
				this.selectedRT = this.selectedProduct.rtFlag;
			}
			else if(dt.type =="rt") {
				this.selectedRT = dt.value;
			}
		}
	},
	mounted() {
		this.init();
	}
}

</script>

<style scoped>

.modal-mask {
	position: fixed;
	z-index: 9998;
	top: 0;
	left: 0;
	width: 100%;
	height: 100%;
	background-color: rgba(0, 0, 0, 0.5);
	display: table;
}

.modal-wrapper {
	display: table-cell;
	vertical-align: middle;
}

.aoiMap {
	height:470px;
	z-index: 10;
	width:100%;
}

@media(min-width:901px) {
	.modal-container {
		width: 90%;
		height: 850px;
		margin: 0px auto;
		padding: 20px 30px;
		background-color: #fff;
		border-radius: 2px;
		box-shadow: 0 2px 8px rgba(0, 0, 0, 0.33);
		font-family: Helvetica, Arial, sans-serif;
	}
}

@media(max-width:900px) {
	.modal-container {
		width: 100%;
		margin: 0px auto;
		padding: 20px 30px;
		background-color: #fff;
		border-radius: 2px;
		box-shadow: 0 2px 8px rgba(0, 0, 0, 0.33);
		font-family: Helvetica, Arial, sans-serif;
	}
}

.modal-header h2 {
	text-align:center;
	width:100%;
}

.modal-header h3 {
	text-align:center;
	width:100%;
}

.modal-body {
	margin: 1px 0;
}

.modal-default-button {
	display: block;
	margin-top: 1rem;
}

.modal-enter-active,
.modal-leave-active {
	transition: opacity 0.5s ease;
}

.modal-enter-from,
.modal-leave-to {
	opacity: 0;
}

</style>




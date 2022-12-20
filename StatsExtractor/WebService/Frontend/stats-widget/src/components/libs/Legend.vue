
 <template>
 <div class="container">
	<div class="row">
		<div class="col-1 empty"></div>
		<div class="col d-inline-flex justify-content-center"><span>{{settings.title}}</span></div>
		<div class="col-1 empty"></div>
	</div>
	<div class="row">
		<div class="col-1 empty"></div>
		<div class="col d-inline-flex  justify-content-start scaleBarLetters">{{settings.values[0]}}</div>
		<div class="col scaleBarLetters">{{settings.values[1]}}</div>
		<div class="col d-inline-flex justify-content-end scaleBarLetters">{{settings.values[2]}}</div>
		<div class="col-1 empty"></div>
	</div>
	<div class=" row">
		<div class="col-1 empty"></div>
		<div class="col legendColor" v-bind:style="{backgroundImage: settings.style}"></div>
		<div class="col-1 empty"></div>
	</div>
</div>
 </template>
 
 <script>
 import utils from "../../libs/js/utils.js";
 let styleStr = "linear-gradient(to right, ";
 function __legendSettings() {
	this.title = "Undefined";
	this.values =["0%", "50%", "100%"];
	this.style = styleStr;
}

 export default {
	name: 'DensityLegend',
	props: {
		mode:String
	},
	computed: {
		density() {
			return this.$store.getters.areaDensity;
		},
		paletteCol() {
			return this.$store.getters.areaDensity.palette_col;
		},
		product() {
			return this.$store.getters.product;
		},
		settings() {			
			let settings =  new __legendSettings();
			if (this.mode =="Raw")
				settings = this.__computeRawLegend();
			else if (this.mode== "Density")
				settings = this.__computeDensityLegend();
			else if (this.mode =="Anomalies")
				settings =  this.__computeAnomalyLegend();
			return settings;
		},
		stratificationViewOptions() {
			return this.$store.getters.stratificationViewOptions;

		},
		statsViewMode() {
			return this.$store.getters.productStatisticsViewMode;
		},
		stratifiedOrRaw() {
			return this.$store.getters.stratifiedOrRaw;
		},
		
	},
	methods:{
		__computeAnomalyLegend() {
			let settings = new __legendSettings();
			let anomaly = this.$store.getters.productAnomaly;
			settings.title = "Value Range for Anomaly Algorithm: " + anomaly.description;
			let ret = this.__computeLegendValuesAndStyle(anomaly.value_ranges, anomaly.style);
			settings.values = ret.values;
			settings.values[0] += " (-)";
			settings.values[1] += " (Stable)";
			settings.values[2] += " (+)";
			
			settings.style = ret.style;
			return settings;
		},
		__computeDensityLegend() {
			let id = this.density.id;
			let settings = new __legendSettings();
			settings.title = "Density Legend (Total Area (%) having values in range [" + this.product.properties.raw.valueRanges[id].toFixed(2).toString() + "," + this.product.properties.raw.valueRanges[id+1].toFixed(2).toString()  + "))";
			Object.keys(this.product[this.paletteCol]).forEach( (key) => {
				let rgb = this.product[this.paletteCol][key];
				let hexColor = "#"+ utils.rgbToHex(rgb[0], rgb[1], rgb[2]);
				settings.style += hexColor +" " + key +"%, "
			});
			settings.style = settings.style.slice(0,-2) +")";
			return settings;
		},
		__computeRawLegend() {
			let settings = new __legendSettings();
			settings.title = "Value Range for Product: " + this.product.description;
			let tmp = this.__computeLegendValuesAndStyle(this.product.properties.raw.valueRanges, this.product.properties.style);
			settings.values = tmp.values;
			settings.style = tmp.style;
			return settings;
		},
		__computeLegendValuesAndStyle(valueRange, style) {
			let ret = {
				values: null,
				style: styleStr
			};
			ret.values = [
				valueRange[0],
				Math.round((valueRange[0]+valueRange[valueRange.length-1])/2*100)/100,
				valueRange[valueRange.length-1]
			];
			
			let step = 100/(style.length-1);
			let key = 0;
			style.forEach((hexColor) =>{
				ret.style += hexColor +" " + key +"%, ";
				key += step;
			});
			ret.style = ret.style.slice(0,-2) +")";
			return ret;
		}
	}
}
 </script>
 
 <style scoped>


.legendColor {}
.scaleBarLetters {
	font-size: 0.8rem;
}

.legendColor:empty::after{
	content: ".";
	visibility:hidden;
}
 </style>

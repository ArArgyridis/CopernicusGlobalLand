 <template>
 <div class="container">
	<div class="row">
		<div class="col-1 empty"></div>
		<div class="col d-inline-flex justify-content-center"><span>{{settings.title}}</span></div>
		<div class="col-1 empty"></div>
	</div>
	<div class="row">
		<div class="col-1 empty"></div>
		<div class="col d-inline-flex  justify-content-start">{{settings.values[0]}}</div>
		<div class="col ">{{settings.values[1]}}</div>
		<div class="col d-inline-flex justify-content-end">{{settings.values[2]}}</div>
		<div class="col-1 empty"></div>
	</div>
	<div class=" row">
		<div class="col-1 empty"></div>
		<div class="col legendColor" id="densityLegendColorBar"></div>
		<div class="col-1 empty"></div>
	</div>
</div>
 </template>
 
 <script>
 import utils from "../../libs/js/utils.js";
 
 export default {
	name: 'DensityLegend',
	computed: {
		settings() {
			let product = this.$store.getters.product;
			let stratificationViewOptions = this.$store.getters.stratificationViewOptions;
			let paletteCol = this.$store.getters.areaDensity.palette_col;
			let currentView = this.$store.getters.currentView;
			let statsVIewMode = this.$store.getters.productStatisticsViewMode;
			let settings =  {
				title:"Undefined",
				values: ["0%", "50%", "100%"],
				style: null
			}
			
			settings.style = "linear-gradient(to right, ";
			
			if (statsVIewMode == 0 ) {
				if (stratificationViewOptions.viewMode == 0 || (stratificationViewOptions.viewMode != 0 && currentView == 1) ) {
					settings.title = "Value Range for Product: " + product.description;
					let ret = this.__computeLegendValuesAndStyle(product.value_ranges, product.viewInfo.style);
					settings.values = ret.values;
					settings.style = ret.style;
				}
				else if (stratificationViewOptions.viewMode == 1) {
					let id = this.$store.getters.areaDensity.id;
					settings.title = "Density Legend (Total Area (%) having values in range [" + product.value_ranges[id].toFixed(2).toString() + "," +product.value_ranges[id+1].toFixed(2).toString()  + "))";
								
					Object.keys(product[paletteCol]).forEach( (key) => {
						let rgb = product[paletteCol][key];
						let hexColor = "#"+utils.rgbToHex(rgb[0], rgb[1], rgb[2]);
						settings.style += hexColor +" " + key +"%, "
					});
				}
			}
			else if (statsVIewMode == 1) {
				let anomaly = this.$store.getters.productAnomaly;
				settings.title = "Value Range for Anomaly Algorithm: " + anomaly.description;
				let ret = this.__computeLegendValuesAndStyle(anomaly.value_ranges, anomaly.style);
				settings.values = ret.values;
				settings.style = ret.style;
			}
			
			settings.style = settings.style.slice(0,-2) +")";
			this.refresh(settings.style);
			return settings;
		}
	},
	methods:{
		init() {
			this.refresh();
		},
		refresh(style = null) {
			if (style == null)
				style = this.settings.style;
				
			let colorBar = document.getElementById("densityLegendColorBar");
			if (colorBar != null)
				colorBar.style["backgroundImage"]= style;
		},
		__computeLegendValuesAndStyle(valueRange, style) {
			let ret = {
				values: null,
				style: "linear-gradient(to right, "
			}
			
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
			return ret;
		} 
	},
	mounted() {
		this.init();
	}
}
 </script>
 
 <style scoped>


.legendColor {}

.legendColor:empty::after{
	content: ".";
	visibility:hidden;
}
 </style>

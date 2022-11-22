 <template>
 <div class="container">
	<div class="row">
		<div class="col-1 empty"></div>
		<div class="col d-inline-flex justify-content-center"><span>{{title}}</span></div>
		<div class="col-1 empty"></div>
	</div>
	<div class="row">
		<div class="col-1 empty"></div>
		<div class="col d-inline-flex  justify-content-start">0%</div>
		<div class="col ">50%</div>
		<div class="col d-inline-flex justify-content-end">100%</div>
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
		title() {
			let product = this.$store.getters.currentProduct;
			let id = this.$store.getters.areaDensity.id;
			return "Density Legend (Total Area (%) having values in range [" + product.value_ranges[id].toFixed(2).toString() + "," +product.value_ranges[id+1].toFixed(2).toString()  + "))";
		}
	},
	methods:{
		init() {
			this.refresh();
		},
		refresh() {
			let areaDensity = this.$store.getters.areaDensity;
			if (areaDensity == null)
				return;
			let product = this.$store.getters.currentProduct;
			let paletteCol = this.$store.getters.areaDensity.palette_col;
			
			console.log();
			
			
			let style = "linear-gradient(to right, ";
			Object.keys(product[paletteCol]).forEach( (key) => {
				let rgb = product[paletteCol][key];
				let hexColor = "#"+utils.rgbToHex(rgb[0], rgb[1], rgb[2]);
				style += hexColor +" " + key +"%, "
			});
			style = style.slice(0,-2) +")";	
			let colorBar = document.getElementById("densityLegendColorBar");
			colorBar.style["backgroundImage"]=style;
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

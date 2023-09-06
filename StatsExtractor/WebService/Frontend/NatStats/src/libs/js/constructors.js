import options from "./options.js";
import utils from "./utils.js";
import requests from "./requests.js";

export function	areaDensityOptions() {
	return [
		{
			id: 0,
			col: "noval_area_ha",
			description: "No value",
			color_col: "noval_color",
			palette_col: "noval_colors"
		},
		{
			id: 1,
			col:"sparse_area_ha",
			description:"Sparse",
			color_col: "sparseval_color",
			palette_col:"sparseval_colors"
		},
		{
			id: 2,
			col:"mid_area_ha",
			description:"Mild",
			color_col: "midval_color",
			palette_col:"midval_colors"
		},
		{
			id: 3,
			col:"dense_area_ha",
			description:"Dense",
			color_col: "highval_color",
			palette_col:"highval_colors"
		}
	];
}

export function consolidationPeriods(hasRT) {
	if (!hasRT){
		return[{
				id: -1,
				description: "Not Available"
			}]
	}
	return  [
	{
		id: 0,
		description: "Near Realtime (RT-0)"
	},
	{
		id: 1,
		description: "1 - Dekad (RT-1)"
	},
	{
		id: 2,
		description: "2 - Dekads (RT-2)"
	},
	{
		id: 6,
		description: "6 - Dekads (RT-6)"
	}
	]
	
}
	
export function	Categories() {
		this.info= null;
		this.current = null;
		this.previous = null;
}

export function	stratificationViewProps(colorCol) {
		this.viewMode = 0;
		this.colorCol = colorCol;
}

export function	AnomaliesProps(product, variable, dateStart, dateEnd) {
		variable.previousAnomaly = null;
		variable.nextAnomaly = null;
		
		if (variable.anomaly_info == null) {
			variable.currentAnomaly = null;
			return;
		}
		
		for (let i = 0; i < variable.anomaly_info.length; i++) {
			if ( variable.anomaly_info[i].variable == null)
				continue;
			
			//because the anomaly variable for a product variable can be only one.....
			let tmp = createVariableInfo( variable.anomaly_info[i].variable);
			 variable.anomaly_info[i] = {... variable.anomaly_info[i], ...tmp};
		}
		variable.currentAnomaly = variable.anomaly_info[0];
}

export function VariableProperties(product, dateStart, dateEnd) {
	for (let i = 0; i < product.variables.length; i++) {
		if (product.variables[i].anomaly_info != null)
			AnomaliesProps(product, product.variables[i], dateStart, dateEnd);
		let tmp = createVariableInfo(product.variables[i]);

		product.variables[i] = {...product.variables[i], ...tmp};
	}

}


export function createVariableInfo(variable) {
	let ret = new Object();
	
	ret.cog					= new CogProps();
	ret.valueRanges 			= [variable.min_value, variable.low_value, variable.mid_value, variable.high_value, variable.max_value];
	ret.density 				= new areaDensityOptions()[2];
	
	ret.density.description 	= utils.computeDensityDescription(ret.density.description, ret.valueRanges[2], ret.valueRanges[3]);
	ret.style 					= new styleBuilder(variable.style, variable.max_prod_value);
	ret.stratificationInfo 		= new stratificationViewProps("meanval_color");

	return ret;
}

export function	styleBuilder(style, maxValue) {
		let parser = new DOMParser();
		let xmlDoc = parser.parseFromString(style, "text/xml");
		let colors = xmlDoc.getElementsByTagName("sld:ColorMapEntry");
		let colorsArr = [];
		if (maxValue < 10) {
			for (let i = 0; i <= maxValue; i++) {
				let tmp = colors[i];
				colorsArr.push(tmp.getAttribute("color"));
			}
		}
		else {
			let step = Math.floor((maxValue-3)/4);
			colorsArr = [
				colors[0].getAttribute("color"),
				colors[step].getAttribute("color"),
				colors[2*step].getAttribute("color"),
				colors[3*step].getAttribute("color"),
				colors[maxValue-1].getAttribute("color")
			];
		}
		return colorsArr; 
}

export function	ProductViewProperties(product, dateStart, dateEnd) {
	product.statisticsViewMode 			= 0;
	product.previousStatisticsViewMode 	= null;
	let tmpPeriods = new consolidationPeriods(product.rt);
	product.rtFlag = tmpPeriods[0];
	if(product.rt) {
		let stop = false;
		for (let i = 0; i < tmpPeriods.length && !stop; i++) {
			if(tmpPeriods[i].id in product.dates) {
				product.rtFlag = tmpPeriods[i];
				stop = true;
			}
		}
	}
	product.previousRtFlag				= null;
	VariableProperties(product, dateStart, dateEnd);
	product.currentVariable				= product.variables[0];
	product.currentDate 					= product.dates[product.rtFlag.id][0];
}

export function	ProductsProps() {
		this.previous = null;
		this.current = null;
		this.info = [];
	
}
export function CogProps() {
	this.current 	= null;
	this.previous = null;
	this.next 	= null;
	this.layers 	= {};
}

export function	StratificationProps() {
	this.current = null;
	this.previous = null;
	this.next = null;
	this.info = [];
	this.clickedCoordinates = null;
}

export function initProduct(product, dateStart, dateEnd) {
	if (product.currentVariable == null) 
		ProductViewProperties(product, dateStart, dateEnd);
}


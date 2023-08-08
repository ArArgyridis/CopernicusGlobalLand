import options from "./options.js";
import utils from "./utils.js";

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
				description: "No Consolidation"
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
export function	AnomaliesProps(product, variable) {
		variable.previousAnomaly = null;
		variable.nextAnomaly = null;
		
		if (variable.anomaly_info == null) {
			variable.currentAnomaly = null;
			return;
		}
		
		variable.currentAnomaly = variable.anomaly_info[0];
		variable.anomaly_info.forEach( anomaly => {
			anomaly.valueRanges 	= [anomaly.min_value, anomaly.low_value, anomaly.mid_value, anomaly.high_value, anomaly.max_value];
			anomaly.wms 			= new WMSProps(anomaly.name, product.dates, anomaly.variable, options.anomaliesWMSURL);
			anomaly.stratificationInfo 	= new stratificationViewProps("meanval_color");
			anomaly.style 			= new styleBuilder(anomaly.style);
		});
	}
export function VariableProperties(product) {
	product.variables.forEach( variable => {
		AnomaliesProps(product, variable);
		variable.wms 				= new WMSProps(product.name, product.dates, variable.variable, options.wmsURL, product.rt)
		variable.valueRanges 			= [variable.min_value, variable.low_value, variable.mid_value, variable.high_value, variable.max_value];
		variable.density 				= new areaDensityOptions()[2];

		variable.density.description 	= utils.computeDensityDescription(variable.density.description, variable.valueRanges[2], variable.valueRanges[3]);
		variable.style 				= new styleBuilder(variable.style);
		variable.stratificationInfo 		= new stratificationViewProps("meanval_color");
	});
}

export function	styleBuilder(style) {
		let parser = new DOMParser();
		let xmlDoc = parser.parseFromString(style, "text/xml");
		let colors = xmlDoc.getElementsByTagName("sld:ColorMapEntry");
		let colorsArr = [];
		if (colors.length < 10) {
			for (let i = 0; i < colors.length; i++) {
				let tmp = colors[i];
				colorsArr.push(tmp.getAttribute("color"));
			}
		}
		else {
			let step = Math.floor((colors.length-3)/4);
			colorsArr = [
				colors[0].getAttribute("color"),
				colors[step].getAttribute("color"),
				colors[2*step].getAttribute("color"),
				colors[3*step].getAttribute("color"),
				colors[colors.length-1].getAttribute("color")
			];
		}
		return colorsArr; 
	}
export function	ProductViewProperties(product) {
	product.statisticsViewMode 			= 0;
	product.previousStatisticsViewMode 	= null;
	product.rtFlag 						= new consolidationPeriods(product.rt)[0]
	product.previousRtFlag				= null;
	VariableProperties(product);
	product.currentVariable				= product.variables[0];
	product.currentDate 					= product.dates[product.rtFlag.id][0];
}

export function	ProductsProps() {
		this.previous = null;
		this.current = null;
		this.info = [];
	
}
export function WMSProps(name, dates, variable, wmsURL=options.wmsURL, rtFlag=false) {
	this.current 	= null;
	this.previous = null;
	this.next 	= null;
	this.urls 		= new Set();
	this.layers 	= {};

	if(!rtFlag)
		this.layers[-1] = {}
	else {
		let rts = consolidationPeriods(rtFlag);
		rts.forEach(rt => {
			this.layers[rt.id] = {}
		});
	}	
	Object.keys(dates).forEach(rt => {
		dates[rt].forEach(date=> {
			let splitDate	= date.split("-");
			let url		= wmsURL + name + "/" + splitDate[0] +"/" +splitDate[1];
			if (variable.length > 0)
				url += "/" + variable;
			this.urls.add(url);
		});
	});
}

export function	StratificationProps() {
	this.current = null;
	this.previous = null;
	this.next = null;
	this.info = [];
	this.clickedCoordinates = null;
}

export function initProduct(product) {
	if (product.currentVariable == null) 
		ProductViewProperties(product);
}


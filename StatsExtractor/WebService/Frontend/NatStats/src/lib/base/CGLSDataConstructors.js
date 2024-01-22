import options from "./options.js";
import utils from "./utils.js";
import requests from "./requests.js";

export function AreaDensityOptions(valueRanges) {
	return [
		{
			id: 1,
			col: "noval_area_ha",
			description: "No value",
			title: utils.computeDensityDescription("Percentage of Variable Values in Range", valueRanges[0], valueRanges[1]),
			colorCol: "noval_color",
			paletteCol: "noval_colors"
		},
		{
			id: 2,
			col: "sparse_area_ha",
			description: "Sparse",
			title: utils.computeDensityDescription("Percentage of Variable Values in Range", valueRanges[1], valueRanges[2]),
			colorCol: "sparseval_color",
			paletteCol: "sparseval_colors"
		},
		{
			id: 3,
			col: "mid_area_ha",
			description: "Mild",
			title: utils.computeDensityDescription("Percentage of Variable Values in Range", valueRanges[2], valueRanges[3]),
			colorCol: "midval_color",
			paletteCol: "midval_colors"
		},
		{
			id: 4,
			col: "dense_area_ha",
			description: "Dense",
			title: "Percentage of Variable Values in Range (≥" + valueRanges[3] + ")",
			colorCol: "highval_color",
			paletteCol: "highval_colors"
		}
	];
}

export function DisplayPolygonValues(valueRanges) {
	return [{
		id:0,
		col: "meanval_color",
		description: "Mean Variable Value",
		title: "Mean Variable Value",
		colorCol: "meanval_color",
		paletteCol: "meanval_colors"
	}, ...AreaDensityOptions(valueRanges)]
}

//analysis mode options
export const analysisModes = ["Raw Values", "Anomalies"];

//view mode options
export const stratifiedOrRawModes = ["Boundary-Based Statistics", "Pixel View"];


export function consolidationPeriods(hasRT) {
	if (!hasRT) {
		return [{
			id: -1,
			description: "Not Available"
		}]
	}
	return [
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

export class Categories {
	constructor(info) {
		this.info = info;
		this.current = null;
		this.previous = null;
	}
}

export class MapViewOptions {
	constructor(displayPolygonValue) {
		this.analysisMode = analysisModes[0];
		this.dataView = stratifiedOrRawModes[0];
		this.displayPolygonValue = displayPolygonValue;
	};
}

export function AnomaliesProps(product, variable, dateStart, dateEnd) {
	variable.previousAnomaly = null;
	variable.nextAnomaly = null;

	if (variable.anomaly_info == null) {
		variable.currentAnomaly = {variable:null};
		return;
	}

	for (let i = 0; i < variable.anomaly_info.length; i++) {
		if (variable.anomaly_info[i].variable == null)
			continue;

		//because the anomaly variable for a product variable can be only one.....
		let tmp = new VariableInfo(variable.anomaly_info[i].variable);
		variable.anomaly_info[i].variable = { ...variable.anomaly_info[i].variable, ...tmp };
	}
	variable.currentAnomaly = variable.anomaly_info[0];
}

export function VariableProperties(product, dateStart, dateEnd) {
	for (let i = 0; i < product.variables.length; i++) {
		AnomaliesProps(product, product.variables[i], dateStart, dateEnd);
		let tmp = new VariableInfo(product.variables[i]);
		product.variables[i] = { ...product.variables[i], ...tmp };
	}

}

export class VariableInfo {
	constructor(variable) {
		this.cog = new CogProps();
		this.valueRanges = [variable.min_value, variable.low_value, variable.mid_value, variable.high_value, variable.max_value];
		this.style = styleBuilder(variable.style, variable.max_prod_value);
		this.mapViewOptions = new MapViewOptions(DisplayPolygonValues(this.valueRanges)[0]);
	}
}

export function styleBuilder(style, maxValue) {
	let colorsArr = [];
	if (style == null)
		return colorsArr;

	let parser = new DOMParser();
	let xmlDoc = parser.parseFromString(style, "text/xml");
	let colors = xmlDoc.getElementsByTagName("sld:ColorMapEntry");

	if (maxValue < 10) {
		for (let i = 0; i <= maxValue; i++) {
			let tmp = colors[i];
			colorsArr.push(tmp.getAttribute("color"));
		}
	}
	else {
		let step = Math.floor((maxValue - 3) / 4);
		colorsArr = [
			colors[0].getAttribute("color"),
			colors[step].getAttribute("color"),
			colors[2 * step].getAttribute("color"),
			colors[3 * step].getAttribute("color"),
			colors[maxValue - 1].getAttribute("color")
		];
	}
	return colorsArr;
}

export function ProductViewProperties(product, dateStart, dateEnd) {
	let tmpPeriods = consolidationPeriods(product.rt);
	product.rtFlag = tmpPeriods[0];
	if (product.rt) {
		let stop = false;
		for (let i = 0; i < tmpPeriods.length && !stop; i++) {
			if (tmpPeriods[i].id in product.dates) {
				product.rtFlag = tmpPeriods[i];
				stop = true;
			}
		}
	}
	product.previousRtFlag = null;
	VariableProperties(product, dateStart, dateEnd);
	product.currentVariable = product.variables[0];
	product.currentDate = utils.dateFromUTCDateString(product.dates[product.rtFlag.id][0]);
}

export class ProductsProps {
	constructor() {
		this.previous = null;
		this.current = null;
		this.info = [];
	}
}
export class CogProps {
	constructor() {
		this.current = null;
		this.previous = null;
		this.next = null;
		this.layers = {};
	}
}

export class ProductFile {
	constructor(pathArray) {
		this.layerId = null;
		this.url = options.s3CogURL + pathArray[0];
		this.raw = options.fetchRawDataURL + "/" + pathArray[1];
	}
}

export class Boundary {
	constructor(boundary, maxZoom = 14, layerId = null, selectedPolygonId = null) {
		this.id = undefined;
		this.description = undefined;
		this.url = undefined;
		Object.assign(this, boundary);
		this.maxZoom = maxZoom;
		this.layerId = layerId;
		this.selectedPolygonId = selectedPolygonId;
	}
}

export class StratificationProps {
	constructor() {
		this.current = null;
		this.previous = null;
		this.next = null;
		this.info = [];
		this.clickedCoordinates = null;
	}
}

export function Product(product, dateStart, dateEnd) {
	if (product == null)
		product = {
			id: -1,
			name: "No Name",
			description: "No description",
			dates: { "-1": [(new Date()).toISOString().substring(0, 19)] },
			rt: false,
			variables: [
				{
					id: 1,
					style: null,
					anomaly_info: null,
					compute_statistics: true
				}
			]
		}

	if (product.currentVariable == null)
		ProductViewProperties(product, dateStart, dateEnd);
	return product;
}


/*
   Copyright (C) 2024  Argyros Argyridis arargyridis at gmail dot com
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
*/

import options from "./options.js";
import {computeDensityDescription, dateFromUTCDateString} from "./utils.js";

export function AreaDensityOptions(variable) {
	let description = variable.variable;
	if (variable.isAnomaly)
		description = variable.description;

	return [
		{
			id: 1,
			col: "noval_area_ha",
			description: "No value",
			title: computeDensityDescription("Percentage of " + description + " values in Range", variable.valueRanges[0], variable.valueRanges[1]),
			colorCol: "noval_color",
			paletteCol: "noval_colors"
		},
		{
			id: 2,
			col: "sparse_area_ha",
			description: "Sparse",
			title: computeDensityDescription("Percentage of " + description + " values in Range", variable.valueRanges[1], variable.valueRanges[2]),
			colorCol: "sparseval_color",
			paletteCol: "sparseval_colors"
		},
		{
			id: 3,
			col: "mid_area_ha",
			description: "Mild",
			title: computeDensityDescription("Percentage of " + description + " values in Range", variable.valueRanges[2], variable.valueRanges[3]),
			colorCol: "midval_color",
			paletteCol: "midval_colors"
		},
		{
			id: 4,
			col: "dense_area_ha",
			description: "Dense",
			title: "Percentage of " + description + " in Range (≥" + variable.valueRanges[3] + ")",
			colorCol: "highval_color",
			paletteCol: "highval_colors"
		}
	];
}

export function DisplayPolygonValues(variable) {
	let description = variable.variable +" Value Range";
	let title = variable.variable + " Raw Values";
	if(variable.isAnomaly) {
		description = "Shifted "+variable.description;
		title = description;

	}

	return [{
		id: 0,
		col: "meanval_color",
		description: description,
		title: title,
		colorCol: "meanval_color",
		paletteCol: "meanval_colors"
	}, ...AreaDensityOptions(variable)]
}

//analysis mode options
export const analysisModes = ["Raw Values", "Anomalies"];

//view mode options
export const stratifiedOrRawModes = ["Boundary-Based Statistics", "Pixel View"];

export class ConsolidationPeriods {
	static #rtFlags = {
		"-1": {
			id: -1,
			description: "Not Available"
		},
		0: {
			id: 0,
			description: "Near Realtime (RT-0)"
		},
		1: {
			id: 1,
			description: "1 - Dekad (RT-1)"
		},
		2: {
			id: 2,
			description: "2 - Dekads (RT-2)"
		},
		5: {
			id: 5,
			description: "5 - Dekads (RT-5)"
		},
		6: {
			id: 6,
			description: "6 - Dekads (RT-6)"
		}
	}

	constructor(dates) {
		let rts = {};
		Object.keys(dates).forEach(id => {
			rts[id] = structuredClone(ConsolidationPeriods.#rtFlags[id]);
			rts[id].currentDate = dateFromUTCDateString(dates[id][0]);
			rts[id].dates = dates[id];
		});
		Object.assign(this, rts);
	}
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

export class VariableInfo {
	constructor(variable, dates = null, isAnomaly=false) {
		Object.assign(this, variable);
		this.isAnomaly = isAnomaly;
		this.cog = new CogProps();
		if(!variable) { //create a null variable just to initialize the values
			this.valueRanges = [0, 1, 2, 3, 4];
			this.style = null;
			this.rts = new ConsolidationPeriods({0:['2000-01-01T00:00:00']})
			this.rtFlag = this.rts[Object.keys(this.rts)[0]];
			this.#anomaliesProps(variable);
		}
		else {
			this.valueRanges = [variable.min_value, variable.low_value, variable.mid_value, variable.high_value, variable.max_value];
			this.style = this.#styleBuilder(variable.style, variable.max_prod_value);
			this.updated = false;
			if (dates) { //this is not an anomaly
				this.rts = new ConsolidationPeriods(dates);
				this.rtFlag = this.rts[Object.keys(this.rts)[0]];
				this.#anomaliesProps(variable);
			}
		}
		this.mapViewOptions = new MapViewOptions(DisplayPolygonValues(this)[0]);
	}
	#anomaliesProps(variable) {
		this.previousAnomaly = null;
		this.nextAnomaly = null;
		if (!variable || variable.anomaly_info == null) {
			this.currentAnomaly = { variable: null };
			return;
		}

		for (let i = 0; i < variable.anomaly_info.length; i++) {
			if (variable.anomaly_info[i].variable == null)
				continue;

			//because the anomaly variable for a product variable can be only one.....
			variable.anomaly_info[i].variable = new VariableInfo(variable.anomaly_info[i].variable, null, true);
		}
		this.currentAnomaly = variable.anomaly_info[0];
	}

	#styleBuilder(style, maxValue) {
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
		this.current = new ProductFile([null, null]);
		this.previous = null;
		this.next = null;
		this.layers = {};
	}
}

export class ProductFile {
	constructor(pathArray, productType="raw") {
		this.layerId = null;
		this.url = null;
		if (pathArray[0] != null) 
			this.url = options.s3CogURL + pathArray[0];

		this.raw = null;
		
		if (pathArray[1] != null) {
			let fetchURL = options.fetchRawDataURL;
			if (productType == "anomaly")
				fetchURL = options.fetchAnomaliesDataURL;
			this.raw = fetchURL + "/" + pathArray[1];
		}
	}
}

export class Boundary {
	constructor(boundary, maxZoom = 14, layerId = null, selectedPolygonId = null) {
		if (!boundary) {
			this.id = undefined;
			this.description = undefined;
			this.url = undefined;
		}
		else 
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

export class Product {
	constructor(product) {
		if (product == null) {
			this.id = -1;
			this.name = "No Product";
			this.description = "No Description"
			this.rt = false;
			this.variables = [new VariableInfo(null)]

		}
		else {
			this.id = product.id;
			this.name = product.name;
			this.description = product.description;
			this.rt = product.rt;
			this.variables = new Array(product.variables.length);

			for (let vrbl = 0; vrbl < product.variables.length; vrbl++)
				this.variables[vrbl] = new VariableInfo(product.variables[vrbl], product.dates);
		}
		this.currentVariable = this.variables[0];
	}

}



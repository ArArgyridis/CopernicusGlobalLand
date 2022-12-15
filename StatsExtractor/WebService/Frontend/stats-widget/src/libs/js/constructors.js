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

export function	Categories() {
		this.info= null;
		this.current = null;
		this.previous = null;
	}
export function	stratificationViewProps(colorCol) {
		this.viewMode = 0;
		this.colorCol = colorCol;
	}
export function	AnomaliesProps(product) {
		this.info = product.anomaly_info;
		this.current = this.info[0];
		this.previous = null;
		this.next = null;
	
		this.info.forEach( anomaly => {
		
			anomaly.urls = new Set();
			anomaly.layers = {
				current: null,
				previous: null,
				info: []
			};
			anomaly.stratificationInfo = new stratificationViewProps("meanval_color");
			anomaly.style = new styleBuilder(anomaly.stylesld);
			product.dates.forEach(date =>{
				let splitDate = date.split("-");
				let url = options.anomaliesWMSURL + anomaly.key + "/" + splitDate[0] +"/" +splitDate[1];
				anomaly.urls.add(url);
			});
		});
	}
export function	RawProps(product) {
		this.wms = new rawWMSProps(product);
		let tmpDensity = new areaDensityOptions()[2];
		this.valueRanges = product.value_ranges;
		tmpDensity.description = utils.computeDensityDescription(tmpDensity.description, this.valueRanges[2], this.valueRanges[3]);
		this.density = tmpDensity;
		this.stratificationInfo = new stratificationViewProps("meanval_color");
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
export function	ProductViewProps(product) {
		this.anomalies = new AnomaliesProps(product);
		this.raw = new RawProps(product);
		this.statisticsViewMode = 0;
		this.previousStatisticsViewMode = null;
		this.currentDate = product.dates[0],
		this.style = new styleBuilder(product.stylesld);
		product.style = null;
	}
export function	ProductsProps() {
		this.previous = null;
		this.current = null;
		this.info = [];
	}
export function	rawWMSProps(product) {
		this.current = null;
		this.previous = null;
		this.next = null;
		this.urls = new Set();
		this.layers = [];
	
		product.dates.forEach(date =>{
			let splitDate = date.split("-");
			let url = options.wmsURL + product.name + "/" + splitDate[0] +"/" +splitDate[1];
			this.urls.add(url);
		});
	}

export function	StratificationProps() {
		this.current = null;
		this.previous = null;
		this.next = null;
		this.info = [];
		this.clickedCoordinates = null;
	}
export function	initProduct(product) {
		if (product.properties == null) 
			product.properties = new ProductViewProps(product);
	}


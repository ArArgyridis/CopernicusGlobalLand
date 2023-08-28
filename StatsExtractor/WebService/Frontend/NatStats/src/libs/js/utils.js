export default {
	computeDensityDescription(str, val1, val2) {
		return str +" [" + val1 + ", " + val2 + ")";
	},
	markerProperties() {
		let ret = 		{
			anchor: [0.3, 1.0],
			anchorXUnits: 'fraction',
			anchorYUnits: 'fraction',
			src: "/assets/marker.png",
			scale: 0.02
		};
		return ret;
	},
	rgbToHex(r, g, b) {
		return(this.valueToHex(r) + this.valueToHex(g) + this.valueToHex(b));
	},
	sort(a, b) {
		let keyA = a.title, keyB = b.title;
		if (keyA < keyB) return 1;
		if (keyA > keyB) return -1;
		return 0;
	},
	valueToHex(c) {
		let hex = c.toString(16);
		return hex.length == 1 ? "0" + hex : hex;
	},
	subtractYears(date, years) {
		date.setFullYear(date.getFullYear() - years);
	}
} 

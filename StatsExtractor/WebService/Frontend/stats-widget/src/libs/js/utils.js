export default{
	computeDensityDescription(str, val1, val2) {
		return str +" [" + val1 + ", " + val2 + ")";
		/*
		if (str == "No value")
			return "No value (less than " + val2 +  ")";
		else if (str =="Sparse")
			return "Sparse (" + val1 + ", " + val2 + ")";
		else if (str =="Mild")
			return "Mild (" + val1 + ", " + val2 + ")";
		else 
			return "Dense (greater than " + val1 +  ")";
		*/
	},
	rgbToHex(r, g, b) {
		return(this.valueToHex(r) + this.valueToHex(g) + this.valueToHex(b));
	},
	valueToHex(c) {
		let hex = c.toString(16);
		return hex.length == 1 ? "0" + hex : hex;
	}
} 

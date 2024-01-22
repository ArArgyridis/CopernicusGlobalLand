/*
   Copyright (C) 2023  Argyros Argyridis arargyridis at gmail dot com
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

export default {
	computeDensityDescription(str, val1, val2) {
		return str + " [" + val1 + ", " + val2 + ")";
	},
	dateFromUTCDateString(date) {
		return new Date(date + "+00:00");
	},
	markerProperties() {
		return {
			anchor: [0.3, 1.0],
			anchorXUnits: 'fraction',
			anchorYUnits: 'fraction',
			src: "assets/marker.png",
			scale: 0.02
		};
	},
	rgbToHex(r, g, b) {
		return (this.valueToHex(r) + this.valueToHex(g) + this.valueToHex(b));
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
	},
	localDateAsUTCString(date) {
		return new Date(date.getTime() - date.getTimezoneOffset() * 60000).toISOString();
	}
} 

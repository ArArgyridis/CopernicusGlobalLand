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

export function computeDensityDescription(str, val1, val2) {
	return str + " [" + val1 + ", " + val2 + ")";
}

export function dateFromUTCDateString(date) {
	return new Date(date + "+00:00");
}

export function	localDateAsUTCString(date) {
	return new Date(date.getTime() - date.getTimezoneOffset() * 60000).toISOString();
}

export class MarkerProperties {
	constructor() {
		this.anchor = [0.3, 1.0];
		this.anchorXUnits = 'fraction';
		this.anchorYUnits = 'fraction';
		this.src = "assets/marker.png";
		this.scale = 0.02;
	}
}

export function	rgbToHex(r, g, b) {
	return (this.valueToHex(r) + this.valueToHex(g) + this.valueToHex(b));
}

export function	sort(a, b) {
	let keyA = a.title, keyB = b.title;
	if (keyA < keyB) return 1;
	if (keyA > keyB) return -1;
	return 0;
}

export function	subtractYears(date, years) {
	date.setFullYear(date.getFullYear() - years);
}

export function	uuidv4() {
	return "10000000-1000-4000-8000-100000000000".replace(/[018]/g, c =>
		(c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16)
  	);
}

export function	valueToHex(c) {
	let hex = c.toString(16);
	return hex.length == 1 ? "0" + hex : hex;
}
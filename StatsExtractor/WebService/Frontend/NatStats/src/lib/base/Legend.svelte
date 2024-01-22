<script>
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

	import utils from "./utils.js";
	import { currentProduct } from "../../store/ProductParameters";
	import {
		analysisModes,
		stratifiedOrRawModes,
	} from "../base/CGLSDataConstructors.js";

	export let analysisMode;

	class LegendSettings {
		constructor() {
			this.title = "Undefined";
			this.values = ["0%", "25%", "50%", "75%", "100%"];
			this.style = "linear-gradient(to right, ";
		}
		update() {
			this.style = "linear-gradient(to right, ";
			let variable = $currentProduct.currentVariable;

			//check if anomalies are displayed
			if (analysisMode == analysisModes[1])
				variable =
					$currentProduct.currentVariable.currentAnomaly.variable;
			
			if (!variable) return;

			let valueRange = variable.valueRanges;
			let style = variable.style;

			//if pixel view or mean polygon values are not displayed...
			if (!($currentProduct.currentVariable.mapViewOptions.dataView == stratifiedOrRawModes[1] || $currentProduct.currentVariable.mapViewOptions.displayPolygonValue.id == 0)) {
				this.values = ["0%", "25%", "50%", "75%", "100%"];
				let paletteCol = variable.mapViewOptions.displayPolygonValue.paletteCol;
				let tmpStyle = [];
				let keys = Array();
				Object.keys(variable[paletteCol]).forEach(key=>{keys.push(parseInt(key))});
				keys = keys.sort(function(a,b){return a-b;});

				keys.forEach(key =>{
					let color = variable[paletteCol][key];
					tmpStyle.push("#"+utils.rgbToHex(color[0], color[1], color[2]));
				});
				style = tmpStyle;
			} else {
				this.values = [
					valueRange[0],
					Math.round((valueRange[0]+valueRange[valueRange.length-1])/4*100)/100,
					Math.round((valueRange[0]+valueRange[valueRange.length-1])/2*100)/100,
					Math.round((valueRange[0]+valueRange[valueRange.length-1])/4*300)/100,
					valueRange[valueRange.length-1]
				];
			}
			settings.title = variable.mapViewOptions.displayPolygonValue.title;
			let step = 100/(style.length-1);
			let key = 0;
			style.forEach((hexColor) =>{
				this.style += hexColor +" " + key +"%, ";
				key += step;
			});
			this.style = this.style.slice(0,-2) +")";
		}
	}

	let style = "linear-gradient(to right, ";
	let settings = new LegendSettings();

	$: $currentProduct, settings.update();
</script>

<div class={$$restProps.class +" container legendBackground"}>
	<div class="row">
		<div class="col-1 empty"></div>
		<div class="col d-inline-flex justify-content-center"><span>{settings.title}</span></div>
		<div class="col-1 empty"></div>
	</div>
	<div class="row">
		<div class="col-1 empty"></div>
		<div class="col d-inline-flex  justify-content-start scaleBarLetters">{settings.values[0]}</div>
		<div class="col d-inline-flex scaleBarLetters text-center">{settings.values[1]}</div>
		<div class="col scaleBarLetters text-center">{settings.values[2]}</div>
		<div class="col d-inline-flex  justify-content-end scaleBarLetters">{settings.values[3]}</div>
		<div class="col d-inline-flex justify-content-end scaleBarLetters">{settings.values[4]}</div>
		<div class="col-1 empty"></div>
	</div>
	<div class=" row">
		<div class="col-1 empty"></div>
		<div class="col legendColor" style="background-image: {settings.style};"></div>
		<div class="col-1 empty"></div>
	</div>
</div>

<style>
	.legendBackground {
		background-color: #eeeeee;
		border-radius: 10px;
		box-shadow: 0px 1px 12px rgba(0, 0, 0, 0.5);
	}

	.scaleBarLetters {
		font-size: 0.8rem;
	}

	.legendColor:empty::after {
		content: ".";
		visibility: hidden;
	}
</style>

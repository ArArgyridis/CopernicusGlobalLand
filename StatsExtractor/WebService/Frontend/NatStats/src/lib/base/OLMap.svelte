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
	import axios from "axios";
	import Crop from "ol-ext/filter/Crop";
	import Feature from "ol/Feature";
	import GeoJSON from "ol/format/GeoJSON";
	import Draw from "ol/interaction/Draw";
	import "ol/ol.css";
	import BingMaps from "ol/source/BingMaps";
	//import WKT from 'ol/format/WKT';
	import Map from "ol/Map";
	import Overlay from "ol/Overlay";
	import View from "ol/View";
	import { defaults as defaultControls } from "ol/control";
	import KML from "ol/format/KML";
	import MVT from "ol/format/MVT";
	import WMSCapabilities from "ol/format/WMSCapabilities";
	import { LineString, MultiPolygon, Point, Polygon } from "ol/geom";
	import DoubleClickZoom from "ol/interaction/DoubleClickZoom";
	import LayerGroup from "ol/layer/Group";
	import TileLayer from "ol/layer/Tile";
	import VectorLayer from "ol/layer/Vector";
	import VectorTileLayer from "ol/layer/VectorTile";
	import WebGLTileLayer from "ol/layer/WebGLTile";
	import { transformExtent } from "ol/proj";
	import { register } from "ol/proj/proj4";
	import GeoTIFF from "ol/source/GeoTIFF.js";
	import OSM from "ol/source/OSM";
	import TileWMS from "ol/source/TileWMS";
	import VectorSource from "ol/source/Vector";
	import VectorTileSource from "ol/source/VectorTile";
	import VectorTile from "ol/layer/VectorTile.js";
	import { Circle, Fill, Stroke, Style, Text } from "ol/style";
	import proj4 from "proj4";
	import { onMount } from "svelte";
    import { nullId } from "../../store/ProductParameters";

	/*params*/
	export let id;
	export let center = "[0,0]";
	export let zoom = 1;
	export let projection = "EPSG:3857";
	export let projectionDef = "";
	export let disableMapControls = false;
	export let selectedFeatureId = 0;
	export let clickedCoordinates = null;

	/*internal variables*/
	let hoverLayers = {};
	let layers = {};
	let map = null;
	let activeHighlightLayer = null;
	let highlightPolygonStyle = new Style({
		stroke: new Stroke({
			color: "rgba(240,0,0,1)",
			width: 3,
		}),
	});

	let emitMapCoordinates = {
		status: false,
		evtTypes: null,
		fn: (evt) => {
			clickedCoordinates = {
				obj: evt,
				epsg: projection,
			};
		},
	};

	function addFeatureToLayer(layerId, ft) {
		layers[layerId].getSource().addFeature(ft);
	}

	function addGenericLayer(tmpLayer, zIndex = null) {
		if (zIndex != null) tmpLayer.setZIndex(zIndex);
		map.addLayer(tmpLayer);
		layers[tmpLayer.ol_uid] = tmpLayer;
		setVisibility(tmpLayer.ol_uid, false);
		return tmpLayer.ol_uid;
	}

	function addVectorLayerToMap(source, zIndex = null) {
		let tmpLayer = new VectorLayer({ source: source });
		return addGenericLayer(tmpLayer, zIndex);
	}

	function addVectorTileLayerToMap(source, zIndex = null) {
		let tmpLayer = new VectorTileLayer({
			source: source,
			renderMode: "hybrid",
			declutter: false,
		});
		return addGenericLayer(tmpLayer, zIndex);
	}

	function createTileLayer(source, zIndex = null, tileLayerConstructor = "TileLayer") {
		let tmpLayer = null;
		if (tileLayerConstructor == "TileLayer")
			tmpLayer = new TileLayer({ source: source });
		else if (tileLayerConstructor == "WebGLTileLayer")
			tmpLayer = new WebGLTileLayer({ source: source });
		
			return addGenericLayer(tmpLayer, zIndex);
	}

	function getRandomInt(min, max) {
		return Math.floor(Math.random() * (max - min + 1)) + min;
	}

	function toggleHighlightLayerVisibility(id, status) {
		setVisibility(hoverLayers[id].hoverId, status); //setting visibility status of current hover layer
		if (!status) {
			map.un("singleclick", hoverLayers[id].listener);
			selectedFeatureId = 0;
		} else {
			map.on("singleclick", hoverLayers[id].listener);
			activeHighlightLayer = hoverLayers[id].hoverId;
		}

		layers[hoverLayers[id].hoverId].changed();
	}

	export function addBingLayerToMap(
		style,
		bingKey = null,
		maxZoom = 19,
		zIndex = null,
	) {
		if (!bingKey) {
			console.error("A Bing Maps API key is required");
			return;
		}
		let options = {
			key: bingKey,
			imagerySet: style,
		};
		if (maxZoom != null) options.maxZoom = maxZoom;
		let bingSource = new BingMaps(options);

		return createTileLayer(bingSource, zIndex);
	}

	export function activateSpinner() {
		document.getElementById(id).classList.add("spinner");
	}

	export function addDrawInteraction(params) {
		if (!params.type) {
			console.error("Specify geometry type");
			return;
		}

		let newVectorLayer;
		if (params.layer) newVectorLayer = params.layer;
		else newVectorLayer = createEmptyVectorLayer();

		let drawOptions = {
			source: layers[newVectorLayer].getSource(),
			type: params.type,
			stopClick: true,
		};
		if (params.style) drawOptions["style"] = params.style;

		let draw = new Draw(drawOptions);
		map.addInteraction(draw);
		return { draw: draw, layer: newVectorLayer };
	}

	export function addFeaturesToLayer(layerId, ft) {
		layers[layerId].getSource().addFeatures(ft);
	}

	export function addOSMLayerToMap(zIndex = null) {
		let osmSource = new OSM();
		return createTileLayer(osmSource, zIndex);
	}

	export function addPointToLayer(layerId, featureId, x, y, options) {
			let ft = new Feature({
				geometry:new Point([x,y])
			});
			ft.setId(featureId);
			ft.setStyle(newMarkerStyle(options, featureId));
			addFeatureToLayer(layerId, ft);
		}

	export function clearVectorLayer(id) {
		layers[id].getSource().clear();
	}

	export function createEmptyVectorLayer(zIndex = null) {
		let source = new VectorSource();
		return addVectorLayerToMap(source, zIndex);
	}

	export function createGEOJSONLayerFromString(str, zIndex = null) {
		let geojsonSource = new VectorSource({
			features: new GeoJSON().readFeatures(str)
		});
		 return addVectorLayerToMap(geojsonSource, zIndex);
	}

	export function createGeoTIFFLayer(
		url,
		zIndex = null,
		extent = null,
		overviews = null,
		min = 0,
		max = 255,
		noData = null,
		interpolate = false,
	) {
		let sourceObj =  {
			url: url,
			min: min,
			max: max
		}

		if(noData != null)
			sourceObj.nodata = noData;

		const source = new GeoTIFF({
			sources: [sourceObj],
		});
		//need to see how to update the
		source.tileOptions.interpolate = interpolate; //hack to disable interpollation
		return createTileLayer(source, zIndex, "WebGLTileLayer");
	}

	export function createVectorTileLayer(params) {
		let tmpSource = new VectorTileSource({
			format: new MVT(),
			url: params.url,
			maxZoom: params.maxZoom,
		});
		return addVectorTileLayerToMap(tmpSource, params.zIndex);
	}

	export function deactivateSpinner() {
		document.getElementById(id).classList.remove("spinner");
	}

	export function deleteFeatureFromVectorLayer(layerId, featureId) {
		let tmpFeature = layers[layerId].getSource().getFeatureById(featureId);
		layers[layerId].getSource().removeFeature(tmpFeature);
	}

	export function fitToExtent(extent, epsgIn) {
		if (epsgIn != projection) {
			let p1 = [extent[0], extent[1]];
			let p2 = [extent[2], extent[3]];
			extent = [p1[0], p1[1], p2[0], p2[1]];
		}
		map.getView().fit(extent);
	}

	export function fitToLayerExtent(id) {
		let extent = layers[id].getSource().getExtent();
		map.getView().fit(extent);
	}

	export function getLayerObject(id) {
		return layers[id];
	}

	export function getMap() {
		return map;
	}

	export function highlightOnLayer(id) {
		if (id in hoverLayers) {
			toggleHighlightLayerVisibility(id, layers[id].getVisible());
		} else {
			let tmpLayer = new VectorTileLayer({
				renderMode: "hybrid",
				declutter: true,
				source: layers[id].getSource(),
				style: (ft) => {
					if (ft.getId() == selectedFeatureId) {
						return highlightPolygonStyle;
					}
				},
			});
			hoverLayers[id] = {
				hoverId: addGenericLayer(tmpLayer, layers[id].getZIndex() + 1),
				listener: (e) => {
					layers[id].getFeatures(e.pixel).then((fts) => {
						if (!fts.length) {
							selectedFeatureId = 0;
						} else {
							let currentId = fts[0].getId();
							if (currentId != selectedFeatureId) {
								selectedFeatureId = currentId;
							}
						}
						layers[hoverLayers[id].hoverId].changed();
					});
				},
			};
			activeHighlightLayer = id;
			toggleHighlightLayerVisibility(
				activeHighlightLayer,
				layers[id].getVisible(),
			);
		}
	}

	export function removeLayer(id) {
		map.removeLayer(layers[id]);
		delete layers[id];
		//remove overlay layer if exists
		if (id in hoverLayers) {
			toggleHighlightLayerVisibility(id, false);
			map.removeLayer(id);
			delete hoverLayers[id];
			activeHighlightLayer = null;
		}
	}

	export function newMarkerStyle(options, label = null) {
		if (options && "icon" in options) {

			return new Style({
				image: options.icon,
			});
		}
		if (!options)
			options = {};

		if (options.color == null)
			options.color =
				"rgba(" +
				getRandomInt(80, 170) +
				"," +
				getRandomInt(80, 170) +
				"," +
				getRandomInt(80, 170) +
				"," +
				1 +
				")";

		if (options.stroke == null)
			options.stroke =
				"rgba(" +
				getRandomInt(80, 170) +
				"," +
				getRandomInt(80, 170) +
				"," +
				getRandomInt(80, 170) +
				"," +
				1 +
				")";

		let markerStroke = new Stroke({
			color: options.stroke,
			width: 1.5,
		});
		let fill = new Fill({ color: options.color });
		let style = new Style({
			image: new Circle({
				radius: 5,
				fill: fill,
				stroke: markerStroke,
			}),
		});
		if (label != null) {
			let text = new Text({
				offsetX: 15,
				offsetY: -12,
				text: label.toString(),
				fill: fill,
				scale: 1.5,
			});

			style.setText(text);
		}

		return style;
	}

	export function rotateMap(angle) {
		map.getView().setRotation(angle);
	}

	export function setView(view) {
		map.setView(view);
	}

	export function setVisibility(id, status) {
		layers[id].setVisible(status);
		if (id in hoverLayers) toggleHighlightLayerVisibility(id, status);
	}

	export function toggleGetMapCoordinates(evt = ["click"]) {
		if (emitMapCoordinates.status) {
			map.un(emitMapCoordinates.evtTypes, emitMapCoordinates.fn);
			emitMapCoordinates.status = false;
		} else {
			emitMapCoordinates.evtTypes = evt;
			map.on(emitMapCoordinates.evtTypes, emitMapCoordinates.fn);
			emitMapCoordinates.status = true;
		}
	}

	export function updateLayerStyle(id, style) {
		layers[id].setStyle(style);
	}

	onMount(() => {
		if (projectionDef != "") {
			proj4.defs(projection, projectionDef);
			register(proj4);
		}

		let cntr = JSON.parse(center);
		map = new Map({
			controls: defaultControls({ attribution: false }),
			target: id,
			view: new View({
				zoom: zoom,
				projection: projection,
			}),
		});
		map.getView().setCenter(cntr);
		if (disableMapControls) {
			let ctrls = map.getControls();
			for (let i = 0; i < ctrls.getLength(); i++)
				map.removeControl(ctrls.getArray()[i]);
		}
	});
</script>



<div {id} class={$$restProps.class || ""} />

<style>
	.map {
		width: 100%;
		height: 500px;
		background: #f8f4f0;
	}

	.ol-tooltip {
		position: relative;
		background: rgba(0, 0, 0, 0.5);
		border-radius: 4px;
		color: white;
		padding: 4px 8px;
		opacity: 0.7;
		white-space: nowrap;
		font-size: 12px;
	}

	.ol-tooltip-measure {
		opacity: 1;
		font-weight: bold;
	}

	.ol-tooltip-static {
		background-color: #ffcc33;
		color: black;
		border: 1px solid white;
	}

	.ol-tooltip-measure:before,
	.ol-tooltip-static:before {
		border-top: 6px solid rgba(0, 0, 0, 0.5);
		border-right: 6px solid transparent;
		border-left: 6px solid transparent;
		content: "";
		position: absolute;
		bottom: -6px;
		margin-left: -7px;
		left: 50%;
	}
	.ol-tooltip-static:before {
		border-top-color: #ffcc33;
	}

	@keyframes spinner {
		to {
			transform: rotate(360deg);
		}
	}
	.spinner {
		pointer-events: none;
	}
	.spinner:after {
		content: "";
		box-sizing: border-box;
		position: absolute;
		top: 50%;
		left: 50%;
		width: 40px;
		height: 40px;
		margin-top: -20px;
		margin-left: -20px;
		border-radius: 50%;
		border: 5px solid rgba(180, 180, 180, 0.6);
		border-top-color: rgba(0, 0, 0, 0.6);
		animation: spinner 0.6s linear infinite;
		z-index: 10000;
	}
</style>

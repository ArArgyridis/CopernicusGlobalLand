<!---
   Copyright (C) 2022  Argyros Argyridis arargyridis at gmail dot com
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
--->
<template>
    <div v-bind:id=id class="map" />
</template>

<script>
import 'ol/ol.css';

import axios from 'axios';
import BingMaps from 'ol/source/BingMaps';
import Draw from 'ol/interaction/Draw';
import Feature from 'ol/Feature';
//import FeatureFormat from 'ol/format/Feature';
import GeoJSON from 'ol/format/GeoJSON';
//import WKT from 'ol/format/WKT';
import Map from 'ol/Map';
import MVT from 'ol/format/MVT';
import OSM from 'ol/source/OSM';
import Overlay from 'ol/Overlay';
import {register} from 'ol/proj/proj4';
import {LineString, Point, Polygon} from 'ol/geom';
import TileLayer from 'ol/layer/Tile';
import TileWMS from 'ol/source/TileWMS';
import VectorLayer from 'ol/layer/Vector';
import VectorSource from 'ol/source/Vector';
import VectorTileLayer from 'ol/layer/VectorTile';
import VectorTileSource from 'ol/source/VectorTile';
import View from 'ol/View';
import WMSCapabilities from 'ol/format/WMSCapabilities';
import {defaults as defaultControls} from 'ol/control';
//import { inflateCoordinatesArray } from "ol/geom/flat/inflate"
import {Fill, Circle, Stroke, Style, Text} from 'ol/style';
import DoubleClickZoom from "ol/interaction/DoubleClickZoom";

export default {
	name: 'OLMap',
	data() {
		return {
			activeHighlightLayer: null,
			emitMapCoordinates: {
				status: false,
				evtTypes:null,
				fn: (evt) => {
					this.$emit("mapCoordinate", {epsg: this.epsg, coordinate: evt.coordinate});
				}
			},
			currentHighlightLayer:null,
			currentHighlightListener:null,
			hoverLayers:{},
			hoverListeners:{},
			layers: null,
			map: null,
			measurementInteraction: null,
			lastMeasurementTooltip: null,
			highlightPolygonStyle:new Style({
				stroke: new Stroke({
					color: 'rgba(240,0,0,1)',
					width: 3,
				}),
			}),
			selectedFeatureId: null,
			hoverListener: null
		}
	},
	props: {
		id: String,
		bingKey: String,
		epsg: String,
		zoom: Number,
		center: Array,
		targetEPSG: String //will be used in cases where data should be returned in different EPSG than the one specified
	},
	methods: {
		init() {
			this.map = new Map({
				controls: defaultControls({attribution: false}),
				target: this.id,
				view: new View({
					center: this.center,
					zoom: parseInt(this.zoom),
					projection: this.epsg
				})
			});
            
			this.layers = {};
			register(this.$store.state.proj4);
			let ctrls = this.map.getControls();
			for (let i = 0; i < ctrls.getLength(); i++)
				this.map.removeControl(ctrls.getArray()[i]);	
				
				
			let dblClickInteraction;
			// find DoubleClickZoom interaction
			this.map.getInteractions().getArray().forEach(function(interaction) {
				if (interaction instanceof DoubleClickZoom) {
					dblClickInteraction = interaction;
				}
			});
			// remove from map
			this.map.removeInteraction(dblClickInteraction);
		}
		,addBingLayerToMap (style, setMaxZoom, zIndex = null) {
			if (!this.bingKey) {console.error("A Bing Maps API key is required"); return;}
			let bingSource =  new BingMaps({
				key: this.bingKey,
				imagerySet: style
			});
			if (setMaxZoom) bingSource.maxZoom = 19;
				return this.createWMSLayer(bingSource, zIndex);
		}
		,addCustomWMSLayerToMap(params) {
			if (!params.url) {console.error("Specify WMS url"); return;}
			if (!params.projection) {console.error("Specify WMS projection"); return;}
			if (!params.wmsParams) {console.error("Specify WMS parameters"); return;}
			if (!params.serverType) {console.error("Specify WMS server type"); return;}

			params.wmsParams["width"] = 256;
			params.wmsParams["height"] = 256;


			if (params.url.substr(params.url.length-1) !="&")
				params.url = params.url.concat("&");
				let wmsSource = new TileWMS({
					url: params.url,
					params: params.wmsParams,
					serverType: params.serverType,
					crossOrigin: params.crossOrigin,
					projection: params.projection,
					key: Math.random()
				});
				wmsSource.updateParams({seq: (new Date()).getTime()});
				return this.createWMSLayer(wmsSource, params.extent, params.zIndex);
		},
		addDrawInteraction(params) {
			if(!params.type) {console.error("Specify geometry type"); return;}
		
			let newVectorLayer;
			if(params.layer)
				newVectorLayer = params.layer;
			else
				newVectorLayer = this.createEmptyVectorLayer();
			let drawOptions = {
				source: this.layers[newVectorLayer].getSource(),
				type: params.type,
				stopClick:true,
			};
				
			if (params.style)
				drawOptions["style"] = params.style;

			let draw = new Draw(drawOptions);
			this.map.addInteraction(draw);
			return {draw: draw, layer: newVectorLayer};
		},
			
		addMeasurementInteraction(params) {
			let mLayer = null;
			if (params.layer == null) {
				mLayer = this.createEmptyVectorLayer(20);
				this.layers[mLayer].setStyle(new Style({
					fill: new Fill({
						color: 'rgba(255, 255, 255, 0.2)'
					}),
				
					stroke: new Stroke({
						color: '#ffcc33',
						width: 3
					}),
					image: new Circle({
						radius: 7,
						fill: new Fill({
							color: '#ffcc33'
						})
					})
				}));
			}
			else
				mLayer = params.Layer;

			this.measurementInteraction = this.addDrawInteraction({
				type: params.type,
				layer: mLayer,
				style: new Style({
					fill: new Fill({
						color: 'rgba(255, 255, 255, 0.2)'
					}),
					stroke: new Stroke({
						color: 'rgba(255, 204, 51, 0.7)',
						lineDash: [10, 10],
						width: 4
					}),
					image: new Circle({
						radius: 5,
						stroke: new Stroke({
							color: 'rgba(0, 0, 0, 0.7)'
						}),
						fill: new Fill({
							color: 'rgba(255, 255, 255, 0.2)'
						})
					})
				})
			});
			this.measurementInteraction["tooltips"] = [];

			this.measurementInteraction.draw.on("drawstart", (evt) => {
				let tooltipCoord = null;
				let output = null;
				let geom = evt.feature;
				geom.getGeometry().on("change", (e) => {
					this.lastMeasurementTooltip = this.__createMeasurementTooltip(this.lastMeasurementTooltip);
					let geom = e.target;
					if(geom instanceof Polygon) {
						console.log("polygon!");
					}
					else if (geom instanceof LineString) {
						output = this.__formatMeasurementLength(geom);
						tooltipCoord = geom.getLastCoordinate();
					}
					this.lastMeasurementTooltip.node.innerHTML = output;
					this.lastMeasurementTooltip.overlay.setPosition(tooltipCoord);
				});
			});
			this.measurementInteraction.draw.on("drawend", () => {
				this.measurementInteraction.draw.setActive(false);
				this.measurementInteraction.tooltips.push(this.lastMeasurementTooltip);
				this.lastMeasurementTooltip = null;
			});
			this.measurementInteraction.draw.setActive(false);
			return this.measurementInteraction;
		},
		addOSMLayerToMap (zIndex = null) {
			let osmSource = new OSM();
			return this.createWMSLayer(osmSource, zIndex);
		},
		addPointToLayer(layerId, featureId, x, y, color) {
			let ft = new Feature({
				geometry:new Point([x,y])
			});
			ft.setId(featureId);
			ft.setStyle(this.__newMarkerStyle(color, featureId));
			this.layers[layerId].getSource().addFeature(ft);
		},
		createVectorTileLayer(params){
			let tmpSource = new VectorTileSource({
				declutter: true,
				renderMode: 'vector',
				format: new MVT(),
				maxZoom:params.maxZoom,
				url: params.url			
			})
			return this.__addVectorTileLayerToMap(tmpSource, params.zIndex);
		
		},		
		clearMeasurements() {
			this.clearVectorLayer(this.measurementInteraction.layer);
			this.measurementInteraction.tooltips.forEach( (tooltip) => {
				tooltip.node.remove();
				this.map.removeOverlay(tooltip.overlay);
			});

		},
		clearVectorLayer(id) {
			this.layers[id].getSource().clear();
		},
		createEmptyVectorLayer (zIndex = null) {
			let source = new VectorSource();
			return this.__addVectorLayerToMap(source, zIndex);
		},
		createGEOJSONLayer(url) {
			if(!url) { console.error("Please specify GeoJSON url"); return;}
			let geojsonSource =  new VectorSource({
				url: url,
				format: new GeoJSON()
			});
			return this.__addVectorLayerToMap(geojsonSource);
		},
		createGEOJSONLayerFromString(str) {
			let geojsonSource = new VectorSource({
				features: new GeoJSON().readFeatures(str)
			});
			return this.__addVectorLayerToMap(geojsonSource);
		},
		createPointLabel(layerId, featureId, color, showLabel) {
			let tmpFeature = this.layers[layerId].getSource().getFeatureById(featureId);
		
			if (showLabel)
				tmpFeature.setStyle(this.__newMarkerStyle(color, featureId) );
			else
				tmpFeature.setStyle(this.__newMarkerStyle(color) );

		},
		createWMSLayer (source, extent = null, zIndex = null) {
			let tmpLayer = new TileLayer({source: source, preload: Infinity});
			if (extent != null)
				tmpLayer.setExtent(extent);
			return this.__addGenericLayer(tmpLayer, zIndex);
		},
		deleteFeatureFromVectorLayer(layerId, featureId) {
			let tmpFeature = this.layers[layerId].getSource().getFeatureById(featureId);
			this.layers[layerId].getSource().removeFeature(tmpFeature);
		},
		fitToExtent(extent, epsg) {
			if (epsg != this.epsg) {

				let p1 = [extent[0], extent[1]];
				let p2 = [extent[2], extent[3]];
				p1 = this.$store.state.proj4(epsg, this.epsg, p1);
				p2 = this.$store.state.proj4(epsg, this.epsg, p2);
				extent = ([p1[0], p1[1], p2[0], p2[1] ]);
			}
			this.map.getView().fit(extent);
		},
		fitToLayerExtent(id) {
			this.map.getView().fit(this.layers[id].getSource().getExtent());
		},
		getAvailableWMSLayers(url, zIndex=null) {
			let tmpURL = url+"?service=wms&version=1.3.0&request=GetCapabilities";
			return axios.get(tmpURL).then( (response) =>{
				let parser = new WMSCapabilities();
				let ret = [];
				try {
					let capabilities = parser.read(response.data);
					capabilities.Capability.Layer.Layer.forEach( (layer) => {
						let layerId = this.addCustomWMSLayerToMap({
							url: url,
							projection: layer.CRS[0],
							wmsParams: {
								LAYERS: layer.Title,
								WIDTH:256,
								HEIGHT:256
							},
							serverType: "mapserver",
							crossOrigin: "anonymous",
							zIndex: zIndex
						});
						this.setVisibility(layerId);
						ret.push({title: layer.Title, layerId: layerId, name: layer.Name});
				});
				}catch (e) {
					console.log("Unable to parse wms capabilities");
					console.log(e);
				}
				return ret;
			});

		},
		getMapExtent() {
			return this.map.getView().calculateExtent();
		},
		getLayerList() {
			return this.layers;
		},
		getLayerObject(id){
			return this.layers[id];
		},
		toggleGetMapCoordinates(evt=["click"]) {
			if (this.emitMapCoordinates.status) {
				this.map.un(this.emitMapCoordinates.evtTypes, this.emitMapCoordinates.fn);
				this.emitMapCoordinates.status = false;
			}
			else {
				this.emitMapCoordinates.evtTypes = evt;
				this.map.on(this.emitMapCoordinates.evtTypes, this.emitMapCoordinates.fn);
				this.emitMapCoordinates.status = true;
			}
		},
		getMap(){
			return this.map;
		},
		highlightOnLayer(id) {
			if (this.activeHighlightLayer != null)  //if already a layer has an active hover
				this.__toggleHighlightLayerVisibility(this.activeHighlightLayer, false);
			
			if (id in this.hoverLayers) {
				this.__toggleHighlightLayerVisibility(id, true);
			}
			else {
				let tmpLayer = new VectorTileLayer({
					renderMode: 'vector',
					source: this.layers[id].getSource(),
					style: ( (ft) => {
						//console.log(ft);
						if (ft.getId() == this.selectedFeatureId) 
							return this.highlightPolygonStyle;
						
						//return null;
					})
				});

				this.hoverLayers[id] = {
					hoverId: this.__addGenericLayer(tmpLayer,  this.layers[id].getZIndex()+1),
					listener: ((e) => {
						//console.log(e);
						
						this.layers[id].getFeatures(e.pixel).then((fts) => {
							let emt = null;
							if (!fts.length) {
								this.selectedFeatureId = null;
							}
							else {
								let currentId = fts[0].getId();
						
								if (currentId != this.selectedFeatureId) {
									this.selectedFeatureId = currentId;
									//this.layers[this.hoverLayers[this.activeHighlightLayer].hoverId].changed();
									emt = fts[0];
								}
							}
							this.layers[this.hoverLayers[this.activeHighlightLayer].hoverId].changed();
							this.$emit("featureClicked", emt);
						});
						//console.log(this.map.getFeaturesAtPixel(e.pixel));
					})
				}
				this.activeHighlightLayer = id;
				this.__toggleHighlightLayerVisibility(this.activeHighlightLayer, true);
			}
		},
		clearCurrentPolygonSelection() {
			this.selectedFeatureId = null;
			this.layers[this.hoverLayers[this.activeHighlightLayer].hoverId].changed();
		},
		
		removeLayer(id) {
			this.map.removeLayer(this.layers[id]);
			delete this.layers[id];
			//remove overlay layer if exists
			if (id in this.hoverLayers) {
				this.__toggleHighlightLayerVisibility(id, false);
				this.map.removeLayer(id);
				delete this.hoverLayers;
				this.activeHighlightLayer = null;
			}
		},
		rorateMap(angle) {
			this.map.getView().setRotation(angle);
		},
		setVisibility(id, status) {			
			this.layers[id].setVisible(status);
			if(id in this.hoverLayers)
				this.__toggleHighlightLayerVisibility(id, status);
		},
		toggleLayerVisibility(layerId) {
			this.layers[layerId].setVisible(!this.layers[layerId].getVisible());
			if(layerId in this.hoverLayers)
				this.__toggleHighlightLayerVisibility(layerId,this.layers[layerId].getVisible());
		},
		updateFeatureCoordinates(layerId, featureId, geometry) {
			this.layers[layerId].getSource().getFeatureById(featureId).getGeometry().setCoordinates(geometry);
		},
		updateFeatureStyle(layerId, featureId, styleOptions) {
			let tmpStyle = this.__newMarkerStyle(styleOptions, featureId);
			this.layers[layerId].getSource().getFeatureById(featureId).setStyle(tmpStyle);
		},
		updateEPSG(epsg) {
			let center = this.map.getView().getCenter();
			//reprojecting center to new epsg
			let currentEPSG = this.map.getView().getProjection().getCode();
			center = this.$store.state.proj4(currentEPSG, epsg, center);

			let zoom = this.map.getView().getZoom();
			let tmpView = new View({
				projection: epsg,
				center: center,
				zoom: zoom
			});

			this.map.setView(tmpView);

			//updating vector layers to new epsg
			for (let layer of (Object.entries(this.layers))) {
				if(layer[1] instanceof VectorLayer) {
					layer[1].getSource().forEachFeature((ft) => {
						let tmpGeometry = ft.getGeometry();
						let tmpCoords = ft.getGeometry().getCoordinates();
						if (tmpGeometry instanceof Point) {
							tmpCoords = this.$store.state.proj4(currentEPSG, epsg, tmpCoords);
						}
						else if (tmpGeometry instanceof LineString) {
							let newCoords = [];
							for (let i = 0; i < tmpCoords.length; i++)
								newCoords.push(this.$store.state.proj4(currentEPSG, epsg, tmpCoords[i]));
						
							tmpCoords = newCoords;
						}
						ft.getGeometry().setCoordinates(tmpCoords);
					}) ;
				}
			}
		},
		updateLayerStyle(id, style){
			this.layers[id].setStyle(style);
		},
		
		updateWMSOpacity(layerId, opacity) {
			this.layers[layerId].setOpacity(opacity);
		},
		zoomToLayerFeature(layerId, featureId) {
			let tmpFeature = this.layers[layerId].getSource().getFeatureById(featureId);
			this.map.getView().setCenter(tmpFeature.getGeometry().getCoordinates());
		},
		__addGenericLayer(tmpLayer, zIndex=null) {
			if (zIndex != null)
				tmpLayer.setZIndex(zIndex);
			
			this.map.addLayer(tmpLayer);
			this.layers[tmpLayer.ol_uid] = tmpLayer;
			this.setVisibility(tmpLayer.ol_uid, false);
			return tmpLayer.ol_uid;
		},
		__addVectorLayerToMap(source, zIndex = null) {
			let tmpLayer = new VectorLayer({source: source});
			return this.__addGenericLayer(tmpLayer, zIndex);
		},
		__addVectorTileLayerToMap(source, zIndex=null) {
			let tmpLayer = new VectorTileLayer({
				source: source,
				declutter: true
			});
			return this.__addGenericLayer(tmpLayer, zIndex);
			
		},
		__createMeasurementTooltip(el=null) {
			if (el != null) {
				el.node.remove();
				this.map.removeOverlay(el.overlay);
			}

			let newEl = document.createElement("div");
			newEl.classList.add('ol-tooltip');
			newEl.classList.add('ol-tooltip-static');
			let overlay = new Overlay( {
				element: newEl,
				offset: [0, -15],
				positioning: 'bottom-center',
				zindex:1000
			});

			this.map.addOverlay(overlay);

			return {"node": newEl, "overlay": overlay};
		},
		__formatMeasurementLength(line) { //measurements are returned in either the map projection system OR the target EPSG if specified
			let tmpLine = line;
			if (this.targetEPSG != null && this.map.getView().getProjection().getCode() != this.targetEPSG) {
				let tmpCoords = line.getCoordinates();
				let newCoords = [];
				for (let i = 0; i < tmpCoords.length; i++)
					newCoords.push(this.$store.state.proj4(this.map.getView().getProjection().getCode(), this.targetEPSG, tmpCoords[i]));
				
				tmpLine = new LineString( newCoords);
			}

			let length = Math.round(tmpLine.getLength() * 100) / 100;
			if (length > 100)
				return (Math.round(length / 1000 * 100) / 100) + ' ' + 'km';
			else
				return (Math.round(length * 100) / 100) + ' ' + 'm';
		},
		__getRandomInt (min, max) {
			return Math.floor(Math.random() * (max - min + 1)) + min;
		},
		__newMarkerStyle (options, label=null) {
			if (options.color == null)
				options.color = "rgba(" + this.__getRandomInt(80, 170) + "," + this.__getRandomInt(80, 170) + "," + this.__getRandomInt(80, 170) + "," + 1 +")";

			if (options.stroke == null)
				options.stroke ="rgba(" + this.__getRandomInt(80, 170) + "," + this.__getRandomInt(80, 170) + "," + this.__getRandomInt(80, 170) + "," + 1 +")";

			let markerStroke = new Stroke({
				color: options.stroke,//"rgba(232, 232, 115, 1)",
				width: 1.5,
			});
			let fill = new Fill({color: options.color, width: 5});
			let style = new Style({
				image: new Circle({
					radius: 5,
					fill: fill,
					stroke: markerStroke
				})
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
		},__toggleHighlightLayerVisibility(id, status) {
			this.setVisibility(this.hoverLayers[id].hoverId, status); //turning off current hover layer
			if(!status) {
				this.map.un("singleclick", this.hoverLayers[id].listener); 
				this.selectedFeatureId = false;
				this.layers[this.hoverLayers[id].hoverId].changed();
			}
			else
				this.map.on("singleclick", this.hoverLayers[id].listener);
		}
	},
	mounted() {
		this.init();
	}
}
</script>

<style>

.map {
	width: 100%;
	height:500px;
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
</style>

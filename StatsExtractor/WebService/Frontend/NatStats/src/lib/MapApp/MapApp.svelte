<!---
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
--->

<script>
    import OLMap from "../base/OLMap.svelte";
    import { onMount } from "svelte";
    import { currentBoundary, boundaries } from "../../store/Boundaries.js";
    import {
        currentProduct,
        styleCache,
    } from "../../store/ProductParameters.js";
    import {
        analysisModes,
        DisplayPolygonValues,
        stratifiedOrRawModes,
    } from "../base/CGLSDataConstructors.js";
    import { Fill, Stroke, Style, Icon } from "ol/style";
    import requests from "../base/requests.js";
    import options from "../base/options.js";
    import MapInfo from "./MapInfo/MapInfo.svelte";
    import utils from "../base/utils.js";


    let refs = {};
    let visibleBoundary = null;
    let visibleCogLayer = null;
    let selectedFeatureId = null;
    let clickedCoordinates = null;
    let mapInfoLoading = false;
    let markerLayer = null;

    let defaultBoundariesStyle = new Style({
        fill: new Fill({ color: "rgb(208, 208, 208, 0.3)" }),
        stroke: new Stroke({
            color: "rgb(0, 170, 255, 0.3)",
            width: 1.5,
        }),
    });

    let outlineboundariestyle = new Style({
        fill: new Fill({ color: "rgb(54, 102, 142, 0.0)" }),
        stroke: new Stroke({
            color: "rgb(54, 102, 142, 0.6)",
            width: 1.5,
        }),
    });

    //Boundary_id/variable_id/rt_flag/raw_or_anomaly/date/column_name/style_array

    function changeVisibleBoundary() {
        if (!("map" in refs)) return;

        if ($currentBoundary.url == null) return;

        if (visibleBoundary != null)
            refs.map.setVisibility($boundaries[visibleBoundary].layerId, false);

        visibleBoundary = $currentBoundary.id;
        refs.map.setVisibility($boundaries[visibleBoundary].layerId, true);
    }

    function refreshBoundaries() {
        if (!("map" in refs)) return;

        let keys = Object.keys($boundaries);
        keys.sort();
        keys.forEach((key) => {
            $boundaries[key]["zIndex"] = options.vectorTileZIndex;
            $boundaries[key].layerId = refs.map.createVectorTileLayer(
                $boundaries[key],
            );
            refs.map.highlightOnLayer($boundaries[key].layerId);
        });

        visibleBoundary = keys[0];
        //refs.map.highlightOnLayer($boundaries[keys[0]].layerId);
        refs.map.setVisibility($boundaries[keys[0]].layerId, true);
    }

    function refreshMarker() {
        if (!("map" in refs)) return;

        refs.map.clearVectorLayer(markerLayer);
        console.log();
        refs.map.addPointToLayer(markerLayer, 1, clickedCoordinates.obj.coordinate[0], clickedCoordinates.obj.coordinate[1], {icon: new Icon(utils.markerProperties())});

         
    }

    function setBoundaryStyle(tmpLayer, style) {
        tmpLayer.setStyle((ft) => {
            return style[ft.getId()];
        });
    }

    function setViewOptions() {
        if (visibleBoundary == null) return;

        let product = $currentProduct;
        let analysisMode =
            $currentProduct.currentVariable.mapViewOptions.analysisMode;
        let dataView = $currentProduct.currentVariable.mapViewOptions.dataView;
        let variable = $currentProduct.currentVariable;
        if (analysisMode == analysisModes[1])
            variable = $currentProduct.currentVariable.currentAnomaly.variable;

        let varId = variable.id;
        let rt = $currentProduct.rtFlag.id;
        let tmpLayer = refs.map.getLayerObject(
            $boundaries[visibleBoundary].layerId,
        );
        let date = $currentProduct.currentDate.toISOString().substr(0, 19);
        let strata = $currentBoundary;

        if (Object.keys(variable.cog.layers).length > 0) //cog layers have been fetched
            variable.cog.current = variable.cog.layers[rt][date];

        if (visibleCogLayer != null)
            refs.map.setVisibility(visibleCogLayer.layerId, false);

        if (dataView == stratifiedOrRawModes[0]) {
            //checking if color in cache
            refs.map.activateSpinner();
            //console.log("spinner activated!");

            //Boundary_id/product_id/rt_flag/raw_or_anomaly/date/column_name/style_array
            if (!(strata.id in $styleCache)) $styleCache[strata.id] = {};

            let strataCache = $styleCache[strata.id];
            if (!(product.currentVariable.id in strataCache))
                strataCache[product.currentVariable.id] = {};

            let variableCache = strataCache[product.currentVariable.id];
            if (!(rt in variableCache)) variableCache[rt] = {};

            let rtCache = variableCache[rt];
            if (
                !(
                    product.currentVariable.mapViewOptions.analysisMode in
                    rtCache
                )
            )
                rtCache[product.currentVariable.mapViewOptions.analysisMode] =
                    {};

            let analysisCache =
                rtCache[product.currentVariable.mapViewOptions.analysisMode];

            if (!(date in analysisCache)) analysisCache[date] = {};

            let dateCache = analysisCache[date];
            let columnName =
                product.currentVariable.mapViewOptions.displayPolygonValue
                    .colorCol;
            if (
                product.currentVariable.mapViewOptions.analysisMode ==
                analysisModes[1]
            ) {
                columnName =
                    product.currentVariable.currentAnomaly.variable
                        .mapViewOptions.displayPolygonValue.colorCol;
                varId = product.currentVariable.currentAnomaly.variable.id;
            }

            if (!(columnName in dateCache)) {
                let polygonStyles = DisplayPolygonValues(
                    $currentProduct.currentVariable.valueRanges,
                );
                polygonStyles.forEach((polyStyle) => {
                    dateCache[polyStyle.colorCol] = {};
                });

                requests
                    .fetchBoundaryDataByProductAndDate(
                        date,
                        varId,
                        rt,
                        strata.id,
                    )
                    .then((response) => {
                        if (response.data.data == null) {
                            tmpLayer.setStyle(defaultBoundariesStyle);
                            refs.map.deactivateSpinner();
                            //console.log("spinner deactivated 1");
                            return;
                        }
                        Promise.all(
                            response.data.data.map((rec) =>
                                styleCreator(rec, dateCache),
                            ),
                        ).then((e) => {
                            setBoundaryStyle(tmpLayer, dateCache[columnName]);
                            refs.map.deactivateSpinner();
                            //console.log("spinner deactivated 2");
                        });
                    });
            } else {
                if (Object.keys(dateCache[columnName]).length == 0)
                    tmpLayer.setStyle(defaultBoundariesStyle);
                else setBoundaryStyle(tmpLayer, dateCache[columnName]);
                refs.map.deactivateSpinner();
                //console.log("spinner deactivated 3");
            }
        } else if (dataView == stratifiedOrRawModes[1]) {

            if (Object.keys(variable.cog.layers).length == 0) return;

            tmpLayer.setStyle(outlineboundariestyle);
            if (visibleCogLayer != null)
                refs.map.setVisibility(visibleCogLayer.layerId, false);
            
            if (variable.cog.current.layerId == null)
                variable.cog.current.layerId = refs.map.createGeoTIFFLayer(
                    variable.cog.current.url,
                    options.cogZIndex,
                );

            refs.map.setVisibility(variable.cog.current.layerId, true);
            visibleCogLayer = variable.cog.current;
        }
    }

    function styleCreator(rec, dateCache) {
        Object.keys(dateCache).forEach((colorCol) => {
            let color = rec[colorCol];
            if (color != null) {
                let joinedColor = color.join();
                dateCache[colorCol][rec.id] = new Style({
                    fill: new Fill({
                        color: "rgba(" + joinedColor + ",0.7)",
                    }),
                    stroke: new Stroke({
                        color: "rgba(" + joinedColor + ",1.0)",
                        width: 1.2,
                    }),
                });
            } else dateCache[colorCol][rec.id] = defaultBoundariesStyle;
        });
    }

    function toggleSpinner() {
        if (!refs.map) return;

        if (mapInfoLoading) refs.map.activateSpinner();
        else refs.map.deactivateSpinner();
    }

    //reactivity
    $: $boundaries, refreshBoundaries();
    $: $currentBoundary, changeVisibleBoundary();
    $: $currentBoundary, $currentProduct, setViewOptions();
    $: mapInfoLoading, toggleSpinner();
    $:clickedCoordinates, refreshMarker();

    onMount(() => {
        let layerId = refs.map.addBingLayerToMap("aerial", options.bingKey);
        refs.map.setVisibility(layerId, true);
        refs.map.toggleGetMapCoordinates();
        
        markerLayer = refs.map.createEmptyVectorLayer(6);
        refs.map.setVisibility(markerLayer, true);
    });
</script>

<div class="col px-0 mainMap">
    <MapInfo
        mapInfoId="mapInfoId"
        {selectedFeatureId}
        {clickedCoordinates}
        bind:dataLoading={mapInfoLoading}
    />

    <OLMap
        id="basemap"
        class="map"
        bind:this={refs.map}
        disableMapControls={true}
        bind:selectedFeatureId
        bind:clickedCoordinates
    />
</div>

<style>
    .mainMap :global(.map) {
        height: 100vh;
        position: relative;
    }
</style>
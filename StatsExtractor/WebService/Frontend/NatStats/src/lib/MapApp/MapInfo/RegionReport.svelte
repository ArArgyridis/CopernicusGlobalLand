<!---
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
--->
<script>
    import "bootstrap/dist/css/bootstrap.min.css";
    import html2canvas from "html2canvas";
    import { Fill, Icon, Stroke, Style } from "ol/style";
    import Legend from "../../base/Legend.svelte";
    import AreaDensityPieChart from "./AreaDensityPieChart.svelte";
    import PointTimeSeries from "./PointTimeSeries.svelte";
    import PolygonHistogramData from "./PolygonHistogramData.svelte";
    import PolygonTimeSeries from "./PolygonTimeSeries.svelte";

    import { onMount } from "svelte";
    import {
        currentProduct,
        dateEnd,
        dateStart,
    } from "../../../store/ProductParameters";
    import OlMap from "../../base/OLMap.svelte";
    import options from "../../base/options.js";
    import utils from "../../base/utils";
    
    export let regionInfo;
    export let diagramData;
    export let clickedCoordinates;
    export let parentId = "report";

    let hidePrintableArea = true;
    let refs = {};
    refs.maps = {};
    refs.diagramKeys = {};
    let backgroundIDs = {};
    let cogLayerIDs = {};
    let polygonLayerIDs = {};
    let pointLayerIDs = {};
    let mapIterator = [
        {
            variable: () => {
                return $currentProduct.currentVariable;
            },
            layer: () => {
                return $currentProduct.currentVariable.cog.current;
            },
            key: "productMap",
        },
        {
            variable: () => {
                return $currentProduct.currentVariable.currentAnomaly.variable;
            },
            layer: () => {
                return $currentProduct.currentVariable.currentAnomaly.variable
                    .cog.current;
            },
            key: "anomalyMap",
        },
    ];

    let polyStyle = new Style({
        fill: new Fill({
            color: "rgba(244, 244, 246, 0.3)"
        }),
        stroke: new Stroke({
            color: "rgb(27,238,213)",
            width: 3,
        }),
    });

    function updateMapsView() {
        let renderHandlers = [];
        mapIterator.forEach((pair) => {
            let map = refs.maps[pair.key];
            if (pair.variable()) {
                //adding cog layer
                if (pair.key in cogLayerIDs)
                    map.removeLayer(cogLayerIDs[pair.key]);

                cogLayerIDs[pair.key] = map.createGeoTIFFLayer(
                    pair.layer().url,
                );
                map.setVisibility(cogLayerIDs[pair.key], true);

                //adding polygon layer
                if (pair.key in polygonLayerIDs)
                    map.removeLayer(polygonLayerIDs[pair.key]);

                polygonLayerIDs[pair.key] =
                    map.createGEOJSONLayerFromString(regionInfo);
                map.setVisibility(polygonLayerIDs[pair.key], true);
                map.getLayerObject(polygonLayerIDs[pair.key]).setStyle(
                    polyStyle,
                );

                //adding point layer
                if (pair.key in pointLayerIDs)
                    map.removeLayer(pointLayerIDs[pair.key]);

                pointLayerIDs[pair.key] = map.createEmptyVectorLayer();
                map.setVisibility(pointLayerIDs[pair.key], true);
                map.addPointToLayer(pointLayerIDs[pair.key], 1, clickedCoordinates.obj.coordinate[0], clickedCoordinates.obj.coordinate[1], {icon: new Icon(utils.markerProperties())});
                //renderHandlers.push( new Promise(resolve=> map.getMap().once("rendercomplete", resolve)));
                //renderHandlers.push( new Promise(resolve=> map.getLayerObject(cogLayerIDs[pair.key]).on("postcompose", resolve)));
            }
        });
        return renderHandlers;
    }
    export function printReport() {
        hidePrintableArea = false;
        let renderHandlers = updateMapsView();
        Object.keys(refs.diagramKeys).forEach((key) => {
            refs.diagramKeys[key].update();
        });
        /*
        Promise.all(renderHandlers).then(() =>{
            html2canvas(refs.printArea).then((canvas) => {                
                canvas.getContext("2d", { willReadFrequently: true });
                let tmpEl = document.createElement("a");
                tmpEl.href = canvas.toDataURL("image/png").replace("image/png", "image/octet-stream");
                tmpEl.download = regionInfo.properties.description + ".png";
                document.body.appendChild(tmpEl);
                tmpEl.click();
                document.body.removeChild(tmpEl);
                hidePrintableArea = true;
            });   
        });
        */
        //hack since there is no convenient way to know that the map finished loading...
        return new Promise((resolve, reject) => {
            setTimeout(() => {
                mapIterator.forEach((pair) => {
                    if (pair.variable())
                        refs.maps[pair.key].fitToLayerExtent(
                            polygonLayerIDs[pair.key],
                        );
                });
            }, 50);
            setTimeout(() => {
                resolve(
                    html2canvas(refs.printArea).then((canvas) => {
                        canvas.getContext("2d", { willReadFrequently: true });
                        let tmpEl = document.createElement("a");
                        tmpEl.href = canvas
                            .toDataURL("image/png")
                            .replace("image/png", "image/octet-stream");
                        tmpEl.download =
                            regionInfo.properties.description + ".png";
                        document.body.appendChild(tmpEl);
                        tmpEl.click();
                        document.body.removeChild(tmpEl);
                        hidePrintableArea = true;
                    }),
                );
            }, 6000);
        });
    }

    onMount(() => {
        //refs.maps.productMap.getMap().once("rendercomplete", (evt)=>{console.log((evt))} )
        mapIterator.forEach((pair) => {
            backgroundIDs[pair.key] = refs.maps[pair.key].addBingLayerToMap(
                    "aerial",
                    options.bingKey,
                );

                refs.maps[pair.key].setVisibility(
                    backgroundIDs[pair.key],
                    true,
                );
        });
    });

</script>
<!--    -->
<div
    class="dashboardPrintArea"
    bind:this={refs.printArea}
    class:d-none={hidePrintableArea}
>
<!--<button on:click={printReport}>forceTest</button>-->

    <div class="dashboardPrintInnerArea">
        <div class="container">
            <div class="row">
                <div
                    class="col d-flex align-items-center flex-column justify-content-center"
                >
                    <h4>
                        Examined Region: {regionInfo.properties.description} ({regionInfo
                            .properties.strata})
                    </h4>
                </div>
            </div>
            <div class="row">
                <div
                    class="col d-flex align-items-center flex-column justify-content-center"
                >
                    <h5>Selected Product: {$currentProduct.description}</h5>
                </div>
            </div>
            <div class="row">
                <div
                    class="col d-flex align-items-center flex-column justify-content-center"
                >
                    <h6>
                        Examination Period: {$dateStart.toDateString()} / {$dateEnd.toDateString()},
                        Selected Date: {$currentProduct.currentDate.toDateString()}
                    </h6>
                </div>
            </div>
            <div class="row">
                <div
                    class="col-sm reportMaps d-flex align-items-center flex-column justify-content-center">
                        <h6>Raw Data</h6>
                        <OlMap
                            id={parentId + "_product_map"}
                            class="reportMap"
                            disableMapControls={true}
                            bind:this={refs.maps.productMap}
                        />
                        <Legend analysisMode={"Raw"}/>

                </div>
                <div
                    class="col-sm reportMaps d-flex align-items-center flex-column justify-content-center"
                    class:d-none={$currentProduct.currentVariable.currentAnomaly
                        .variable == null}
                >                   
                        <h6>Anomalies</h6>
                        <OlMap
                            id={parentId + "_anomaly_map"}
                            class="reportMap"
                            disableMapControls={true}
                            bind:this={refs.maps.anomalyMap}
                        />
                        <Legend analysisMode={"Anomalies"}/>

                </div>
            </div>
            <div class="row mt-1">
                <div class="col-sm">
                    <PointTimeSeries
                        chartId={parentId + "_locationTimeSeriesRaw"}
                        diagramData={diagramData.locationTimeSeriesRaw}
                        mode="raw"
                        bind:this={refs.diagramKeys.pointTimeSeriesRaw}
                    />
                </div>
                <div class="col-sm">
                    <PolygonTimeSeries
                        chartId={parentId + "_polygonTimeSeriesRaw"}
                        diagramData={diagramData.polygonTimeSeriesRaw}
                        mode="raw"
                        bind:this={refs.diagramKeys.polygonTimeSeriesRaw}
                    />
                </div>
            </div>
            <div class="row">
                <div class="col-sm">
                    <AreaDensityPieChart
                        chartId={parentId + "_areaDensityPieChart"}
                        diagramData={diagramData.areaDensityPieChart}
                        bind:this={refs.diagramKeys.areaDensityPieChart}
                    />
                </div>
                <div class="col-sm">
                    <PolygonHistogramData
                        chartId={parentId + "_polygonHistogramData"}
                        diagramData={diagramData.polygonHistogramData}
                        bind:this={refs.diagramKeys.polygonHistogramData}
                    />
                </div>
            </div>
        </div>
        <div
            class="container"
            hidden={$currentProduct.currentVariable.currentAnomaly.variable ==
                null}
        >
            <div class="row">
                <div class="col-sm">
                    <PointTimeSeries
                        chartId={parentId + "_locationTimeSeriesAnomalies"}
                        diagramData={diagramData.locationTimeSeriesAnomalies}
                        mode={"anomalies"}
                        bind:this={refs.diagramKeys.locationTimeSeriesAnomalies}
                    />
                </div>
                <div class="col-sm">
                    <PolygonTimeSeries
                        chartId={parentId + "_polygonTimeSeriesAnomalies"}
                        diagramData={diagramData.polygonTimeSeriesAnomalies}
                        mode={"anomalies"}
                        bind:this={refs.diagramKeys.polygonTimeSeriesAnomalies}
                    />
                </div>
            </div>
        </div>
    </div>
</div>

<style>
    .dashboardPrintArea {
        z-index: -1;
        width: 1240px;
        height: 1754px;
        border: 2px solid red;
        position: absolute;
        margin-top: 2000px;
    }

    .halfMap {
        width: 50%;
    }
    .fullMap {
        width:100%;
    }

    .dashboardPrintInnerArea {
        margin: 31px;
        box-sizing: border-box;
        padding: 31px;
        border: 1px solid black;
        height: 1692px;
    }
    .reportMaps :global(.reportMap) {
        width: 100%;
        height: 260px;
    }

    .container {
        max-width: 100%;
    }
    .row {
        width: 1112px;
        /*flex-wrap: nowrap*/
    }
    .col-sm {
        width: 100%;
        flex: 1 0 0%;
        border: 1px solid rgb(155, 126, 126);
    }
</style>

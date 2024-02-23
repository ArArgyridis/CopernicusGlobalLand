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
    import bootstrap from "bootstrap/dist/js/bootstrap.min.js";
    import requests from "../../base/requests";
    import {
        currentProduct,
        dateEnd,
        dateStart,
    } from "../../../store/ProductParameters";
    import AreaDensityPieChart from "./AreaDensityPieChart.svelte";
    import { onMount } from "svelte";
    import PolygonTimeSeries from "./PolygonTimeSeries.svelte";
    import PointTimeSeries from "./PointTimeSeries.svelte";
    import PolygonHistogramData from "./PolygonHistogramData.svelte";
    import RegionReport from "./RegionReport.svelte";

    export let mapInfoId = "mapInfo";
    export let selectedFeatureId = false;
    export let clickedCoordinates = null;
    export let dataLoading = false;

    let diagramModal = null;
    let selectedRegion = {
        properties: {
            description: "Dummy",
            strata: "Dummy",
        },
    };

    let refs = {};
    refs.diagrams = {};

    let diagramKeys = [];
    let displayDiagrams = {};
    let diagramData = {};
    let loadingDiagrams = {};

    let showExportReportSpinner = false;
    let allowExportRegionReport = false;
    let activeDiagramId = 0;

    function displayDiagramModal() {
        if (!selectedFeatureId) return;

        dataLoading = true;
        requests
            .fetchDashboard(
                selectedFeatureId,
                $currentProduct.id,
                $dateStart.toISOString(),
                $dateEnd.toISOString(),
            )
            .then((response) => {
                selectedRegion = response.data.data;
                dataLoading = false;
                diagramModal.show();
            });
    }

    function enableRegionReport() {
        allowExportRegionReport = true;
        for (
            let i = 0, key = diagramKeys[i];
            i < diagramKeys.length;
            i++, key = diagramKeys[i]
        ) {
            if (!displayDiagrams[key]) continue;

            allowExportRegionReport =
                allowExportRegionReport && !loadingDiagrams[key];
        }
    }

    function resetActiveDiagram() {
        let cont = true;
        for (let id = 0; id < diagramKeys.length && cont; id++) {
            if (displayDiagrams[diagramKeys[id]]) {
                activeDiagramId = diagramKeys.indexOf(diagramKeys[id]);
                cont = false;
            }
        }
    }

    function updateDiagramsVisibility() {
        diagramKeys.forEach((key) => {
            displayDiagrams[key] = refs.diagrams[key].toShow();
        });
    }

    $: $currentProduct, selectedFeatureId, updateDiagramsVisibility();
    $: selectedFeatureId, displayDiagramModal();
    $: loadingDiagrams, enableRegionReport();

    onMount(() => {
        //setting up modal
        let modalEl = document.getElementById(mapInfoId);
        diagramModal = new bootstrap.Modal(modalEl);
        modalEl.addEventListener("hidden.bs.modal", resetActiveDiagram);
        //loading diagram names
        diagramKeys = Object.keys(refs.diagrams);
        updateDiagramsVisibility();
    });
</script>

<RegionReport
    {diagramData}
    {clickedCoordinates}
    regionInfo={selectedRegion}
    bind:this={refs.regionReport}
/>
<div
    class="modal fade"
    id={mapInfoId}
    tabindex="-1"
    aria-labelledby={mapInfoId + "label"}
    aria-hidden="true"
>
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="exampleModalLabel">
                    {selectedRegion.properties.description +
                        " (" +
                        selectedRegion.properties.strata +
                        ")"}
                </h5>
                <button
                    type="button"
                    class="btn-close"
                    data-bs-dismiss="modal"
                    aria-label="Close"
                ></button>
            </div>
            <div class="modal-body">
                <ul class="nav nav-tabs text-muted text-center">
                    {#each diagramKeys as key, idx}
                        <li class="nav-item">
                            <button
                                class="nav-link"
                                class:active={idx == activeDiagramId}
                                class:d-none={!displayDiagrams[key]}
                                aria-current="page"
                                on:click={() => {
                                    activeDiagramId = idx;
                                }}>{refs.diagrams[key].title()}</button
                            >
                        </li>
                    {/each}
                </ul>

                <PointTimeSeries
                    active={activeDiagramId ==
                        diagramKeys.indexOf("locationTimeSeriesRaw")}
                    bind:this={refs.diagrams.locationTimeSeriesRaw}
                    bind:diagramData={diagramData.locationTimeSeriesRaw}
                    bind:loading={loadingDiagrams.locationTimeSeriesRaw}
                    chartId={mapInfoId + "_locationtimeseriesraw"}
                    mode="raw"
                    {clickedCoordinates}
                />
                <PointTimeSeries
                    active={activeDiagramId ==
                        diagramKeys.indexOf("locationTimeSeriesAnomalies")}
                    bind:this={refs.diagrams.locationTimeSeriesAnomalies}
                    bind:diagramData={diagramData.locationTimeSeriesAnomalies}
                    bind:loading={loadingDiagrams.locationTimeSeriesAnomalies}
                    chartId={mapInfoId + "_locationtimeseriesanomalies"}
                    mode="anomalies"
                    {clickedCoordinates}
                />
                <PolygonTimeSeries
                    shown={activeDiagramId ==
                        diagramKeys.indexOf("polygonTimeSeriesRaw")}
                    bind:this={refs.diagrams.polygonTimeSeriesRaw}
                    bind:diagramData={diagramData.polygonTimeSeriesRaw}
                    bind:loading={loadingDiagrams.polygonTimeSeriesRaw}
                    chartId={mapInfoId + "_polygontimeseriesraw"}
                    polygonId={selectedFeatureId}
                    mode="raw"
                />
                <PolygonTimeSeries
                    shown={activeDiagramId ==
                        diagramKeys.indexOf("polygonTimeSeriesAnomalies")}
                    bind:this={refs.diagrams.polygonTimeSeriesAnomalies}
                    bind:diagramData={diagramData.polygonTimeSeriesAnomalies}
                    bind:loading={loadingDiagrams.polygonTimeSeriesAnomalies}
                    chartId={mapInfoId + "_polygontimeseriesanomalies"}
                    polygonId={selectedFeatureId}
                    mode="anomalies"
                />
                <AreaDensityPieChart
                    shown={activeDiagramId ==
                        diagramKeys.indexOf("areaDensityPieChart")}
                    bind:this={refs.diagrams.areaDensityPieChart}
                    bind:diagramData={diagramData.areaDensityPieChart}
                    bind:loading={loadingDiagrams.areaDensityPieChart}
                    chartId={mapInfoId + "_areadensity"}
                    polygonId={selectedFeatureId}
                />
                <PolygonHistogramData
                    shown={activeDiagramId ==
                        diagramKeys.indexOf("polygonHistogramData")}
                    bind:this={refs.diagrams.polygonHistogramData}
                    bind:diagramData={diagramData.polygonHistogramData}
                    bind:loading={loadingDiagrams.polygonHistogramData}
                    chartId={mapInfoId + "_histogramdata"}
                    polygonId={selectedFeatureId}
                />
            </div>
            <div class="modal-footer">
                <button
                    type="button"
                    class="btn btn-primary"
                    class:disabled={!allowExportRegionReport}
                    on:click={() => {
                        showExportReportSpinner = true;
                        allowExportRegionReport = false;
                        refs.regionReport.printReport().then(() =>{
                            allowExportRegionReport = true;
                            showExportReportSpinner = false;
                        });
                        
                    }}>Export Region Report
                    <div class="spinner-border spinner-border-sm text-light" role="status" hidden = {!showExportReportSpinner}>
                      </div>
                    </button>
            </div>
        </div>
    </div>
</div>

<style>
    .modal-dialog {
        margin-top: 20vh;
        width: 790px;
    }
    .modal-content {
        width: 850px;
    }
</style>

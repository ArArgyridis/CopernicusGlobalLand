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
    import {
        currentProduct,
        dateEnd,
        dateStart,
    } from "../../../store/ProductParameters";
    import requests from "../../base/requests";
    import Highcharts from "highcharts";
    import highchartsMore from "highcharts/highcharts-more";
    import { updateButtons } from "mc-datepicker/src/js/handlers";
    import { onMount } from "svelte";
    highchartsMore(Highcharts);

    export let chartId = "polygonTimeSeriesraw";
    export let mode = "raw";
    export let shown = true;
    export let polygonId = false;

    let noData = [[], [], [], []];
    export let diagramData = structuredClone(noData);
    export let loading = true;

    let chart = null;
    let variable = $currentProduct.currentVariable;

    function refreshData() {
        if (!polygonId) return;
       
        reset();

        if (!polygonId || !variable) return;

        chart.showLoading();
        requests
            .polygonStatsTimeSeries(
                polygonId,
                $dateStart.toISOString(),
                $dateEnd.toISOString(),
                variable.id,
                $currentProduct.rtFlag.id,
            )
            .then((response) => {
                diagramData = [
                    new Array(response.data.data.length),
                    new Array(response.data.data.length),
                    new Array(response.data.data.length),
                    new Array(response.data.data.length),
                ];

                if (mode == "raw") {
                    for (let i = 0; i < response.data.data.length; i++) {
                        let it = response.data.data[i];
                        it[0] = new Date(
                            Date.parse(it[0] + "+00:00"),
                        ).getTime();
                        diagramData[0][i] = [it[0], it[3] - it[4], it[3] + it[4]];
                        diagramData[1][i] = [it[0], it[1]];
                        diagramData[2][i] = [it[0], it[1] - it[2], it[1] + it[2]];
                        diagramData[3][i] = [it[0], it[3]];
                    }
                } else if (mode == "anomalies") {
                    diagramData = [
                        null,
                        new Array(response.data.data.length),
                        new Array(response.data.data.length),
                        null,
                    ];

                    for (let i = 0; i < response.data.data.length; i++) {
                        let it = response.data.data[i];
                        it[0] = new Date(
                            Date.parse(it[0] + "+00:00"),
                        ).getTime();
                        diagramData[1][i] = [it[0], it[1]];
                        diagramData[2][i] = [it[0], it[1] - it[2], it[1] + it[2]];
                    }
                }
                chart.hideLoading();

                update();
                loading = false;
            })
            .catch(() => {
                chart.hideLoading();
                loading = false;
            });
    }

    function reset() {
        diagramData = structuredClone(noData);
        update();
        loading = true;
    }

    function setChartOptions() {
        let valueRange = [0, 1.5];
        if (variable != null) valueRange = variable.valueRanges;

        let step =
            (valueRange[valueRange.length - 1] - valueRange[0]) /
            valueRange.length;

        return {
            credits: {
                enabled: false,
            },
            title: {
                text: "Region Time Series for Product (" + mode + ")",
                style: {
                    fontSize: "15px",
                },
            },
            series: [
                {
                    name: "valid range",
                    type: "arearange",
                    data: diagramData[0],
                    showInLegend: false,
                    color: "rgba(201, 201, 201, 0.7)",
                    marker: {
                        enabled: false,
                    },
                },
                {
                    name: "Polygon Mean Values",
                    data: diagramData[1],
                },
                {
                    type: "errorbar",
                    data: diagramData[2],
                },
                {
                    name: "Polygon Long-Term Mean Value",
                    data: diagramData[3],
                    color: "#EB603F",
                    marker: {
                        enabled: false,
                    },
                    dashStyle: "dot",
                    showInLegend: mode == "raw",
                },
            ],
            yAxis: {
                min: valueRange[0] - step,
                max: valueRange[valueRange.length - 1] + step,
                title: {
                    enabled: true,
                    text: "Product value",
                },
            },
            xAxis: {
                type: "datetime",
                dateTimeLabelFormats: {
                    month: "%e/%m/%y",
                },
                title: {
                    enabled: true,
                    text: "Date",
                },
                plotBands: [
                    {
                        // mark the weekend
                        color: "rgba(255,145,71,0.9)",
                        from:
                            Date.parse($currentProduct.currentDate) -
                            86400 * 34,
                        to:
                            Date.parse($currentProduct.currentDate) +
                            86400 * 34,
                        id: "pltbnd1",
                    },
                ],
            },
            legend: {
                enabled: true,
            },
        };
    }

    export function title() {
        return "Polygon Time Series (" + mode + ")";
    }

    export function toShow() {
        let ret = false;
        if (mode == "raw") ret = $currentProduct.currentVariable != null;
        else if (mode == "anomalies")
            ret =
                $currentProduct.currentVariable.currentAnomaly.variable != null;
        return ret;
    }

    export function update() {
        if($currentProduct.id < 1)
            return;

        variable = $currentProduct.currentVariable;
        if (mode == "anomalies") 
            variable = $currentProduct.currentVariable.currentAnomaly.variable;

        let options = setChartOptions();
        chart = new Highcharts.Chart(chartId, options);
        
    }

    onMount(() => {
        update();
    });

    //reactivity
    $: polygonId, refreshData();


</script>

<div id={chartId} class:d-none={!shown} />

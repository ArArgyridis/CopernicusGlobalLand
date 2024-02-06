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
    import { onMount } from "svelte";
    highchartsMore(Highcharts);

    export let chartId = "histogram";
    export let mode = "raw";
    export let shown = true;
    export let polygonId = false;
    export let loading = true;

    let variable = $currentProduct.currentVariable;
    let noData = [[], []];
    export let diagramData = structuredClone(noData);
    let chart = null;

    export function getNoData() {
        return noData;
    }

    function refreshData() {
        if (!polygonId) return;

        reset();

        requests
            .fetchHistogramByPolygonAndDate(
                polygonId,
                $currentProduct.currentVariable.rtFlag.currentDate,
                $currentProduct.currentVariable.id,
                $currentProduct.currentVariable.rtFlag.id,
            )
            .then((response) => {
                let xAxisCategories = [];
                for (
                    let i = 0;
                    i < response.data.data.histogram.y.length;
                    i++
                ) {
                    xAxisCategories.push(
                        response.data.data.histogram.x[i].toString() +
                            "-" +
                            response.data.data.histogram.x[i + 1].toString(),
                    );
                }
                diagramData = [response.data.data.histogram.y, xAxisCategories];
                update();
                loading = false;
            });
    }

    function reset() {
        diagramData = structuredClone(noData);
        update();
        loading = true;
    }

    function setChartOptions() {
        return {
            credits: {
                enabled: false,
            },
            title: {
                text: "Region Frequency Histogram (raw)",
                style: {
                    fontSize: "15px",
                },
            },
            subtitle: {
                text: $currentProduct.currentVariable.rtFlag.currentDate.toDateString(),
            },
            plotOptions: {
                column: {
                    pointPadding: 0,
                    borderWidth: 1,
                    groupPadding: 0,
                    shadow: false,
                },
            },
            series: [
                {
                    name: "Histogram",
                    type: "column",
                    data: diagramData[0],
                },
            ],
            yAxis: {
                title: {
                    enabled: true,
                    text: "Number of Pixels",
                },
            },
            xAxis: {
                categories: diagramData[1],
                title: {
                    enabled: true,
                    text: "Frequency",
                },
            },
            legend: {
                enabled: false,
            },
        };
    }

    export function title() {
        return "Region Frequency Histogram (raw)";
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
        let options = setChartOptions();
        chart = new Highcharts.Chart(chartId, options);
    }

    onMount(() => {
        update();
    });

    $: polygonId, refreshData();
</script>

<div id={chartId} class:d-none={!shown} />

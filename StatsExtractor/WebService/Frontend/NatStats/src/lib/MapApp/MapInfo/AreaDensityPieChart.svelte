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
    import requests from "../../base/requests";
    import Highcharts from "highcharts";
    import Accessibility from "highcharts/modules/accessibility.js";
    import { currentProduct } from "../../../store/ProductParameters";
    import { AreaDensityOptions } from "../../base/CGLSDataConstructors";
    import {onMount} from "svelte";

    export let chartId = "areaDensityPieChart";
    export let polygonId = false;
    export let shown = true;
    let noData = [{name: "no data",
                    y: 100,
                }];
    export let diagramData = structuredClone(noData);
    export let loading = true;

    let chart = null;

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
            chart: {
                plotBackgroundColor: null,
                plotBorderWidth: null,
                plotShadow: false,
                type: "pie",
            },
            title: {
                text: "Region Raw Product Values Clustering (%)",
                style: {
                    fontSize: "15px",
                },
            },
            subtitle: {
                text: $currentProduct.currentVariable.rtFlag.currentDate.toDateString(),
            },
            tooltip: {
                headerFormat: null,
                pointFormat: "<b>{point.name}:</b> {point.percentage:.1f}%",
            },
            accessibility: {
                point: {
                    valueSuffix: "%",
                },
            },
            plotOptions: {
                pie: {
                    allowPointSelect: true,
                    cursor: "pointer",
                    dataLabels: {
                        enabled: true,
                        format: "<b>{point.name}</b>: {point.percentage:.1f} % ",
                    },
                },
            },
            series: [
                {
                    name: "Density",
                    colorByPoint: true,
                    data: diagramData,
                    showInLegend: true,
                },
            ],
            legend: {
                enabled: true,
            },
        };
    }

    function refreshData() {
        if (!polygonId) return;

        reset();
        chart.showLoading();

        requests
            .getPieDataByDateAndPolygon(
                $currentProduct.currentVariable.id,
                $currentProduct.currentVariable.rtFlag.id,
                $currentProduct.currentVariable.rtFlag.currentDate,
                polygonId,
            )
            .then((response) => {                
                let areaDensityInfo = AreaDensityOptions(
                    $currentProduct.currentVariable.valueRanges,
                );
                diagramData = [];
                areaDensityInfo.forEach((density) => {
                    diagramData.push({
                        name: density.title,
                        y: response.data.data[density.description],
                    });
                });
                update();
                loading = false;
            });
    }

    export function getNoData() {
        return noData;
    }

    export function title() {
        return "Region Raw Product Values Clustering (%)";
    }

    export function toShow() {
        return true;
    }

    export function update() {
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

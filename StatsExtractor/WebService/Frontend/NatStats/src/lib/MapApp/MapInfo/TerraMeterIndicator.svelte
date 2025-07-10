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

    let chart = null;
    let noData = [];
    let noParams = { raw_mean: 0, lts_mean: 0, lts_sd: 0 };
    let params = structuredClone(noParams);

    export let chartId = "terraMeterIndicator";
    export let diagramData = structuredClone(noData);
    export let shown = true;
    export let polygonId = false;
    export let loading = true;

    function refreshData() {
        if (!polygonId) return;

        reset();


        requests.terraMeterIndicator(
                polygonId,
                $currentProduct.currentVariable.rtFlag.currentDate,
                $currentProduct.currentVariable.id,
                $currentProduct.currentVariable.rtFlag.id
            )
            .then((response) => {
                params = response.data.data;
                diagramData = [parseFloat(params.raw_mean.toFixed(2))];
                update();
            });
    }

    function reset() {
        diagramData = structuredClone(noData);
        params = structuredClone(noParams);
        update();
        loading = true;
    }

    function setChartOptions() {
        let mnCoef = -3.3;
        let mxCOef = 3.3;

        let plotBands = [];
        [{
            color: "rgb(140,81,10)",  //"#FCE724",
            min: mnCoef,
            max: -3.0,
        },
        {
            color: "rgb(216,179,101)",
            min: -3.0,
            max: -2.0
        },
        {
            color: "rgb(246,232,195)",
            min: -2.0,
            max: -1.0
        }
        ,{
            color: "rgb(245,245,245)",
            min: -1.0,
            max: 1.0
        }
        ,{
            color: "rgb(199,234,229)",
            min: 1.0,
            max: 2.0
        }
        ,{
            color: "rgb(90,180,172)",
            min: 2.0,
            max: 3.0
        },{
            color: "rgb(1,102,94)",
            min: 3.0,
            max: mxCOef
        }].forEach(config => {
            plotBands.push(
                {
                    from: config.min*params.lts_sd + params.lts_mean,
                    to: config.max*params.lts_sd + params.lts_mean,
                    color: config.color,
                    thickness: 20,
                    borderRadius: '50%'
                })
        });

        return {
            credits: {
                enabled: false,
            },
            title: {
                text: title(),
                style: {
                    fontSize: "15px",
                },
            },
            subtitle: {
                text: $currentProduct.currentVariable.rtFlag.currentDate.toDateString(),
            },

            chart: {
                type: 'gauge',
                plotBackgroundColor: null,
                plotBackgroundImage: null,
                plotBorderWidth: 0,
                plotShadow: false,
                //height: '80%'
            },

             pane: {
                startAngle: -80,
                endAngle: 79.9,
                background: null,
                center: ['50%', '75%'],
                //size: '110%'
            },

            yAxis: {
                //min: $currentProduct.currentVariable.low_value,
                //max: $currentProduct.currentVariable.max_value,
                min:  mnCoef*params.lts_sd + params.lts_mean,
                max: mxCOef*params.lts_sd + params.lts_mean,
                tickPixelInterval: 72,
                tickPosition: 'inside',
                tickColor: Highcharts.defaultOptions.chart.backgroundColor || '#FFFFFF',
                tickLength: 20,
                tickWidth: 2,
                minorTickInterval: null,
                labels: {
                    distance: 20,
                    style: {
                        fontSize: '14px'
                    }
                },
                lineWidth: 0,
                plotBands: plotBands
            },

            series: [{
                name: '',
                data: diagramData,
                tooltip: {
                    format: 'The average is: {y}',
                },
                dataLabels: {
                    format: 'Average is: {y}',
                    borderWidth: 0,
                    color: (
                        Highcharts.defaultOptions.title &&
                        Highcharts.defaultOptions.title.style &&
                        Highcharts.defaultOptions.title.style.color
                    ) || '#333333',
                    style: {
                        fontSize: '16px'
                    }
                },
                dial: {
                    radius: '80%',
                    backgroundColor: 'gray',
                    baseWidth: 12,
                    baseLength: '0%',
                    rearLength: '0%'
                },
                pivot: {
                    backgroundColor: 'gray',
                    radius: 6
                }
            }],
            legend: {
                enabled: true,
                squareSymbol: true
            },
        };
    }

    export function getNoData() {
        return noData;
    }

    export function title() {
        return "TerraMeter Indicator";
    }

    export function toShow() {
        return $currentProduct.currentVariable.anomaly_info != null;
    }

    function update() {
        let options = setChartOptions();
        chart = new Highcharts.Chart(chartId, options);
        console.log($currentProduct.currentVariable);
    }

    $: polygonId, refreshData();

</script>

<div id={chartId} class:d-none={!shown} />

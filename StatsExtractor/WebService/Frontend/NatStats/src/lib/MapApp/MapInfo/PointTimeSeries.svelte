<script>
    import requests from "../../base/requests";
    import Highcharts from "highcharts";
    import highchartsMore from "highcharts/highcharts-more";
    import {onMount} from "svelte";
    highchartsMore(Highcharts);
    import {
        currentProduct,
        dateEnd,
        dateStart,
        nullId
    } from "../../../store/ProductParameters";

    export let chartId = "pointTimeSeries";
    export let clickedCoordinates = false;
    export let active = true;
    export let mode = "raw";
    let noData = [[], [], []];
    export let diagramData = structuredClone(noData);
    export let loading = true;
    
    let variable = $currentProduct.currentVariable;
    let chart = null;
   
    function refreshData() {
        if (!clickedCoordinates)
            return;

        reset();


        if (!clickedCoordinates || !variable) return;

        chart.showLoading();
        requests
            .getRawTimeSeriesDataForRegion(
                $dateStart.toISOString(),
                $dateEnd.toISOString(),
                variable.id,
                $currentProduct.currentVariable.rtFlag.id,
                clickedCoordinates.obj.coordinate,
                clickedCoordinates.epsg,
            )
            .then((response) => {
                if (mode == "raw") {
                    diagramData = [
                        new Array(response.data.data.length),
                        new Array(response.data.data.length),
                        new Array(response.data.data.length),
                    ];

                    for (let i = 0; i < response.data.data.length; i++) {
                        let row = response.data.data[i];

                        let tm = new Date(
                            Date.parse(row[0] + "+00:00"),
                        ).getTime();

                        diagramData[0][i] = [
                            tm,
                            row[2] - 2 * row[3],
                            row[2] + 2 * row[3],
                        ];
                        diagramData[1][i] = [tm, row[1]];
                        diagramData[2][i] = [tm, row[2]];
                    }
                } else {
                    diagramData = [null, new Array(response.data.data.length), null];

                    for (let i = 0; i < response.data.data.length; i++) {
                        let row = response.data.data[i];
                        let tm = new Date(
                            Date.parse(row[0] + "+00:00"),
                        ).getTime();
                        diagramData[1][i] = [tm, row[1]];
                    }
                }
                update();
                loading = false;

            }).catch(() =>{
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
        if (variable)
            valueRange = variable.valueRanges;
        
        let step =
            (valueRange[valueRange.length - 1] - valueRange[0]) /
            valueRange.length;
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
                    name: "Product value",
                    data: diagramData[1],
                    color: "#0F602C",
                },
                {
                    name: "Long-Term Value",
                    data: diagramData[2],
                    color: "#EB603F",
                    showInLegend: mode == "raw",
                    marker: {
                        enabled: false,
                    },
                    dashStyle: "dot",
                },
            ],
            yAxis: {
                min: valueRange[0] - step,
                max: valueRange[valueRange.length - 1] + step,
                title: {
                    enabled: true,
                    text: "Variable Value",
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
                            Date.parse($currentProduct.currentVariable.rtFlag.currentDate) - 86400 * 4,
                        to: Date.parse($currentProduct.currentVariable.rtFlag.currentDate) + 86400 * 4,
                        id: "pltbnd1",
                    },
                ],
            },
            legend: {
                enabled: true,
            },
        };
    }

    export function getNoData() {
        return noData;
    }

    export function title() {
        return "Location Time Series (" + mode + ")";
    }

    export function toShow() {
        let ret = false;
        if (mode == "raw")
            ret = $currentProduct.currentVariable != null;
        else if (mode == "anomalies")
            ret = $currentProduct.currentVariable.currentAnomaly.variable != null && 
            $currentProduct.currentVariable.rtFlag.id in $currentProduct.currentVariable.currentAnomaly.variable.cog.layers;
        return ret;
    }

    export function update() {       
        variable = $currentProduct.currentVariable;
        if (mode == "anomalies") 
            variable = $currentProduct.currentVariable.currentAnomaly.variable;

        let options = setChartOptions();
        chart = new Highcharts.Chart(chartId, options);
    }

    onMount(() => {
        update();
    });

    $: clickedCoordinates, refreshData();
</script>

<div id={chartId} class:d-none={!active} />

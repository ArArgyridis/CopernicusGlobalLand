<script>
    import axios from "axios";
    import OlMap from "../../../base/OLMap.svelte";
    import options from "../../../base/options";
    import { Fill, Stroke, Style } from "ol/style";
    export let downloadPanelId;
    import { onMount } from "svelte";
    import GeoJSON from "ol/format/GeoJSON";
    import bootstrap from "bootstrap/dist/js/bootstrap.min.js";
    import KML from "ol/format/KML";
    import {Polygon,  MultiPolygon} from 'ol/geom';

    import {
        faDrawPolygon,
        faEraser,
        faGlobe,
        faDownload,
        faUpload,
    } from "@fortawesome/free-solid-svg-icons";
    import Fa from "svelte-fa/src/fa.svelte";
    import { isNumber } from "highcharts";

    export let aoiSet = false;
    export let maxExtentFt = null;
    export let mapProjection = "EPSG:3857";

    let refs = {};
    let aoiMode = null;
    let aoiOLOptions = {
        layer: null,
    };

    let drawStyle = new Style({
        stroke: new Stroke({
            color: "rgba(200, 0, 0, 0.6)",
            width: 3,
        }),
        fill: new Fill({
            color: "rgba(226, 226, 226, 0.3)",
        }),
    });

    let showStyle = new Style({
        stroke: new Stroke({
            color: "rgba(255, 0, 0, 1.0)",
            width: 3,
        }),
        fill: new Fill({
            color: "rgba(226, 226, 226, 0.6)",
        }),
    });

    function drawAOI() {
        eraseAOI();
        aoiMode = "drawAOI";
        aoiOLOptions.draw.setActive(true);
        aoiOLOptions.draw.on("drawend", (evt) => {
            aoiOLOptions.draw.setActive(false);
            evt.feature.set("id", 1);
            aoiSet = true;
        });
    }

    function eraseAOI() {
        aoiMode = "eraseAOI";
        refs.map.clearVectorLayer(aoiOLOptions.layer);
        aoiSet = false;
    }

    function onKMLChange(evt) {
        let file = evt.target.files[0];
        let reader = new FileReader();
        reader.readAsText(file);


        reader.onload = (e) => {
            let features = new KML().readFeatures(e.target.result);
            let newFeatures = [];
            let errorMessage = `The system accepts only: 
            - Polygon/Multipolygon geometries. 
            - A field called "id" having unique integer values (add it before converting your dataset to KML)
            - A max File size of 10 MB\n`;
            errorMessage += "Please update your KML data accordingly :-)";
            let ids = new Set();
            let validFeature = true;
            for (let readerId = 0; readerId < features.length && validFeature; readerId++ ) {
                let ft = features[readerId];
                let ftId = parseInt(ft.get("id"));
                //validate feature                
                validFeature = (ft.getGeometry() instanceof Polygon ||
                    ft.getGeometry() instanceof MultiPolygon) && isNumber(ftId) && Number.isInteger(ftId) 
                    && !ids.has(ftId);

                ft.getGeometry().transform("EPSG:4326", mapProjection);
                ft.setStyle(showStyle);
                ft.set("id",ftId);
                newFeatures.push(ft);
                ids.add(ftId);
            }

            if (!validFeature)
                window.alert(errorMessage);
            else {
                refs.map.addFeaturesToLayer(
                    aoiOLOptions.layer,
                    newFeatures,
                );
                refs.map.fitToLayerExtent(aoiOLOptions.layer);
                aoiSet = true;
            }
        };
    }

    function setToMaxExtent() {
        eraseAOI();
        aoiMode = "maxExtentAOI";
        if (!maxExtentFt)
            axios.get(options.maxAOIBounds3857URL).then((response) => {
                maxExtentFt = new GeoJSON().readFeatures(response.data);
                refs.map.addFeaturesToLayer(aoiOLOptions.layer, maxExtentFt);
            });
        else refs.map.addFeaturesToLayer(aoiOLOptions.layer, maxExtentFt);
        aoiSet = true;
    }

    function uploadAOI() {
        eraseAOI();
        aoiMode = "uploadAOI";
        refs.kmlUpload.value = "";
        refs.kmlUpload.click();
    }

    export function getFeatures() {
        return refs.map.getLayerObject(aoiOLOptions.layer)
                    .getSource()
                    .getFeatures();
    }

    onMount(() => {
        let layerId = refs.map.addBingLayerToMap("aerial", options.bingKey);
        refs.map.setVisibility(layerId, true);
        aoiOLOptions = refs.map.addDrawInteraction({
            type: "Polygon",
            style: drawStyle,
        });

        refs.map.setVisibility(aoiOLOptions.layer, true);
        refs.map.updateLayerStyle(aoiOLOptions.layer, showStyle);
        aoiOLOptions.draw.setActive(false);
        setToMaxExtent();

        //activate tooltips
        document
            .querySelectorAll('button[data-bs-toggle="tooltip"]')
            .forEach((tooltipNode) => {
                new bootstrap.Tooltip(tooltipNode, {
                    animated: "fade",
                    container: document.getElementById(
                        downloadPanelId + "_toolbar",
                    ),
                    delay: { show: 200, hide: 100 },
                    trigger: "hover",
                });
            });
    });
</script>

<div class={$$restProps.class + " achiveDownloaderMap"}>
    <OlMap
        projection={mapProjection}
        bind:this={refs.map}
        class="aoiMap"
    />
    <div class="aoiToolbar" id={downloadPanelId + "_toolbar"}>
        <button
            class="btn btn-secondary aoiToolbarButton"
            data-bs-toggle="tooltip"
            title="Set AOI To Maximum Extent"
            on:click={() => {
                setToMaxExtent();
            }}
        >
            <Fa icon={faGlobe} color="#eaeada" size="1x" />
        </button>

        <button
            class="btn btn-secondary aoiToolbarButton"
            class:active={aoiMode == "drawAOI" && aoiSet == false}
            data-bs-toggle="tooltip"
            data-bs-placement="top"
            title="Draw Custom AOI"
            on:click={() => {
                drawAOI();
            }}
        >
            <Fa icon={faDrawPolygon} color="#eaeada" size="1x" />
        </button>

        <button
            class="btn btn-secondary aoiToolbarButton"
            data-bs-toggle="tooltip"
            data-bs-placement="top"
            title="Clear AOI"
            on:click={() => {
                eraseAOI();
            }}
        >
            <Fa icon={faEraser} color="#eaeada" size="1x" />
        </button>

        <button
            class="btn btn-secondary aoiToolbarButton"
            data-bs-toggle="tooltip"
            data-bs-placement="top"
            title="Upload AOI from KML"
            on:click={() => {
                uploadAOI();
            }}
        >
            <Fa icon={faUpload} color="#eaeada" size="1x" />
            <input
                type="file"
                bind:this={refs.kmlUpload}
                accept=".kml"
                style="display:none"
                on:change|preventDefault|stopPropagation|capture|nonpassive={onKMLChange}
            />
        </button>
    </div>
</div>

<style>
    .achiveDownloaderMap :global(.aoiMap) {
        width: 100%;
        height: 100%;
        position: relative;
    }

    .aoiToolbar {
        position: absolute;
        top: 2%;
        right: 13px;
    }

    .aoiToolbarButton {
        margin-left: 5px;
    }
</style>

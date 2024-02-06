<script>
    import "bootstrap/dist/css/bootstrap.min.css";

    import { currentProduct } from "../../../store/ProductParameters.js";
    import {
        DisplayPolygonValues,
        MapViewOptions,
    } from "../../base/CGLSDataConstructors.js";
    import {
        analysisModes,
        stratifiedOrRawModes,
    } from "../../base/CGLSDataConstructors.js";
    export let bindToId;
    export let propIdx;

    let polygonValuesType = [];
    let variable = null;

    function updateValues() {
        variable = $currentProduct.currentVariable;
        if (
            $currentProduct.currentVariable.mapViewOptions.analysisMode ==
            analysisModes[1]
        )
            variable = $currentProduct.currentVariable.currentAnomaly.variable;

        polygonValuesType = DisplayPolygonValues(variable.valueRanges);
    }

    $: $currentProduct, updateValues();
</script>

<div class="accordion-item">
    <h2 class="accordion-header">
        <button
            class="accordion-button collapsed"
            class:disabledAccordion={!(
                $currentProduct.currentVariable.mapViewOptions.analysisMode == analysisModes[0] && $currentProduct.currentVariable.mapViewOptions.dataView == stratifiedOrRawModes[0]
            )}
            type="button"
            data-bs-toggle="collapse"
            data-bs-target={"#collapse_" + bindToId + "_" + propIdx}
            aria-expanded="false"
            aria-controls={"collapse_" + bindToId + "_" + propIdx}
            disabled={!(
                $currentProduct.currentVariable.mapViewOptions.analysisMode ==analysisModes[0] &&
                $currentProduct.currentVariable.mapViewOptions.dataView == stratifiedOrRawModes[0]
            )}
        >
            <b>Displayed Boundary Statistics:&nbsp;</b>{variable.mapViewOptions.displayPolygonValue.title}
        </button>
    </h2>

    <div
        id={"collapse_" + bindToId + "_" + propIdx}
        class="accordion-collapse collapse"
        data-bs-parent={"#" + bindToId}
    >
        <div class="accordion-body">
            <select
                class="form-select"
                size="5"
                aria-label="size 3 select example"
            >
                {#each polygonValuesType as polyVal, idx}
                    <option
                        on:click={() => {
                            variable.mapViewOptions.displayPolygonValue =
                                polyVal;
                            $currentProduct = $currentProduct; //to trigger reactivity...
                        }}
                        selected={polyVal.id ==
                            variable.mapViewOptions.displayPolygonValue.id}
                        >{polyVal.title}</option
                    >
                {/each}
            </select>
        </div>
    </div>
</div>

<style>
    .accordion-button:not(.collapsed) {
        background-color: rgba(172, 184, 38, 0.3);
    }

    .disabledAccordion {
        background-color: #d3d3d5;
        color: #6d6d6d;
    }
</style>

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
    import "bootstrap/dist/css/bootstrap.min.css";
    import { currentProduct } from "../../../store/ProductParameters.js";
    import { analysisModes } from "../../base/CGLSDataConstructors.js";

    export let bindToId;
    export let propIdx;
</script>

<div class="accordion-item">
    <h2 class="accordion-header">
        <button
            class="accordion-button collapsed"
            class:disabledAccordion={$currentProduct.currentVariable.currentAnomaly.variable == null}
            type="button"
            data-bs-toggle="collapse"
            data-bs-target={"#collapse_" + bindToId + "_" + propIdx}
            aria-expanded="false"
            aria-controls={"collapse_" + bindToId + "_" + propIdx}
            disabled={$currentProduct.currentVariable.currentAnomaly.variable == null}
        >
            <b>Analysis Mode:&nbsp;</b>{$currentProduct.currentVariable.mapViewOptions.analysisMode}
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
                size="4"
                aria-label="size 3 select example"
            >
                {#each analysisModes as analysisMode}
                    <option
                        on:click={() => {
                            $currentProduct.currentVariable.mapViewOptions.analysisMode =
                                analysisMode;
                        }}
                        selected={analysisMode ==
                            $currentProduct.currentVariable.mapViewOptions
                                .analysisMode}>{analysisMode}</option
                    >
                {/each}
            </select>
        </div>
    </div>
</div>

<style>
    .disabledAccordion {
        background-color: #d3d3d5;
        color: #6d6d6d;
    }

    .accordion-button:not(.collapsed) {
        background-color: rgba(172, 184, 38, 0.3);
    }
</style>

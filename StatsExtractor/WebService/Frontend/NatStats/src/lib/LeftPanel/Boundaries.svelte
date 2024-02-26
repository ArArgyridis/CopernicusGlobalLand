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
    import { currentBoundary, boundaries } from "../../store/Boundaries.js";

    export let accordionId = "boundaries";
    export let bindToId = accordionId;
    export let propIdx = 0;


</script>

<div class="row mt-2 text-center">
    <h5>Boundaries</h5>
</div>
<div class="accordion accordion-flush overflow-auto mb-2" id={accordionId}>
    <div class="accordion-item">
        <h2 class="accordion-header">
            <button
                class="accordion-button"
                type="button"
                data-bs-toggle="collapse"
                data-bs-target={"#collapse_" + bindToId + "_" + propIdx}
                aria-expanded="true"
                aria-controls={"collapse_" + bindToId + "_" + propIdx}
            >
                <b>Active Boundary:&nbsp;</b>{$currentBoundary.description}
            </button>
        </h2>
        <div
            id={"collapse_" + bindToId + "_" + propIdx}
            class="accordion-collapse collapse show overflow-auto"
            data-bs-parent={"#" + bindToId}
        >
            <div class="accordion-body">
                <select
                    class="form-select"
                    size="4"
                    aria-label="size 3"
                >
                    {#each Object.keys($boundaries) as stratId, productIdx}
                        <option
                            on:click={() => {
                                console.log("hereeee");
                                $currentBoundary = $boundaries[stratId];
                            }}
                            selected={$currentBoundary.id ==
                                $boundaries[stratId].id}
                            >{$boundaries[stratId].description}</option
                        >
                    {/each}
                </select>
            </div>
        </div>
    </div>
</div>

<style>
    .accordion-button:not(.collapsed) {
        background-color: rgba(172, 184, 38, 0.3);
    }
</style>

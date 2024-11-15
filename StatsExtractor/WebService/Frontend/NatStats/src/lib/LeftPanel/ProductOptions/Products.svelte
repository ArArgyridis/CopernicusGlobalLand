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
    import {
        currentCategory,
        currentProduct,
        products,
    } from "../../../store/ProductParameters.js";

    export let bindToId;
    export let propIdx;

    let refs = {};
    refs.dataInitializer={}

    let prods = $products[$currentCategory.id];

    let activeCategoryProduct = {}
    activeCategoryProduct[$currentCategory.id] = $currentProduct;

    function updateLocals() {
        prods = $products[$currentCategory.id];
        activeCategoryProduct[$currentCategory.id] = $currentProduct;
    }

    $: if($products && prods != $products[$currentCategory.id]) updateLocals();    

</script>

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
            
            <b>Product:&nbsp;</b>{activeCategoryProduct[$currentCategory.id].description}
           
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
                aria-label="size 3 select example"
            >
                {#each prods as prd, productIdx}
                    <option
                        on:click={() => {
                            $currentProduct = prd;
                            activeCategoryProduct[$currentCategory.id] = prd;
                        }}
                        selected={activeCategoryProduct[$currentCategory.id].id == prd.id}
                        >{prd.description}</option
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
</style>

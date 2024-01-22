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
    import requests from "../../base/requests.js";
    import {
        currentCategory,
        currentProduct,
        dateEnd,
        dateStart,
        nullId,
        products,
    } from "../../../store/ProductParameters.js";
    import {
        analysisModes,
        Product,
        ProductFile,
    } from "../../base/CGLSDataConstructors.js";

    export let bindToId;
    export let propIdx;

    let dtStart = null;
    let dtEnd = null;
    let prods = $products[$currentCategory.id];

    let activeCategoryProduct = {}
    activeCategoryProduct[$currentCategory.id] = prods[0];

    function updateProductFiles() {
        let variables = [
            $currentProduct.currentVariable,
            $currentProduct.currentVariable.currentAnomaly.variable,
        ];

        variables.forEach((variable) => {
            if (variable == null) return;

            if (Object.keys(variable.cog.layers).length > 0)
                //data have been fetched
                return;

            requests
                .productFiles(
                    variable.id,
                    $dateStart.toISOString(),
                    $dateEnd.toISOString(),
                )
                .then((response) => {
                    if (response.data.data == null) return;

                    Object.keys(response.data.data).forEach((rt) => {
                        variable.cog.layers[rt] = {};
                        Object.keys(response.data.data[rt]).forEach((date) => {
                            variable.cog.layers[rt][date] = new ProductFile(
                                response.data.data[rt][date],
                            );
                        });
                    });

                    let date = $currentProduct.currentDate.toISOString().substr(0,19);
                    //setting current Variable and current anomaly cog layers
                    variable.cog.current = variable.cog.layers[$currentProduct.rtFlag.id][date];
                });
        });
    }

    function updateProducts() {
        // no data have been fetched
        if ($currentCategory.id == $nullId) return;

        if (
            dtStart == $dateStart.toISOString() &&
            dtEnd == $dateEnd.toISOString() &&
            $currentCategory.id in $products
        ) {
            prods = $products[$currentCategory.id];
            if (activeCategoryProduct[$currentCategory.id]) //use last
                $currentProduct = activeCategoryProduct[$currentCategory.id];
            else {//use first and cache it
                $currentProduct = $products[$currentCategory.id][0];
                activeCategoryProduct[$currentCategory.id] = $currentProduct;
            }
            return 0;
        }

        dtStart = $dateStart.toISOString();
        dtEnd = $dateEnd.toISOString();
        requests
            .fetchProductInfo(dtStart, dtEnd, $currentCategory.id)
            .then((response) => {
                if (response.data.data != null) {
                    response.data.data.forEach((prd) => {
                        prd = Product(prd, dtStart, dtEnd);
                    });
                    $products[$currentCategory.id] = response.data.data;
                } else $products[$currentCategory.id] = [Product(null, dtStart, dtEnd)];
                prods = $products[$currentCategory.id];
                $currentProduct = $products[$currentCategory.id][0];
                activeCategoryProduct[$currentCategory.id] = $products[$currentCategory.id][0];
            });        
    }

    $: $currentCategory, $dateStart, $dateEnd, updateProducts();
    $: $currentProduct, updateProductFiles();
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
            <b>Product:&nbsp;</b>{$currentProduct.description}
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
                        selected={$currentProduct.id == prd.id}
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

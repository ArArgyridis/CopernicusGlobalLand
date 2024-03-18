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
    import bootstrap from "bootstrap/dist/js/bootstrap.min.js";
    import {
        categories,
        currentCategory,
        currentProduct,
        dateEnd,
        dateStart,
        products,
        showProductDownloadPanel,
    } from "../../../../store/ProductParameters.js";
    import { onMount } from "svelte";
    import {
        Product,
        ConsolidationPeriods,
    } from "../../../base/CGLSDataConstructors.js";
    import requests from "../../../base/requests.js";
    import { DateInput } from "date-picker-svelte";
    import { faDownload, faTrash } from "@fortawesome/free-solid-svg-icons";
    import "bootstrap/dist/css/bootstrap.min.css";
    import Fa from "svelte-fa/src/fa.svelte";
    import DownloadTable from "./DownloadTable.svelte";
    import ArchiveDownloaderMap from "./ArchiveDownloaderMap.svelte";
    import GeoJSON from "ol/format/GeoJSON";

    export let downloadPanelId = "downloadRoot";

    let emailRegex =
        /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    let validEmail = false;
    let submitVerification = false;
    let validated = false;
    let aoiSet = false;

    const outputValuesOptions = [
        {id: 0, description: "Polygon(s) Statistics (.csv)"},
        {id: 1, description: "AOI (Bounding Box) Raster Data (.tif)"},
        {id: 2, description: "Polygon(s) Statistics and AOI Raster Data"},
    ];

    const statisticsGetModeOptions = [
        { id: 0, description: "Raw Data" },
        { id: 1, description: "Anomalies" },
        { id: 2, description: "Raw Data and Anomalies" },
    ];

    let downloadOptions = {};
    let auxilaryDownloadOptions = {};
    let downloadModal = null;
    let refs = {};
    refs["submitVerification"] = { checked: false };
    let dnCategories = null;
    let dnProducts = null;
    let dnDateEnd = null;
    let dnDateStart = null;
    
    let selectedCategory = null;
    let selectedProduct = null;
    let outputValue = outputValuesOptions[0];
    let statisticsGetMode = statisticsGetModeOptions[0];
    let myDnRTs = null; 
    let selectedRT = null;

    let dateFormat = "yyyy-MM-dd";

    function appendToDownloadList() {
        let key =
            selectedProduct.currentVariable.id.toString() +
            "_" +
            selectedRT.id.toString();

        if (key in downloadOptions) return;

        downloadOptions[key] = {
            dateStart: dnDateStart,
            dateEnd: dnDateEnd,
            dataFlag: statisticsGetMode.id,
            rtFlag: selectedRT.id,
            variable: selectedProduct.currentVariable.id,
            outputValue: outputValue.id
        };

        auxilaryDownloadOptions[key] = {
            rt: selectedRT.description,
            variable: selectedProduct.currentVariable.description,
        };
    }

    function dataVerification() {
        if (!refs.submitVerification) return;
        submitVerification = false;
        if (validEmail && Object.keys(downloadOptions).length > 0 && aoiSet)
            submitVerification = true;
        else {
            refs.submitVerification.checked = false;
            validated = false;
        }
    }

    function displayDownloadModal() {
        if(!downloadModal) {
            let modalEl = document.getElementById(downloadPanelId);
            downloadModal = new bootstrap.Modal(modalEl);
            modalEl.addEventListener("hidden.bs.modal", reset);
        }

        //initializing variables
        init();
        downloadModal.show();
    }

    function init() {
        dnCategories = structuredClone($categories);
        dnProducts = structuredClone($products);
        dnDateEnd = structuredClone($dateEnd);
        dnDateStart = structuredClone($dateStart);

        selectedCategory = structuredClone($currentCategory);
        selectedProduct = structuredClone($currentProduct);
        statisticsGetMode = statisticsGetModeOptions[0];
        updateRT();
    }

    function reset() {
        $showProductDownloadPanel = false;
    }

    function submitOrder() {
        let aoi = null;
        if (aoiSet) {
            let fmt = new GeoJSON();
            aoi = fmt.writeFeatures(refs.map.getFeatures());
        }

        let optionsObj =  {
			email: refs.emailForm.value,
			aoi:aoi,
			request_data: downloadOptions
		};
		requests.insertOrder(optionsObj).then((response) => {
			window.alert(response.data.data.message);
            if(response.data.data.result == "OK") {
                downloadOptions = {};
                auxilaryDownloadOptions = {};
                dataVerification();
                validated = false;
            }
		});
    }

    function updateCategoryProducts(cat) {
        //checking if products for this category are fetches
        selectedCategory = cat;
        if (dnProducts[selectedCategory.id].length == 0) {
            let dtStart = dnDateStart.toISOString();
            let dtEnd = dnDateEnd.toISOString();
            requests
                .fetchProductInfo(dtStart, dtEnd, selectedCategory.id)
                .then((response) => {
                    if (response.data.data != null) {
                        response.data.data.forEach((prd) => {
                            prd = new Product(prd);
                        });
                        dnProducts[selectedCategory.id] = response.data.data;
                    } else
                        dnProducts[selectedCategory.id] = [
                            new Product(null),
                        ];
                    selectedProduct = dnProducts[selectedCategory.id][0];
                });
        } else selectedProduct = dnProducts[selectedCategory.id][0];
    }

    function updateRT() {
        myDnRTs = selectedProduct.currentVariable.rts;
        selectedRT = myDnRTs[Object.keys(myDnRTs)[0]];
    }

    function validateEmail() {
        validEmail = false;
        if (refs.emailForm != null) {
            let res = refs.emailForm.value.match(emailRegex);
            validEmail = res != null && res.length > 0;
        }
    }

    onMount(() => {
        init();
        //setting up modal
    });

    //reactivity
    $: if ($showProductDownloadPanel && $products) displayDownloadModal();
    $: if(selectedProduct && selectedProduct.currentVariable) updateRT();
    $: validEmail, downloadOptions, aoiSet, dataVerification();
</script>


{#if selectedRT != null} 
<div
    class="modal fade"
    id={downloadPanelId}
    tabindex="-1"
    aria-labelledby={downloadPanelId + "label"}
    aria-hidden="true"
>
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="exampleModalLabel">
                    Products Downloader
                </h5>
                <button
                    type="button"
                    class="btn-close"
                    data-bs-dismiss="modal"
                    aria-label="Close"
                ></button>
            </div>
            <div class="modal-body">
                <div class="container">                    
                    <div class="row">
                        <div class="col-sm-9 myMap">
                            <ArchiveDownloaderMap
                                {downloadPanelId}
                                bind:aoiSet
                                bind:this={refs.map}
                                class="map"
                            />
                        </div>
                        <div class="col-sm-3">
                            <div class="container">
                                <div class="row">
                                    <div class="col text-center">
                                        <h6>Select Date Range</h6>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class = "col text-center">
                                        <span class="align-middle">Date Start</span>
                                    </div>
                                    <div class = "col text-center">
                                        <span class="align-middle">Date End</span>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class = "col text-center">
                                        <DateInput
                                            bind:value={dnDateStart}
                                            format={dateFormat}
                                            browseWithoutSelecting={true}
                                            closeOnSelection={true}
                                        />
                                    </div>
                                    <div class = "col text-center">
                                        <DateInput
                                            bind:value={dnDateEnd}
                                            format={dateFormat}
                                            browseWithoutSelecting={true}
                                            closeOnSelection={true}
                                        />
                                    </div>
                                </div>

                                <div class="row mt-2">
                                    <div class="col text-center">
                                        <h6>Select Product Data to Download</h6>
                                    </div>
                                </div>

                                <div class="row mt-1">                                     
                                    {#each statisticsGetModeOptions as mode, idx}
                                        <div class="form-check">
                                           
                                            <input
                                                class="form-check-input"
                                                type="radio"
                                                name="rawDataFetch"
                                                checked={statisticsGetMode.id ==
                                                    mode.id}
                                                on:click={() => {
                                                    statisticsGetMode = mode;
                                                }}
                                            />                                         
                                            <label
                                                class="form-check-label"
                                                for="rawDataFetch"
                                                >{mode.description}</label
                                            >
                                        </div>
                                    {/each}
                                </div>

                                <div class="row mt-2">
                                    <div class="col text-center">
                                        <h6>Select Output</h6>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col">
                                        {#each outputValuesOptions as mode, idx}
                                        <div class="form-check">
                                            <input
                                                class="form-check-input"
                                                type="radio"
                                                name="outputData"
                                                checked={outputValue.id ==
                                                    mode.id}
                                                on:click={() => {
                                                    outputValue = mode;
                                                }}
                                            />                                         
                                            <label
                                                class="form-check-label"
                                                for="outputData"
                                                >{mode.description}</label
                                            >
                                        </div>
                                    {/each}
                                    </div>
                                </div>

                                <div class="row mt-2">
                                    <div
                                        class="col-2 d-flex flex-column justify-content-center"
                                    >
                                        Email(*):
                                    </div>
                                    
                                    <div class="col">
                                        <input
                                            type="email"
                                            class="form-control"
                                            aria-describedby="emailHelp"
                                            placeholder="example@mail.com"
                                            bind:this={refs.emailForm}
                                            on:keyup={() => {
                                                validateEmail();
                                            }}
                                        />
                                    </div>
                                    
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row mt-2">
                        <div class="col-2 d-flex flex-column align-items-center justify-content-center"><h6>1. Select Category</h6></div>
                        <div class="col-5 d-flex flex-column align-items-center justify-content-center"><h6>2. Select Product</h6></div>
                        <div class="col-2 d-flex flex-column align-items-center justify-content-center"><h6>3. Select Consolidation Period</h6></div>
                        <div class="col-3 d-flex flex-column align-items-center justify-content-center"><h6>4. Select Product Variable</h6></div>

                    </div>
                    <div class="row mt-2">
                        <div class="col-2">
                            <!--categories-->
                            <select
                                class="form-select"
                                size="4"
                                aria-label="size 3 select example"
                            >
                                {#each dnCategories as cat, idx}
                                    <option
                                        value={cat.id}
                                        selected={cat.id == selectedCategory.id}
                                        on:click={() => {
                                            updateCategoryProducts(cat);
                                        }}>{cat.title}</option
                                    >
                                {/each}
 
                                
                            </select>
                        </div>
                        <div class="col-5">
                            <!--products-->
                            <select
                                class="form-select"
                                size="4"
                                aria-label="size 3 select example">
                                
                                {#each Object.keys(dnProducts[selectedCategory.id]) as prdId, idx}
                                    <option
                                        value={dnProducts[selectedCategory.id][
                                            prdId
                                        ].id}
                                        selected={dnProducts[
                                            selectedCategory.id
                                        ][prdId].id == selectedProduct.id}
                                        title={dnProducts[selectedCategory.id][
                                            prdId
                                        ].description}
                                        on:click={() => {
                                            selectedProduct =
                                                dnProducts[selectedCategory.id][
                                                    prdId
                                                ];
                                        }}
                                        >{dnProducts[selectedCategory.id][prdId]
                                            .description}</option
                                    >
                                {/each}                                
                            </select>
                        </div>
                        <div class="col-2">
                            <!--RTs-->
                            <select
                                class="form-select"
                                size="4"
                                aria-label="size 3 select example"
                            >
                                {#each Object.keys(myDnRTs) as rtId, idx}
                                    <option
                                        value={myDnRTs[rtId].id}
                                        selected={myDnRTs[rtId].id == selectedRT.id}
                                        title={myDnRTs[rtId].description}
                                        on:click={() => {
                                            selectedRT = myDnRTs[rtId];
                                        }}>{myDnRTs[rtId].description}</option
                                    >
                                {/each}
                            </select>
                        </div>
                        <div class="col-sm-3">
                            <!--Variables-->
                            <select
                                class="form-select"
                                size="4"
                                aria-label="size 3 select example"
                            >                           
                                {#each selectedProduct.variables as variable, idx}
                                    <option
                                        value={variable.id}
                                        selected={variable.id ==
                                            selectedProduct.currentVariable.id}
                                        title={variable.description}
                                        on:click={() => {
                                            selectedProduct.currentVariable =
                                                variable;
                                        }}>{variable.description}</option
                                    >
                                {/each}
                            </select>
                        </div>
                    </div>
                    <div class="row mt-2">
                        <div class="col d-flex justify-content-center">
                            <button
                                class="btn btn-secondary"
                                on:click={() => {
                                    appendToDownloadList();
                                }}
                                >Add to Download List
                                <Fa
                                    icon={faDownload}
                                    color="#eaeada"
                                    size="1x"
                                /></button
                            >
                        </div>
                    </div>
                    <div class="row mt-2 downloadTable">
                        <DownloadTable
                            class="table-responsive"
                            bind:downloadOptions
                            bind:auxilaryDownloadOptions
                            {statisticsGetModeOptions}
                            {outputValuesOptions}
                        />
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <div class="container">
                    <div class="row">
                        <div
                            class="col-9 d-flex align-items-end flex-column justify-content-center"
                        >
                            <label class="form-check-label">
                                <input
                                    class="form-check-input"
                                    type="checkbox"
                                    bind:value={validated}
                                    disabled={!submitVerification}
                                    bind:this={refs.submitVerification}
                                />
                                I verify that all provided parameters are correct
                            </label>
                        </div>
                        <div class="col d-flex justify-content-end">
                            <button
                                class="btn btn-primary"
                                on:click={() => {
                                    submitOrder();
                                }}
                                disabled={!validated || !aoiSet}>Submit</button
                            >                            
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
{/if}
<style>
    .myMap :global(.map) {
        height: 100%;
        width: 100%;
        position: relative;
    }
    .modal-dialog {
        width: 95%;
        max-width: 95%;
    }

    .modal-body {
        height: 80%;
    }
    .container {
        margin-left: 0px;
        margin-right: 0px;
        max-width: 100%;
        max-height: 100%;
    }
    .downloadTable :global(.table-responsive) {
        max-height: 30vh;
    }
</style>

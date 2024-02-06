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
    import "bootstrap/dist/js/bootstrap.min.js";  
    import DataDownload from "./DataDownload/DataDownload.svelte";

    import { DateInput } from "date-picker-svelte";
    import utils from "../base/utils.js";
    import {
        currentProduct,
        dateEnd,
        dateStart,
    } from "../../store/ProductParameters.js";

    let dateFormat = "yyyy-MM-dd";
    let displayDates;
    let activeProduct;

    function setCurrentDate(idx) {
        $currentProduct.currentVariable.rtFlag.currentDate = utils.dateFromUTCDateString(displayDates[idx]);
    }

    function updateDates() {
        displayDates = $currentProduct.currentVariable.rtFlag.dates;
    }

    $: if ($currentProduct != null) activeProduct = $currentProduct;
    $: if($currentProduct != null && displayDates != $currentProduct.currentVariable.rtFlag.dates) updateDates();
</script>




<div class="row align-items-center text-center">
    <div class="col">
        <h5>Time Range for Timeseries Analysis</h5>
    </div>
</div>
<div class="row px-1 d-flex align-items-center text-center">
    <div class="col-sm-3">From Date</div>
    <div class="col-sm-3">To Date</div>
    <div class="col-sm-3">Displayed</div>
    <div class="col-sm-3">Download</div>
</div>
<div class="row px-1 d-flex align-items-center text-center">
    <div class="col-sm-3">
        <DateInput
            bind:value={$dateStart}
            format={dateFormat}
            browseWithoutSelecting={true}
            closeOnSelection={true}
        />
    </div>
    <div class="col-sm-3">
        <DateInput
            bind:value={$dateEnd}
            format={dateFormat}
            browseWithoutSelecting={true}
            closeOnSelection={true}
        />
    </div>
    <div class="col-sm-3">
        <div class="dropdown">
            <button
                class="btn btn-secondary btn-block dropdown-toggle"
                id="availableDates"
                type="button"
                data-bs-toggle="dropdown"
                aria-expanded="false"
                >{utils
                    .localDateAsUTCString(activeProduct.currentVariable.rtFlag.currentDate)
                    .substring(0, 10)}</button>
            <ul
                class="dropdown-menu scrollable"
                aria-labelledby="availableDates"
            >
                {#each displayDates as date, idx}
                    <li>
                        <button
                            class="dropdown-item"
                            on:click={() => setCurrentDate(idx)}
                            >{date.substring(0, 10)}
                        </button>
                    </li>
                {/each}
            </ul>
        </div>
    </div>
    <div class="col-sm-3"><DataDownload /></div>
</div>

<style>
    :root {
        --date-picker-background: #6d757d;
        --date-picker-foreground: #f2f2f2;
        --date-picker-selected-background: #255cb1;
        --date-input-width: 100px;
        border-top-left-radius: 20px;
    }

    .scrollable {
        max-height: 30vh;
        overflow-y: scroll;
    }

</style>

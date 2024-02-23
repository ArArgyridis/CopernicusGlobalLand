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
  import { onMount } from "svelte";
  import LeftPanel from "./lib/LeftPanel/LeftPanel.svelte";
  import MapApp from "./lib/MapApp/MapApp.svelte";
  import Legend from "./lib/base/Legend.svelte";
  import ArchiveDownloader from "./lib/LeftPanel/DataDownload/ArchiveDownloader/ArchiveDownloader.svelte";
  import {currentProduct} from "./store/ProductParameters.js";
  import {currentBoundary} from "./store/Boundaries.js";
  import DataInitializer from "./lib/base/DataInitializer.svelte";
  
  let finishedDataLoading = false;
  let refs = {};

  


</script>

<main>
  <DataInitializer bind:finishedLoading={finishedDataLoading} />
  {#if finishedDataLoading}
  <div class="container-fluid myApp">
    <div class="row position-relative">
      <div class="px-0 position-absolute"><MapApp /></div>
      <LeftPanel class="leftPanel" shown={true} />
      <ArchiveDownloader />
      <Legend class="legend hide transition is-open position-absolute" bind:this={refs.legend} analysisMode = {$currentProduct.currentVariable.mapViewOptions.analysisMode}/>
      <!--<img class="logo" src="assets/copernicus_land_monitoring.png" alt="Copernicus GLMS"/>-->

    </div>
  </div>
  {/if}
</main>

<style>
  @media (max-width: 900px) {
    .myApp :global(.leftPanel) {
      width: 100%;
      z-index: 1;
    }
    .myApp :global(.legend) {
        width: 500px;
        bottom: 280px;
        z-index: 1;
    }

    .logo {
        position:absolute;
        bottom:10px;
        width:100%;
    }
  }

  @media (min-width: 900px) {
    .myApp :global(.leftPanel) {
      width: 600px;
    }
    .myApp :global(.legend) {
        width: 500px;
        margin: auto;
        bottom: 10px;
        right: 300px;
        z-index: 1;
    }
    .logo {
        position:absolute;
        bottom:10px;
        right:5px;
        width:290px;
    }
  }


</style>

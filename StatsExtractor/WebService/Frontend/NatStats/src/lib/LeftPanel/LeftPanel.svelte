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
    import { faBars } from "@fortawesome/free-solid-svg-icons";
    import "bootstrap/dist/css/bootstrap.min.css";
    import Fa from "svelte-fa/src/fa.svelte";
    import DateRangePicker from "./DateRangePicker.svelte";
    import VariableDisplayOptions from "./VariableDisplayOptions/VariableDisplayOptions.svelte";
    import Boundaries from "./Boundaries.svelte";
    import Header from "./Header.svelte";
    import ProductCategories from "./ProductCategories.svelte";
    import ProductConfiguration from "./ProductOptions/ProductConfiguration.svelte";

    export let shown = true;
</script>

<div
    class={$$restProps.class + " scrollable px-0 transition hide"}
    class:is-open={shown}
>
    <Header />
    <div class="panelBody">
        <ProductCategories />
        <DateRangePicker />
        <Boundaries accordionId="boundaries" />
        <ProductConfiguration />
        <VariableDisplayOptions />
    </div>
</div>
<div class="col">
    <button
        class="btn btn-sm transition hide"
        class:is-open={shown}
        on:click={() => {
            shown = !shown;
        }}><Fa icon={faBars} color="#eaeada" size="3x" /></button
    >
</div>


<style>
    @media (max-width: 900px) {
        .hide {
            transform: translateX(-100%);
        }
    }

    @media (min-width: 900px) {
        .hide {
            transform: translateX(-600px);
        }
    }

    .scrollable {
        height: 100vh;
        overflow-y: auto;
        overflow-x: hidden;
    }

    .transition {
        transition: transform ease-out 0.6s;
    }

    .panelBody {
        background-color: rgba(234, 234, 218, 0.8);
    }

    .hide.is-open {
        transform: translateX(0%);
    }

    .hide.is-open {
        transform: translateX(0px);
    }
    
</style>

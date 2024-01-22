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
    import requests from "../base/requests.js";
    import {
        categories,
        currentCategory,
        dateEnd,
        dateStart,
        products
    } from "../../store/ProductParameters.js";
    import {Product} from "../../lib/base/CGLSDataConstructors.js";

    function setCurentCategory(id) {
        $currentCategory.active = false;
        $categories[id].active = true;
        $currentCategory = $categories[id];
    }

    onMount(() => {
        requests.categories().then((response) => {
            response.data.data.forEach((category) => {
                if (category.active) $currentCategory = category;
                $products[category.id] = [Product(null, $dateStart, $dateEnd)];
            });
            $categories = response.data.data;
        });
    });
</script>

<ul class="nav nav-tabs text-muted text-center">
    {#each $categories as category, idx}
        <li class="nav-item">
            <a
                class="nav-link"
                class:active={category.active}
                aria-current="page"
                href={"#" + category.id}
                on:click={() => {
                    setCurentCategory(idx);
                }}>{category.title}</a
            >
        </li>
    {/each}
</ul>

<style>
    .nav-link {
        color: #888888;
    }
</style>

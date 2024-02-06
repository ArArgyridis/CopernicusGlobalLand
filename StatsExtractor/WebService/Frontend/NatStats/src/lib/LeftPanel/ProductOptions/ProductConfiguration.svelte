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
    import Products from "./Products.svelte";
    import ProductVariables from "./ProductVariables.svelte";
    import ConsolidationPeriod from "./ConsolidationPeriod.svelte";
    let accordionId = "productOptions";
</script>

<div class="mt-2 row d-flex align-items-center text-center">
    <h5>Product Configuration</h5>
    <div class="accordion accordion-flush overflow-auto mb-2" id={accordionId}>
          
        <Products bindToId={accordionId} propIdx="0" />     
        <ProductVariables bindToId={accordionId} propIdx="1" />
        <ConsolidationPeriod bindToId={accordionId} propIdx="2" />
    </div>
</div>

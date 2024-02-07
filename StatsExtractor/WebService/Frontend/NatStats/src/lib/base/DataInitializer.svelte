<script>
    import requests from "./requests.js";
    import {categories, currentCategory, currentProduct, dateEnd, dateStart, products} from "../../store/ProductParameters.js";
    import {currentBoundary, boundaries} from "../../store/Boundaries.js";
    import {Boundary, Product, ProductFile } from "./CGLSDataConstructors.js";
    import {onMount} from "svelte";
    import AnalysisMode from "../LeftPanel/VariableDisplayOptions/AnalysisMode.svelte";

    export let finishedLoading;
    let countCogDownloads = 0;
    let fetchedProductData = new Set();

    let dtStart = $dateStart;
    let dtEnd = $dateEnd;

    function fetchCategories() {
        requests.categories().then((response) => {
            response.data.data.forEach((category) => {
                if (category.active) $currentCategory = category;
                $products[category.id] = [];
            });
            $categories = response.data.data;
        });
    }

    function fetchBoundaries() {
        console.log("fetching boundaries");
        requests.fetchBoundaryInfo().then((response) => {
            let keys = Object.keys(response.data.data);
            keys.sort();

            keys.forEach((stratificationId) => {
                response.data.data[stratificationId] = new Boundary(
                    response.data.data[stratificationId],
                );
            });
            $boundaries = response.data.data;
            $currentBoundary = $boundaries[keys[0]];
        });
    }

    function fetchProducts() {
        console.log("getting products");
        fetchedProductData = new Set();
        dtStart = $dateStart;
        dtEnd = $dateEnd;

        requests.fetchProductInfo($dateStart.toISOString(), $dateEnd.toISOString(), $currentCategory.id)
            .then((response) => {
                if (response.data.data != null) {
                    let tmpProducts = new Array(response.data.data.length);
                    for (let prdId =0; prdId < response.data.data.length; prdId++) 
                        tmpProducts[prdId] = new Product(response.data.data[prdId]);
                 
                    $products[$currentCategory.id] = tmpProducts;
                }
                $currentProduct = $products[$currentCategory.id][0];
            });   
    }

    function updateCogInfo() {
        let variables = [
            $currentProduct.currentVariable,
            $currentProduct.currentVariable.currentAnomaly.variable,
        ];
        console.log("fetching cog info for: ", $currentProduct.description);
        fetchedProductData.add($currentProduct.id);

        variables.forEach((variable) => {
            if (variable == null) return;

            if (Object.keys(variable.cog.layers).length > 0)
                //data have been fetched
                return;

            requests.productFiles(
                    variable.id,
                    dtStart.toISOString(),
                    dtEnd.toISOString(),
                ).then((response) => {
                    countCogDownloads += 1;
                    if (response.data.data == null) return;

                    Object.keys(response.data.data).forEach((rt) => {
                        variable.cog.layers[rt] = {};
                        Object.keys(response.data.data[rt]).forEach((date) => {
                            variable.cog.layers[rt][date] = new ProductFile(
                                response.data.data[rt][date],
                            );
                        });
                    });

                    let date = $currentProduct.currentVariable.rtFlag.currentDate.toISOString().substr(0,19);
                    //setting current Variable and current anomaly cog layers
                    if($currentProduct.currentVariable.rtFlag.id in variable.cog.layers) {
                        variable.cog.current = variable.cog.layers[$currentProduct.currentVariable.rtFlag.id][date];
                        $currentProduct = $currentProduct; //enforce reactivity
                    }
                });
        });
    }
    $: if($currentCategory == null) fetchCategories();
    $: if($currentCategory != null && ($currentProduct == null || dtStart != $dateStart || dtEnd != $dateEnd) ) fetchProducts();
    $: if($currentProduct != null && !(fetchedProductData.has($currentProduct.id)) ) updateCogInfo();
    $: if($currentBoundary == null) fetchBoundaries();
    $: if(countCogDownloads >=2) finishedLoading = true;

</script>

<div></div>
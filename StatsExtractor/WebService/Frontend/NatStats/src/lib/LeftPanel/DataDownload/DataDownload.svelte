<script>
    import "bootstrap/dist/css/bootstrap.min.css";
    import Fa from "svelte-fa/src/fa.svelte";
    import { faDownload } from "@fortawesome/free-solid-svg-icons";
    import { currentProduct, showProductDownloadPanel } from "../../../store/ProductParameters";
    import { analysisModes } from "../../base/CGLSDataConstructors";


    let downloadFile = null;
    function getCurrentCog() {
        let variable = $currentProduct.currentVariable;

        if (
            $currentProduct.currentVariable.mapViewOptions.analysisMode ==
            analysisModes[1]
        )
            variable = $currentProduct.currentVariable.currentAnomaly.variable;

        downloadFile = variable.cog.current.raw;
    }
</script>

<div class="dropdown show">
    <button
        class="btn btn-secondary dropdown-toggle"
        data-bs-toggle="dropdown"
        data-toggle="dropdown"
        aria-haspopup="true"
        aria-expanded="true"
        ><Fa
            icon={faDownload}
            color="#eaeada"
            size="1x"
            id="downloadMenuButton"
        /></button
    >
    <div class="dropdown-menu" aria-labelledby="downloadMenuButton">
        <a
            class="dropdown-item"
            href={downloadFile}
            on:click={() => {
                getCurrentCog();
            }}
            type="button">Download Current Data</a
        >
        <button
            class="dropdown-item"
            on:click={() => {
                $showProductDownloadPanel = true;
            }}>Retrieve from Archive...</button
        >
    </div>
</div>

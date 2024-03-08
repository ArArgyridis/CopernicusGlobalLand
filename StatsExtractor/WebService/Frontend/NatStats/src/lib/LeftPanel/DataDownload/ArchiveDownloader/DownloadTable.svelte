<script>
    import "bootstrap/dist/css/bootstrap.min.css";
    export let downloadOptions;
    export let auxilaryDownloadOptions;
    export let statisticsGetModeOptions;
    export let outputValuesOptions;
    import Fa from "svelte-fa/src/fa.svelte";
    import { faTrash } from "@fortawesome/free-solid-svg-icons";

    function removeFromDownloadList(key) {
        delete downloadOptions[key];
        delete auxilaryDownloadOptions[key];
        downloadOptions = downloadOptions;
        auxilaryDownloadOptions = auxilaryDownloadOptions;
    }

    $: downloadOptions, console.log(outputValuesOptions);
</script>

<div class={$$restProps.class || ""}>
    <table class="table table-striped">
        <thead>
            <tr>
                <th scope="col">Date Start</th>
                <th scope="col">Date End</th>
                <th scope="col">Variable</th>
                <th scope="col">RT Flag</th>
                <th scope="col">Download Data</th>
                <th scope="col">Output Type</th>
                <th scope="col">Delete</th>
            </tr>
        </thead>
        {#each Object.keys(downloadOptions) as key, idx}
            <tr>
                <td>{downloadOptions[key].dateStart.toDateString()}</td>
                <td>{downloadOptions[key].dateEnd.toDateString()}</td>
                <td>{auxilaryDownloadOptions[key].variable}</td>
                <td>{auxilaryDownloadOptions[key].rt}</td>
                <td
                    >{statisticsGetModeOptions[downloadOptions[key].dataFlag]
                        .description}</td
                >
                <td>
                    {outputValuesOptions[downloadOptions[key].outputValue].description}
                </td>
                <td
                    ><div>
                        <button
                            class="btn btn-danger"
                            on:click={() => {
                                removeFromDownloadList(key);
                            }}
                        >
                            <Fa
                                icon={faTrash}
                                color="#eaeada"
                                size="1x"
                            /></button
                        >
                    </div></td
                >
            </tr>
        {/each}
    </table>
</div>

#include <cpl_conv.h>
#include <format>
#include <iostream>
#include <rapidjson/document.h>
#include <unistd.h>

#include "Crop.hxx"
#include "ProductOrderProcessor.h"

void ProductOrderProcessor::processFile(std::filesystem::path inRelFile, std::filesystem::path &orderPath, AOINfo &maskInfo){
    std::filesystem::path inFile  = config->filesystem.imageryPath/inRelFile;
    GDALDatasetUniquePtr inDataset =  GDALDatasetUniquePtr(GDALDataset::FromHandle(GDALOpen(inFile.c_str(), GA_ReadOnly)));
    char **meta = inDataset->GetMetadata("SUBDATASETS");

    //for each sub-dataset identify the data type
    for (size_t i = 0; meta[i] != nullptr; i+=2) {

        std::string subDatasetPath(meta[i]);
        auto splitPath = split(subDatasetPath, ":");
        std::filesystem::path inSubDt = std::string("NETCDF:") + std::string(inFile.c_str()) + ":" + splitPath.back();
        auto subDatasetMetadata = getMetadata(inSubDt);

        //all outfiles have a .tif extension
        std::filesystem::path outFile = orderPath/inRelFile;
        outFile.replace_extension("tif");

        auto splitNewPath = split(outFile.c_str(), "/");
        splitNewPath[splitNewPath.size()-1] = splitPath.back() + "_" + splitNewPath.back();

        outFile = boost::algorithm::join(splitNewPath, "/");
        if(std::filesystem::exists(outFile))
            std::filesystem::remove(outFile);
        createDirectoryForFile(outFile);

        //identifying proper crop function
        bool scale = subDatasetMetadata->find(splitPath.back()+"#add_offset") != subDatasetMetadata->end();
        if(scale)
            crop<FloatImageType>(inSubDt, outFile, maskInfo, scale, stof((*subDatasetMetadata)[splitPath.back()+"#scale_factor"]), stof((*subDatasetMetadata)[splitPath.back()+"#add_offset"])  );
        else if(stoi((*subDatasetMetadata)["GDAL_RASTER_TYPE"]) == GDT_Byte)
            crop<UCharImageType>(inSubDt, outFile, maskInfo);
        else if(stoi((*subDatasetMetadata)["GDAL_RASTER_TYPE"]) == GDT_UInt16)
            crop<UShortImageType>(inSubDt, outFile, maskInfo);
    }
}


ProductOrderProcessor::ProductOrderProcessor(Configuration::Pointer &cfg): config(cfg){}

void ProductOrderProcessor::process() {    
    std::string fetchOrdersQuery = "SELECT id, email, ST_AsText(ST_Transform(aoi,4326)), request_data FROM product_order po WHERE NOT processed;";
    //for(;;){
        PGPool::PGConn::Pointer cn  = PGPool::PGConn::New(Configuration::connectionIds[config->statsInfo.connectionId]);
        PGPool::PGConn::PGRes unprocessedOrders   = cn->fetchQueryResult(fetchOrdersQuery);
        for(size_t order = 0; order < unprocessedOrders.size(); order++) {
            std::string requestData = unprocessedOrders[order][3].as<std::string>();
            rapidjson::Document requestDataJSON;
            requestDataJSON.Parse(requestData.c_str());
            for (auto& dataReq: requestDataJSON.GetObject()){
                std::string rawDataQuery =  std::format(R"""(
                SELECT
                pf.rel_file_path, pfd.id, pfv.variable
                FROM product_file pf
                JOIN product_file_description pfd ON pf.product_file_description_id = pfd.id
                JOIN product_file_variable pfv ON pfd.id = pfv.product_file_description_id
                WHERE pfv.id = {0} AND pf.date BETWEEN '{1}' AND '{2}')""", dataReq.name.GetString(), dataReq.value["dateStart"].GetString(), dataReq.value["dateEnd"].GetString());

                if(dataReq.value["rtFlag"].GetInt() > -1)
                    rawDataQuery += std::format(" AND pf.rt_flag = {0}", dataReq.value["rtFlag"].GetInt());
                //rawDataQuery += " LIMIT 1";
                std::string aoi = unprocessedOrders[order][2].as<std::string>();
                std::cout << rawDataQuery <<"\n";
                PGPool::PGConn::PGRes rawFiles = cn->fetchQueryResult(rawDataQuery);

                //don't process anymore
                if (rawFiles.size() == 0)
                    continue;

                //based on product's first file create a raster representation for the aoi
                AOINfo maskInfo = rasterizeAOI<FloatImageType>(Constants::productInfo[rawFiles[order][1].as<size_t>()]->variables[rawFiles[order][2].as<std::string>()]->firstProductVariablePath, aoi);
                size_t fl = 0;
                std::filesystem::path orderPath = config->filesystem.tmpZipPath/unprocessedOrders[order][0].as<std::string>();
/*
                if(std::filesystem::exists(orderPath))
                    std::filesystem::remove_all(orderPath);

#pragma omp parallel for private(fl)
                for(fl = 0; fl < rawFiles.size(); fl++)
                    processFile(rawFiles[fl][0].as<std::string>(), orderPath, maskInfo);
*/

                std::filesystem::path outZipPath = config->filesystem.tmpZipPath/(unprocessedOrders[order][0].as<std::string>() + "-archive");
                std::filesystem::path outZipFile = outZipPath/(unprocessedOrders[order][0].as<std::string>() +".7z");

                if(std::filesystem::exists(outZipPath))
                    std::filesystem::remove_all(outZipPath);
                createDirectoryForFile(outZipFile);

                //zip & split outfiles
                //std::string command = fmt::format("zip -r -s 500m \"{0}\" \"{1}\"", outZipFile.c_str(), sourceDir.c_str());
                std::string command = std::format("7z a -l -mx=5 -m0=LZMA2 -v512000k \"{0}\" \"{1}\"", outZipFile.string(), orderPath.string());
                system(command.c_str());

                auto productFolderSize  = getFolderSizeOnDisk(orderPath);
                auto archiveSize        =   getFolderSizeOnDisk(outZipPath);
                std::cout << outZipPath << "\n";
                std::cout << "product folder size: " << productFolderSize <<", archive size: " << archiveSize << "\n";

            }


        }
        //sleep(12);
    //}


}


ProductOrderProcessor::SharedPtr ProductOrderProcessor::NewShared(Configuration::Pointer &cfg) {
    return std::shared_ptr<ProductOrderProcessor>(new ProductOrderProcessor(cfg));
}

ProductOrderProcessor::UniquePtr ProductOrderProcessor::NewUnique(Configuration::Pointer &cfg) {
    return std::unique_ptr<ProductOrderProcessor>(new ProductOrderProcessor(cfg));
}

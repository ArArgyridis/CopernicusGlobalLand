#define FMT_HEADER_ONLY
#include <cpl_conv.h>
#include <fmt/format.h>
#include <iomanip>
#include <iostream>
#include <rapidjson/document.h>
#include <unistd.h>

#include "Crop.hxx"
#include "ProductOrderProcessor.h"
#include "../Utils/EmailClient/SmtpServer.h"

void ProductOrderProcessor::processFile(std::filesystem::path inRelFile, std::filesystem::path &tmpOrderPath, AOINfo &maskInfo){
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
        std::filesystem::path outFile = tmpOrderPath/inRelFile;
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


ProductOrderProcessor::ProductOrderProcessor(Configuration::SharedPtr &cfg): config(cfg){}

void ProductOrderProcessor::process() {    
    std::string fetchOrdersQuery = "SELECT id, email, ST_AsText(ST_Transform(aoi,4326)), request_data FROM product_order po WHERE NOT processed;";
    for(;;){
        PGPool::PGConn::Pointer cn  = PGPool::PGConn::New(Configuration::connectionIds[config->statsInfo.connectionId]);
        PGPool::PGConn::PGRes unprocessedOrders   = cn->fetchQueryResult(fetchOrdersQuery);
        for(size_t order = 0; order < unprocessedOrders.size(); order++) {
            std::string requestData = unprocessedOrders[order][3].as<std::string>();
            rapidjson::Document requestDataJSON;
            requestDataJSON.Parse(requestData.c_str());
            std::filesystem::path tmpOrderPath = config->filesystem.tmpZipPath/unprocessedOrders[order][0].as<std::string>();
            if(std::filesystem::exists(tmpOrderPath))
                std::filesystem::remove_all(tmpOrderPath);
            std::filesystem::create_directories(tmpOrderPath);

            for (auto& dataReq: requestDataJSON.GetObject()){
                std::string rawDataQuery =  fmt::format(R"""(
                SELECT
                pf.rel_file_path, pfd.id, pfv.variable
                FROM product_file pf
                JOIN product_file_description pfd ON pf.product_file_description_id = pfd.id
                JOIN product_file_variable pfv ON pfd.id = pfv.product_file_description_id
                WHERE pfv.id = {0} AND pf.date BETWEEN '{1}' AND '{2}')""", dataReq.name.GetString(), dataReq.value["dateStart"].GetString(), dataReq.value["dateEnd"].GetString());

                if(dataReq.value["rtFlag"].GetInt() > -1)
                    rawDataQuery += fmt::format(" AND pf.rt_flag = {0}", dataReq.value["rtFlag"].GetInt());
                //rawDataQuery += " LIMIT 1";
                std::string aoi = unprocessedOrders[order][2].as<std::string>();
                PGPool::PGConn::PGRes rawFiles = cn->fetchQueryResult(rawDataQuery);

                //don't process these files
                if (rawFiles.size() == 0)
                    continue;


                //based on product's first file create a raster representation for the aoi
                AOINfo maskInfo = rasterizeAOI<FloatImageType>(Constants::productInfo[rawFiles[order][1].as<size_t>()]->variables[rawFiles[order][2].as<std::string>()]->firstProductVariablePath, aoi);
                size_t fl = 0;


#pragma omp parallel for private(fl)
                for(fl = 0; fl < rawFiles.size(); fl++)
                    processFile(rawFiles[fl][0].as<std::string>(), tmpOrderPath, maskInfo);

            }
            compressAndEMail(tmpOrderPath, unprocessedOrders[order][0].as<std::string>(), unprocessedOrders[order][1].as<std::string>());
            std::string updateQuery = fmt::format("UPDATE product_order SET processed = TRUE WHERE id = '{0}'",  unprocessedOrders[order][0].as<std::string>());
            cn->executeQuery(updateQuery);
        }
        std::cout << "Waiting....\n";
        sleep(12);
    }


}

void ProductOrderProcessor::compressAndEMail(std::filesystem::path &tmpOrderPath, std::string orderId, std::string email){
    std::filesystem::path tmpZipPath = config->filesystem.tmpZipPath/(orderId + "-archive");
    std::filesystem::path tmpZipFile = tmpZipPath/(orderId +".7z");
    std::filesystem::path dstOrderPath = config->filesystem.serverZipPath/orderId;

    if(std::filesystem::exists(tmpZipPath))
        std::filesystem::remove_all(tmpZipPath);
    createDirectoryForFile(tmpZipFile);

    //zip & split outfiles
    //std::string command = fmt::format("zip -r -s 500m \"{0}\" \"{1}\"", outZipFile.c_str(), sourceDir.c_str());
    std::string command = fmt::format("7z a -l -mx=5 -m0=LZMA2 -v512000k \"{0}\" \"{1}\"", tmpZipFile.string(), tmpOrderPath.string());
    system(command.c_str());
    auto orderSize      = getFolderSizeOnDisk(tmpOrderPath);
    auto archiveSize    = getFolderSizeOnDisk(tmpZipPath);

    //copy 7z files to destination folder
    if (std::filesystem::exists(dstOrderPath))
        std::filesystem::remove_all(dstOrderPath);
    std::filesystem::create_directories(dstOrderPath);

    std::string urls = "";

    size_t zipFilesCount = 0;
    for (auto& fl: std::filesystem::recursive_directory_iterator(tmpZipPath) ) {
        std::string flStr = fl.path().string();

        if (flStr.find(".7z") != std::string::npos) {
            std::filesystem::path dstFileName = dstOrderPath/fl.path().filename();
            std::string url = config->natStatsURL + "orders/" + orderId+"/"+fl.path().filename().string();
            urls += url + "\r\n";
            std::filesystem::copy(fl, dstFileName);
            std::filesystem::remove(fl);
            zipFilesCount++;
        }
    }
    std::filesystem::remove_all(tmpZipPath);
    std::string message = fmt::format("Your order is ready.\r\nIt consists of {0} archived file(s).\r\nThe download size is {1}.\r\nYou will also need {2} available disk space to extract the data.\r\nYou can download them for the following URLs:\r\n{3}",
                                      zipFilesCount,bytesToMaxUnit(archiveSize), bytesToMaxUnit(orderSize),urls);
    SmtpServer smtp(config->smtpOptions.server, config->smtpOptions.user, config->smtpOptions.password, config->smtpOptions.certificate, config->smtpOptions.selfSigned);
    std::string subject = "[CGLS NatStats] Your data order is ready!";
    smtp.setData(config->smtpOptions.user, email, subject, message);
    smtp.send();

}

ProductOrderProcessor::SharedPtr ProductOrderProcessor::NewShared(Configuration::SharedPtr &cfg) {
    return std::shared_ptr<ProductOrderProcessor>(new ProductOrderProcessor(cfg));
}

ProductOrderProcessor::UniquePtr ProductOrderProcessor::NewUnique(Configuration::SharedPtr &cfg) {
    return std::unique_ptr<ProductOrderProcessor>(new ProductOrderProcessor(cfg));
}

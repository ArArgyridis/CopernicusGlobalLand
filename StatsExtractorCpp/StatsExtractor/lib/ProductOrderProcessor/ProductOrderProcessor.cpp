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

std::string ProductOrderProcessor::createRawDataQuery(rapidjson::GenericMember<rapidjson::UTF8<>, rapidjson::MemoryPoolAllocator<> > &dataReq) {
    std::string query =  fmt::format(R"""(
                SELECT
                pf.rel_file_path, pfd.id, pfv.variable, 'raw' flag
                FROM product_file pf
                JOIN product_file_description pfd ON pf.product_file_description_id = pfd.id
                JOIN product_file_variable pfv ON pfd.id = pfv.product_file_description_id
                WHERE pfv.id = {0} AND pf.date BETWEEN '{1}' AND '{2}')""", dataReq.name.GetString(), dataReq.value["dateStart"].GetString(), dataReq.value["dateEnd"].GetString());

    if(dataReq.value["rtFlag"].GetInt() > -1)
        query += fmt::format(" AND pf.rt_flag = {0}", dataReq.value["rtFlag"].GetInt());
    //query += " LIMIT 1 ";
    return query;
}

std::string ProductOrderProcessor::createAnomaliesDataQuery(rapidjson::GenericMember<rapidjson::UTF8<>, rapidjson::MemoryPoolAllocator<> > &dataReq) {
    std::string query =  fmt::format(R"""(
                SELECT  pf.rel_file_path, pfv.product_file_description_id , pfv.variable, 'anomaly' flag
                FROM long_term_anomaly_info ltai
                JOIN product_file_variable pfv  ON pfv.id = ltai.anomaly_product_variable_id
                JOIN product_file pf  ON pf.product_file_description_id = pfv.product_file_description_id
                WHERE ltai.raw_product_variable_id = {0} AND pf.date BETWEEN '{1}' AND '{2}')""", dataReq.name.GetString(), dataReq.value["dateStart"].GetString(), dataReq.value["dateEnd"].GetString());

    if(dataReq.value["rtFlag"].GetInt() > -1)
        query += fmt::format(" AND pf.rt_flag = {0}", dataReq.value["rtFlag"].GetInt());
    //query += " LIMIT 0 ";
    return query;
}

void ProductOrderProcessor::createOutput(std::filesystem::path inRelFile, std::filesystem::path &tmpOrderPath, AOINfo &maskInfo, std::string rawOrAnomaly){
    std::filesystem::path dataPath = config->filesystem.imageryPath;
    if (rawOrAnomaly == "anomaly")
        dataPath = config->filesystem.anomalyProductsPath;

    std::filesystem::path inFile  = dataPath/inRelFile;
    if (inFile.extension() == ".nc") {
        GDALDatasetUniquePtr inDataset =  GDALDatasetUniquePtr(GDALDataset::FromHandle(GDALOpen(inFile.c_str(), GA_ReadOnly)));
        char **meta = inDataset->GetMetadata("SUBDATASETS");
        for (size_t i = 0; meta[i] != nullptr; i+=2) {
            std::string subDatasetPath(meta[i]);
            auto splitPath = split(subDatasetPath, ":");
            std::filesystem::path inSubDt = std::string("NETCDF:") + std::string(inFile.c_str()) + ":" + splitPath.back();
            processSingleFile(inSubDt, tmpOrderPath, inRelFile, maskInfo, splitPath.back());
        }
    }
    else { //right now assuming that all other file types are GeoTIFF from the anomalies
        processSingleFile(inFile, tmpOrderPath, inRelFile, maskInfo);
    }

}

void ProductOrderProcessor::processSingleFile(std::filesystem::path &inFile, std::filesystem::path &tmpOrderPath, std::filesystem::path &inRelFile, AOINfo &maskInfo, std::string variable) {
    auto metadata = getMetadata(inFile);
    //all outfiles have a .tif extension
    std::filesystem::path outFile = tmpOrderPath/inRelFile;
    outFile.replace_extension("tif");

    std::vector<std::string> splitNewPath = split(outFile.c_str(), "/");
    if (variable.length() > 0 )
        splitNewPath[splitNewPath.size()-1] = variable + "_" + splitNewPath.back();

    outFile = boost::algorithm::join(splitNewPath, "/");
    if(std::filesystem::exists(outFile))
        std::filesystem::remove(outFile);
    createDirectoryForFile(outFile);

    //identifying proper crop function
    bool scale = metadata->find(variable+"#add_offset") != metadata->end();
    if(scale)
        crop<FloatImageType>(inFile, outFile, maskInfo, scale, stof((*metadata)[variable+"#scale_factor"]), stof((*metadata)[variable+"#add_offset"])  );
    else if(stoi((*metadata)["GDAL_RASTER_TYPE"]) == GDT_Byte)
        crop<UCharImageType>(inFile, outFile, maskInfo);
    else if(stoi((*metadata)["GDAL_RASTER_TYPE"]) == GDT_UInt16)
        crop<UShortImageType>(inFile, outFile, maskInfo);
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

            std::string aoi = "MULTIPOLYGON(((-180 90,180 90,180 -90,-180 -90,-180 90)))";

            if (!unprocessedOrders[order][2].is_null())
                aoi = unprocessedOrders[order][2].as<std::string>();


            for (auto& dataReq: requestDataJSON.GetObject()) {

                PGPool::PGConn::PGRes processFiles;
                std::string dataQuery;
                std::map<std::string, AOINfo> maskInfo;



                if (dataReq.value["dataFlag"].GetInt() == 0)
                    dataQuery = createRawDataQuery(dataReq);
                else if (dataReq.value["dataFlag"].GetInt() == 1)
                    dataQuery = createAnomaliesDataQuery(dataReq);
                else if (dataReq.value["dataFlag"].GetInt() == 2)
                    dataQuery = createRawDataQuery(dataReq) + " UNION " + createAnomaliesDataQuery(dataReq) + " ORDER BY flag DESC";
                //don't process if there are no files
                processFiles = cn->fetchQueryResult(dataQuery);

                std::cout << dataQuery << "\n";
                if (processFiles.size() == 0)
                    continue;

                if (dataReq.value["dataFlag"].GetInt() == 0) {
                    maskInfo["raw"] = rasterizeAOI<FloatImageType>(Constants::productInfo[processFiles[0][1].as<size_t>()]->variables[processFiles[0][2].as<std::string>()]->firstProductVariablePath, aoi);
                }
                else if (dataReq.value["dataFlag"].GetInt() == 1) {
                    maskInfo["anomaly"] = rasterizeAOI<FloatImageType>(Constants::productInfo[processFiles[0][1].as<size_t>()]->variables[processFiles[0][2].as<std::string>()]->firstProductVariablePath, aoi);
                }
                else if (dataReq.value["dataFlag"].GetInt() == 2) {
                    maskInfo["raw"] = rasterizeAOI<FloatImageType>(Constants::productInfo[processFiles[0][1].as<size_t>()]->variables[processFiles[0][2].as<std::string>()]->firstProductVariablePath, aoi);
                    bool stop = false;
                    size_t flId;
                    for(flId = 0; flId < processFiles.size() && !stop; flId++ )
                        if (processFiles[flId][3].as<std::string>() == "anomaly")
                            stop = true;

                    auto k = Constants::productInfo;

                    if (flId < processFiles.size()) //an anomaly has been found
                        maskInfo["anomaly"] = rasterizeAOI<FloatImageType>(Constants::productInfo[processFiles[flId][1].as<size_t>()]->variables[processFiles[flId][2].as<std::string>()]->firstProductVariablePath, aoi);
                }





                //based on product's first file create a raster representation for the aoi
                //AOINfo maskInfo = rasterizeAOI<FloatImageType>(Constants::productInfo[processFiles[0][1].as<size_t>()]->variables[processFiles[0][2].as<std::string>()]->firstProductVariablePath, aoi);
                size_t fl = 0;

#pragma omp parallel for private(fl)
                for(fl = 0; fl < processFiles.size(); fl++)
                    createOutput(processFiles[fl][0].as<std::string>(), tmpOrderPath, maskInfo[processFiles[fl][3].as<std::string>()], processFiles[fl][3].as<std::string>());

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

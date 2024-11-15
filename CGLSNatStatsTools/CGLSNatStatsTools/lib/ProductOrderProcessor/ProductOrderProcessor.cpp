/*
   Copyright (C) 2024  Argyros Argyridis arargyridis at gmail dot com
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
*/
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
#include "../Filters/Statistics/StratificationStatistics/OrderStatisticsFilter.hxx"
#include "../Filters/Statistics/StratificationStatistics/StreamedSystemStratificationStatisticsFilter.h"

using StreamedStatisticsType                            = otb::StreamedStatisticsFromLabelImageFilter<otb::ShortImageType, otb::ULongImageType>;
using ExtractROIFilter                                  = otb::ExtractROI<otb::ShortImageType::PixelType, otb::ShortImageType::PixelType>;
using StratificationStatisticsFilter                    = otb::OrderStatisticsFilter<otb::ShortImageType, otb::VectorDataType>;
using StreamedSystemStratificationStatisticsFilter      = otb::StreamedStatisticsExtractorFilter<StratificationStatisticsFilter>;

using OrderStatistics = otb::OrderStatisticsFilter<otb::ShortImageType, otb::VectorDataType>;
using StreamedOrderStatistics = otb::StreamedStatisticsExtractorFilter<OrderStatistics>;


ProductOrderProcessor::AOINfo::AOINfo(){
    originIdx[0] = originIdx[1] = size[0] = size[1] = envelope.MinX = envelope.MaxX = envelope.MinY = envelope.MaxY = 0;
}

std::string ProductOrderProcessor::createRawDataQuery(JSONObjectMember &dataReq) {
    std::string query =  fmt::format(R"""(
                SELECT
                pf.rel_file_path, pfd.id, pfv.variable, pf.id, pfv.id pfvid, 0 flag, pf.date
                FROM product_file pf
                JOIN product_file_description pfd ON pf.product_file_description_id = pfd.id
                JOIN product_file_variable pfv ON pfd.id = pfv.product_file_description_id
                WHERE pfv.id = {0} AND pf.date BETWEEN '{1}' AND '{2}')""", dataReq.value["variable"].GetInt(), dataReq.value["dateStart"].GetString(), dataReq.value["dateEnd"].GetString());

    if(dataReq.value["rtFlag"].GetInt() > -1)
        query += fmt::format(" AND pf.rt_flag = {0}", dataReq.value["rtFlag"].GetInt());
    //query += " LIMIT 1 ";
    return query;
}

std::string ProductOrderProcessor::createAnomaliesDataQuery(JSONObjectMember &dataReq) {
    std::string query =  fmt::format(R"""(
                SELECT  pf.rel_file_path, pfv.product_file_description_id , pfv.variable, pf.id, pfv.id pfvid, 1 flag, pf.date
                FROM long_term_anomaly_info ltai
                JOIN product_file_variable pfv  ON pfv.id = ltai.anomaly_product_variable_id
                JOIN product_file pf  ON pf.product_file_description_id = pfv.product_file_description_id
                WHERE ltai.raw_product_variable_id = {0} AND pf.date BETWEEN '{1}' AND '{2}')""", dataReq.value["variable"].GetInt(), dataReq.value["dateStart"].GetString(), dataReq.value["dateEnd"].GetString());

    if(dataReq.value["rtFlag"].GetInt() > -1)
        query += fmt::format(" AND pf.rt_flag = {0}", dataReq.value["rtFlag"].GetInt());
    //query += " LIMIT 0 ";
    return query;
}

void ProductOrderProcessor::createRasterOutput(std::filesystem::path inRelFile, std::filesystem::path &tmpOrderPath, AOINfo &maskInfo, size_t &variableId){

    std::filesystem::path inFile  = *Constants::variableInfo[variableId]->getProductInfo()->rootPath/inRelFile;
    if (inFile.extension() == ".nc") {
        GDALDatasetUniquePtr inDataset =  GDALDatasetUniquePtr(GDALDataset::FromHandle(GDALOpen(inFile.c_str(), GA_ReadOnly)));
        char **meta = inDataset->GetMetadata("SUBDATASETS");
        for (size_t i = 0; meta[i] != nullptr; i+=2) {
            std::string subDatasetPath(meta[i]);
            auto splitPath = split(subDatasetPath, ":");
            std::filesystem::path inSubDt = std::string("NETCDF:") + std::string(inFile.c_str()) + ":" + splitPath.back();
            cropSingleRasterFile(inSubDt, tmpOrderPath, inRelFile, maskInfo, splitPath.back());
        }
    }
    else { //right now assuming that all other file types are GeoTIFF from the anomalies
        cropSingleRasterFile(inFile, tmpOrderPath, inRelFile, maskInfo);
    }

}

void ProductOrderProcessor::cropSingleRasterFile(std::filesystem::path &inFile, std::filesystem::path &tmpOrderPath, std::filesystem::path &inRelFile, AOINfo &maskInfo, std::string variable) {
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
    bool scale = metadata->find(variable+"#scale_factor") != metadata->end();
    if(scale) {
        float offset = 0;
        if (metadata->find(variable+"#add_offset") != metadata->end())
            offset = stof((*metadata)[variable+"#add_offset"]);
        crop<otb::FloatImageType>(inFile, outFile, maskInfo, scale, stof((*metadata)[variable+"#scale_factor"]), offset);
    }
    else if(stoi((*metadata)["GDAL_RASTER_TYPE"]) == GDT_Byte)
        crop<otb::UCharImageType>(inFile, outFile, maskInfo);
    else if(stoi((*metadata)["GDAL_RASTER_TYPE"]) == GDT_UInt16)
        crop<otb::UShortImageType>(inFile, outFile, maskInfo);
}


ProductOrderProcessor::ProductOrderProcessor(Configuration::SharedPtr &cfg): config(cfg){}

void ProductOrderProcessor::computeStatistics(PGPool::PGConn::UniquePtr &cn, std::filesystem::path &tmpOrderPath, PGPool::PGConn::PGRes &processFiles, std::map<size_t, AOINfo> &maskInfo, std::string &orderId, JSONObjectMember &orderParams) {
    //std::string orderId = "27510d6a-c2df-41ff-b3e9-2c507260a224";
    std::filesystem::path dstDir = tmpOrderPath/"CSV";
    if(! std::filesystem::is_directory(dstDir))
        std::filesystem::create_directories(dstDir);

    JsonDocumentSharedPtr polyIds = std::make_shared<JsonDocument>();
    JsonValue imagesArray;
    imagesArray.SetArray();
    unsigned char maxArraySize = 10;
    std::string query = fmt::format(R"""(SELECT ARRAY_TO_JSON(ARRAY_AGG(pog.poly_id))
            FROM product_order_geom pog
            WHERE product_order_id  = '{0}')""", orderId);

    PGPool::PGConn::PGRes polyIdsRes = cn->fetchQueryResult(query);
    polyIds->Parse(polyIdsRes[0][0].as<std::string>().c_str());

    for(size_t rowCnt = 0; rowCnt < processFiles.size(); rowCnt++) {
        if(imagesArray.Size() == maxArraySize ||
            (rowCnt > 0 && imagesArray.Size() < maxArraySize && processFiles[rowCnt-1][4].as<size_t>() != processFiles[rowCnt][4].as<size_t>()) ) {
            //process images to get the statistics
            size_t variableId = processFiles[rowCnt-1][4].as<size_t>();
            polyStatsExtractor(orderId, orderParams, polyIds, variableId, imagesArray, maskInfo, dstDir);
            imagesArray.Clear();
        }
        JsonValue imageArray;
        imageArray.SetArray();
        JsonValue relFilePath, pfId, pfvId;
        relFilePath.SetString(processFiles[rowCnt][0].as<std::string>(),polyIds->GetAllocator());
        imageArray.PushBack(relFilePath,polyIds->GetAllocator());

        pfId.SetInt64(processFiles[rowCnt][3].as<size_t>());
        imageArray.PushBack(pfId,polyIds->GetAllocator());

        pfvId.SetInt64(processFiles[rowCnt][4].as<size_t>());
        imageArray.PushBack(pfvId,polyIds->GetAllocator());

        imagesArray.PushBack(imageArray, polyIds->GetAllocator());
    }
    if(imagesArray.Size() > 0) {
        //get these statistics as well
        size_t variableId = processFiles.back()[4].as<size_t>();
        polyStatsExtractor(orderId, orderParams, polyIds, variableId, imagesArray, maskInfo, dstDir);
    }
}

void ProductOrderProcessor::generateRasterData(std::map<size_t, AOINfo> &maskInfo, size_t &variableId, std::filesystem::path &tmpOrderPath, PGPool::PGConn::PGRes &processFiles) {
    size_t fl = 0;
    std::filesystem::path dstPath = tmpOrderPath/"Raster";
#pragma omp parallel for private(fl)
    for(fl = 0; fl < processFiles.size(); fl++)
        createRasterOutput(processFiles[fl][0].as<std::string>(), dstPath, maskInfo[processFiles[fl][4].as<size_t>()], variableId);
}

void ProductOrderProcessor::polyStatsExtractor(std::string &orderId, JSONObjectMember &orderParams, JsonDocumentSharedPtr polyIds, size_t &variableId, JsonValue &imagesArray, std::map<size_t, AOINfo> &maskInfo, std::filesystem::path &dstDir) {
    StreamedOrderStatistics::Pointer statsExtractor = StreamedOrderStatistics::New();
    statsExtractor->SetParams(config, Constants::variableInfo[variableId], maskInfo[variableId].envelope, imagesArray, polyIds, 3857);
    statsExtractor->GetFilter()->SetOrderId(orderId);
    statsExtractor->GetFilter()->SetOutputDirectory(dstDir);
    statsExtractor->GetFilter()->SetRTFlag(orderParams.value["rtFlag"].GetInt());
    statsExtractor->Update();
}
void ProductOrderProcessor::process() {    
    std::string fetchOrdersQuery = "SELECT id, email, ST_AsText(ST_Transform(aoi,4326)), request_data FROM product_order po WHERE NOT processed;";
    for(;;){
        PGPool::PGConn::UniquePtr cn  = PGPool::PGConn::New(Configuration::connectionIds[config->statsInfo.connectionId]);
        PGPool::PGConn::PGRes unprocessedOrders   = cn->fetchQueryResult(fetchOrdersQuery);
        for(size_t order = 0; order < unprocessedOrders.size(); order++) {
            std::string requestData = unprocessedOrders[order][3].as<std::string>();
            rapidjson::Document requestDataJSON;
            requestDataJSON.Parse(requestData.c_str());
            std::filesystem::path tmpOrderPath = config->filesystem.tmpZipPath/unprocessedOrders[order][0].as<std::string>();
            if(std::filesystem::exists(tmpOrderPath))
                std::filesystem::remove_all(tmpOrderPath);
            std::filesystem::create_directories(tmpOrderPath);

            std::string aoi = unprocessedOrders[order][2].as<std::string>();
            OGRMultiPolygon aoiPoly;
            std::unique_ptr<const char*> requestAOI = std::make_unique<const char*>(const_cast<char*>(aoi.c_str()));
            aoiPoly.importFromWkt(requestAOI.get());
            OGREnvelope aoiEnvelope;
            aoiPoly.getEnvelope(&aoiEnvelope);

            for (JSONObjectMember& dataReq: requestDataJSON.GetObject()) {
                PGPool::PGConn::PGRes processFiles;
                std::string dataQuery;
                std::map<size_t, AOINfo> maskInfo;
                if (dataReq.value["dataFlag"].GetInt() == 0)
                    dataQuery = createRawDataQuery(dataReq);
                else if (dataReq.value["dataFlag"].GetInt() == 1)
                    dataQuery = createAnomaliesDataQuery(dataReq);
                else if (dataReq.value["dataFlag"].GetInt() == 2)
                    dataQuery = createRawDataQuery(dataReq) + " UNION " + createAnomaliesDataQuery(dataReq);
                dataQuery += " ORDER BY flag, \"date\";";
                processFiles = cn->fetchQueryResult(dataQuery);

                //std::cout << dataQuery << "\n";
                //don't process if there are no files
                if (processFiles.size() == 0)
                    continue;

                std::string orderId = unprocessedOrders[order][0].as<std::string>();
                size_t variableId = processFiles[0][4].as<size_t>();
                //checking which data should be downloaded: 0 - Raw, 1 - Anomalies, 2 - both
                if (dataReq.value["dataFlag"].GetInt() == 0 || dataReq.value["dataFlag"].GetInt() == 2)//the first file will always be a raw file
                    maskInfo[variableId] = alignAOI<otb::FloatImageType>(Constants::variableInfo[variableId]->firstProductVariablePath, aoiEnvelope);

                if (dataReq.value["dataFlag"].GetInt() == 1 || dataReq.value["dataFlag"].GetInt() == 2) {
                    for(auto & anomId: Constants::variableInfo[variableId]->anomalyVariableIds)
                        maskInfo[anomId] = alignAOI<otb::FloatImageType>(Constants::variableInfo[anomId]->firstProductVariablePath, aoiEnvelope);
                }

                //checking what type of statistics should be downloaded: 0 - Polygon-based, 1 - Raster-based, 2 - Both
                if(dataReq.value["outputValue"].GetInt() == 0 || dataReq.value["outputValue"].GetInt() == 2)
                    computeStatistics(cn, tmpOrderPath, processFiles, maskInfo, orderId, dataReq);
                if(dataReq.value["outputValue"].GetInt() == 1 || dataReq.value["outputValue"].GetInt() == 2)
                    generateRasterData(maskInfo, variableId, tmpOrderPath, processFiles);
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

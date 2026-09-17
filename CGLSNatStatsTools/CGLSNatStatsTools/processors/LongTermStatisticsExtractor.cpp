#include <fmt/format.h>

#include <iostream>
#include <otbImageFileReader.h>
#include <otbImageFileWriter.h>
#include <otbMultiImageFileWriter.h>

#include <rapidjson/rapidjson.h>
#include <thread>

#include "../lib/ConfigurationParser/ConfigurationParser.h"
#include "../lib/Constants/Constants.h"
#include "../lib/Filters/Statistics/LongTermStatisticsFilter.hpp"



using UCharImage = otb::Image<unsigned char, 2>;
using FloatImage = otb::Image<float, 2>;
using LongTermStatisticsFilter = otb::LongTermStatisticsFilter<UCharImage>;
using UCharReader = otb::ImageFileReader<UCharImage>;
using FloatWriter = otb::ImageFileWriter<FloatImage>;

int main(int argc, char *argv[]) {
    if (argc < 4) {
        std::cout << "usage: LongTermStatisticsExtractor configuration_file product_file_variable_id rt_flag(-1 for no rt_flag)";
        return 1;
    }
    GDALAllRegister();
    CPLSetConfigOption("GDAL_CACHEMAX", "4096"); // MB
    std::string cfgFile(argv[1]);

    Configuration::SharedPtr config = Configuration::New(cfgFile);
    if (config->parse() != 0)
        return 1;

    if (Constants::load(config) != 0)
        return 1;

    //clean up tmp directory before starting
    if(std::filesystem::exists(config->filesystem.tmpPath))
        std::filesystem::remove_all(config->filesystem.tmpPath);

    std::filesystem::create_directories(config->filesystem.tmpPath);


    PGPool::PGConn::UniquePtr cn  = PGPool::PGConn::New(Configuration::connectionIds[config->statsInfo.connectionId]);

    std::string rtFlagStr = "";
    if (std::string(argv[3]) != "-1")
        rtFlagStr = "AND pf.rt_flag = " + std::string(argv[3]);

    std::string query = fmt::format(R"""(
    WITH files as(
    SELECT pf.rel_file_path, EXTRACT(DAY FROM "date") as day, EXTRACT(MONTH FROM "date") as month, EXTRACT(YEAR FROM "date") as YEAR
    FROM product_file_variable pfv
    JOIN product_file_description pfd ON pfd.id = pfv.product_file_description_id
    JOIN product_file pf on pf.product_file_description_id = pfd.id
    WHERE pfv.id = {0} {1}
    )
    ,year_count AS(
        SELECT year, count(*) year_count
        FROM files
        GROUP BY year
    )
    ,max_year_count AS(
        SELECT max(year_count) mx
        FROM year_count
    )
    ,valid_dt AS(
        SELECT files.*
        FROM max_year_count myc
        JOIN year_count yc ON myc.mx = yc.year_count
        JOIN files ON yc.year = files.year
    )
    SELECT month, day, count(rel_file_path), ARRAY_TO_JSON(ARRAY_AGG(rel_file_path ORDER BY valid_dt.month, valid_dt.day,  valid_dt.year)), min(year) min_year, max(year) max_year
    FROM valid_dt
    GROUP BY month, day
    ORDER BY month, day;)""", argv[2], rtFlagStr);

    auto variable = Constants::variableInfo[std::stoi(argv[2])];

    std::filesystem::path dstPath = config->filesystem.ltsPath/variable->getProductInfo()->productNames[0];
    if (variable->variable.size() > 1)
        dstPath /= variable->variable;

    std::filesystem::create_directories(dstPath);

    std::cout << dstPath <<"\n";


    auto res = cn->fetchQueryResult(query);

    for(const auto& row: res) {
        JsonDocumentUniquePtr  imageGroups = std::make_unique<JsonDocument>();
        imageGroups->Parse(row[3].as<std::string>().c_str());

        std::vector<UCharReader::Pointer> imgReaders;
        imgReaders.resize(imageGroups->GetArray().Size());

        LongTermStatisticsFilter::Pointer ltsFilter = LongTermStatisticsFilter::New();
        ltsFilter->SetVariable(variable);
        size_t imgIdx = 0;
        for (auto& image: imageGroups->GetArray()) {
            imgReaders[imgIdx] = UCharReader::New();
            imgReaders[imgIdx]->SetFileName(variable->productAbsPath(image.GetString()));
            ltsFilter->SetInput(imgIdx, imgReaders[imgIdx]->GetOutput());
            imgIdx++;

        }

        std::vector<std::string> filenames = {
            fmt::format(R"(c_gls_FAPAR300-RT{}-LTS_{:02d}{:02d}_{}_{}_NUMS_GLOBE.tif)", argv[3], row[0].as<int>(), row[1].as<int>(), row[4].as<int>(), row[5].as<int>()),
            fmt::format(R"(c_gls_FAPAR300-RT{}-LTS_{:02d}{:02d}_{}_{}_MEDIAN_GLOBE.tif)", argv[3], row[0].as<int>(), row[1].as<int>(), row[4].as<int>(), row[5].as<int>()),
            fmt::format(R"(c_gls_FAPAR300-RT{}-LTS_{:02d}{:02d}_{}_{}_MEAN_GLOBE.tif)", argv[3], row[0].as<int>(), row[1].as<int>(), row[4].as<int>(), row[5].as<int>()),
            fmt::format(R"(c_gls_FAPAR300-RT{}-LTS_{:02d}{:02d}_{}_{}_STD_GLOBE.tif)", argv[3], row[0].as<int>(), row[1].as<int>(), row[4].as<int>(), row[5].as<int>()),
        };

        std::vector<std::filesystem::path> tmpFiles(filenames.size());

        otb::MultiImageFileWriter::Pointer writer = otb::MultiImageFileWriter::New();

        for(size_t idx = 0; idx < filenames.size(); idx++) {
            FloatWriter::Pointer tmpWriter = FloatWriter::New();

            tmpFiles[idx] = config->filesystem.tmpPath/filenames[idx];
            if(std::filesystem::exists(tmpFiles[idx]))
                std::filesystem::remove(tmpFiles[idx]);

            writer->AddInputImage(ltsFilter->GetOutput(idx), std::string(std::string(tmpFiles[idx])+"?&gdal:co:COMPRESS=ZSTD&gdal:co:PREDICTOR=3&gdal:co:BIGTIFF=YES").c_str());
        }
        writer->SetAutomaticStrippedStreaming(config->statsInfo.memoryMB);
        writer->SetNumberOfLinesStrippedStreaming(10000);
        writer->Update();

        //copying files to destination

        for(size_t idx = 0; idx < tmpFiles.size(); idx++) {
            std::filesystem::path dstFileName = dstPath/filenames[idx];
            std::filesystem::copy(tmpFiles[idx], dstFileName);
            //delete tmp file
            std::filesystem::remove(tmpFiles[idx]);
        }
    }

    return 0;
}
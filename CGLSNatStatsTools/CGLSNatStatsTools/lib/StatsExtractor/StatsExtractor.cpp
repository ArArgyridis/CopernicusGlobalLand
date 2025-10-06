/*
   Copyright (C) 2021  Argyros Argyridis arargyridis at gmail dot com
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
#include <fmt/format.h>
#include <gdal.h>
#include <iostream>
#include <memory>
#include <otbImage.h>
#include <otbImageFileReader.h>
#include <otbImageFileWriter.h>
#include <otbExtractROI.h>
#include <otbVectorDataToLabelImageFilter.h>
#include <otbVectorImage.h>
#include <rapidjson/document.h>

#include "StatsExtractor.h"
#include "../Constants/Constants.h"
#include "../Filters/OTBImageDefs.h"
#include "../Filters/Statistics/StratificationStatistics/SystemStratificationStatisticsFilter.h"
#include "../Filters/Statistics/StratificationStatistics/StreamedSystemStratificationStatisticsFilter.h"
#include "../Filters/Statistics/StreamedStatisticsFromLabelImageFilter.h"

using ULongImageReaderType = otb::ImageFileReader<otb::ULongImageType>;
using ULongImageWriterType = otb::ImageFileWriter<otb::ULongImageType>;

using RawDataImageReaderType = otb::ImageFileReader<otb::ShortImageType>;
using RawDataImageWriterType = otb::ImageFileWriter<otb::ShortImageType>;


using StreamedStatisticsType                            = otb::StreamedStatisticsFromLabelImageFilter<otb::ShortImageType, otb::ULongImageType>;
using ExtractROIFilter                                  = otb::ExtractROI<otb::ShortImageType::PixelType, otb::ShortImageType::PixelType>;
using StratificationStatisticsFilter                    = otb::SystemStratificationStatisticsFilter<otb::ShortImageType, otb::VectorDataType>;
using StreamedSystemStratificationStatisticsFilter      = otb::StreamedStatisticsExtractorFilter<StratificationStatisticsFilter>;


StatsExtractor::StatsExtractor(Configuration::SharedPtr cfg, const std::string &stratificationType):config(cfg), stratificationID(stratificationType) {}

void StatsExtractor::process() {
    for (auto& product: Constants::productInfo) {
        for(auto& variable : product.second->variables) {
            if(!variable.second->computeStatistics)
                continue;

            std::cout <<"Retrieving image info for product " << product.second->productNames[0] <<"(variable: " << variable.second->variable <<")\n";

            std::string query = fmt::format(R""""(
            WITH extent AS(
                SELECT sg.stratification_id, st_extent(geom) extg, ARRAY_TO_JSON(array_agg(sg.id)) geomids, min(sg.id)  mingmid, max(sg.id) maxgmid
                FROM stratification_geom sg
                WHERE sg.stratification_id = {0}
                GROUP BY sg.stratification_id
            ),image_info AS(
                SELECT (JSON_BUILD_ARRAY(pf.rel_file_path, pf.id, pfv.id))::jsonb image, pf.rt_flag, pf.date
                FROM extent ext
                JOIN product_file_variable pfv ON pfv.id = {1}
                JOIN product_file_description pfd ON pfd.id = pfv.product_file_description_id
                JOIN product_file pf ON pfd.id = pf.product_file_description_id
                LEFT JOIN poly_stats ps ON ps.poly_id = ext.mingmid  AND ps.product_file_id = pf.id AND ps.product_file_variable_id = pfv.id
                WHERE ext.stratification_id = {0} AND ps.poly_id IS NULL
            ),images AS( -- partition images into groups each having 5 images
                SELECT ARRAY_TO_JSON(ARRAY_AGG(images)) images
                FROM (
                    SELECT ARRAY_TO_JSON(ARRAY_AGG(image ORDER BY grpid)) images
                    FROM (
                        SELECT (ROW_NUMBER() OVER(ORDER BY rt_flag, date))/5 grpid, image
                        FROM(
                            SELECT DISTINCT image, rt_flag, date --SELECT array_to_json(ARRAY_AGG(DISTINCT image)) images
                            FROM image_info --LIMIT 1
                        )a
                    )b
                    GROUP BY grpid
                )c
            )
            SELECT images, geomids, st_xmin(extg), st_ymin(extg), st_xmax(extg), st_ymax(extg), Find_SRID('public', 'stratification_geom', 'geom'),
            mingmid, maxgmid+1
            FROM extent
            JOIN images ON TRUE;)"""", stratificationID, std::to_string(variable.second->id));
            //std::cout << query <<"\n";

            PGPool::PGConn::UniquePtr cn          = PGPool::PGConn::New(Configuration::connectionIds[config->statsInfo.connectionId]);
            PGPool::PGConn::PGRes processInfo   = cn->fetchQueryResult(query, "product info");

            if (processInfo.empty() || processInfo[0][0].is_null() || processInfo[0][1].is_null()) //no data at all, or no polygons, or no images
                continue;

            //Creating stats partition table if not exists
            std::string partitionTable = fmt::format(R"""(poly_stats_{0}_{1}_{2})""", variable.second->id, processInfo[0][7].as<size_t>(), processInfo[0][8].as<size_t>());
            query = fmt::format(R"""(CREATE TABLE IF NOT EXISTS {0} PARTITION OF poly_stats FOR VALUES FROM ({1},{2}) TO ({1},{3});)""", partitionTable, variable.second->id, processInfo[0][7].as<size_t>(), processInfo[0][8].as<size_t>());
            //std::cout << query <<"\n";
            cn->executeQuery(query);

            JsonDocumentUniquePtr  imageGroups = std::make_unique<JsonDocument>();
            JsonDocumentSharedPtr polyIds = std::make_shared<JsonDocument>();

            //prepare images
            imageGroups->Parse(processInfo[0][0].as<std::string>().c_str());
            //prepare geomIds
            polyIds->Parse(processInfo[0][1].as<std::string>().c_str());

            //prepare envelope
            OGREnvelope envelope;
            envelope.MinX = processInfo[0][2].as<double>();
            envelope.MinY = processInfo[0][3].as<double>();
            envelope.MaxX = processInfo[0][4].as<double>();
            envelope.MaxY = processInfo[0][5].as<double>();

            //geometries srid
            size_t srid = processInfo[0][6].as<size_t>();

            for (auto &group: imageGroups->GetArray()){
                StreamedSystemStratificationStatisticsFilter::Pointer processingChain = StreamedSystemStratificationStatisticsFilter::New();
                processingChain->SetParams(config, variable.second, envelope, group, polyIds, srid, partitionTable);
                processingChain->UpdateOutputInformation();
                processingChain->GetStreamer()->GetStreamingManager()->SetDefaultRAM(config->statsInfo.memoryMB);
                processingChain->UpdateOutputInformation();

                if (processingChain->ValidAOI())
                    processingChain->Update();
            }
        }
    }
}

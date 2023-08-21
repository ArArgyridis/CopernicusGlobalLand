/**
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
#include "../Filters/StreamedProcessingChainFilter.h"
#include "../Filters/Statistics/StreamedStatisticsFromLabelImageFilter.h"



using labelType         = unsigned long;
using dataType          = short int;
const short Dimension   = 2;
using LabelImageType    = otb::Image< labelType, Dimension >;
using RawDataImageType  = otb::Image<dataType, Dimension>;

using VectorDataToLabelImageFilterType = otb::VectorDataToLabelImageFilter<otb::VectorDataType, LabelImageType>;
using ULongImageReaderType = otb::ImageFileReader<LabelImageType>;
using ULongImageWriterType = otb::ImageFileWriter<LabelImageType>;

using RawDataImageReaderType = otb::ImageFileReader<RawDataImageType>;
using RawDataImageWriterType = otb::ImageFileWriter<RawDataImageType>;


using StreamedStatisticsType    = otb::StreamedStatisticsFromLabelImageFilter<RawDataImageType, LabelImageType>;
using ExtractROIFilter          = otb::ExtractROI<RawDataImageType::PixelType, RawDataImageType::PixelType>;
using ProcessingChainFilter     = otb::StreamedProcessingChainFilter<RawDataImageType, otb::VectorDataType>;


StatsExtractor::StatsExtractor(Configuration::Pointer &cfg, std::string stratificationType):config(cfg), stratification(stratificationType) {}

void StatsExtractor::process() {
    for (auto& product: Constants::productInfo) {
        for(auto& variable : product.second->variables) {
            if(!variable.second->computeStatistics)
                continue;

            std::cout <<"Retrieving image info for product " << product.second->productNames[0] <<"(variable: " << variable.second->variable <<")\n";

            std::string query = fmt::format(R""""(
                WITH info AS (
                    SELECT sg.id geomid, (JSON_BUILD_ARRAY(pf.rel_file_path, pf.id, pfv.id))::jsonb image
                    FROM stratification s
                    JOIN stratification_geom sg ON s.id = sg.stratification_id
                    JOIN product p ON TRUE
                    JOIN product_file_description pfd ON p.id = pfd.product_id
                    JOIN product_file_variable pfv ON pfd.id = pfv.product_file_description_id
                    JOIN product_file pf ON pfd.id = pf.product_file_description_id --AND sg.id = 63 --AND pf.id = 867 --AND pf.id = 1 --AND p.id = 1 AND sg.id = 45
                    LEFT JOIN poly_stats ps ON ps.poly_id = sg.id AND ps.product_file_id = pf.id AND ps.product_file_variable_id = pfv.id
                    WHERE s.description  = '{0}' AND pfv.id = {1} AND ps.id IS NULL
                ),extent AS(
                    SELECT  st_extent(geom) extg, ARRAY_TO_JSON(array_agg(a.geomid)) geomids
                    FROM (SELECT distinct geomid FROM info) a
                    JOIN stratification_geom sg ON a.geomid = sg.id
                ),images AS( -- partition images into groups each having 5 images
                    SELECT ARRAY_TO_JSON(ARRAY_AGG(images)) images
                    FROM(
                        SELECT ARRAY_TO_JSON(ARRAY_AGG(image ORDER BY grpid)) images
                        FROM (
                            SELECT (ROW_NUMBER() OVER(ORDER BY image[1]))/5 grpid, image
                            FROM(
                                SELECT DISTINCT image --SELECT array_to_json(ARRAY_AGG(DISTINCT image)) images
                                FROM info
                                --LIMIT 1
                            )a
                        )b
                        GROUP BY grpid
                    )c
                )
                SELECT images, geomids, st_xmin(extg), st_ymin(extg), st_xmax(extg), st_ymax(extg), Find_SRID('public', 'stratification_geom', 'geom')
                FROM extent
                JOIN images ON TRUE)"""", stratification, std::to_string(variable.second->id));
            //std::cout << query <<"\n";

            PGPool::PGConn::Pointer cn          = PGPool::PGConn::New(Configuration::connectionIds[config->statsInfo.connectionId]);
            PGPool::PGConn::PGRes processInfo   = cn->fetchQueryResult(query, "product info");

            if (processInfo.empty() || processInfo[0][0].is_null() || processInfo[0][1].is_null()) //no data at all, or no polygons, or no images
                continue;

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
                ProcessingChainFilter::Pointer processingChain = ProcessingChainFilter::New();
                processingChain->SetParams(config, product.second, variable.second, envelope, group, polyIds, srid);
                processingChain->UpdateOutputInformation();
                processingChain->GetStreamer()->GetStreamingManager()->SetDefaultRAM(config->statsInfo.memoryMB);
                processingChain->UpdateOutputInformation();

                if (processingChain->ValidAOI())
                    processingChain->Update();

                processingChain->ReleaseDataFlagOn();
                processingChain->ResetPipeline();
            }
        }
    }
}


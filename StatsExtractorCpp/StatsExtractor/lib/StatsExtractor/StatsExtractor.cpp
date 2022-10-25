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

#include <iostream>
#include <memory>
#include <otbImage.h>
#include <otbImageFileReader.h>
#include <otbImageFileWriter.h>
#include <otbExtractROI.h>
#include <otbVectorDataToLabelImageFilter.h>
#include <otbVectorImage.h>
#include <rapidjson/document.h>
#include <gdal.h>

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


StatsExtractor::StatsExtractor(Configuration::Pointer cfg, std::string stratificationType):config(cfg), stratification(stratificationType) {}

void StatsExtractor::process() {
    for (auto& product: Constants::productInfo) {
        std::cout <<"Retrieving info for product files with id: " << product.second->id <<"(product name: " << product.second->productNames[0] << ")\n";

        std::string query = "with info as ( "
                "SELECT sg.id geomid, (JSON_BUILD_ARRAY(pf.rel_file_path, pf.id))::jsonb image "
                "FROM stratification s "
                "JOIN stratification_geom sg ON s.id = sg.stratification_id "
                "JOIN product p ON TRUE "
                "JOIN product_file_description pfd ON p.id = pfd.product_id AND pfd.id = " + std::to_string(product.first) +
                "JOIN product_file pf ON pfd.id = pf.product_description_id "
                "LEFT JOIN poly_stats ps ON ps.poly_id = sg.id AND ps.product_file_id = pf.id "
                "WHERE s.description  = '" + stratification +
                "' AND ((p.type='raw'AND pfd.variable IS NOT NULL) OR p.type='anomaly') AND ps.id IS null /*AND sg.id = 199 AND sg.id=74 AND pf.id <2*/"
                "),extent AS( "
                "  SELECT  st_extent(geom) extg, ARRAY_TO_JSON(array_agg(a.geomid)) geomids "
                "  FROM (SELECT distinct geomid FROM info) a "
                "  JOIN stratification_geom sg ON a.geomid = sg.id "
                "),images AS( "
                "  SELECT array_to_json(ARRAY_AGG(DISTINCT image)) images "
                "  FROM info)"
                "SELECT images, geomids, st_xmin(extg), st_ymin(extg), st_xmax(extg), st_ymax(extg), Find_SRID('public', 'stratification_geom', 'geom') "
                "FROM extent "
                "JOIN images ON true";
        //std::cout << query <<"\n";

        PGPool::PGConn::Pointer cn          = PGPool::PGConn::New(Configuration::connectionIds[config->statsInfo.connectionId]);
        PGPool::PGConn::PGRes processInfo   = cn->fetchQueryResult(query, "product info");

        if (processInfo.empty() || processInfo[0][0].is_null() || processInfo[0][1].is_null()) //no data at all, or no polygons, or no images
            continue;

        JsonDocumentPtr  images = std::make_unique<JsonDocument>(), polyIds = std::make_unique<JsonDocument>();

        //prepare images
        images->Parse(processInfo[0][0].as<std::string>().c_str());
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

        ProcessingChainFilter::Pointer processingChain = ProcessingChainFilter::New();
        processingChain->SetParams(config, product.second, envelope, std::move(images), std::move(polyIds), srid);
        processingChain->UpdateOutputInformation();
        processingChain->GetStreamer()->GetStreamingManager()->SetDefaultRAM(12000);
        processingChain->UpdateOutputInformation();
        if (processingChain->ValidAOI())
            processingChain->Update();

    }
}


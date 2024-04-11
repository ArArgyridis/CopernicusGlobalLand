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
#include <limits>
#include <memory>

#include "../../PostgreSQL/PostgreSQL.h"
#include "PolygonStats.h"

void PolygonStats::finalizeData() {
    if(finalized)
        return;

    if (validCount != 0 || sd > pow(mean/validCount, 2)) {
        mean /= validCount;
        sd = sqrt((sd/validCount) - pow(mean, 2));
    }
    finalized = true;
}

JsonDocumentUniquePtr PolygonStats::histogramToJSON() {
    //setting histogram Object
    JsonDocumentUniquePtr tmpHistogram = std::make_unique<rapidjson::Document>(rapidjson::kObjectType);

    rapidjson::Document::AllocatorType &allocator = tmpHistogram->GetAllocator();
    JsonValuePtr histogramXAxis = std::make_unique<rapidjson::Value>(rapidjson::kArrayType);

    for (auto& it: histogramRanges)
        histogramXAxis->PushBack(it, allocator);

    tmpHistogram->AddMember("x", *histogramXAxis, allocator);

    JsonValuePtr histogramYAxis = std::make_unique<rapidjson::Value>(rapidjson::kArrayType);
    for (auto& val:histogram)
        histogramYAxis->PushBack(val, allocator);

    tmpHistogram->AddMember("y", *histogramYAxis, allocator);
    return tmpHistogram;
}

PolygonStats::PolygonStats(ProductVariable::SharedPtr variable, size_t polyID): finalized(false), polyID(polyID), validCount(0), totalCount(0), variable(variable) {
    mean = sd = 0;

    min = std::numeric_limits<float>::max();
    max = -std::numeric_limits<float>::min();

    std::fill(densityArray.begin(),densityArray.end(), 0.0);

    histogram.reserve(this->variable->histogramBins);
    histogram.resize(this->variable->histogramBins);
    std::fill(histogram.begin(), histogram.end(), 0);

    float histWidth = (this->variable->minMaxValues[1]- this->variable->minMaxValues[0])/this->variable->histogramBins;

    histogramRanges.reserve(this->variable->histogramBins+1);
    histogramRanges.resize(this->variable->histogramBins+1);

    for (size_t i = 0; i < this->variable->histogramBins+1; i++)
        histogramRanges[i] = this->variable->minMaxValues[0] +i*histWidth;

    densityColors = std::vector<RGBVal>(4);
    for (auto & color: densityColors)
        color.fill(0);
}

PolygonStats::~PolygonStats(){}

PolygonStats::Pointer PolygonStats::New(ProductVariable::SharedPtr variable, const size_t &polyID) {
    return std::shared_ptr<PolygonStats>(new PolygonStats(variable, polyID));
}

PolygonStats::PolyStatsMapPtr PolygonStats::NewPointerMap(const LabelsArrayPtr &labels, ProductVariable::SharedPtr variable) {
    PolyStatsMapPtr myMap = std::make_shared<PolyStatsMap>();

    for(const size_t & id: *labels)
        myMap->insert(std::pair<size_t, Pointer>(id,PolygonStats::New(variable, id)));

    return myMap;
}

PolygonStats::PolyStatsPerRegionPtr PolygonStats::NewPolyStatsPerRegionMap(size_t regionCount, const LabelsArrayPtr labels, ProductVariable::SharedPtr variable ){
    PolyStatsPerRegionPtr ret = std::make_shared<PolyStatsPerRegion>();
    for (size_t i = 0; i < regionCount; i++)
        (*ret)[i] = NewPointerMap(labels, variable);
    return ret;
}

PolygonStats::PolyStatsPerRegionPtr PolygonStats::NewPolyStatsPerRegionMap(ImagesInfo& images, const LabelsArrayPtr labels, ProductVariable::SharedPtr variable) {
    PolyStatsPerRegionPtr ret = std::make_shared<PolyStatsPerRegion>();
    for (auto& img: images)
        (*ret)[img.first] = NewPointerMap(labels, variable);
    return ret;
}

void PolygonStats::addToHistogram(float &value) {
    bool stop = false;
    for (size_t i = 0; i < variable->histogramBins && !stop; i++ ) {
        stop = histogramRanges[i] <= value && value < histogramRanges[i+1];
        histogram[i] += static_cast<int>(stop);
    }
}

std::string PolygonStats::getCSVLine(char separator) {
    finalizeData();
    auto hist = histogramToJSON();
    std::stringstream data;

    data << mean << separator << sd << separator << min <<separator << max <<separator << densityArray[0]/10000 <<separator
         << densityArray[1]/10000 <<separator << densityArray[2]/10000 <<separator << densityArray[3]/10000 << separator << '\''
         << jsonToString(*hist) << '\'' << separator << totalCount <<separator << validCount;
    return data.str();
}

std::string PolygonStats::getCSVHeader() {
    return "mean sd min max novalarea_ha lowval_area_ha midval_area_ha highval_area_ha histogram_json total_count valid_count";
}

void PolygonStats::collapseData(PolyStatsPerRegionPtr source, PolyStatsMapPtr destination) {
    if (source == nullptr || destination == nullptr)
        return;

    for(auto& sourceRegionData: *source) {
        for (auto& polyData: *sourceRegionData.second) {
            auto outputPolygonStats = destination->find(polyData.first);
            if(outputPolygonStats == destination->end())
                continue;
            auto polyStat = polyData.second;
            if(polyStat->validCount == 0)
                continue;

            outputPolygonStats->second->totalCount += polyStat->totalCount;
            outputPolygonStats->second->validCount += polyStat->validCount;
            outputPolygonStats->second->mean       += polyStat->mean;
            outputPolygonStats->second->sd         += polyStat->sd;

            if (outputPolygonStats->second->min > polyStat->min)
                outputPolygonStats->second->min  = polyStat->min;

            if (outputPolygonStats->second->max < polyStat->max)
                outputPolygonStats->second->max = polyStat->max;

            for (size_t i = 0; i < outputPolygonStats->second->densityArray.size(); i++)
                outputPolygonStats->second->densityArray[i] += polyStat->densityArray[i];

            for(size_t i = 0; i <outputPolygonStats->second->variable->histogramBins; i++)
                outputPolygonStats->second->histogram[i] += polyStat->histogram[i];
        }
    }
}

void PolygonStats::updateDB(const size_t &productFileID, Configuration::SharedPtr cfg, PolyStatsMapPtr polygonData){
    std::stringstream data;
    for(auto & polyData:*polygonData) {
        data  <<"(" << polyData.first << ',' << productFileID << ',' << polyData.second->variable->id << ',' << polyData.second->getCSVLine(',') << "),";
    }

    if (data.tellp() == 0)
        return;

    std::string query = "WITH tmp_data(poly_id, product_file_id, product_file_variable_id, mean, sd, min_val,max_val, noval_area_ha, sparse_area_ha, mid_area_ha, dense_area_ha,"
                        " histogram, total_pixels, valid_pixels) AS( VALUES " + stringstreamToString(data) + ")" +
                        " INSERT INTO poly_stats(poly_id, product_file_id, product_file_variable_id, mean, sd, min_val, max_val, noval_area_ha, sparse_area_ha, mid_area_ha, dense_area_ha,"
                        "  histogram, total_pixels, valid_pixels)"
                        " SELECT tdt.poly_id::bigint, tdt.product_file_id::bigint, tdt.product_file_variable_id::bigint, mean::double precision, sd::double precision, min_val::double precision, max_val::double precision, tdt.noval_area_ha::double precision,"
                        " tdt.sparse_area_ha::double precision, tdt.mid_area_ha::double precision, tdt.dense_area_ha::double precision,"
                        " histogram::jsonb, total_pixels::bigint, valid_pixels::bigint"
                        " FROM tmp_data tdt"
                        " ON CONFLICT(poly_id, product_file_id, product_file_variable_id) DO NOTHING;";

    PGPool::PGConn::UniquePtr cn = PGPool::PGConn::New(cfg->connectionIds[cfg->statsInfo.connectionId]);
    cn->executeQuery(query);
}

void PolygonStats::updateDBTmp(const size_t &productFileID, size_t& regionId, Configuration::SharedPtr cfg, PolyStatsMapPtr polygonData) {
    std::stringstream data;

    for(auto & polyData:*polygonData) {
        polyData.second->finalizeData();
        data  <<"(" << polyData.first << ',' << productFileID << ',' << polyData.second->variable->id << ','<< regionId << ',' << polyData.second->getCSVLine(',') << "),";
    }

    if (data.tellp() == 0)
        return;

    std::string query = "WITH tmp_data(poly_id, product_file_id, product_file_variable_id, region_id, mean, sd, min_val,max_val, noval_area_ha, sparse_area_ha, mid_area_ha, dense_area_ha,"
                        " histogram, total_pixels, valid_pixels) AS( VALUES " + stringstreamToString(data) + ")" +
            " INSERT INTO tmp.poly_stats_per_region(poly_id, product_file_id, product_file_variable_id, region_id, mean, sd, min_val, max_val, noval_area_ha, sparse_area_ha, mid_area_ha, dense_area_ha,"
            "  histogram, total_pixels, valid_pixels)"
            " SELECT tdt.poly_id::bigint, tdt.product_file_id::bigint, tdt.product_file_variable_id::bigint, region_id::bigint, mean::double precision, sd::double precision, min_val::double precision, max_val::double precision, tdt.noval_area_ha::double precision,"
            " tdt.sparse_area_ha::double precision, tdt.mid_area_ha::double precision, tdt.dense_area_ha::double precision,"
            " histogram::jsonb, total_pixels::bigint, valid_pixels::bigint"
            " FROM tmp_data tdt"
            " ON CONFLICT(poly_id, product_file_id, product_file_variable_id, region_id) DO NOTHING;";

    PGPool::PGConn::UniquePtr cn = PGPool::PGConn::New(cfg->connectionIds[cfg->statsInfo.connectionId]);
    cn->executeQuery(query);
}




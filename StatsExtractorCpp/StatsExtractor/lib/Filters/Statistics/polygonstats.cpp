#include <memory>

#include "polygonstats.hxx"
#include "../../PostgreSQL/postgresql.hxx"

JsonDocumentPtr PolygonStats::histogramToJSON() {
    computeColors();
    //setting histogram Object
    JsonDocumentPtr tmpHistogram = std::make_unique<rapidjson::Document>(rapidjson::kObjectType);

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



PolygonStats::PolygonStats(ProductInfo::Pointer prod, size_t polyID, size_t histBins):polyID(polyID), validCount(0), totalCount(0), histogramBins(histBins), product(prod) {
    mean = sd = 0;

    std::fill(densityArray.begin(),densityArray.end(), 0.0);

    histogram.reserve(histogramBins);
    histogram.resize(histogramBins);
    std::fill(histogram.begin(), histogram.end(), 0);

    float histWidth = (product->minMaxValues[1]-product->minMaxValues[0])/histogramBins;

    histogramRanges.reserve(histogramBins+1);
    histogramRanges.resize(histogramBins+1);

    for (size_t i = 0; i < histogramBins+1; i++)
        histogramRanges[i] = product->scaleValue(product->minMaxValues[0] +i*histWidth);

}

PolygonStats::~PolygonStats(){};

PolygonStats::Pointer PolygonStats::New(ProductInfo::Pointer prod, const size_t &polyID, size_t histBins) {
    return std::make_shared<PolygonStats>(prod, polyID, histBins);
}

PolygonStats::MapPointer PolygonStats::NewPointerMap(const std::vector<size_t> &labels, ProductInfo::Pointer prod, size_t histBins) {
    MapPointer myMap = std::make_shared<PolygonStatsMap>();

    for(const size_t & id: labels)
        (*myMap)[id] = PolygonStats::New(prod, id, histBins);

    return myMap;
}

void PolygonStats::addToHistogram(float &value) {
    bool stop = false;
    for (size_t i = 0; i <histogramBins &&!stop; i++ ) {
        stop = histogramRanges[i] <= value && value <=histogramRanges[i+1];
        histogram[i] += (int)(stop);
    }
}

void PolygonStats::computeColors() {
    long double area = product->convertPixelsToArea(validCount);
    noValColor = product->noVal.interpolateColor(densityArray[0]/area);
    sparseValColor = product->sparseVal.interpolateColor(densityArray[1]/area);
    mildValColor = product->mildVal.interpolateColor(densityArray[2]/area);
    denseValColor = product->denseVal.interpolateColor(densityArray[3]/area);
}





void PolygonStats::updateDB(size_t &productFileID, Configuration::Pointer cfg){
    if (validCount == 0)
        return;

    auto hist = this->histogramToJSON();
    std::stringstream data;

    data  <<"(" << polyID <<"," << productFileID <<"," << densityArray[0]/10000 <<"," << densityArray[1]/10000 <<"," << densityArray[2]/10000 <<"," << densityArray[3]/10000
         <<",'"<<rgbToArrayString(noValColor) <<"','" <<rgbToArrayString(sparseValColor) <<"','" << rgbToArrayString(mildValColor) << "','" << rgbToArrayString(denseValColor) <<"','"
         << jsonToString(*hist) << "'," << totalCount <<"," <<validCount << ")";

    std::string query = "WITH tmp_data(poly_id, product_file_id, noval_area_ha, sparse_area_ha, mid_area_ha, dense_area_ha,"
                        " noval_color, sparseval_color, midval_color, highval_color, histogram, total_pixels, valid_pixels) AS( VALUES " + data.str() + ")"
                        " INSERT INTO " + cfg->statsInfo.schema +".poly_stats(poly_id, product_file_id, noval_area_ha, sparse_area_ha, mid_area_ha, dense_area_ha,"
                        " noval_color, sparseval_color, midval_color, highval_color, histogram, total_pixels, valid_pixels)"
                        " SELECT tdt.poly_id::bigint, tdt.product_file_id::bigint, tdt.noval_area_ha::double precision, "
                        " tdt.sparse_area_ha::double precision, tdt.mid_area_ha::double precision, tdt.dense_area_ha::double precision,"
                        " noval_color::jsonb, sparseval_color::jsonb, midval_color::jsonb, highval_color::jsonb, histogram::jsonb, total_pixels::bigint, valid_pixels::bigint"
                        " FROM tmp_data tdt"
                        " ON CONFLICT(poly_id, product_file_id) DO NOTHING;";

    PGPool::PGConn::Pointer cn = PGPool::PGConn::New(cfg->connectionIds[cfg->statsInfo.connectionId]);
    cn->executeQuery(query);
}



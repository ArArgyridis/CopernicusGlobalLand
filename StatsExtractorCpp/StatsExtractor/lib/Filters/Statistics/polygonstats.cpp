#include "polygonstats.hxx"


PolygonStats::PolygonStats(ProductInfoPtr prod, size_t histBins):validCount(0), totalCount(0), histogramBins(histBins), product(prod) {
    mean = sd = 0;

    densityArray.fill(0);

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

PolygonStats::Pointer PolygonStats::New(ProductInfoPtr prod, size_t histBins) {
    return std::make_shared<PolygonStats>(prod, histBins);
}

PolygonStats::MapPointer PolygonStats::NewPointerMap(const std::vector<size_t> &labels, ProductInfoPtr prod, size_t histBins) {
    MapPointer myMap = std::make_shared<PolygonStatsMap>();

    for(const size_t & id: labels)
        (*myMap)[id] = PolygonStats::New(prod, histBins);

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
    auto asd = product->noval.interpolateColor(densityArray[0]);
}

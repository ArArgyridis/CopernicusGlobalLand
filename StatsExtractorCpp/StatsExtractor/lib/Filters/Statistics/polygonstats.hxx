#ifndef POLYGONSTATS_HXX
#define POLYGONSTATS_HXX
#include <array>
#include <itkVariableLengthVector.h>
#include <map>
#include <memory>
#include <set>
#include <vector>

#include "../../Constants/constants.hxx"

class PolygonStats {
    std::vector<float> histogramRanges;
    size_t polyID;

    JsonDocumentPtr histogramToJSON();

public:
    using Pointer = std::shared_ptr<PolygonStats>;
    using PolygonStatsMap = std::map<std::size_t, Pointer>;
    using MapPointer = std::shared_ptr<PolygonStatsMap>;

    PolygonStats(ProductInfo::Pointer prod, size_t polyID, size_t histBins=10);
    ~PolygonStats();

    static Pointer New(ProductInfo::Pointer prod, const size_t &polyID, size_t histBins=10);
    static MapPointer NewPointerMap(const std::vector<size_t> &labels, ProductInfo::Pointer prod, size_t histBins=10);
    void addToHistogram(float &value);
    void computeColors();
    void updateDB(size_t& productFileID, Configuration::Pointer cfg);



    long double mean, sd;
    std::array<long double, 4> densityArray;
    size_t validCount, totalCount, histogramBins;
    ProductInfo::Pointer product;
    std::vector<size_t> histogram;
    RGBVal noValColor, sparseValColor, mildValColor, denseValColor;
};

#endif // POLYGONSTATS_HXX

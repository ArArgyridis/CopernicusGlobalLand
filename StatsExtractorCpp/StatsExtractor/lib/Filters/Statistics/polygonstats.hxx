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

public:
    using Pointer = std::shared_ptr<PolygonStats>;
    using PolygonStatsMap = std::map<std::size_t, Pointer>;
    using MapPointer = std::shared_ptr<PolygonStatsMap>;

    PolygonStats(ProductInfoPtr prod, size_t histBins=10);
    ~PolygonStats();

    static Pointer New(ProductInfoPtr prod, size_t histBins=10);
    static MapPointer NewPointerMap(const std::vector<size_t> &labels, ProductInfoPtr prod, size_t histBins=10);
    void addToHistogram(float &value);
    void computeColors();


    long double mean, sd;
    std::array<long double, 4> densityArray;
    size_t validCount, totalCount, histogramBins;
    ProductInfoPtr product;
    std::vector<size_t> histogram;
};

#endif // POLYGONSTATS_HXX

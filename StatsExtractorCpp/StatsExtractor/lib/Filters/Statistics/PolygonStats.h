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

#ifndef POLYGONSTATS_HXX
#define POLYGONSTATS_HXX
#include <array>
#include <itkVariableLengthVector.h>
#include <map>
#include <memory>
#include <set>
#include <vector>

#include "../../Constants/Constants.h"
#include "../../Utils/Utils.hxx"

class PolygonStats {
    std::vector<float> histogramRanges;
    size_t polyID;

    JsonDocumentPtr histogramToJSON();

public:
    using Pointer               = std::shared_ptr<PolygonStats>;
    using PolyStatsMap          = std::map<std::size_t, Pointer>;
    using PolyStatsMapPtr       = std::shared_ptr<PolyStatsMap>;
    using PolyStatsArray        = std::vector<Pointer>;
    using PolyStatsArrayPtr     = std::shared_ptr<PolyStatsArray>;
    using PolyStatsPerRegion    = std::map<std::size_t, PolyStatsArrayPtr>;
    using PolyStatsPerRegionPtr = std::shared_ptr<PolyStatsPerRegion>;

    PolygonStats(ProductInfo::Pointer prod, size_t polyID);
    ~PolygonStats();

    static Pointer New(ProductInfo::Pointer& prod, const size_t& polyID);
    static PolyStatsMapPtr NewPointerMap(const LabelsArrayPtr& labels, ProductInfo::Pointer& prod);
    static PolyStatsPerRegionPtr NewPolyStatsPerRegionMap(size_t regionCount, const LabelsArrayPtr& labels, ProductInfo::Pointer& prod);

    static void collapseData(PolyStatsPerRegionPtr source, PolyStatsMapPtr destination, ProductInfo::Pointer product);
    static void finalizeStatistics(PolyStatsMapPtr stats);

    void addToHistogram(float &value);
    void computeColors();
    static void updateDB(const size_t& productFileID, Configuration::Pointer cfg, PolyStatsMapPtr polygonData);
    static void updateDBTmp(const size_t& productFileID, size_t &regionId, Configuration::Pointer cfg, PolyStatsMapPtr polygonData);


    long double mean, sd;
    float min, max;
    std::array<long double, 4> densityArray;
    size_t validCount, totalCount;
    ProductInfo::Pointer product;
    std::vector<size_t> histogram;
    std::vector<RGBVal> densityColors;
    template <class InputPixelType, class LabelPixelType>
    inline void updateStats(InputPixelType& pixelData) { //apply it on valid polygon pixels!
        totalCount++;


        if (pixelData == static_cast<InputPixelType>(this->product->getNoData()))
            return;

        validCount++;

        auto val = product->lutProductValues[pixelData-product->minMaxValues[0]];
        mean += val;
        sd   += pow(val,2);

        if (min > val)
            min = val;

        if (max < val)
            max = val;

        size_t idx = (val <= product->valueRange.low)*0 +
                (product->valueRange.low <= val && val < product->valueRange.mid)*1 +
                (product->valueRange.mid <= val && val < product->valueRange.high)*2 +
                (val >= product->valueRange.high)*3;

        this->densityArray[idx]++;
        this->addToHistogram(val);
    }

};

#endif // POLYGONSTATS_HXX

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
    bool finalized;

    JsonDocumentUniquePtr histogramToJSON();
    void finalizeData();

public:
    using Pointer               = std::shared_ptr<PolygonStats>;
    using PolyStatsMap          = std::map<std::size_t, Pointer>;
    using PolyStatsMapPtr       = std::shared_ptr<PolyStatsMap>;
    using PolyStatsPerRegion    = std::map<std::size_t, PolyStatsMapPtr>;
    using PolyStatsPerRegionPtr = std::shared_ptr<PolyStatsPerRegion>;
    using ImagesInfo            = std::map<size_t,std::string>;

    ~PolygonStats();

    static Pointer New(ProductVariable::SharedPtr variable, const size_t& polyID);
    static PolyStatsMapPtr NewPointerMap(const LabelsArrayPtr& labels,ProductVariable::SharedPtr variable);
    static PolyStatsPerRegionPtr NewPolyStatsPerRegionMap(size_t regionCount, const LabelsArrayPtr labels, ProductVariable::SharedPtr variable);
    static PolyStatsPerRegionPtr NewPolyStatsPerRegionMap(ImagesInfo& images, const LabelsArrayPtr labels, ProductVariable::SharedPtr variable);

    void addToHistogram(float &value);
    std::string getCSVLine(char separator=' ');
    static void collapseData(PolyStatsPerRegionPtr source, PolyStatsMapPtr destination);
    static std::string getCSVHeader();
    static void updateDB(const size_t& productFileID, Configuration::SharedPtr cfg, PolyStatsMapPtr polygonData);
    static void updateDBTmp(const size_t& productFileID, size_t &regionId, Configuration::SharedPtr cfg, PolyStatsMapPtr polygonData);
    long double mean, sd;
    float min, max;
    std::array<long double, 4> densityArray;
    size_t validCount, totalCount;
    ProductVariable::SharedPtr variable;
    std::vector<size_t> histogram;
    std::vector<RGBVal> densityColors;

    template <class InputPixelType, class LabelPixelType>
    inline void updateStats(InputPixelType& pixelData) { //apply it on valid polygon pixels!

        totalCount++;
        if (pixelData == static_cast<InputPixelType>(this->variable->getNoData()))
            return;

        validCount++;

        auto val = variable->lutProductValues[pixelData-variable->minMaxValues[0]];
        mean += val;
        sd   += pow(val,2);
        min = (min > val)*val + (min <= val)*min;
        max = (max < val)*val + (max >= val)*max;
        //std::cout << max <<"\t" << val <<"\t" << (max < val) <<"\n";

        size_t idx = (val <= variable->valueRange.low)*0 +
                (variable->valueRange.low <= val && val < variable->valueRange.mid)*1 +
                (variable->valueRange.mid <= val && val < variable->valueRange.high)*2 +
                (val >= variable->valueRange.high)*3;

        this->densityArray[idx]++;
        this->addToHistogram(val);

    }
protected:
    PolygonStats(ProductVariable::SharedPtr variable, size_t polyID);
};

#endif // POLYGONSTATS_HXX

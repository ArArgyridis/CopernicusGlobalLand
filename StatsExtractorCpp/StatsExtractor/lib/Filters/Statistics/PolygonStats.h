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

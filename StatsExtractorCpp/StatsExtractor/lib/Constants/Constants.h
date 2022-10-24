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
#ifndef CONSTANTS_HXX
#define CONSTANTS_HXX
#include <map>
#include <memory>
#include <rapidjson/document.h>
#include <string>

#include "../ConfigurationParser/ConfigurationParser.h"
#include "../PostgreSQL/PostgreSQL.h"
#include "../Utils/ColorInterpolation.h"
#include "../Utils/Utils.hxx"

struct ValueRange {
    float low, mid, high;
};

class ProductInfo {
    Configuration::Pointer config;
    void loadMetadata();
    MetadataDictPtr metadata;
    float scaleFactor, addOffset, pixelSize, noData;
    float (*scaler)(float, float&, float&);
    long double (*pixelsToArea)(long double&, long double);

public:
    using Pointer = std::shared_ptr<ProductInfo>;

    std::string productType, pattern, types, dateptr, variable, style, fileNameCreationPattern;
    rapidjson::Document novalColorRamp, sparsevalColorRamp, midvalColorRamp, highvalColorRamp;
    boost::filesystem::path rootPath, firstProductPath;
    std::vector<std::string> productNames;
    size_t id;
    ValueRange valueRange;
    std::array<float, 2> minMaxValues;
    std::vector<float> lutProductValues;
    std::array<ColorInterpolation, 4> colorInterpolation; //0 - no val, 1 - sparce val, 2- mild val, 3- dense val


    ProductInfo();
    ProductInfo(PGPool::PGConn::PGRow row, Configuration::Pointer cfg);
    long double convertPixelsToArea(long double pixels);
    float getNoData();
    boost::filesystem::path productAbsPath(boost::filesystem::path &relPath);
    float scaleValue(float value);

};

class Constants {
public:
    static std::map<std::size_t, ProductInfo::Pointer> productInfo;
    Constants();
    static unsigned short load(Configuration::Pointer cfg);

};

#endif // CONSTANTS_HXX

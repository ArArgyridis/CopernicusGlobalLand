/*
   Copyright (C) 2024  Argyros Argyridis arargyridis at gmail dot com
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

#ifndef PRODUCTVARIABLE_H
#define PRODUCTVARIABLE_H
#include <array>
#include <rapidjson/document.h>
#include <vector>

#include "../Utils/ColorInterpolation.h"
#include "../Utils/Utils.hxx"

struct ValueRange {
    float low, mid, high;
};

class ProductInfo;
class ProductVariable {
    std::weak_ptr<ProductInfo> product;
    long double (*pixelsToArea)(long double&, long double);
    float scaleFactor, addOffset, pixelSize, noData;
    float (*scaler)(float, float&, float&);
    size_t (*reverseScaler)(float, float&, float&);
    void loadMetadata();

public:
    MetadataDictPtr metadata;
    using SharedPtr = std::shared_ptr<ProductVariable>;
    StringPtr productType;
    PathSharedPtr rootPath, firstProductPath, firstProductVariablePath;
    std::vector<RGBVal> styleColors;
    rapidjson::Document novalColorRamp, sparsevalColorRamp, midvalColorRamp, highvalColorRamp;
    size_t id;
    std::string variable, style, description;

    unsigned short histogramBins;
    ValueRange valueRange;
    std::array<float, 2> minMaxProdValues;
    std::array<float, 2> minMaxValues;
    bool computeStatistics;
    std::vector<float> lutProductValues;
    std::array<ColorInterpolation, 4> colorInterpolation; //0- no val, 1- sparce val, 2- mild val, 3- dense val


    long double convertPixelsToArea(long double pixels);
    float getNoData();
    float getOffset();
    float getScaleFactor();
    std::filesystem::path productAbsPath(std::filesystem::path relPath);
    size_t reverseValue(float value);
    void setProductRef(std::weak_ptr<ProductInfo> prd);
    float scaleValue(float value);
    static SharedPtr New(JsonValue& params, StringPtr prdType, PathSharedPtr rootPath, PathSharedPtr firstProductPath);
    std::shared_ptr<ProductInfo> getProductInfo();

protected:
    ProductVariable();
    ProductVariable(JsonValue& params, StringPtr prdType, PathSharedPtr rootPath, PathSharedPtr firstProductPath);
};

#endif // PRODUCTVARIABLE_H

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

#include "ProductVariable.h"

ProductVariable::ProductVariable() {}

ProductVariable::ProductVariable(JsonValue &params, StringPtr prdType , PathSharedPtr rootPath, PathSharedPtr firstProductPath):productType(prdType), rootPath(rootPath),
    firstProductPath(firstProductPath), firstProductVariablePath(firstProductPath), addOffset(0) {

    id              = params["id"].GetInt64();
    variable        = params["variable"].GetString();
    if(!params["style"].IsNull())
        style       = params["style"].GetString();
    styleColors     = styleColorParser(style);
    if(!params["description"].IsNull())
        description = params["description"].GetString();
    histogramBins   = params["histogram_bins"].GetInt64();

    valueRange.low  = params["low_value"].GetDouble();
    valueRange.mid  = params["mid_value"].GetDouble();
    valueRange.high = params["high_value"].GetDouble();

    minMaxProdValues[0] = params["min_prod_value"].GetDouble();
    minMaxProdValues[1] = params["max_prod_value"].GetDouble();
    minMaxValues[0]     = params["min_value"].GetDouble();
    minMaxValues[1]     = params["max_value"].GetDouble();
    computeStatistics   = params["compute_statistics"].GetBool();
    if(params.FindMember("anomalies") != params.MemberEnd() && params["anomalies"].IsArray() ) {
        for(auto &id : params["anomalies"].GetArray())
            anomalyVariableIds.emplace_back(id.GetInt64());
    }


    std::vector<std::string> colorRamps = {"noval_colors", "sparseval_colors", "midval_colors", "highval_colors"};
    for (size_t i = 0; i < colorRamps.size(); i++)
        colorInterpolation[i] = ColorInterpolation(params[colorRamps[i].c_str()]);

    if (firstProductPath != nullptr) {
        if((*productType == "raw" || *productType == "lts") && firstProductPath->extension() == ".nc")
            firstProductVariablePath = std::make_shared<std::filesystem::path>(std::string("NETCDF:") + firstProductPath->string() + ":" + variable);

        loadMetadata();
    }
}

ProductVariable::SharedPtr ProductVariable::New(JsonValue &params, StringPtr prdType, PathSharedPtr rootPath, PathSharedPtr firstProductPath) {
    return std::shared_ptr<ProductVariable>(new ProductVariable(params, prdType, rootPath, firstProductPath));
}


std::filesystem::path ProductVariable::productAbsPath(std::filesystem::path relPath) {
    std::filesystem::path retPath;

    if(relPath.extension() == ".nc")
        retPath = std::string("NETCDF:") + (*rootPath/relPath).string() + ":" + variable;
    else
        retPath = *rootPath/relPath;
    return retPath;
}

float ProductVariable::getScaleFactor() {
    return scaleFactor;
}

float ProductVariable::getOffset() {
    return addOffset;
}

std::shared_ptr<ProductInfo> ProductVariable::getProductInfo() {
    if(!product.expired())
        return std::shared_ptr<ProductInfo>(product);
    return nullptr;
}

size_t ProductVariable::reverseValue(float value) {
    return reverseScaler(value, scaleFactor, addOffset);
}

void ProductVariable::setProductRef(std::weak_ptr<ProductInfo> prd) {
    if(product.expired())
        product = prd;
}

float ProductVariable::scaleValue(float value) {
    return scaler(value, scaleFactor, addOffset);
}


long double ProductVariable::convertPixelsToArea(long double pixels) {
    return pixelsToArea(pixels, pixelSize);
}

float ProductVariable::getNoData() {
    return noData;
}

void ProductVariable::loadMetadata() {
    if (firstProductVariablePath->empty())
        return;

    scaler = &noScalerFunc;
    reverseScaler = &reverseNoScalerFunc;
    metadata = getMetadata(*firstProductVariablePath);
    if ( std::stod((*metadata)["SCALE"]) != 1.0 || std::stod((*metadata)["OFFSET"]) != 0.0) {
        scaleFactor = std::stod((*metadata)["SCALE"]);
        addOffset = std::stod((*metadata)["OFFSET"]);
        scaler = &scalerFunc;
        reverseScaler = &reverseScalerFunc;
    }

    /*
    std::string s = (firstProductVariablePath->string()).substr(0,6);
    if (firstProductVariablePath->extension() == ".nc") {
        if (metadata->find(variable+"#scale_factor") != metadata->end()) {
            scaleFactor = std::stod((*metadata)[variable+"#scale_factor"]);
            if((*metadata)[variable+"#add_offset"].length() > 0)
                addOffset = std::stod((*metadata)[variable+"#add_offset"]);
                scaler = &scalerFunc;
                reverseScaler = &reverseScalerFunc;
        }
    }
    else if (firstProductVariablePath->extension() == ".tiff") {
        for (const auto& key: *metadata)
            std::cout << key.first << "\n";
    }
    */


    noData = stof((*metadata)["MY_NO_DATA_VALUE"]);

    if ((*metadata)["MY_UNIT"]== "degree")
        pixelsToArea = &pixelsToAreaM2Degrees;
    else
        pixelsToArea = &pixelsToAreaM2Meters;

    pixelSize = stof((*metadata)["MY_PIXEL_SIZE"]);

    lutProductValues = std::vector<float>(minMaxProdValues[1]-minMaxProdValues[0]+1);
    size_t i;
#pragma omp parallel shared(lutProductValues,minMaxValues, scaleFactor, addOffset) private(i)
    {
#pragma omp for
        for (i = 0; i < lutProductValues.size(); i++)
            lutProductValues[i] = scaler(minMaxProdValues[0]+static_cast<int>(i), scaleFactor, addOffset);
    }
}

#include "ProductVariable.h"

ProductVariable::ProductVariable() {}

ProductVariable::ProductVariable(JsonValue &params, StringPtr prdType , PathSharedPtr rootPath, PathSharedPtr firstProductPath):productType(prdType), rootPath(rootPath),
firstProductPath(firstProductPath), firstProductVariablePath(firstProductPath), addOffset(0) {

    id              = params["id"].GetInt64();
    variable        = params["variable"].GetString();
    style           = params["style"].GetString();
    styleColors     = styleColorParser(style);
    description     = params["description"].GetString();
    histogramBins   = params["histogram_bins"].GetInt64();

    valueRange.low  = params["low_value"].GetDouble();
    valueRange.mid  = params["mid_value"].GetDouble();
    valueRange.high = params["high_value"].GetDouble();

    minMaxProdValues[0] = params["min_prod_value"].GetDouble();
    minMaxProdValues[1] = params["max_prod_value"].GetDouble();
    minMaxValues[0]     = params["min_value"].GetDouble();
    minMaxValues[1]     = params["max_value"].GetDouble();
    computeStatistics   = params["compute_statistics"].GetBool();

    std::vector<std::string> colorRamps = {"noval_colors", "sparseval_colors", "midval_colors", "highval_colors"};
    for (size_t i = 0; i < colorRamps.size(); i++)
        colorInterpolation[i] = ColorInterpolation(params[colorRamps[i].c_str()]);

    if (firstProductPath != nullptr) {
        if(*productType == "raw" && firstProductPath->extension() == ".nc")
            firstProductVariablePath = std::make_shared<boost::filesystem::path>(std::string("NETCDF:") + firstProductPath->string() + ":" + variable);

        loadMetadata();
    }
}

ProductVariable::Pointer ProductVariable::New(JsonValue &params, StringPtr prdType, PathSharedPtr rootPath, PathSharedPtr firstProductPath) {
    return std::shared_ptr<ProductVariable>(new ProductVariable(params, prdType, rootPath, firstProductPath));
}


boost::filesystem::path ProductVariable::productAbsPath(boost::filesystem::path &relPath) {
    boost::filesystem::path retPath;

    if(relPath.extension() == ".nc")
        retPath = std::string("NETCDF:") + (*rootPath/relPath).string() + ":" + variable;
    else
        retPath = *rootPath/relPath;
    return retPath;
}


size_t ProductVariable::reverseValue(float value) {
    return reverseScaler(value, scaleFactor, addOffset);
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
    std::string s = (firstProductVariablePath->string()).substr(0,6);

    if ((firstProductVariablePath->string()).substr(0,6) == "NETCDF") {
        if (metadata->find(variable+"#scale_factor") != metadata->end()) {
            scaleFactor = std::stod((*metadata)[variable+"#scale_factor"]);
            if((*metadata)[variable+"#add_offset"].length() > 0)
                addOffset = std::stod((*metadata)[variable+"#add_offset"]);
                scaler = &scalerFunc;
                reverseScaler = &reverseScalerFunc;
        }
    }

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

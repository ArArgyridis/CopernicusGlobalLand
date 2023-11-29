#ifndef PRODUCTVARIABLE_H
#define PRODUCTVARIABLE_H
#include <array>
#include <rapidjson/document.h>
#include <vector>

#include "../PostgreSQL/PostgreSQL.h"
#include "../Utils/ColorInterpolation.h"
#include "../Utils/Utils.hxx"

struct ValueRange {
    float low, mid, high;
};


class ProductVariable {
    long double (*pixelsToArea)(long double&, long double);
    float scaleFactor, addOffset, pixelSize, noData;
    float (*scaler)(float, float&, float&);
    size_t (*reverseScaler)(float, float&, float&);

    void loadMetadata();


public:
    MetadataDictPtr metadata;
    using Pointer = std::shared_ptr<ProductVariable>;
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
    std::filesystem::path productAbsPath(std::filesystem::path &relPath);
    size_t reverseValue(float value);
    float scaleValue(float value);

    static Pointer New(JsonValue& params, StringPtr prdType, PathSharedPtr rootPath, PathSharedPtr firstProductPath);

protected:
    ProductVariable();
    ProductVariable(JsonValue& params, StringPtr prdType, PathSharedPtr rootPath, PathSharedPtr firstProductPath);
};

#endif // PRODUCTVARIABLE_H

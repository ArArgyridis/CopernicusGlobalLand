#ifndef CONSTANTS_HXX
#define CONSTANTS_HXX
#include <map>
#include <memory>
#include <rapidjson/document.h>
#include <string>

#include "../ConfigurationParser/configurationparser.hxx"
#include "../PostgreSQL/postgresql.hxx"
#include "../Utils/utils.hxx"
#include "../Utils/ColorInterpolation.h"

struct ValueRange {
    float low, mid, high;
};

class ProductInfo {
    Configuration::Pointer config;
    void loadMetadata();
    MetadataDictPtr metadata;
    float scaleFactor, addOffset;
    float (*scaler)(float, float&, float&);

public:
    std::string productType, pattern, types, dateptr, variable, style, fileNameCreationPattern;
    rapidjson::Document novalColorRamp, sparsevalColorRamp, midvalColorRamp, highvalColorRamp;
    boost::filesystem::path rootPath, firstProductPath;
    std::vector<std::string> productNames;
    size_t id;
    ValueRange valueRange;
    std::array<float, 2> minMaxValues;
    std::vector<float> lutProductValues;
    ColorInterpolation noval, sparseval, midval, highval;


    ProductInfo();
    ProductInfo(PGConn::PGRow row, Configuration::Pointer cfg);
    boost::filesystem::path productAbsPath(boost::filesystem::path &relPath);
    float scaleValue(float value);

};

using ProductInfoPtr =std::shared_ptr<ProductInfo>;

class Constants {
public:
    static std::map<std::size_t, ProductInfoPtr> productInfo;

    Constants();
    static unsigned short load(Configuration::Pointer cfg);

};

#endif // CONSTANTS_HXX

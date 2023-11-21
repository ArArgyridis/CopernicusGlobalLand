#ifndef PRODUCTORDERPROCESSOR_H
#define PRODUCTORDERPROCESSOR_H

#include <boost/algorithm/string/join.hpp>
#include <boost/filesystem/path.hpp>
#include <gdal.h>
#include <gdal_alg.h>
#include <gdalwarper.h>
#include <memory>
#include <otbExtractROI.h>
#include <otbImage.h>
#include <otbImageFileReader.h>
#include <otbImageFileWriter.h>

#include "../../lib/ConfigurationParser/ConfigurationParser.h"
#include "../../lib/Constants/Constants.h"
#include "../../lib/Filters/IO/VectorWktToLabelImageFilter.hxx"
#include "../../lib/PostgreSQL/PostgreSQL.h"
#include "../../lib/Utils/Utils.hxx"

class ProductOrderProcessor {
    using UCharImageType    = otb::Image<unsigned char, 2>;
    using FloatImageType    = otb::Image<float, 2>;
    using UShortImageType   = otb::Image<unsigned short, 2>;

    struct AOINfo {
        UCharImageType::Pointer labelImagePtr;
        UCharImageType::RegionType::IndexType originIdx;
    };

    std::mutex cropMtx, labelMtx;
    
    Configuration::SharedPtr config;

    template <class TInputImage>
    void crop(std::filesystem::path &inImage, std::filesystem::path &outImage, AOINfo &mask, bool scale=false, double a=0, double b=0);
    void createOutput(std::filesystem::path inRelFile, std::filesystem::path &orderPath, AOINfo& maskInfo, std::string rawOrAnomaly);
    void processSingleFile(std::filesystem::path& inFile, std::filesystem::path& tmpOrderPath, std::filesystem::path& inRelFile, AOINfo& maskInfo, std::string variable="");

    template <class TInputImage>
    AOINfo rasterizeAOI(PathSharedPtr imgPath, std::string& ogrPolygonStr);
    
    void compressAndEMail(std::filesystem::path &tmpOrderPath, std::string orderId, std::string email);
    std::string createAnomaliesDataQuery(rapidjson::GenericMember<rapidjson::UTF8<>, rapidjson::MemoryPoolAllocator<>>& dataReq);
    std::string createRawDataQuery(rapidjson::GenericMember<rapidjson::UTF8<>, rapidjson::MemoryPoolAllocator<>>& dataReq);

protected:
    ProductOrderProcessor(Configuration::SharedPtr& cfg);

public:
    using SharedPtr = std::shared_ptr<ProductOrderProcessor>;
    using UniquePtr = std::unique_ptr<ProductOrderProcessor>;

    void process();
    
    static SharedPtr NewShared(Configuration::SharedPtr& cfg);
    static UniquePtr NewUnique(Configuration::SharedPtr& cfg);



};

#endif // PRODUCTORDERPROCESSOR_H

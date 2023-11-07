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

    Configuration::Pointer config;

    template <class TInputImage>
    void crop(std::filesystem::path &inImage, std::filesystem::path &outImage, AOINfo &mask, bool scale=false, double a=0, double b=0);

    template <class TInputImage>
    AOINfo rasterizeAOI(PathSharedPtr imgPath, std::string& ogrPolygonStr);
    void processFile(std::filesystem::path inRelFile, std::filesystem::path &orderPath, AOINfo& maskInfo);

protected:
    ProductOrderProcessor(Configuration::Pointer& cfg);

public:
    using SharedPtr = std::shared_ptr<ProductOrderProcessor>;
    using UniquePtr = std::unique_ptr<ProductOrderProcessor>;

    void process();

    static SharedPtr NewShared(Configuration::Pointer& cfg);
    static UniquePtr NewUnique(Configuration::Pointer& cfg);



};

#endif // PRODUCTORDERPROCESSOR_H

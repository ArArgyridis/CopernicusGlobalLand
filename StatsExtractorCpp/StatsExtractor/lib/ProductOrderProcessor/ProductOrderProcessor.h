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
#include "../../lib/Filters/IO/VectorWktToLabelImageFilter.hxx"
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
    void crop(boost::filesystem::path &inImage, boost::filesystem::path &outImage, AOINfo &mask, bool scale=false, double a=0, double b=0);

    template <class TInputImage>
    AOINfo rasterizeAOI(PathSharedPtr imgPath, std::string& ogrPolygonStr);

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

#ifndef CROP_HXX
#define CROP_HXX
#include <otbFunctorImageFilter.h>

#include "ProductOrderProcessor.h"
#include "../../lib/Filters/Functors/LinearScaler.h"

template <class TInputImage>
void ProductOrderProcessor::crop(boost::filesystem::path &inImage, boost::filesystem::path &outImage, AOINfo &mask, bool scale, double a, double b) {
    using InputImageReader  = otb::ImageFileReader<TInputImage>;
    using InputImageWriter  = otb::ImageFileWriter<TInputImage>;

    using ExtractRawDataROIFilter   = otb::ExtractROI<typename TInputImage::PixelType, typename TInputImage::PixelType>;
    typename InputImageReader::Pointer reader = InputImageReader::New();
    reader->SetFileName(inImage.c_str());
    {
        std::lock_guard lck(cropMtx);
        reader->UpdateOutputInformation();
    }

    typename ExtractRawDataROIFilter::Pointer extractor = ExtractRawDataROIFilter::New();
    extractor->SetInput(reader->GetOutput());
    extractor->SetStartX(mask.originIdx[0]);
    extractor->SetStartY(mask.originIdx[1]);
    extractor->SetSizeX(mask.labelImagePtr->GetLargestPossibleRegion().GetSize()[0]);
    extractor->SetSizeY(mask.labelImagePtr->GetLargestPossibleRegion().GetSize()[1]);

    auto tmpImage = extractor->GetOutput();

    //scale if needed - it's going to be activated only for float images
    auto scaler = otb::NewFunctorFilter(LinearScaler<typename TInputImage::ValueType, typename TInputImage::ValueType>(a,b));
    if(scale) {
        std::cout << "SCALING!\n";
        scaler->SetInput(tmpImage);
        tmpImage = scaler->GetOutput();
    }

    typename InputImageWriter::Pointer writer = InputImageWriter::New();
    writer->SetFileName(outImage.string()+"?gdal:co:COMPRESS=DEFLATE&gdal:co:PREDICTOR=2&gdal:co:ZLEVEL=9");
    writer->SetInput(tmpImage);
    writer->GetStreamingManager()->SetDefaultRAM(500);
    writer->Update();

    //copying all available metadata inside
    GDALDatasetUniquePtr inGDALDt, outGDALDt;
    inGDALDt = GDALDatasetUniquePtr(GDALDataset::FromHandle(GDALOpen( inImage.c_str(), GA_ReadOnly)));
    outGDALDt = GDALDatasetUniquePtr(GDALDataset::FromHandle(GDALOpen(outImage.c_str(), GA_Update)));
    outGDALDt->SetMetadata(inGDALDt->GetMetadata());

}


template <class TInputImage>
ProductOrderProcessor::AOINfo ProductOrderProcessor::rasterizeAOI(PathSharedPtr imgPath, std::string &ogrPolygonStr){
    using InputImageReader  = otb::ImageFileReader<TInputImage>;
    using RasterizerFilter  = otb::VectorWktToLabelImageFilter<UCharImageType>;

    AOINfo ret;

    UCharImageType::Pointer labelImagePointer = nullptr;
    typename InputImageReader::Pointer inReader = InputImageReader::New();

    using LabelImageWriter = otb::ImageFileWriter<UCharImageType>;
    inReader->SetFileName(imgPath->c_str());
    inReader->UpdateOutputInformation();


    OGRMultiPolygon geom;
    std::unique_ptr<const char*> tmpGeom = std::make_unique<const char*>(const_cast<char*>(ogrPolygonStr.c_str()));
    geom.importFromWkt(tmpGeom.get());
    OGREnvelope aoiEnvelope;
    geom.getEnvelope(&aoiEnvelope);

    aoiEnvelope = alignAOIToImage<TInputImage>(aoiEnvelope, inReader->GetOutput());
    UCharImageType::SpacingType spacing = inReader->GetOutput()->GetSignedSpacing();

    UCharImageType::RegionType::SizeType size;

    size[0] = (aoiEnvelope.MaxX - aoiEnvelope.MinX)/spacing[0];
    size[1] = (aoiEnvelope.MinY - aoiEnvelope.MaxY)/spacing[1];

    UCharImageType::RegionType region;
    region.SetSize(size);


    point2d origin;
    origin[0] = aoiEnvelope.MinX-spacing[0]/2;
    origin[1] = aoiEnvelope.MaxY-spacing[1]/2;

    UCharImageType::IndexType originIdx;
    inReader->GetOutput()->TransformPhysicalPointToIndex(origin, ret.originIdx);

    typename RasterizerFilter::Pointer rasterizer = RasterizerFilter::New();
    rasterizer->SetGeometryMetaData();
    rasterizer->AppendData(ogrPolygonStr,1);
    rasterizer->SetOutputOrigin(origin);
    rasterizer->SetOutputProjectionRef(inReader->GetOutput()->GetProjectionRef());
    rasterizer->SetOutputSignedSpacing(spacing);
    rasterizer->SetOutputRegion(region);
    rasterizer->SetBackgroundValue(0);
    rasterizer->Update();

    LabelImageWriter::Pointer writer = LabelImageWriter::New();
    writer->SetInput(rasterizer->GetOutput());
    writer->SetFileName("test.tif");
    //writer->GetStreamingManager()->SetDefaultRAM(2500);
    writer->Update();


    ret.labelImagePtr = rasterizer->GetOutput();
    return ret;
}
#endif // CROP_HXX

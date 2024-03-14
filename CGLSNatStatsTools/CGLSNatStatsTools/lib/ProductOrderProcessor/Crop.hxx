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

#ifndef CROP_HXX
#define CROP_HXX
#include <otbFunctorImageFilter.h>

#include "ProductOrderProcessor.h"
#include "../../lib/Filters/Functors/LinearScaler.h"

template <class TInputImage>
void ProductOrderProcessor::crop(std::filesystem::path &inImage, std::filesystem::path &outImage, AOINfo &mask, bool scale, double a, double b) {
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
    extractor->SetSizeX(mask.size[0]);
    extractor->SetSizeY(mask.size[1]);

    auto tmpImage = extractor->GetOutput();

    //scale if needed - it's going to be activated only for float images
    auto scaler = otb::NewFunctorFilter(LinearScaler<typename TInputImage::ValueType, typename TInputImage::ValueType>(a,b));
    std::string compressArgs = "";// "?gdal:co:COMPRESS=DEFLATE&gdal:co:PREDICTOR=2&gdal:co:ZLEVEL=9";
    if(scale) {
        scaler->SetInput(tmpImage);
        tmpImage = scaler->GetOutput();
    }

    typename InputImageWriter::Pointer writer = InputImageWriter::New();
    writer->SetFileName(outImage.string()+compressArgs);
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
ProductOrderProcessor::AOINfo ProductOrderProcessor::alignAOI(PathSharedPtr imgPath, OGREnvelope &aoiEnvelope){
    AOINfo ret;
    if (!imgPath) //this will happen iff no files are present for this variable in the DB...
        return ret;
    using InputImageReader  = otb::ImageFileReader<TInputImage>;
    using RasterizerFilter  = otb::VectorWktToLabelImageFilter<otb::UCharImageType>;

    typename InputImageReader::Pointer inReader = InputImageReader::New();
    inReader->SetFileName(imgPath->c_str());
    inReader->UpdateOutputInformation();

    ret.envelope = alignAOIToImage<TInputImage>(aoiEnvelope, inReader->GetOutput());
    otb::UCharImageType::SpacingType spacing = inReader->GetOutput()->GetSignedSpacing();

    ret.size[0] = (ret.envelope.MaxX - ret.envelope.MinX)/spacing[0];
    ret.size[1] = (ret.envelope.MinY - ret.envelope.MaxY)/spacing[1];

    point2d origin;
    origin[0] = ret.envelope.MinX;
    origin[1] = ret.envelope.MaxY;

    inReader->GetOutput()->TransformPhysicalPointToIndex(origin, ret.originIdx);

    /*
    UCharImageType::RegionType region;
    region.SetSize(ret.size);
    typename RasterizerFilter::Pointer rasterizer = RasterizerFilter::New();
    rasterizer->SetGeometryMetaData();
    rasterizer->AppendData(ogrPolygonStr,1);
    rasterizer->SetOutputOrigin(origin);
    rasterizer->SetOutputProjectionRef(inReader->GetOutput()->GetProjectionRef());
    rasterizer->SetOutputSignedSpacing(spacing);
    rasterizer->SetOutputRegion(region);
    rasterizer->SetBackgroundValue(0);
    rasterizer->Update();
    ret.labelImagePtr = rasterizer->GetOutput();
    */

    /*
    using LabelImageWriter = otb::ImageFileWriter<UCharImageType>;
    LabelImageWriter::Pointer writer = LabelImageWriter::New();
    writer->SetInput(rasterizer->GetOutput());
    writer->SetFileName("test.tif");
    //writer->GetStreamingManager()->SetDefaultRAM(2500);
    writer->Update();
    */    
    return ret;
}
#endif // CROP_HXX

/**
   Copyright (C) 2021  Argyros Argyridis arargyridis at gmail dot com
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

#ifndef PROCESSINGCHAINFILTER_HXX
#define PROCESSINGCHAINFILTER_HXX

#include <otbImageFileWriter.h>
#include <otbImage.h>

#include "fmt/format.h"
#include "ProcessingChainFilter.h"
#include "../Constants/Constants.h"

namespace otb {

template <class TInputImage, class TPolygonDataType>
void ProcessingChainFilter<TInputImage, TPolygonDataType>::Reset() {
    repeat = 0;
}



template <class TInputImage, class TPolygonDataType>
void ProcessingChainFilter<TInputImage, TPolygonDataType>::SetParams(const Configuration::Pointer config, const ProductInfo::Pointer product,
                                                                     OGREnvelope &envlp, JsonDocumentPtr images,
                                                                     JsonDocumentPtr polyIds, size_t &polySRID) {
    this->config        = config;
    this->product       = product;
    this->polySRID      = polySRID;

    //setting the reference image as input
    typename RawDataImageReaderType::Pointer reader = RawDataImageReaderType::New();
    reader->SetFileName(this->product->firstProductPath.string().c_str());
    reader->UpdateOutputInformation();
    this->SetNthInput(0, reader->GetOutput());

    this->processGeomIdsAndImages(polyIds, images);
    this->alignAOIToImage(envlp);
}




template <class TInputImage, class TPolygonDataType>
void ProcessingChainFilter<TInputImage, TPolygonDataType>::GenerateInputRequestedRegion() {
    Superclass::GenerateInputRequestedRegion();
    TInputImagePointer inputImage = this->GetReferenceImage(), out = this->GetOutput();
    typename TInputImage::RegionType requestedRegion = out->GetRequestedRegion();

    point2d originPnt;
    typename TInputImage::IndexType originIdx;

    out->TransformIndexToPhysicalPoint(requestedRegion.GetIndex(), originPnt);
    inputImage->TransformPhysicalPointToIndex(originPnt, originIdx);

    requestedRegion.SetIndex(originIdx);
    inputImage->SetRequestedRegion(requestedRegion);


}


template <class TInputImage, class TPolygonDataType>
void ProcessingChainFilter<TInputImage, TPolygonDataType>::GenerateOutputInformation() {
    //Superclass::GenerateOutputInformation();

    TInputImagePointer inputImage = this->GetReferenceImage(), out = this->GetOutput();
    typename TInputImage::SpacingType spacing = inputImage->GetSignedSpacing();


    point2d originPnt;
    typename TInputImage::IndexType originIdx;
    originPnt[0] = aoi.MinX + spacing[0]/2;
    originPnt[1] = aoi.MaxY - abs(spacing[1])/2;
    //inputImage->TransformPhysicalPointToIndex(originPnt, originIdx);

    typename TInputImage::SizeType outSize;
    outSize[0] = (aoi.MaxX-aoi.MinX)/spacing[0];
    outSize[1] = (aoi.MaxY-aoi.MinY)/abs(spacing[1]);

    //cropping to image region extents
    typename TInputImage::RegionType outRegion;
    originIdx.Fill(0);
    outRegion.SetIndex(originIdx);
    outRegion.SetSize(outSize);

    out->SetLargestPossibleRegion(outRegion);
    out->SetOrigin(originPnt);
    out->SetSignedSpacing(inputImage->GetSignedSpacing());
    out->SetProjectionRef(inputImage->GetProjectionRef());

}


template <class TInputImage, class TPolygonDataType>
void ProcessingChainFilter<TInputImage, TPolygonDataType>::Synthetize() {
    std::cout <<"COLLAPSING!!!!\n";
    for(auto &image: productImages) {
        PolygonStats::collapseData(image.second->regionStatistics, image.second->outStats, this->product);
        PolygonStats::updateDB(image.first, config, image.second->outStats);
    }
    std::cout <<"COLLAPSING Finished!!!!\n";



}

template <class TInputImage, class TPolygonDataType>
ProcessingChainFilter<TInputImage, TPolygonDataType>::ProcessingChainFilter() {
    this->SetNumberOfRequiredInputs(1);
}



template <class TInputImage, class TPolygonDataType>
void ProcessingChainFilter<TInputImage, TPolygonDataType>::AfterThreadedGenerateData(){
    repeat++;
}


template <class TInputImage, class TPolygonDataType>
void ProcessingChainFilter<TInputImage, TPolygonDataType>::BeforeThreadedGenerateData() {
    Superclass::BeforeThreadedGenerateData();
    std::cout <<"Repeat: " << repeat <<"\n";
}
template <class TInputImage, class TPolygonDataType>
typename TInputImage::Pointer ProcessingChainFilter<TInputImage, TPolygonDataType>::GetReferenceImage() {
    return static_cast<TInputImage*>(this->ProcessObject::GetInput(0));
}


template <class TInputImage, class TPolygonDataType>
void ProcessingChainFilter<TInputImage, TPolygonDataType>::ThreadedGenerateData(const RegionType& outputRegionForThread, itk::ThreadIdType threadId) {

    typename LabelImageType::Pointer labelImage = this->rasterizer(outputRegionForThread, threadId);
    if (labelImage == nullptr)
        return;

    TInputImagePointer out          = this->GetOutput();
    TInputImagePointer inputImage   = this->GetReferenceImage();

    //getting origin idx
    point2d originPnt;
    typename TInputImage::RegionType::IndexType originRawDataIdx;

    out->TransformIndexToPhysicalPoint(outputRegionForThread.GetIndex(), originPnt);
    inputImage->TransformPhysicalPointToIndex(originPnt, originRawDataIdx);

    for(auto& image:productImages) {
        std::cout <<"Processing image: " <<image.second->path << ")\n";

        typename RawDataImageReaderType::Pointer imgReader= RawDataImageReaderType::New();
        imgReader->SetFileName(image.second->path.c_str());

        {
            std::lock_guard<std::mutex> lock(readMtx);
            imgReader->UpdateOutputInformation();
        }
        typename ExtractRawDataROIFilter::Pointer roi = ExtractRawDataROIFilter::New();

        roi->SetInput(imgReader->GetOutput());
        roi->SetStartX(originRawDataIdx[0]);
        roi->SetStartY(originRawDataIdx[1]);
        roi->SetSizeX(outputRegionForThread.GetSize()[0]);
        roi->SetSizeY(outputRegionForThread.GetSize()[1]);

        typename StreamedStatisticsType::Pointer stats = StreamedStatisticsType::New();
        stats->SetInputLabels(labels);
        stats->SetInputProduct(product);
        stats->SetPolyStatsPerRegion(image.second->regionStatistics, threadId);
        stats->SetInputLabelImage(labelImage);
        stats->SetInputDataImage(roi->GetOutput());
        stats->GetStreamer()->GetStreamingManager()->SetDefaultRAM(7000);

        stats->GlobalWarningDisplayOff();
        stats->Update();
        stats->ReleaseDataFlagOn();
        stats->ResetPipeline();
    }
}

template <class TInputImage, class TPolygonDataType>
typename ProcessingChainFilter<TInputImage, TPolygonDataType>::LabelImageType::Pointer
ProcessingChainFilter<TInputImage, TPolygonDataType>::rasterizer(typename TInputImage::RegionType region, itk::ThreadIdType threadId) {
    //converting region to extent
    TInputImagePointer out = this->GetOutput();
    point2d originPnt;
    out->TransformIndexToPhysicalPoint(region.GetIndex(), originPnt);

    OGREnvelope evlp = regionToEnvelope<TInputImage>(out, region);
    typename TInputImage::SpacingType spacing = out->GetSignedSpacing();
    //loading polygons from DB

    std::string query = fmt::format("with region AS( select st_setsrid((st_makeenvelope({0},{1},{2},{3})),4326) bbox) select sg.id, ST_ASTEXT(ST_MULTI(case when st_contains(region.bbox, sg.geom) then sg.geom else st_intersection(sg.geom, region.bbox) end)) geom from stratification_geom sg join region on TRUE where sg.id IN ({4}) AND st_intersects(sg.geom, region.bbox)",
                                    evlp.MinX-spacing[0]/2, evlp.MinY-abs(spacing[1]/2),evlp.MaxX+spacing[0]/2, evlp.MaxY+abs(spacing[1]/2), polyIdsStr);
    PGPool::PGConn::Pointer cn = PGPool::PGConn::New(Configuration::connectionIds[config->statsInfo.connectionId]);
    PGPool::PGConn::PGRes res = cn->fetchQueryResult(query, "fetching polygon info for thread_"+std::to_string(threadId));

    if(res.empty())
        return nullptr;

    RasterizerFilter::Pointer rasterizer = RasterizerFilter::New();
    rasterizer->SetGeometryMetaData(polySRID);
    for(size_t i = 0; i < res.size(); i++)
        rasterizer->AppendData(res[i][1].as<std::string>(), res[i][0].as<size_t>());

    rasterizer->SetOutputOrigin(originPnt);
    rasterizer->SetOutputRegion(region);
    rasterizer->SetOutputSignedSpacing(spacing);
    rasterizer->SetOutputProjectionRef(out->GetProjectionRef());
    if(rasterizer->GetFeatureCount() == 0)
        return nullptr;

    rasterizer->Update();
/*
    using ULongImageWriterType = otb::ImageFileWriter<LabelImageType>;
    ULongImageWriterType::Pointer labelWriter =ULongImageWriterType::New();
    labelWriter->SetFileName(std::to_string(repeat) + "_"+std::to_string(threadId) + "labelImage_v2.tif");
    labelWriter->SetInput(rasterizer->GetOutput());
    labelWriter->Update();
*/
    return rasterizer->GetOutput();

}



template <class TInputImage, class TPolygonDataType>
void ProcessingChainFilter<TInputImage, TPolygonDataType>::alignAOIToImage(OGREnvelope &envlp){
    //aligning aoi to image
    this->aoi = envlp;

    point2d upperLeft, lowerRight;
    typename TInputImage::IndexType upperLeftIdx, lowerRightIdx;
    upperLeft[0]    = aoi.MinX;
    upperLeft[1]    = aoi.MaxY;

    lowerRight[0]   = aoi.MaxX;
    lowerRight[1]   = aoi.MinY;


    //anchoring to indexes
    TInputImagePointer inputImage = this->GetReferenceImage();

    inputImage->TransformPhysicalPointToIndex(upperLeft, upperLeftIdx);
    inputImage->TransformPhysicalPointToIndex(lowerRight, lowerRightIdx);

    //getting centroid coordinates
    inputImage->TransformIndexToPhysicalPoint(upperLeftIdx, upperLeft);
    inputImage->TransformIndexToPhysicalPoint(lowerRightIdx, lowerRight);

    typename TInputImage::SpacingType spacing;
    spacing     = inputImage->GetSignedSpacing();

    aoi.MinX    = upperLeft[0] - spacing[0]/2;
    aoi.MaxY    = upperLeft[1] - abs(spacing[1]/2);

    aoi.MaxX    = lowerRight[0] + spacing[0]/2;
    aoi.MinY    = lowerRight[1] - abs(spacing[1]/2);

    //get aoi from input image
    OGREnvelope imageEnvelope = regionToEnvelope<TInputImage>(inputImage, inputImage->GetLargestPossibleRegion());

    //intersect two aois to get the common one-> this is the actual aoi
    aoi.Intersect(imageEnvelope);
    //std::cout << aoi.MinX <<"," <<aoi.MinY <<"\n" <<aoi.MaxX <<"," << aoi.MaxY <<"\n";
}

template <class TInputImage, class TPolygonDataType>
void ProcessingChainFilter<TInputImage, TPolygonDataType>::prepareImageInfo(JsonDocumentPtr &images) {
    for (auto & image:images->GetArray()) {
        boost::filesystem::path relPath = image.GetArray()[0].GetString();

        auto statsStruct = PolygonStats::NewPolyStatsPerRegionMap(pow(this->GetNumberOfThreads(),2),labels, product);
        auto outputStats = PolygonStats::NewPointerMap(labels, product);

        ImageInfoPtr imgInfo = std::make_shared<ImageInfo>(product->productAbsPath(relPath).string(), statsStruct, outputStats);
        productImages.insert(std::pair<size_t, ImageInfoPtr>(image.GetArray()[1].GetInt64(),imgInfo));
    }
}


template <class TInputImage, class TPolygonDataType>
void ProcessingChainFilter<TInputImage, TPolygonDataType>::processGeomIdsAndImages(JsonDocumentPtr &polyIds, JsonDocumentPtr &images) {

    labels = std::make_shared<std::vector<size_t>>(polyIds->GetArray().Size());
    size_t i = 0;
    for (auto& id: polyIds->GetArray()) {
        (*labels)[i] = id.GetInt64();
        polyIdsStr += std::to_string((*labels)[i]) +",";
        i++;
    }
    polyIdsStr = polyIdsStr.substr(0, polyIdsStr.length()-1);
    this->prepareImageInfo(images);

}
}







#endif // PROCESSINGCHAINFILTER_HXX

#ifndef PROCESSINGCHAINFILTER_HXX
#define PROCESSINGCHAINFILTER_HXX

#include <otbImageFileWriter.h>
#include <otbImage.h>

#include "ProcessingChainFilter.h"
#include "../Constants/constants.hxx"

namespace otb {

template <class TInputImage, class TPolygonDataType>
void ProcessingChainFilter<TInputImage, TPolygonDataType>::Reset() {
    repeat = 0;
}



template <class TInputImage, class TPolygonDataType>
void ProcessingChainFilter<TInputImage, TPolygonDataType>::SetParams(const Configuration::Pointer config, const ProductInfo::Pointer product, OGREnvelope &envlp, std::unique_ptr<std::vector<std::pair<size_t, std::string>>> images,
                                                                     std::unique_ptr<std::vector<size_t>> polyIds, size_t &polySRID) {
    this->config        = config;
    this->product       = product;
    this->aoi           = envlp;
    this->productImages = std::move(images);
    this->labels        = std::move(polyIds);
    this->polySRID      = polySRID;

    //setting the reference image as input
    typename RawDataImageReaderType::Pointer reader = RawDataImageReaderType::New();
    reader->SetFileName(this->product->firstProductPath.string().c_str());
    reader->UpdateOutputInformation();
    this->SetNthInput(0, reader->GetOutput());

    //creating polygonId string
    for (size_t& id :*this->labels)
        polyIdsStr += std::to_string(id) +",";

    polyIdsStr = polyIdsStr.substr(0, polyIdsStr.length()-1);

    //aligning aoi to image
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
    Superclass::GenerateOutputInformation();

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
void ProcessingChainFilter<TInputImage, TPolygonDataType>::Synthetize() {}

template <class TInputImage, class TPolygonDataType>
ProcessingChainFilter<TInputImage, TPolygonDataType>::ProcessingChainFilter() {
    this->SetNumberOfRequiredInputs(1);
};



template <class TInputImage, class TPolygonDataType>
void ProcessingChainFilter<TInputImage, TPolygonDataType>::AfterThreadedGenerateData(){
    repeat++;
};


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

    TInputImagePointer out                      = this->GetOutput();
    TInputImagePointer inputImage               = this->GetReferenceImage();
    typename TInputImage::SpacingType spacing   = out->GetSignedSpacing();

    //getting origin idx
    point2d originPnt;
    typename TInputImage::RegionType::IndexType originRawDataIdx;
    typename LabelImageType::RegionType::IndexType originLabelDataIdx;

    out->TransformIndexToPhysicalPoint(outputRegionForThread.GetIndex(), originPnt);
    inputImage->TransformPhysicalPointToIndex(originPnt, originRawDataIdx);

    for (auto& image:*productImages) {
        std::cout <<"Processing image: " <<image.second << ")\n";

        typename RawDataImageReaderType::Pointer imgReader= RawDataImageReaderType::New();
        imgReader->SetFileName(image.second.c_str());
        imgReader->DebugOff();
        //imgReader->RemoveAllObservers();

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
        roi->ReleaseDataFlagOn();
        roi->DebugOff();
        roi->Update();

        typename StreamedStatisticsType::Pointer stats = StreamedStatisticsType::New();
        stats->SetInputLabels(labels);
        stats->SetInputProduct(product);
        stats->SetInputLabelImage(labelImage);
        stats->SetInputDataImage(roi->GetOutput());
        stats->UpdateOutputInformation();
        stats->GetStreamer()->GetStreamingManager()->SetDefaultRAM(1280);
        stats->DebugOff();
        stats->GlobalWarningDisplayOff();
        stats->Update();
        //stats->GetPolygonStatsByLabel(polyID)->updateDB(imgID, config);

    }


};



template <class TInputImage, class TPolygonDataType>
typename ProcessingChainFilter<TInputImage, TPolygonDataType>::LabelImageType::Pointer
ProcessingChainFilter<TInputImage, TPolygonDataType>::rasterizer(typename TInputImage::RegionType region, itk::ThreadIdType threadId) {
    //converting region to extent
    TInputImagePointer out = this->GetOutput();

    OGREnvelope evlp = regionToEnvelope<TInputImage>(out, region);
    typename TInputImage::SpacingType spacing = out->GetSignedSpacing();
    //loading polygons from DB
    std::string query = "with region AS( "
                        "select st_setsrid((st_makeenvelope(" + std::to_string(evlp.MinX-spacing[0]/2) +"," + std::to_string(evlp.MinY-abs(spacing[1]/2)) +"," + std::to_string(evlp.MaxX+spacing[0]/2) +"," + std::to_string(evlp.MaxY+abs(spacing[1]/2)) + "))," + std::to_string(polySRID) +") bbox) "
                                                                                                                                                                                                                                                                                               "select sg.id, st_astext(ST_MULTI(case when st_contains(region.bbox, sg.geom) then sg.geom else st_intersection(sg.geom, region.bbox) end)) geom "
                                                                                                                                                                                                                                                                                               "from stratification_geom sg "
                                                                                                                                                                                                                                                                                               "join region on TRUE "
                                                                                                                                                                                                                                                                                               "where sg.id IN (" + polyIdsStr +") AND st_intersects(sg.geom, region.bbox)";

    PGConn::Pointer cn = PGConn::New(Configuration::connectionIds[config->statsInfo.connectionId]);
    PGConn::PGRes res = cn->fetchQueryResult(query, "fetching polygon info for thread");

    if(res.empty())
        return nullptr;

    VectorDataType::Pointer polyData = VectorDataType::New();
    otb::WKTVectorDataIO::Pointer wkt = otb::WKTVectorDataIO::New();
    wkt->SetGeometryMetaData(polySRID);
    for(size_t i = 0; i < res.size(); i++)
        wkt->AppendData(res[i][1].as<std::string>(), res[i][0].as<size_t>());

    wkt->Read(polyData);

    if(polyData->GetDataTree()->GetRoot()->CountChildren() == 0) {
        std::cout << "No polygons could be used. Continuing\n";
        /*
        std::ofstream file(std::to_string(repeat) + "_"+std::to_string(threadId) + "_issue.txt");
        file << query;
        file.close();
        */
        return nullptr;
    }


    point2d originPnt;

    out->TransformIndexToPhysicalPoint(region.GetIndex(), originPnt);

    polyData->SetOrigin(originPnt);
    polyData->SetSpacing(spacing);
    polyData->SetProjectionRef(out->GetProjectionRef());

    typename VectorDataToLabelImageFilterType::Pointer labelImageFilter = VectorDataToLabelImageFilterType::New();

    labelImageFilter->AddVectorData(polyData);

    labelImageFilter->SetOutputSize(region.GetSize());
    labelImageFilter->SetOutputOrigin(originPnt);
    labelImageFilter->SetOutputSpacing(spacing);
    labelImageFilter->SetBurnAttribute("id");

    labelImageFilter->SetOutputProjectionRef(out->GetProjectionRef());
    labelImageFilter->Update();
    /*
    using ULongImageWriterType = otb::ImageFileWriter<LabelImageType>;
    ULongImageWriterType::Pointer labelWriter =ULongImageWriterType::New();
    labelWriter->SetFileName(std::to_string(repeat) + "_"+std::to_string(threadId) + "labelImage.tif");
    labelWriter->SetInput(labelImageFilter->GetOutput());
    labelWriter->Update();
*/

    return labelImageFilter->GetOutput();

}

}







#endif // PROCESSINGCHAINFILTER_HXX

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
    currentRegionId = 1;

    //cleaning up temporary info for respective product/stratification
    std::string query = "TRUNCATE tmp.poly_stats_per_region RESTART IDENTITY;";
    PGPool::PGConn::Pointer cn = PGPool::PGConn::New(Configuration::connectionIds[config->statsInfo.connectionId]);
    cn->executeQuery(query);
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
void ProcessingChainFilter<TInputImage, TPolygonDataType>::Synthetize() {
    //insert polygon data & fetch area info to compute colors
    std::string query = "SELECT clms_UpdatePolygonStats(); ";
    PGPool::PGConn::Pointer cn  = PGPool::PGConn::New(Configuration::connectionIds[config->statsInfo.connectionId]);
    cn->executeQuery(query);

    query = "SELECT id, poly_id, product_file_id,"
            " CASE WHEN noval_area_ha+sparse_area_ha+mid_area_ha+dense_area_ha = 0 THEN 0 else noval_area_ha/(noval_area_ha+sparse_area_ha+mid_area_ha+dense_area_ha)*100.0 END noval,"
            " CASE WHEN noval_area_ha+sparse_area_ha+mid_area_ha+dense_area_ha = 0 THEN 0 else sparse_area_ha/(noval_area_ha+sparse_area_ha+mid_area_ha+dense_area_ha)*100.0 END sparse,"
            " CASE WHEN noval_area_ha+sparse_area_ha+mid_area_ha+dense_area_ha = 0 THEN 0 else mid_area_ha/(noval_area_ha+sparse_area_ha+mid_area_ha+dense_area_ha)*100.0 END mid,"
            " CASE WHEN noval_area_ha+sparse_area_ha+mid_area_ha+dense_area_ha = 0 THEN 0 else dense_area_ha/(noval_area_ha+sparse_area_ha+mid_area_ha+dense_area_ha)*100.0 END dense,"
            " mean"
            " FROM poly_stats ps WHERE noval_color IS NULL;";

    PGPool::PGConn::PGRes res = cn->fetchQueryResult(query);
    std::stringstream data;

    for (auto row: res) {
        data <<"(" << row[0] <<"," << row[1] <<"," << row[2] <<",";
        for (size_t i = 0; i< product->colorInterpolation.size(); i++) {
            RGBVal color = product->colorInterpolation[i].interpolateColor(row[i+3].as<long double>());
            data << "'" << rgbToArrayString(color) << "',";
        }

        if (row[7].is_null()) {
            data <<"null),";
            continue;
        }

        float dt =row[7].as<float>();
        RGBVal meanColor = product->styleColors[product->reverseValue(dt)];
        //std::cout << dt <<"," << product->reverseValue(dt)  << " @@@@@@@: " << rgbToArrayString(meanColor) << "\n";
        data <<"'" << rgbToArrayString(meanColor) <<"'),";

    }

    if (data.tellp() == 0)
        return;

    query = "INSERT INTO poly_stats(id, poly_id, product_file_id, noval_color, sparseval_color, midval_color, highval_color, meanval_color) VALUES " + stringstreamToString(data)
            + "ON CONFLICT (id) DO UPDATE SET noval_color=EXCLUDED.noval_color, sparseval_color=EXCLUDED.sparseval_color, midval_color = EXCLUDED.midval_color, highval_color = EXCLUDED.highval_color, meanval_color = EXCLUDED.meanval_color; ";
    cn->executeQuery(query);
}

template <class TInputImage, class TPolygonDataType>
bool ProcessingChainFilter<TInputImage, TPolygonDataType>::ValidAOI() {
    return !(aoi.MaxX == 0 && aoi.MinX == 0 && aoi.MinY == 0 && aoi.MaxY == 0);
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
ProcessingChainFilter<TInputImage, TPolygonDataType>::ProcessingChainFilter():currentRegionId(1) {
    this->SetNumberOfRequiredInputs(1);
}

template <class TInputImage, class TPolygonDataType>
void ProcessingChainFilter<TInputImage, TPolygonDataType>::AfterThreadedGenerateData() {
    currentRegionId++;
}

template <class TInputImage, class TPolygonDataType>
void ProcessingChainFilter<TInputImage, TPolygonDataType>::BeforeThreadedGenerateData() {
    std::cout <<"Processing Region with id: " << currentRegionId <<"\n";
}

template <class TInputImage, class TPolygonDataType>
typename TInputImage::Pointer ProcessingChainFilter<TInputImage, TPolygonDataType>::GetReferenceImage() {
    return static_cast<TInputImage*>(this->ProcessObject::GetInput(0));
}


template <class TInputImage, class TPolygonDataType>
void ProcessingChainFilter<TInputImage, TPolygonDataType>::ThreadedGenerateData(const RegionType& outputRegionForThread, itk::ThreadIdType threadId) {
    RegionData regionData = this->rasterizer(outputRegionForThread, threadId);
    if (regionData.labelImage == nullptr)
        return;

    TInputImagePointer out          = this->GetOutput();
    TInputImagePointer inputImage   = this->GetReferenceImage();

    //getting origin idx
    point2d originPnt;
    typename TInputImage::RegionType::IndexType originRawDataIdx;

    out->TransformIndexToPhysicalPoint(outputRegionForThread.GetIndex(), originPnt);
    inputImage->TransformPhysicalPointToIndex(originPnt, originRawDataIdx);

    for(auto& image:productImages) {

        std::cout <<"Processing image: " <<image.second << ")\n";

        typename RawDataImageReaderType::Pointer imgReader= RawDataImageReaderType::New();
        imgReader->SetFileName(image.second.c_str());

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
        stats->SetInputProduct(product);
        stats->SetConfig(config);
        stats->SetInputLabels(regionData.labels);
        stats->SetInputLabelImage(regionData.labelImage);
        stats->SetParentRegionId(currentRegionId);
        stats->SetParentThreadId(threadId);
        stats->SetInputDataImage(roi->GetOutput(), image.first);
        stats->GetStreamer()->GetStreamingManager()->SetDefaultRAM(config->statsInfo.memoryMB/(this->GetNumberOfThreads()*2));

        stats->GlobalWarningDisplayOff();
        stats->Update();
        stats->ReleaseDataFlagOn();
        stats->ResetPipeline();
    }
}

template <class TInputImage, class TPolygonDataType>
ProcessingChainFilter<TInputImage, TPolygonDataType>::RegionData ProcessingChainFilter<TInputImage, TPolygonDataType>::rasterizer(typename TInputImage::RegionType region, itk::ThreadIdType threadId) {
    //converting region to extent
    RegionData ret;

    TInputImagePointer out = this->GetOutput();
    point2d originPnt;
    out->TransformIndexToPhysicalPoint(region.GetIndex(), originPnt);

    OGREnvelope evlp = regionToEnvelope<TInputImage>(out, region);
    typename TInputImage::SpacingType spacing = out->GetSignedSpacing();
    //loading polygons from DB
    std::string query = fmt::format("with region AS( select st_setsrid((st_makeenvelope({0},{1},{2},{3})),4326) bbox) select sg.id, ST_ASTEXT(ST_MULTI(case when st_contains(region.bbox, sg.geom) then sg.geom else st_intersection(sg.geom, region.bbox) end)) geom from stratification_geom sg join region on TRUE where sg.id IN ({4}) AND st_intersects(sg.geom, region.bbox)",
                                    evlp.MinX-spacing[0]/2, evlp.MinY-abs(spacing[1]/2),evlp.MaxX+spacing[0]/2, evlp.MaxY+abs(spacing[1]/2), polyIdsStr);
    PGPool::PGConn::Pointer cn  = PGPool::PGConn::New(Configuration::connectionIds[config->statsInfo.connectionId]);
    PGPool::PGConn::PGRes res   = cn->fetchQueryResult(query, "fetching polygon info for thread_"+std::to_string(threadId));

    if(res.empty())
        return ret;

    LabelsArrayPtr tmpLabels = std::make_shared<std::vector<size_t>>(res.size());
    RasterizerFilter::Pointer rasterizer = RasterizerFilter::New();
    rasterizer->SetGeometryMetaData(polySRID);
    for(size_t i = 0; i < res.size(); i++) {
        size_t id =  res[i][0].as<size_t>();
        rasterizer->AppendData(res[i][1].as<std::string>(),id);
        (*tmpLabels)[i] = id;
    }

    rasterizer->SetOutputOrigin(originPnt);
    rasterizer->SetOutputRegion(region);
    rasterizer->SetOutputSignedSpacing(spacing);
    rasterizer->SetOutputProjectionRef(out->GetProjectionRef());
    if(rasterizer->GetFeatureCount() == 0)
        return ret;

    rasterizer->Update();
    /*
    using ULongImageWriterType = otb::ImageFileWriter<LabelImageType>;
    ULongImageWriterType::Pointer labelWriter =ULongImageWriterType::New();
    labelWriter->SetFileName(std::to_string(repeat) + "_"+std::to_string(threadId) + "labelImage_v2.tif");
    labelWriter->SetInput(rasterizer->GetOutput());
    labelWriter->Update();
*/
    ret.labelImage = rasterizer->GetOutput();
    ret.labels = tmpLabels;

    return ret;
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

    //when data fall completely outside of product aoi
    if (!aoi.Intersects(imageEnvelope))
        aoi.MinX = aoi.MaxY = aoi.MaxX = aoi.MinY = 0;
    else //intersect two aois to get the common one-> this is the actual aoi
        aoi.Intersect(imageEnvelope);
}

template <class TInputImage, class TPolygonDataType>
void ProcessingChainFilter<TInputImage, TPolygonDataType>::prepareImageInfo(JsonDocumentPtr &images) {
    for (auto & image:images->GetArray()) {
        size_t imageId = image.GetArray()[1].GetInt64();
        boost::filesystem::path relPath = image.GetArray()[0].GetString();
        productImages.insert(std::pair<size_t, std::string>(imageId,product->productAbsPath(relPath).string()));
        imageIdsStr += std::to_string(imageId)+",";
    }
    imageIdsStr = imageIdsStr.substr(0, imageIdsStr.length()-1);
}


template <class TInputImage, class TPolygonDataType>
void ProcessingChainFilter<TInputImage, TPolygonDataType>::processGeomIdsAndImages(JsonDocumentPtr &polyIds, JsonDocumentPtr &images) {

    labels = std::make_shared<std::vector<size_t>>(polyIds->GetArray().Size());
    size_t i = 0;
    for (auto& id: polyIds->GetArray()) {
        (*labels)[i] = id.GetInt64();
        polyIdsStr  += std::to_string((*labels)[i]) +",";
        i++;
    }
    polyIdsStr = polyIdsStr.substr(0, polyIdsStr.length()-1);
    this->prepareImageInfo(images);
}
}







#endif // PROCESSINGCHAINFILTER_HXX

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

#ifndef PROCESSINGCHAINFILTER_H
#define PROCESSINGCHAINFILTER_H

#include <itkImageRegionConstIterator.h>
#include <itkImageRegionIterator.h>
#include <mutex>
#include <otbExtractROI.h>
#include <otbImageFileReader.h>
#include <otbPersistentImageFilter.h>
#include <otbVectorData.h>
#include <otbVectorDataToLabelImageFilter.h>

#include "Statistics/StreamedStatisticsFromLabelImageFilter.h"

#include "../Utils/Utils.hxx"
#include "IO/VectorWktToLabelImageFilter.hxx"

namespace otb {
using VectorDataType    = otb::VectorData<double, 2>;


template <class TInputImage, class TPolygonDataType>
class ProcessingChainFilter:public PersistentImageFilter<TInputImage, TInputImage> {
public:

    /** Standard typedefs */
    using Self                      = ProcessingChainFilter;
    using Superclass                = PersistentImageFilter<TInputImage, TInputImage>;
    using Pointer                   = itk::SmartPointer<Self>;
    using ConstPointer              = itk::SmartPointer<const Self>;

    using TInputImageConstIterator  = itk::ImageRegionConstIterator<TInputImage>;
    using OutputIterator            = itk::ImageRegionIterator<TInputImage>;
    using TInputImagePointer        = typename TInputImage::Pointer;
    using TPolygonDataTypePointer   = typename TPolygonDataType::Pointer;
    using RegionType                = typename TInputImage::RegionType;


    struct ImageInfo {
        std::string path;
        //std::vector<std::pair<LabelsArrayPtr, PolygonStats::PolyStatsPerRegionPtr>> tmpRegionData;
        //PolygonStats::PolyStatsMapPtr outStats;
        ImageInfo(std::string path,PolygonStats::PolyStatsMapPtr out):path(path){}
    };

    using ImageInfoPtr  = std::shared_ptr<ImageInfo>;
    using ImagesInfo    = std::map<size_t,std::string>;



    /** typedefs for needed filters */
    using labelType             = unsigned int;
    const short Dimension       = 2;
    using LabelImageType        = Image< labelType, 2>;

    using VectorDataToLabelImageFilterType      = VectorDataToLabelImageFilter<TPolygonDataType, LabelImageType>;
    using RawDataImageReaderType                = ImageFileReader<TInputImage>;
    using ExtractRawDataROIFilter               = ExtractROI<typename TInputImage::PixelType, typename TInputImage::PixelType>;
    using ExtractLabelDataROIFilter             = ExtractROI<typename LabelImageType::PixelType, typename LabelImageType::PixelType>;
    using StreamedStatisticsType                = StreamedStatisticsFromLabelImageFilter<TInputImage, LabelImageType>;
    using RasterizerFilter                      = VectorWktToLabelImageFilter<LabelImageType>;

    /** Type macro */
    itkNewMacro(Self);

    /** Creation through object factory macro */
    itkTypeMacro(ProcessingChainFilter, PersistentImageFilter);


    virtual void Reset(void) override;
    virtual void SetParams(const Configuration::SharedPtr config, const ProductInfo::Pointer product,
                           const ProductVariable::Pointer variable, OGREnvelope& envlp, JsonValue& images,
                           JsonDocumentSharedPtr polyIds, size_t& polSRID);
    virtual void Synthetize(void) override;
    bool ValidAOI();


protected:
    ProcessingChainFilter();
    ~ProcessingChainFilter() override {}

    ProcessingChainFilter(const Self&) = delete;
    void operator=(const Self&) = delete;
    void AfterThreadedGenerateData() override;
    void BeforeThreadedGenerateData() override;
    virtual void GenerateInputRequestedRegion() override;
    virtual void GenerateOutputInformation(void) override;
    typename TInputImage::Pointer GetReferenceImage();
    void ThreadedGenerateData(const RegionType& outputRegionForThread, itk::ThreadIdType threadId) override;

private:
    struct RegionData {
      LabelImageType::Pointer labelImage=nullptr;
      LabelsArrayPtr labels=nullptr;
    };
    
    
    Configuration::SharedPtr config;
    ProductInfo::Pointer product;
    ProductVariable::Pointer variable;
    OGREnvelope aoi;
    ImagesInfo productImages;
    size_t polySRID, currentRegionId;
    LabelsArrayPtr labels;
    std::mutex readMtx;
    std::string stratification, polyIdsStr, imageIdsStr;
    RegionData rasterizer(typename TInputImage::RegionType region, itk::ThreadIdType threadId);

    void prepareImageInfo(JsonValue& images);
    void processGeomIdsAndImages(JsonDocumentSharedPtr &polyIds, JsonValue& images);

};

}
#endif // PROCESSINGCHAINFILTER_H

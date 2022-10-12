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
#include "../Utils/utils.hxx"

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

    using  TInputImageConstIterator = itk::ImageRegionConstIterator<TInputImage>;
    using OutputIterator            = itk::ImageRegionIterator<TInputImage>;
    using TInputImagePointer        = typename TInputImage::Pointer;
    using TPolygonDataTypePointer   = typename TPolygonDataType::Pointer;
    using RegionType                = typename TInputImage::RegionType;


    /** typedefs for needed filters */
    using labelType             = unsigned int;
    const short Dimension       = 2;
    using LabelImageType        = Image< labelType, 2 >;

    using VectorDataToLabelImageFilterType  = otb::VectorDataToLabelImageFilter<TPolygonDataType, LabelImageType>;
    using RawDataImageReaderType            = otb::ImageFileReader<TInputImage>;
    using ExtractRawDataROIFilter           = otb::ExtractROI<typename TInputImage::PixelType, typename TInputImage::PixelType>;
    using ExtractLabelDataROIFilter         = otb::ExtractROI<typename LabelImageType::PixelType, typename LabelImageType::PixelType>;
    using StreamedStatisticsType            = otb::StreamedStatisticsFromLabelImageFilter<TInputImage, LabelImageType>;

    /** Type macro */
    itkNewMacro(Self);

    /** Creation through object factory macro */
    itkTypeMacro(ProcessingChainFilter, PersistentImageFilter);

    virtual void Reset(void) override;
    virtual void SetParams(const Configuration::Pointer config, const ProductInfo::Pointer product, OGREnvelope &envlp, std::unique_ptr<std::vector<std::pair<size_t,
                           std::string>>> images, std::unique_ptr<std::vector<size_t>> polyIds, size_t& polySRID);
    virtual void Synthetize(void) override;


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
    Configuration::Pointer config;
    ProductInfo::Pointer product;
    OGREnvelope aoi;
    std::unique_ptr<std::vector<std::pair<size_t, std::string>>> productImages;
    size_t polySRID, repeat;
    LabelSetPtr labels;
    std::mutex readMtx;
    std::string stratification, polyIdsStr;

    typename LabelImageType::Pointer rasterizer(typename TInputImage::RegionType region, itk::ThreadIdType threadId);


};

}






#endif // PROCESSINGCHAINFILTER_H

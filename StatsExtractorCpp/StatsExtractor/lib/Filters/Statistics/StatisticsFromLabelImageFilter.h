#ifndef STATISTICS_HXX
#define STATISTICS_HXX

#include <itkArray.h>
#include <itkNumericTraits.h>
#include <itkSimpleDataObjectDecorator.h>
#include <itkVariableLengthVector.h>
#include <otbPersistentImageFilter.h>
#include <unordered_map>
#include <itkImageRegionConstIterator.h>
#include <itkImageRegionIterator.h>

#include "../../Constants/constants.hxx"
#include "../../Utils/utils.hxx"
#include "polygonstats.hxx"




namespace otb {

template <class TInputImage, class TLabelImage>
class StatisticsFromLabelImageFilter:public PersistentImageFilter<TInputImage, TInputImage> {
public:

    /** Standard Self typedef */
    typedef StatisticsFromLabelImageFilter        Self;
    typedef PersistentImageFilter<TInputImage, TInputImage> Superclass;
    typedef itk::SmartPointer<Self>                                     Pointer;
    typedef itk::SmartPointer<const Self>                               ConstPointer;

    using  TInputImageConstIterator   =  itk::ImageRegionConstIterator<TInputImage>;
    using  TInputLabelImageConstIterator     =  itk::ImageRegionConstIterator<TLabelImage>;
    using OutputIterator                                    =  itk::ImageRegionIterator<TInputImage>;


    /** Method for creation through the object factory. */
    itkNewMacro(Self);

    /** Runtime information support. */
    itkTypeMacro(StreamedStatisticsFromLabelImageFilter, PersistentImageFilter);

    /** Image related typedefs. */
    using InputImageType                              = TInputImage;
    using InputImageTypePointer                 = typename TInputImage::Pointer ;

    typedef itk::VariableLengthVector<long double>                       RealInputPixelType;
    using FloatInputImageTypePolyMapStats     = typename PolygonStats::MapPointer;

    using LabelImageType                         = TLabelImage;
    using LabelImagePointer                     = typename TLabelImage::Pointer;

    typedef typename InputImageType::RegionType                    RegionType;
    typedef typename InputImageType::PixelType                     InputPixelType;
    typedef typename LabelImageType::PixelType                      LabelPixelType;

    //typedef StatisticsAccumulator<RealInputPixelType>              AccumulatorType;

    virtual InputImageTypePointer GetInputDataImage();

    virtual LabelImagePointer GetInputLabelImage();

    virtual PolygonStats::Pointer GetPolygonStatsByLabel(size_t &label);

    virtual void SetInputDataImage(const TInputImage* image);

    virtual void SetInputLabelImage(const LabelImageType* image);

    virtual void SetInputLabels(const std::set<std::size_t>& labels);

    virtual void SetInputProduct(const ProductInfoPtr product);

    virtual void Reset(void) override;

    virtual void Synthetize(void) override;


protected:
    StatisticsFromLabelImageFilter();
    ~StatisticsFromLabelImageFilter() override {}

    void ThreadedGenerateData(const RegionType& outputRegionForThread, itk::ThreadIdType threadId) override;
private:
    StatisticsFromLabelImageFilter(const Self&) = delete;
    void operator=(const Self&) = delete;
    FloatInputImageTypePolyMapStats polyMapStats;
    std::vector<FloatInputImageTypePolyMapStats> threadPolyMapStatsVector;
    std::vector<bool> rawDataNullFlags, labelDataNullFlags;
    InputPixelType rawDataNullPixel;
    LabelPixelType labelDataNullPixel;
    std::vector<std::size_t> labels;
    ProductInfoPtr currentProduct;

};





}
#endif // STATISTICS_HXX

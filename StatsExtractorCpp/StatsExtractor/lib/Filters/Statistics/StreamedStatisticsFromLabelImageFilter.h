#ifndef STREAMEDSTATISTICSFROMLABELIMAGEFILTER_H
#define STREAMEDSTATISTICSFROMLABELIMAGEFILTER_H

#include <otbPersistentFilterStreamingDecorator.h>

#include "StatisticsFromLabelImageFilter.hxx"

namespace otb {
template <class TInputImage, class TLabelImage>
class ITK_EXPORT StreamedStatisticsFromLabelImageFilter: public PersistentFilterStreamingDecorator<StatisticsFromLabelImageFilter<TInputImage, TLabelImage>> {
public:
    /** Standard Self typedef */
    typedef StreamedStatisticsFromLabelImageFilter     Self;
    typedef PersistentFilterStreamingDecorator<StatisticsFromLabelImageFilter<TInputImage, TLabelImage>> Superclass;
    typedef itk::SmartPointer<Self>                     Pointer;
    typedef itk::SmartPointer<const Self>           ConstPointer;

    /** Type macro */
    itkNewMacro(Self);

    /** Creation through object factory macro */
    itkTypeMacro(StreamedStatisticsFromLabelImageFilter, PersistentFilterStreamingDecorator);

    PolygonStats::Pointer GetPolygonStatsByLabel(size_t &label) {
        return this->GetFilter()->GetPolygonStatsByLabel(label);
    }

    void SetInputDataImage(const TInputImage* image) {
        this->GetFilter()->SetInputDataImage(image);
    }

    void SetInputLabelImage(const TLabelImage* image){
        this->GetFilter()->SetInputLabelImage(image);
    }

    void SetInputLabels(const std::set<size_t> &labels) {
        this->GetFilter()->SetInputLabels(labels);
    }

    void SetInputProduct(const ProductInfoPtr product) {
        this->GetFilter()->SetInputProduct(product);
    }


protected:
    StreamedStatisticsFromLabelImageFilter() {}

    ~StreamedStatisticsFromLabelImageFilter() override {}

private:
    StreamedStatisticsFromLabelImageFilter(const Self&) = delete;
    void operator=(const Self&) = delete;






};
}
#endif //STREAMEDSTATISTICSFROMLABELIMAGEFILTER_H

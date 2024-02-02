#ifndef MEANREDUCTOR_H
#define MEANREDUCTOR_H

#include <itkImageToImageFilter.h>
#include <itkImageConstIterator.h>
#include <itkImageRegionIterator.h>
#include <otbImage.h>

#include "../../Constants/ProductVariable.h"

namespace otb {

template<class TInputImage, class TOutputImageType>
class MeanReductor:public itk::ImageToImageFilter<TInputImage, Image<TOutputImageType, 2>> {
public:
    /** Standard typedefs */
    using Self                      = MeanReductor;
    using TOutputImage              = Image<TOutputImageType, 2>;
    using Superclass                = itk::ImageToImageFilter<TInputImage, TOutputImage>;
    using Pointer                   = itk::SmartPointer<Self>;
    using ConstPointer              = itk::SmartPointer<const Self>;
    using TInputImageConstIterator  = itk::ImageRegionConstIterator<TInputImage>;
    using TInputImagePointer    = typename TInputImage::Pointer;
    using RegionType            = typename TInputImage::RegionType;

    using TOutputImageIterator  = itk::ImageRegionIterator<TOutputImage>;
    using TOutputImagePointer   = typename TOutputImage::Pointer;

    /** Type macro */
    itkNewMacro(Self);

    /** Creation through object factory macro */
    itkTypeMacro(MeanReductor, ImageToImageFilter);

    void SetParams(ProductVariable::Pointer variable);

protected:
    MeanReductor();
    void ThreadedGenerateData(const RegionType& outputRegionForThread, itk::ThreadIdType threadId) override;
    ProductVariable::Pointer variable;
};

#ifndef OTB_MANUAL_INSTANTIATION
#include "MeanReductor.hxx"
#endif
}
#endif // MEANREDUCTOR_H

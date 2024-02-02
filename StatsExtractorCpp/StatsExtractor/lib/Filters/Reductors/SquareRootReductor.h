#ifndef SQUAREROOTREDUCTOR_H
#define SQUAREROOTREDUCTOR_H

#include "MeanReductor.h"

namespace otb{
template<class TInputImage, class TOutputImageType>
class SquareRootReductor:public otb::MeanReductor<TInputImage, TOutputImageType> {
public:
    /** Standard typedefs */
    using Self                      = SquareRootReductor;
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
    itkTypeMacro(SquareRootReductor, ImageToImageFilter);

protected:
    SquareRootReductor();
    void ThreadedGenerateData(const RegionType& outputRegionForThread, itk::ThreadIdType threadId) override;
};

#ifndef OTB_MANUAL_INSTANTIATION
#include "SquareRootReductor.hxx"
#endif
}
#endif // SQUAREROOTREDUCTOR_H



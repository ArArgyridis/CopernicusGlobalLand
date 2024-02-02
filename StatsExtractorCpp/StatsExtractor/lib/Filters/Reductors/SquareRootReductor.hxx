#include "SquareRootReductor.h"


template<class TInputImage, class TOutputImage>
otb::SquareRootReductor<TInputImage, TOutputImage>::SquareRootReductor::SquareRootReductor() {}

template<class TInputImage, class TOutputImage>
void otb::SquareRootReductor<TInputImage, TOutputImage>::ThreadedGenerateData(const RegionType& outputRegionForThread, itk::ThreadIdType threadId) {
    TOutputImagePointer out = this->GetOutput();
    TOutputImageIterator outItr(out, outputRegionForThread);

    TInputImagePointer in = static_cast<TInputImage*>(this->ProcessObject::GetInput(0));
    TInputImageConstIterator inItr(in, outputRegionForThread);

    for(outItr.GoToBegin(), inItr.GoToBegin(); !outItr.IsAtEnd(); ++outItr, ++inItr){
        typename TOutputImage::PixelType mean = 0;

        typename TInputImage::PixelType inPxl = inItr.Get();
        for(size_t i = 0; i < inPxl.Size(); i++){
            typename TOutputImage::PixelType scaled = this->variable->scaleValue(inPxl[i]);
            mean+=scaled*scaled;
        }
        outItr.Set(sqrt(mean));
    }
}

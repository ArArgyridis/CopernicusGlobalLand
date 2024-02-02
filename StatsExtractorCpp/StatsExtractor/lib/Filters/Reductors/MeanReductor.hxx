#include "MeanReductor.h"

template<class TInputImage, class TOutputImage>
otb::MeanReductor<TInputImage, TOutputImage>::MeanReductor() {}

template<class TInputImage, class TOutputImage>
void otb::MeanReductor<TInputImage, TOutputImage>::SetParams(ProductVariable::Pointer variable) {
    this->variable = variable;
}

template<class TInputImage, class TOutputImage>
void otb::MeanReductor<TInputImage, TOutputImage>::ThreadedGenerateData(const RegionType& outputRegionForThread, itk::ThreadIdType threadId) {
    TOutputImagePointer out = this->GetOutput();
    TOutputImageIterator outItr(out, outputRegionForThread);

    TInputImagePointer in = static_cast<TInputImage*>(this->ProcessObject::GetInput(0));
    TInputImageConstIterator inItr(in, outputRegionForThread);

    for(outItr.GoToBegin(), inItr.GoToBegin(); !outItr.IsAtEnd(); ++outItr, ++inItr){
        typename TOutputImage::PixelType mean = 0;

        typename TInputImage::PixelType inPxl = inItr.Get();
        for(size_t i = 0; i < inPxl.Size(); i++)
            mean += inPxl[i]/inPxl.Size()*1.0;

        outItr.Set(variable->scaleValue(mean));
    }
}


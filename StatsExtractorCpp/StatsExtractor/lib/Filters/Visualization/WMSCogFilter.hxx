/**
   Copyright (C) 2023  Argyros Argyridis arargyridis at gmail dot com
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

#ifndef WMSCOGFILTER_HXX
#define WMSCOGFILTER_HXX
#include <itkNumericTraits.h>
#include <otbNoDataHelper.h>
#include "WMSCogFilter.h"

template <class TInputImage, class TOutputImage>
otb::WMSCogFilter<TInputImage, TOutputImage>::WMSCogFilter(): itk::ImageToImageFilter<TInputImage, TOutputImage>(),nOutputBands(3) {
    this->SetNumberOfRequiredInputs(1);
    this->SetNumberOfRequiredOutputs(1);
}

template <class TInputImage, class TOutputImage>
void otb::WMSCogFilter<TInputImage, TOutputImage>::setProduct(ProductInfo::Pointer product, ProductVariable::Pointer variable) {
    this->product = product;
    this->variable = variable;
    noDataFlags.resize(nOutputBands);
    noDataFlags.reserve(nOutputBands);

    noDataValues.resize(nOutputBands);
    noDataValues.reserve(nOutputBands);
}

template <class TInputImage, class TOutputImage>
void otb::WMSCogFilter<TInputImage, TOutputImage>::BeforeThreadedGenerateData() {

}

template <class TInputImage, class TOutputImage>
void otb::WMSCogFilter<TInputImage, TOutputImage>::GenerateOutputInformation(){
    Superclass::GenerateOutputInformation();
    std::vector<bool> tmpNoDataFlags;
    std::vector<double> tmpNoDataValues;

    otb::ReadNoDataFlags(this->GetInput()->GetImageMetadata(), tmpNoDataFlags, tmpNoDataValues);
    this->GetOutput()->SetNumberOfComponentsPerPixel(nOutputBands);
    std::fill(noDataFlags.begin(), noDataFlags.end(), tmpNoDataFlags[0]);
    std::fill(noDataValues.begin(), noDataValues.end(), 65535);

    otb::WriteNoDataFlags(noDataFlags, noDataValues, this->GetOutput()->GetImageMetadata());
    this->GetOutput()->SetProjectionRef(this->GetInput()->GetProjectionRef());
}

template <class TInputImage, class TOutputImage>
void otb::WMSCogFilter<TInputImage, TOutputImage>::ThreadedGenerateData(const InputRegionType& outputRegionForThread, itk::ThreadIdType threadId) {
    typename TOutputImage::Pointer out  = this->GetOutput();
    auto in    = this->GetInput();

    InputImageConstIterator inIt(in, outputRegionForThread);
    OutputIterator          outIt(out, outputRegionForThread);

    typename TOutputImage::PixelType nullPxl(nOutputBands);
    nullPxl.Fill(255);

    for(outIt.GoToBegin(), inIt.GoToBegin(); !outIt.IsAtEnd(); ++outIt, ++inIt){
        if (inIt.Get() == variable->getNoData()) {
            outIt.Set(nullPxl);
            continue;
        }

        typename TOutputImage::PixelType pxl(3);

        pxl.SetData(variable->styleColors[inIt.Get()].data());
        outIt.Set(pxl);
    }
}

#endif // WMSCOGFILTER_HXX

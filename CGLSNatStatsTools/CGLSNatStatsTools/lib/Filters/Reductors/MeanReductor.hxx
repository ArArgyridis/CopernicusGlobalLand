/*
   Copyright (C) 2024  Argyros Argyridis arargyridis at gmail dot com
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

#include "MeanReductor.h"

template<class TInputImage, class TOutputImage>
otb::MeanReductor<TInputImage, TOutputImage>::MeanReductor() {}

template<class TInputImage, class TOutputImage>
void otb::MeanReductor<TInputImage, TOutputImage>::SetParams(ProductVariable::SharedPtr variable) {
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


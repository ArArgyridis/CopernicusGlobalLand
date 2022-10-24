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

#include <otbNoDataHelper.h>

#include "StatisticsFromLabelImageFilter.h"

namespace otb {


template <class TInputImage, class TLabelImage>
typename StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::InputImageTypePointer StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::GetInputDataImage() {
    return  static_cast<TInputImage*>( this->ProcessObject::GetInput(0) );
}

template <class TInputImage, class TLabelImage>
typename StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::LabelImagePointer StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::GetInputLabelImage() {
    return  static_cast<TLabelImage*>( this->ProcessObject::GetInput(1) );
}

template <class TInputImage, class TLabelImage>
void StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::SetInputDataImage(const TInputImage* image) {
    this->itk::ProcessObject::SetNthInput(0, const_cast<TInputImage*>(image));
}

template <class TInputImage, class TLabelImage>
void StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::SetInputLabelImage(const LabelImageType* image) {
    this->itk::ProcessObject::SetNthInput(1, const_cast<LabelImageType*>(image));

    std::vector<double> nullValues(1);
    otb::ReadNoDataFlags(image->GetImageMetadata(), labelDataNullFlags, nullValues);
    labelDataNullPixel = nullValues[0];

}

template <class TInputImage, class TLabelImage>
void StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::SetInputLabels(LabelsArrayPtr labels) {
    this->labels = labels;
}

template <class TInputImage, class TLabelImage>
void StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::SetInputProduct(const ProductInfo::Pointer product) {
    this->currentProduct = product;
    rawDataNullPixel = static_cast<InputPixelType>(this->currentProduct->getNoData());

}


template <class TInputImage, class TLabelImage>
void StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::SetPolyStatsPerRegion(const PolygonStats::PolyStatsPerRegionPtr stats, itk::ThreadIdType threadId){
    this->m_PolygonStatsPerRegion = stats;
    this->parentThreadId = threadId;
}

template <class TInputImage, class TLabelImage>
StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::StatisticsFromLabelImageFilter():labelDataNullPixel(0), currentProduct(nullptr) {}

template <class TInputImage, class TLabelImage>
void StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::Synthetize() {}

template <class TInputImage, class TLabelImage>
void StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::Reset() {}

template <class TInputImage, class TLabelImage>
void StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::ThreadedGenerateData(const RegionType &outputRegionForThread, itk::ThreadIdType threadId) {
    typename TInputImage::Pointer rawData = this->GetInputDataImage();
    typename TLabelImage::Pointer labels = this->GetInputLabelImage();
    TInputImageConstIterator rawDataIt(rawData, outputRegionForThread);
    TInputLabelImageConstIterator labelDataIt(labels, outputRegionForThread);

    for (rawDataIt.GoToBegin(), labelDataIt.GoToBegin(); !rawDataIt.IsAtEnd(); ++rawDataIt, ++labelDataIt) {
        LabelPixelType label = labelDataIt.Get();

        if(label == labelDataNullPixel)
            continue;

        PolygonStats::Pointer polyStats = (*(*m_PolygonStatsPerRegion)[label])[this->GetNumberOfThreads()*parentThreadId+threadId];
        polyStats->totalCount++;
        InputPixelType pixelData = rawDataIt.Get();

        if (pixelData == rawDataNullPixel)
            continue;

        polyStats->validCount++;
        auto val = currentProduct->lutProductValues[pixelData-currentProduct->minMaxValues[0]];
        polyStats->mean += val;
        polyStats->sd   += pow(val,2);

        size_t idx = (val <= currentProduct->valueRange.low)*0 +
                (currentProduct->valueRange.low <= val && val <= currentProduct->valueRange.mid)*1 +
                (currentProduct->valueRange.mid <= val && val <= currentProduct->valueRange.high)*2 +
                (val >= currentProduct->valueRange.high)*3;

        polyStats->densityArray[idx]++;
        polyStats->addToHistogram(val);


    }
}
}


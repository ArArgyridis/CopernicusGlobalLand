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
PolygonStats::Pointer StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::GetPolygonStatsByLabel(size_t &label) {
    return (*this->polyMapStats)[label];
}


template <class TInputImage, class TLabelImage>
void StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::SetInputLabelImage(const LabelImageType* image) {
    this->itk::ProcessObject::SetNthInput(1, const_cast<LabelImageType*>(image));

    std::vector<double> nullValues(1);
    otb::ReadNoDataFlags(image->GetImageMetadata(), labelDataNullFlags, nullValues);
    labelDataNullPixel = nullValues[0];

}

template <class TInputImage, class TLabelImage>
void StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::SetInputLabels(LabelSetPtr labels) {
    this->labels = std::vector<size_t>(labels->begin(), labels->end());
}



template <class TInputImage, class TLabelImage>
void StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::SetInputProduct(const ProductInfo::Pointer product) {
    this->currentProduct = product;
    rawDataNullPixel = static_cast<InputPixelType>(this->currentProduct->getNoData());

}



template <class TInputImage, class TLabelImage>
StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::StatisticsFromLabelImageFilter():labelDataNullPixel(0), currentProduct(nullptr) {}

template <class TInputImage, class TLabelImage>
void StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::Synthetize() {
/*
    for (size_t i = 0; i < labels.size(); i++) {
        auto polyStat = (*polyMapStats)[labels[i]];
        for(size_t j = 0; j <threadPolyMapStatsVector.size(); j++) {
            auto pos = threadPolyMapStatsVector[j]->find(labels[i]);

            if ( pos != threadPolyMapStatsVector[j]->end()) {
                polyStat->totalCount += pos->second->totalCount;
                polyStat->validCount += pos->second->validCount;
                polyStat->mean += pos->second->mean;
                polyStat->sd += pos->second->sd;

                for (size_t i = 0; i < polyStat->densityArray.size(); i++)
                    polyStat->densityArray[i] += pos->second->densityArray[i];

                for(size_t i = 0; i <polyStat->histogramBins; i++)
                    polyStat->histogram[i] += pos->second->histogram[i];
            }
        }

        if (polyStat->validCount == 0)
            continue;

        polyStat->mean /=polyStat->validCount;
        polyStat->sd = sqrt( polyStat->sd/polyStat->validCount - pow(polyStat->mean, 2));

        for (size_t i = 0; i < 4; i++)
            polyStat->densityArray[i] = pixelsToAreaM2Degrees(polyStat->densityArray[i], this->GetOutput()->GetSpacing()[0]);
    }
    */

}

template <class TInputImage, class TLabelImage>
void StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::Reset() {

    this->polyMapStats = PolygonStats::NewPointerMap(labels, currentProduct);

    threadPolyMapStatsVector = std::vector<FloatInputImageTypePolyMapStats>(this->GetNumberOfThreads());

    for (itk::ThreadIdType threadId = 0; threadId < this->GetNumberOfThreads(); threadId++)
        threadPolyMapStatsVector[threadId] = PolygonStats::NewPointerMap(labels, currentProduct);

}

template <class TInputImage, class TLabelImage>
void StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::ThreadedGenerateData(const RegionType &outputRegionForThread, itk::ThreadIdType threadId) {

    typename TInputImage::Pointer rawData = this->GetInputDataImage();
    typename TLabelImage::Pointer labels = this->GetInputLabelImage();
    TInputImageConstIterator rawDataIt(rawData, outputRegionForThread);
    TInputLabelImageConstIterator labelDataIt(labels, outputRegionForThread);

    FloatInputImageTypePolyMapStats threadPolygonStats = threadPolyMapStatsVector[threadId];
    InputPixelType pixelData;

    for (rawDataIt.GoToBegin(), labelDataIt.GoToBegin(); !rawDataIt.IsAtEnd(); ++rawDataIt, ++labelDataIt) {
        LabelPixelType label = labelDataIt.Get();

        if(label != labelDataNullPixel) {
            (*threadPolygonStats)[label]->totalCount++;
             pixelData = rawDataIt.Get();
            if (pixelData != rawDataNullPixel) {
                typename PolygonStats::Pointer polyStats = (*threadPolygonStats)[label];
                (*threadPolygonStats)[label]->validCount++;

                    auto val = currentProduct->lutProductValues[pixelData-currentProduct->minMaxValues[0]];
                    polyStats->mean += val;
                    polyStats->sd += pow(val,2);

                    size_t idx = (val <= currentProduct->valueRange.low)*0 +
                            (currentProduct->valueRange.low <= val && val <= currentProduct->valueRange.mid)*1 +
                            (currentProduct->valueRange.mid <= val && val <= currentProduct->valueRange.high)*2 +
                            (val >= currentProduct->valueRange.high)*3;

                    polyStats->densityArray[idx]++;
                    polyStats->addToHistogram(val);
            }
        }
    }
}
}


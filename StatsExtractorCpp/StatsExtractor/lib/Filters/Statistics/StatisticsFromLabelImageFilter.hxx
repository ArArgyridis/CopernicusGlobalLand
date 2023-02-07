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
void StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::SetInputDataImage(const TInputImage* image, size_t imageId) {
    this->itk::ProcessObject::SetNthInput(0, const_cast<TInputImage*>(image));
    this->imageId = imageId;
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
void StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::SetInputProduct(const ProductInfo::Pointer product, const ProductVariable::Pointer variable) {
    this->product = product;
    this->variable = variable;
    rawDataNullPixel = static_cast<InputPixelType>(this->variable->getNoData());
}

template <class TInputImage, class TLabelImage>
StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::StatisticsFromLabelImageFilter():labelDataNullPixel(0), product(nullptr),m_ParentRegionId(0) {}

template <class TInputImage, class TLabelImage>
void StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::Synthetize() {
    PolygonStats::PolyStatsMapPtr polyData = PolygonStats::NewPointerMap(labels, product, variable);
    PolygonStats::collapseData(perRegionStats, polyData);
    size_t regionDBID = m_ParentRegionId*10e6 + m_ParentThreadId;
    PolygonStats::updateDBTmp(imageId, regionDBID, m_Config, polyData);
}

template <class TInputImage, class TLabelImage>
void StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::Reset() {
    perRegionStats = PolygonStats::NewPolyStatsPerRegionMap(this->GetNumberOfThreads(), labels, product, variable);
}

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

        InputPixelType pixelData = rawDataIt.Get();
        PolygonStats::Pointer polyStats = (*(*perRegionStats)[label])[threadId];
        polyStats->updateStats<InputPixelType, LabelPixelType>(pixelData);
    }
}
}


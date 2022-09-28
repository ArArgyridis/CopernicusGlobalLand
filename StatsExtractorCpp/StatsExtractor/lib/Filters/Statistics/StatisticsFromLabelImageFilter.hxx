#include "StatisticsFromLabelImageFilter.h"
#include <otbNoDataHelper.h>

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

    std::vector<double> nullValues;
    otb::ReadNoDataFlags(image->GetImageMetadata(), rawDataNullFlags, nullValues);
    rawDataNullPixel = nullValues[0];

}

template <class TInputImage, class TLabelImage>
void StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::SetInputLabelImage(const LabelImageType* image) {
    this->itk::ProcessObject::SetNthInput(1, const_cast<LabelImageType*>(image));

    std::vector<double> nullValues;
    otb::ReadNoDataFlags(image->GetImageMetadata(), labelDataNullFlags, nullValues);

    labelDataNullPixel = nullValues[0];
}

template <class TInputImage, class TLabelImage>
void StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::SetInputLabels(const std::set<std::size_t> &labels) {
    this->labels = std::vector<size_t>(labels.begin(), labels.end());
}



template <class TInputImage, class TLabelImage>
void StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::SetInputProduct(const ProductInfoPtr product) {
    this->currentProduct = product;
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

        if (polyStat->validCount ==0)
            continue;

        polyStat->mean /=polyStat->validCount;
        polyStat->sd = sqrt( polyStat->sd/polyStat->validCount - pow(polyStat->mean, 2));

        for (size_t i = 0; i < 4; i++)
            polyStat->densityArray[i] = 100*pixelsToAreaM2Degrees(polyStat->densityArray[i], this->GetOutput()->GetSpacing()[0])/
                    pixelsToAreaM2Degrees(static_cast<long double>(polyStat->validCount), this->GetOutput()->GetSpacing()[0]);

        polyStat->computeColors();
    }
    */
}

template <class TInputImage, class TLabelImage>
void StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::Reset() {
    this->polyMapStats = PolygonStats::NewPointerMap(labels, currentProduct);

    for (itk::ThreadIdType threadId = 0; threadId < this->GetNumberOfThreads(); threadId++)
        threadPolyMapStatsVector.emplace_back(PolygonStats::NewPointerMap(labels, currentProduct));
}

template <class TInputImage, class TLabelImage>
void StatisticsFromLabelImageFilter<TInputImage, TLabelImage>::ThreadedGenerateData(const RegionType &outputRegionForThread, itk::ThreadIdType threadId) {
/*
    typename TInputImage::Pointer rawData = this->GetInputDataImage();
    typename TLabelImage::Pointer labels = this->GetInputLabelImage();

    TInputImageConstIterator rawDataIt(rawData, outputRegionForThread);
    TInputLabelImageConstIterator labelDataIt(labels, outputRegionForThread);

    FloatInputImageTypePolyMapStats threadPolygonStats = threadPolyMapStatsVector[threadId];
    for (rawDataIt.GoToBegin(), labelDataIt.GoToBegin(); !rawDataIt.IsAtEnd(); ++rawDataIt, ++labelDataIt) {
        LabelPixelType label = labelDataIt.Get();

        if(label != labelDataNullPixel) {
            (*threadPolygonStats)[label]->totalCount++;
            if (rawDataIt.Get()!= rawDataNullPixel) {
                typename PolygonStats::Pointer polyStats = (*threadPolygonStats)[label];
                (*threadPolygonStats)[label]->validCount++;
                InputPixelType data = rawDataIt.Get();

                auto val = currentProduct->lutProductValues[data-currentProduct->minMaxValues[0]];
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
    */


}
}


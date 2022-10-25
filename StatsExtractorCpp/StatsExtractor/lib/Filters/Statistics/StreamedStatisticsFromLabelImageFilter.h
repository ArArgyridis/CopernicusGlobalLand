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

#ifndef STREAMEDSTATISTICSFROMLABELIMAGEFILTER_H
#define STREAMEDSTATISTICSFROMLABELIMAGEFILTER_H

#include <otbPersistentFilterStreamingDecorator.h>

#include "StatisticsFromLabelImageFilter.hxx"

namespace otb {
template <class TInputImage, class TLabelImage>
class ITK_EXPORT StreamedStatisticsFromLabelImageFilter: public PersistentFilterStreamingDecorator<StatisticsFromLabelImageFilter<TInputImage, TLabelImage>> {
public:
    /** Standard Self typedef */
    typedef StreamedStatisticsFromLabelImageFilter     Self;
    typedef PersistentFilterStreamingDecorator<StatisticsFromLabelImageFilter<TInputImage, TLabelImage>> Superclass;
    typedef itk::SmartPointer<Self>                     Pointer;
    typedef itk::SmartPointer<const Self>           ConstPointer;

    /** Type macro */
    itkNewMacro(Self);

    /** Creation through object factory macro */
    itkTypeMacro(StreamedStatisticsFromLabelImageFilter, PersistentFilterStreamingDecorator);

    PolygonStats::Pointer GetPolygonStatsByLabel(size_t &label) {
        return this->GetFilter()->GetPolygonStatsByLabel(label);
    }

    void SetConfig (const Configuration::Pointer cfg) {
        this->GetFilter()->SetConfig(cfg);
    }

    void SetInputDataImage(const TInputImage* image, size_t imageId) {
        this->GetFilter()->SetInputDataImage(image, imageId);
    }

    void SetInputLabelImage(const TLabelImage* image){
        this->GetFilter()->SetInputLabelImage(image);
    }

    void SetInputLabels(LabelsArrayPtr labels) {
        this->GetFilter()->SetInputLabels(labels);
    }

    void SetInputProduct(const ProductInfo::Pointer product) {
        this->GetFilter()->SetInputProduct(product);
    }

    void SetNumberOfThreads(itk::ThreadIdType threadCount) {
        Superclass::SetNumberOfThreads(threadCount);
        this->GetFilter()->SetNumberOfThreads(threadCount);
    }

    void SetParentRegionId(const size_t parentRegionId) {
        this->GetFilter()->SetParentRegionId(parentRegionId);
    }

    void SetParentThreadId(const itk::ThreadIdType threadId) {
        this->GetFilter()->SetParentThreadId(threadId);
    }

protected:
    StreamedStatisticsFromLabelImageFilter() {}
    ~StreamedStatisticsFromLabelImageFilter() override {}

private:
    StreamedStatisticsFromLabelImageFilter(const Self&) = delete;
    void operator=(const Self&) = delete;
};
}
#endif //STREAMEDSTATISTICSFROMLABELIMAGEFILTER_H

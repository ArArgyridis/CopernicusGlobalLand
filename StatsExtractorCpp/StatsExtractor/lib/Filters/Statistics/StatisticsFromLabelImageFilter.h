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

#ifndef STATISTICS_HXX
#define STATISTICS_HXX

#include <itkArray.h>
#include <itkNumericTraits.h>
#include <itkSimpleDataObjectDecorator.h>
#include <itkVariableLengthVector.h>
#include <otbPersistentImageFilter.h>
#include <unordered_map>
#include <itkImageRegionConstIterator.h>
#include <itkImageRegionIterator.h>

#include "../../ConfigurationParser/ConfigurationParser.h"
#include "../../Constants/Constants.h"
#include "../../Utils/Utils.hxx"
#include "PolygonStats.h"

namespace otb {

template <class TInputImage, class TLabelImage>
class StatisticsFromLabelImageFilter:public PersistentImageFilter<TInputImage, TInputImage> {
public:

    /** Standard Self typedef */
    using Self          = StatisticsFromLabelImageFilter;
    using Superclass    = PersistentImageFilter<TInputImage, TInputImage>;
    using Pointer       = itk::SmartPointer<Self>;
    using ConstPointer  = itk::SmartPointer<const Self>;

    using TInputImageConstIterator          =  itk::ImageRegionConstIterator<TInputImage>;
    using TInputLabelImageConstIterator     =  itk::ImageRegionConstIterator<TLabelImage>;
    using OutputIterator                    =  itk::ImageRegionIterator<TInputImage>;


    /** Method for creation through the object factory. */
    itkNewMacro(Self);

    /** Runtime information support. */
    itkTypeMacro(StreamedStatisticsFromLabelImageFilter, PersistentImageFilter);

    /** Image related typedefs. */
    using InputImageType                    = TInputImage;
    using InputImageTypePointer             = typename TInputImage::Pointer ;

    using RealInputPixelType                = itk::VariableLengthVector<long double>;

    using LabelImageType                    = TLabelImage;
    using LabelImagePointer                 = typename TLabelImage::Pointer;

    using RegionType                        = typename InputImageType::RegionType;
    using InputPixelType                    = typename InputImageType::PixelType;
    using LabelPixelType                    = typename LabelImageType::PixelType;

    itkSetMacro(Config, Configuration::Pointer);
    itkSetMacro(ParentRegionId, size_t);
    itkSetMacro(ParentThreadId, itk::ThreadIdType);

    virtual InputImageTypePointer GetInputDataImage();
    virtual LabelImagePointer GetInputLabelImage();
    virtual void Reset(void) override;
    virtual void SetInputDataImage(const TInputImage* image, size_t imageId);
    virtual void SetInputLabelImage(const LabelImageType* image);
    virtual void SetInputLabels(LabelsArrayPtr labels);
    virtual void SetInputProduct(const ProductInfo::Pointer product, const ProductVariable::Pointer variable);
    virtual void Synthetize(void) override;

protected:
    StatisticsFromLabelImageFilter();
    ~StatisticsFromLabelImageFilter() override {}

    void ThreadedGenerateData(const RegionType& outputRegionForThread, itk::ThreadIdType threadId) override;
private:
    StatisticsFromLabelImageFilter(const Self&) = delete;
    void operator=(const Self&) = delete;
    std::vector<bool> rawDataNullFlags, labelDataNullFlags;
    InputPixelType rawDataNullPixel;
    LabelPixelType labelDataNullPixel;
    LabelsArrayPtr labels;
    ProductInfo::Pointer product;
    ProductVariable::Pointer variable;
    itk::ThreadIdType m_ParentThreadId;
    Configuration::Pointer m_Config;
    size_t m_ParentRegionId, imageId;
    PolygonStats::PolyStatsPerRegionPtr perRegionStats;
};





}
#endif // STATISTICS_HXX

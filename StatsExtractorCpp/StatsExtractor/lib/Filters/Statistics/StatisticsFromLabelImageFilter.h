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

#include "../../Constants/Constants.h"
#include "../../Utils/Utils.hxx"
#include "PolygonStats.h"

namespace otb {

template <class TInputImage, class TLabelImage>
class StatisticsFromLabelImageFilter:public PersistentImageFilter<TInputImage, TInputImage> {
public:

    /** Standard Self typedef */
    typedef StatisticsFromLabelImageFilter        Self;
    typedef PersistentImageFilter<TInputImage, TInputImage> Superclass;
    typedef itk::SmartPointer<Self>                                     Pointer;
    typedef itk::SmartPointer<const Self>                               ConstPointer;

    using  TInputImageConstIterator   =  itk::ImageRegionConstIterator<TInputImage>;
    using  TInputLabelImageConstIterator     =  itk::ImageRegionConstIterator<TLabelImage>;
    using OutputIterator                                    =  itk::ImageRegionIterator<TInputImage>;


    /** Method for creation through the object factory. */
    itkNewMacro(Self);

    /** Runtime information support. */
    itkTypeMacro(StreamedStatisticsFromLabelImageFilter, PersistentImageFilter);

    /** Image related typedefs. */
    using InputImageType                              = TInputImage;
    using InputImageTypePointer                 = typename TInputImage::Pointer ;

    typedef itk::VariableLengthVector<long double>                       RealInputPixelType;
    using FloatInputImageTypePolyMapStats     = typename PolygonStats::MapPointer;

    using LabelImageType                         = TLabelImage;
    using LabelImagePointer                     = typename TLabelImage::Pointer;

    typedef typename InputImageType::RegionType                    RegionType;
    typedef typename InputImageType::PixelType                     InputPixelType;
    typedef typename LabelImageType::PixelType                      LabelPixelType;

    virtual InputImageTypePointer GetInputDataImage();
    virtual LabelImagePointer GetInputLabelImage();
    virtual PolygonStats::Pointer GetPolygonStatsByLabel(size_t &label);
    virtual void SetInputDataImage(const TInputImage* image);
    virtual void SetInputLabelImage(const LabelImageType* image);
    virtual void SetInputLabels(LabelSetPtr labels);
    virtual void SetInputProduct(const ProductInfo::Pointer product);
    virtual void Reset(void) override;
    virtual void Synthetize(void) override;

protected:
    StatisticsFromLabelImageFilter();
    ~StatisticsFromLabelImageFilter() override {}

    void ThreadedGenerateData(const RegionType& outputRegionForThread, itk::ThreadIdType threadId) override;
private:
    StatisticsFromLabelImageFilter(const Self&) = delete;
    void operator=(const Self&) = delete;
    FloatInputImageTypePolyMapStats polyMapStats;
    std::vector<FloatInputImageTypePolyMapStats> threadPolyMapStatsVector;
    std::vector<bool> rawDataNullFlags, labelDataNullFlags;
    InputPixelType rawDataNullPixel;
    LabelPixelType labelDataNullPixel;
    std::vector<std::size_t> labels;
    ProductInfo::Pointer currentProduct;

};





}
#endif // STATISTICS_HXX

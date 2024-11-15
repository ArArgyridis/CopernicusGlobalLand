/*
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

#ifndef WMSCOGFILTER_H
#define WMSCOGFILTER_H
#include <itkImageToImageFilter.h>
#include <itkImageRegionConstIterator.h>
#include <itkImageRegionIterator.h>

#include "../../../lib/Constants/ProductInfo.h"

namespace otb {

template <class TInputImage, class TOutputImage>
class WMSCogFilter:public itk::ImageToImageFilter<TInputImage, TOutputImage> {
public:
    /** Standard typedefs */
    using Self          = WMSCogFilter;
    using Superclass    = itk::ImageToImageFilter<TInputImage, TOutputImage>;
    using Pointer       = itk::SmartPointer<Self>;
    using ConstPointer  = itk::SmartPointer<const Self>;

    using InputImageConstIterator  = itk::ImageRegionConstIterator<TInputImage>;
    using OutputIterator            = itk::ImageRegionIterator<TOutputImage>;
    using TInputImagePointer        = typename TInputImage::Pointer;
    using InputRegionType           = typename TInputImage::RegionType;

    /** Type macro */
    itkNewMacro(Self)

    /** Creation through object factory macro */
    itkTypeMacro(WMSCogFilter, itk::ImageToImageFilter)

    void setProduct(ProductInfo::SharedPtr product, ProductVariable::SharedPtr variable);

protected:
    WMSCogFilter();
    ~WMSCogFilter() override {}

    WMSCogFilter(const Self&) = delete;
    void operator=(const Self&) = delete;
    virtual void BeforeThreadedGenerateData() override;
    virtual void GenerateOutputInformation() override;
    void ThreadedGenerateData(const InputRegionType& outputRegionForThread, itk::ThreadIdType threadId) override;

    std::vector<bool>           noDataFlags;
    std::vector<double>         noDataValues;
    size_t                      nOutputBands;
    ProductInfo::SharedPtr        product;
    ProductVariable::SharedPtr    variable;

};
}

#ifndef OTB_MANUAL_INSTANTIATION
#include "WMSCogFilter.hxx"
#endif

#endif // WMSCOGFILTER_H

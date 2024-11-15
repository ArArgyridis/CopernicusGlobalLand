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

#ifndef MEANREDUCTOR_H
#define MEANREDUCTOR_H

#include <itkImageToImageFilter.h>
#include <itkImageConstIterator.h>
#include <itkImageRegionIterator.h>
#include <otbImage.h>

#include "../../Constants/ProductVariable.h"

namespace otb {

template<class TInputImage, class TOutputImageType>
class MeanReductor:public itk::ImageToImageFilter<TInputImage, Image<TOutputImageType, 2>> {
public:
    /** Standard typedefs */
    using Self                      = MeanReductor;
    using TOutputImage              = Image<TOutputImageType, 2>;
    using Superclass                = itk::ImageToImageFilter<TInputImage, TOutputImage>;
    using Pointer                   = itk::SmartPointer<Self>;
    using ConstPointer              = itk::SmartPointer<const Self>;
    using TInputImageConstIterator  = itk::ImageRegionConstIterator<TInputImage>;
    using TInputImagePointer    = typename TInputImage::Pointer;
    using RegionType            = typename TInputImage::RegionType;

    using TOutputImageIterator  = itk::ImageRegionIterator<TOutputImage>;
    using TOutputImagePointer   = typename TOutputImage::Pointer;

    /** Type macro */
    itkNewMacro(Self);

    /** Creation through object factory macro */
    itkTypeMacro(MeanReductor, ImageToImageFilter);

    void SetParams(ProductVariable::SharedPtr variable);

protected:
    MeanReductor();
    void ThreadedGenerateData(const RegionType& outputRegionForThread, itk::ThreadIdType threadId) override;
    ProductVariable::SharedPtr variable;
};

#ifndef OTB_MANUAL_INSTANTIATION
#include "MeanReductor.hxx"
#endif
}
#endif // MEANREDUCTOR_H

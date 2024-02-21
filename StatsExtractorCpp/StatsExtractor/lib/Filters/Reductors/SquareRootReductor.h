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

#ifndef SQUAREROOTREDUCTOR_H
#define SQUAREROOTREDUCTOR_H

#include "MeanReductor.h"

namespace otb{
template<class TInputImage, class TOutputImageType>
class SquareRootReductor:public otb::MeanReductor<TInputImage, TOutputImageType> {
public:
    /** Standard typedefs */
    using Self                      = SquareRootReductor;
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
    itkTypeMacro(SquareRootReductor, ImageToImageFilter);

protected:
    SquareRootReductor();
    void ThreadedGenerateData(const RegionType& outputRegionForThread, itk::ThreadIdType threadId) override;
};

#ifndef OTB_MANUAL_INSTANTIATION
#include "SquareRootReductor.hxx"
#endif
}
#endif // SQUAREROOTREDUCTOR_H



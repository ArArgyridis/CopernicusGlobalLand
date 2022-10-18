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

#ifndef STREAMEDPROCESSINGCHAINFILTER_H
#define STREAMEDPROCESSINGCHAINFILTER_H

#include <otbPersistentFilterStreamingDecorator.h>

#include "ProcessingChainFilter.hxx"

namespace otb {
template <class TInputImage, class TPolygonDataType>
class ITK_EXPORT StreamedProcessingChainFilter: public PersistentFilterStreamingDecorator<ProcessingChainFilter<TInputImage, TPolygonDataType>> {
public:
    /** Standard Self typedef */
    using Self                      =  StreamedProcessingChainFilter;
    using Superclass                = PersistentFilterStreamingDecorator<ProcessingChainFilter<TInputImage, TPolygonDataType>> ;
    using Pointer                   = itk::SmartPointer<Self>;
    using ConstPointer              = itk::SmartPointer<const Self>;
    using TPolygonDataTypePointer   = typename TPolygonDataType::Pointer;

    /** Type macro */
    itkNewMacro(Self);

    /** Creation through object factory macro */
    itkTypeMacro(StreamedStatisticsFromLabelImageFilter, PersistentFilterStreamingDecorator);

    void UpdateOutputInformation() override {
        this->GetFilter()->UpdateOutputInformation();
    }

    void SetParams(const Configuration::Pointer& config, const ProductInfo::Pointer& product, OGREnvelope &envlp, std::unique_ptr<std::vector<std::pair<size_t, std::string>>> images, std::unique_ptr<std::vector<size_t>> polyIds, size_t& polySRID) {
        this->GetFilter()->SetParams(config, product, envlp, std::move(images), std::move(polyIds), polySRID);
    }


protected:
    StreamedProcessingChainFilter() {}

    ~StreamedProcessingChainFilter() override {}

private:
    StreamedProcessingChainFilter(const Self&) = delete;
    void operator=(const Self&) = delete;

};
}
#endif // STREAMEDPROCESSINGCHAINFILTER_H

/*
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

#ifndef STREAMEDSYSTEMSTRATIFICATIONSTATISTICSFILTER_H
#define STREAMEDSYSTEMSTRATIFICATIONSTATISTICSFILTER_H

#include <otbPersistentFilterStreamingDecorator.h>

#include "SystemStratificationStatisticsFilter.hxx"

namespace otb {
template <class BaseClass>
class ITK_EXPORT StreamedStatisticsExtractorFilter: public PersistentFilterStreamingDecorator<BaseClass> {
public:
    /** Standard Self typedef */
    using Self                      = StreamedStatisticsExtractorFilter;
    using Superclass                = PersistentFilterStreamingDecorator<BaseClass> ;
    using Pointer                   = itk::SmartPointer<Self>;
    using ConstPointer              = itk::SmartPointer<const Self>;

    /** Type macro */
    itkNewMacro(Self)

    /** Creation through object factory macro */
    itkTypeMacro(StreamedStatisticsExtractorFilter, PersistentFilterStreamingDecorator)

    void SetParams(const Configuration::SharedPtr config, const ProductVariable::SharedPtr variable, OGREnvelope &envlp, JsonValue &images,
                           JsonDocumentSharedPtr polyIds, size_t polySRID, const std::string& partitionTable="") {
        this->GetFilter()->SetParams(config, variable, envlp, images, polyIds, polySRID, partitionTable);
    }

    void UpdateOutputInformation() override {
        this->GetFilter()->UpdateOutputInformation();
    }

    bool ValidAOI() {
        return this->GetFilter()->ValidAOI();
    }

protected:
    StreamedStatisticsExtractorFilter() {}

    ~StreamedStatisticsExtractorFilter() override {}

private:
    StreamedStatisticsExtractorFilter(const Self&) = delete;
    void operator=(const Self&) = delete;

};
}
#endif // STREAMEDSYSTEMSTRATIFICATIONSTATISTICSFILTER_H

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
#ifndef ORDERSTATISTICSFILTER_H
#define ORDERSTATISTICSFILTER_H

#include <fstream>
#include "SystemStratificationStatisticsFilter.h"

namespace otb{

template <class TInputImage, class TPolygonDataType>
class OrderStatisticsFilter:public SystemStratificationStatisticsFilter<TInputImage, TPolygonDataType> {
public:
    /** Standard Self typedef */
    using Self                      = OrderStatisticsFilter;
    using Superclass                = SystemStratificationStatisticsFilter<TInputImage, TPolygonDataType>;
    using Pointer                   = itk::SmartPointer<Self>;
    using ConstPointer              = itk::SmartPointer<const Self>;

    /** Type macro */
    itkNewMacro(Self)

    /** Creation through object factory macro */
    itkTypeMacro(StreamedStatisticsExtractorFilter, PersistentFilterStreamingDecorator)

    itkSetMacro(OrderId, std::string)
    itkSetMacro(OutputDirectory, std::filesystem::path)
    itkSetMacro(RTFlag, short)

    virtual void Synthetize(void) override {
        for (auto& polyId: *this->labels) {
            std::stringstream outData;
            for (auto& img: this->productImages) {
                auto polyDt = (*(*this->imageStats)[img.first])[polyId];
                outData << polyId << ' ' << this->variable->getProductInfo()->getDateAsStringForFile(img.second) <<
                    ' ' << polyDt->getCSVLine() << "\n";
            }
            std::filesystem::path outPath =  m_OutputDirectory/ std::filesystem::path(this->variable->getProductInfo()->productNames[0])/ std::filesystem::path(this->variable->variable);

            if(m_RTFlag > -1)
                outPath /=std::to_string(m_RTFlag);

            if(!std::filesystem::is_directory(outPath))
                std::filesystem::create_directories(outPath);

            std::filesystem::path outFilePath = outPath/std::filesystem::path(std::to_string(polyId) + ".csv");
            std::ofstream outFile;
            if(!std::filesystem::exists(outFilePath)) {
                outFile.open(outFilePath, std::ios::out);
                outFile << "poly_id date " << PolygonStats::getCSVHeader() << "\n";
            }
            else
                outFile.open(outFilePath, std::ios::out | std::ios::app);
            outFile << outData.str();
            outFile.close();
        }
    }

protected:
    OrderStatisticsFilter(): SystemStratificationStatisticsFilter<TInputImage, TPolygonDataType>() {}
    ~OrderStatisticsFilter(){}
    virtual std::string polygonInfoQuery(OGREnvelope &envelope) override {
        return fmt::format((R"""(with region AS( select st_setsrid((st_makeenvelope({0},{1},{2},{3})),4326) bbox),
            aoi AS(SELECT pog.poly_id id, st_transform(pog.geom, 4326) aoi FROM product_order_geom pog
            WHERE pog.poly_id IN({4}) AND pog.product_order_id = '{5}')
            SELECT aoi.id, ST_ASTEXT(ST_MULTI(CASE WHEN ST_CONTAINS(region.bbox, aoi.aoi) THEN aoi.aoi ELSE ST_INTERSECTION(aoi.aoi, region.bbox) END)) geom
            FROM aoi JOIN region ON TRUE )"""), envelope.MinX, envelope.MinY,envelope.MaxX, envelope.MaxY, this->polyIdsStr, m_OrderId );
    }

private:
    std::string m_OrderId;
    std::filesystem::path m_OutputDirectory;
    short m_RTFlag;
};

}


#endif // ORDERSTATISTICSFILTER_H

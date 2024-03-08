#ifndef ORDERSTATISTICSFILTER_H
#define ORDERSTATISTICSFILTER_H

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
        itkTypeMacro(StreamedStatisticsExtractorFilter, PersistentFilterStreamingDecorator);

protected:
    OrderStatisticsFilter(): SystemStratificationStatisticsFilter<TInputImage, TPolygonDataType>(),
        polygonInfoQuery(R"""(with region AS( select st_setsrid((st_makeenvelope({0},{1},{2},{3})),4326) bbox),
aoi AS(SELECT po.id, st_transform(po.aoi, 4326) aoi FROM product_order po WHERE po.id = '{4}')
select aoi.id, ST_ASTEXT(ST_MULTI(case when ST_CONTAINS(region.bbox, aoi.aoi) THEN aoi.aoi ELSE st_intersection(aoi.aoi, region.bbox) END)) geom
FROM aoi JOIN region ON TRUE )""") {}
    ~OrderStatisticsFilter();

};

}


#endif // ORDERSTATISTICSFILTER_H

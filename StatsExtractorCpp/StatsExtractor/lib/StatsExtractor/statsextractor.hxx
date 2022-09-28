#ifndef STATSEXTRACTOR_HXX
#define STATSEXTRACTOR_HXX

#include <boost/filesystem.hpp>
#include <otbVectorData.h>
#include "../ConfigurationParser/configurationparser.hxx"
#include "../Filters/Statistics/StatisticsFromLabelImageFilter.h"

using VectorDataType = otb::VectorData<double, 2>;

class StatsExtractor {
    Configuration::Pointer config;
    std::string stratificationType;

public:
    StatsExtractor(Configuration::Pointer cfg, std::string stratificationType);
    void process();
};

#endif // STATSEXTRACTOR_HXX

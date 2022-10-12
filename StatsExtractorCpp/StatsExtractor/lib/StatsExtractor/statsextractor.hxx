#ifndef STATSEXTRACTOR_HXX
#define STATSEXTRACTOR_HXX

#include <boost/filesystem.hpp>

#include "../ConfigurationParser/configurationparser.hxx"
#include "../Filters/Statistics/StatisticsFromLabelImageFilter.h"

class StatsExtractor {
    Configuration::Pointer config;
    std::string stratification;

public:
    StatsExtractor(Configuration::Pointer cfg, std::string stratificationType);
    void process();
    void process(bool k);
};

#endif // STATSEXTRACTOR_HXX

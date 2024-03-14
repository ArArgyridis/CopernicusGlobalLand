#ifndef ZSCOREPROCESSOR_H
#define ZSCOREPROCESSOR_H


#include <boost/filesystem.hpp>

#include "../../ConfigurationParser/ConfigurationParser.h"
#include "../../Constants/ProductInfo.h"



class ZScoreProcessor {
    boost::posix_time::ptime dateStart, dateEnd;
    Configuration::SharedPtr config;
    ProductInfo::SharedPtr product;
    ProductVariable::SharedPtr anomalyVariable, productVariable;
    std::filesystem::path tmpFolder;

public:
    ZScoreProcessor();
    ZScoreProcessor(boost::posix_time::ptime dateStart, boost::posix_time::ptime dateEnd, Configuration::SharedPtr cfg, ProductInfo::SharedPtr product, ProductVariable::SharedPtr anomalyVariable, ProductVariable::SharedPtr productVariable);
    ~ZScoreProcessor();
    void process();
};

#endif // ZSCOREPROCESSOR_H

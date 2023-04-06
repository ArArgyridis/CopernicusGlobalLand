#ifndef PRODUCTINFO_H
#define PRODUCTINFO_H

#include "../ConfigurationParser/ConfigurationParser.h"
#include "ProductVariable.h"

class ProductInfo {
    Configuration::Pointer config;

public:
    using Pointer = std::shared_ptr<ProductInfo>;
    StringPtr productType;
    std::map<std::string, ProductVariable::Pointer> variables;
    std::string pattern, types, dateptr, fileNameCreationPattern;
    PathSharedPtr rootPath, firstProductPath;
    std::vector<std::string> productNames;
    size_t id;
    static Pointer New(PGPool::PGConn::PGRow row, Configuration::Pointer cfg);

protected:
    ProductInfo();
    ProductInfo(PGPool::PGConn::PGRow row, Configuration::Pointer cfg);

};

#endif // PRODUCTINFO_H
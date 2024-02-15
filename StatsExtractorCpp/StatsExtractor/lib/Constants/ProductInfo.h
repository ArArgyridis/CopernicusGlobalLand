#ifndef PRODUCTINFO_H
#define PRODUCTINFO_H

#include <string>

#include "ProductVariable.h"
#include "../ConfigurationParser/ConfigurationParser.h"
#include "../PostgreSQL/PostgreSQL.h"
#include "../Utils/Utils.hxx"


class ProductInfo:public std::enable_shared_from_this<ProductInfo> {
    Configuration::SharedPtr config;

public:
    using Pointer = std::shared_ptr<ProductInfo>;
    StringPtr productType;
    std::map<std::string, ProductVariable::Pointer> variables;
    std::string pattern, types, dateptr, fileNameCreationPattern;
    PathSharedPtr rootPath, firstProductPath;
    std::vector<std::string> productNames;
    size_t id;
    static Pointer New(PGPool::PGConn::PGRow row, Configuration::SharedPtr cfg);

protected:
    ProductInfo();
    ProductInfo(PGPool::PGConn::PGRow row, Configuration::SharedPtr cfg);

};

#endif // PRODUCTINFO_H

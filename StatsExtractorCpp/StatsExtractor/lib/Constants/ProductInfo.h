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
    using SharedPtr = std::shared_ptr<ProductInfo>;
    StringPtr productType;
    std::map<std::string, ProductVariable::SharedPtr> variables;
    std::string pattern, types, dateptr, fileNameCreationPattern;
    PathSharedPtr rootPath, firstProductPath;
    std::vector<std::string> productNames;
    size_t id;
    static SharedPtr New(PGPool::PGConn::PGRow row, Configuration::SharedPtr cfg);

protected:
    ProductInfo();
    ProductInfo(PGPool::PGConn::PGRow row, Configuration::SharedPtr cfg);

};

#endif // PRODUCTINFO_H

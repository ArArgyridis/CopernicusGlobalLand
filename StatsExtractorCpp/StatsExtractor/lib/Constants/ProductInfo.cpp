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

#include "ProductInfo.h"
#include <memory>


ProductInfo::ProductInfo(){}

ProductInfo::ProductInfo(PGPool::PGConn::PGRow row, Configuration::SharedPtr cfg) {

    auto productNamesArr = row[0].as_array();
    PGPool::pgArrayToVector<std::string>(productNamesArr, productNames);
    productType = std::make_shared<std::string>(row[1].as<std::string>());

    rootPath = std::make_shared<std::filesystem::path>(cfg->filesystem.imageryPath);
    if (*productType == "anomaly")
        rootPath = std::make_shared<std::filesystem::path>(cfg->filesystem.anomalyProductsPath);
    else if (*productType == "lts")
        rootPath = std::make_shared<std::filesystem::path>(cfg->filesystem.ltsPath);

    id          = row[2].as<size_t>();
    pattern     = row[3].as<std::string>();
    types       = row[4].as<std::string>();
    dateptr     = row[5].as<std::string>();

    if (!row[6].is_null())
        fileNameCreationPattern = row[6].as<std::string>();

    if (!row[7].is_null())
        firstProductPath = std::make_shared<std::filesystem::path>(*rootPath/std::filesystem::path(row[7].as<std::string>()));

    if(!row[8].is_null()) {
        JsonDocumentUniquePtr tmpVars = std::make_unique<JsonDocument>();
        tmpVars->Parse(row[8].as<std::string>().c_str());

        for (auto& ptrn: tmpVars->GetArray()) {
            std::string variable = ptrn["variable"].GetString();
            variables[variable] = ProductVariable::New(ptrn, productType, rootPath, firstProductPath);
        }
        std::weak_ptr<ProductInfo>(shared_from_this());
    }
}

ProductInfo::SharedPtr ProductInfo::New(PGPool::PGConn::PGRow row, Configuration::SharedPtr cfg) {
    auto pnt = std::shared_ptr<ProductInfo>(new ProductInfo(row, cfg));
    for(auto var: pnt->variables)
        var.second->setProductRef(std::weak_ptr<ProductInfo>(pnt));
    return pnt;
}

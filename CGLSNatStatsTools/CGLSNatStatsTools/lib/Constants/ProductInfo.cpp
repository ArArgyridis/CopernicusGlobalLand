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

#include <fmt/format.h>
#include <memory>
#include <regex>

#include "ProductInfo.h"


ProductInfo::ProductInfo(){}

ProductInfo::ProductInfo(PGPool::PGConn::PGRow row, Configuration::SharedPtr cfg) {

    productNames = PGPool::pgArrayToVector<std::string, 1>(row[0].as_sql_array<std::string, 1>());
    productType = std::make_shared<std::string>(row[1].as<std::string>());

    rootPath = std::make_shared<std::filesystem::path>(cfg->filesystem.imageryPath);
    if (*productType == "anomaly")
        rootPath = std::make_shared<std::filesystem::path>(cfg->filesystem.anomalyProductsPath);
    else if (*productType == "lts")
        rootPath = std::make_shared<std::filesystem::path>(cfg->filesystem.ltsPath);

    id              = row[2].as<size_t>();
    auto patterns   = PGPool::pgArrayToVector<std::string, 1>(row[3].as_sql_array<std::string, 1>());
    pattern.resize(patterns.size());
    for (size_t i = 0; i < patterns.size(); i++)
        pattern[i] = std::regex(patterns[i]);

    types       = row[4].as<std::string>();
    datePattern = row[5].as<std::string>();

    if (!row[6].is_null())
        fileNameCreationPattern = row[6].as<std::string>();

    if(!row[7].is_null())
        rtPattern = row[7].as<std::string>();

    if (!row[8].is_null())
        firstProductPath = std::make_shared<std::filesystem::path>(*rootPath/std::filesystem::path(row[8].as<std::string>()));

    if(!row[9].is_null()) {
        JsonDocumentUniquePtr tmpVars = std::make_unique<JsonDocument>();
        tmpVars->Parse(row[9].as<std::string>().c_str());

        for (auto& ptrn: tmpVars->GetArray()) {
            std::string variable = ptrn["variable"].GetString();
            variables[variable] = ProductVariable::New(ptrn, productType, rootPath, firstProductPath);
        }
        std::weak_ptr<ProductInfo>(shared_from_this());
    }
}

std::string ProductInfo::getDateAsStringForFile(std::string &fileName) {
    for (auto& ptrn: pattern) {
        std::sregex_iterator it(fileName.begin(), fileName.end(), ptrn);
        if (it->size() > 0)
            return fmt::format(datePattern, static_cast<std::string>((*it)[1]),
                               static_cast<std::string>((*it)[2]), static_cast<std::string>((*it)[3]),
                               static_cast<std::string>((*it)[4]));
    }
    return "UNKNOWN DATE";
}

std::string ProductInfo::getRtFlagForFile(std::string &fileName) {
    if(rtPattern.size() == 0)
        return "-1";

    for (auto& ptrn: pattern) {
        std::sregex_iterator it(fileName.begin(), fileName.end(), ptrn);
        if (it->size() > 0)
            return fmt::format(rtPattern, (*it)[0].str());
    }
    return "-1";


}

ProductInfo::SharedPtr ProductInfo::New(PGPool::PGConn::PGRow row, Configuration::SharedPtr cfg) {
    auto pnt = std::shared_ptr<ProductInfo>(new ProductInfo(row, cfg));
    for(auto& var: pnt->variables)
        var.second->setProductRef(std::weak_ptr<ProductInfo>(pnt));
    return pnt;
}

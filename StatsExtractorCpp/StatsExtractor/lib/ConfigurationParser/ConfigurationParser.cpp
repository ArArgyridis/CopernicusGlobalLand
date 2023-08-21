/**
   Copyright (C) 2021  Argyros Argyridis arargyridis at gmail dot com
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

#include <boost/filesystem.hpp>
#include <fstream>
#include <iostream>
#include <memory>
#include <rapidjson/document.h>
#include <rapidjson/filereadstream.h>

#include "ConfigurationParser.h"
#include "../PostgreSQL/PostgreSQL.h"

std::map<std::string, std::size_t> Configuration::connectionIds;
Configuration::Configuration() {}
Configuration::Configuration(std::string &cfg):cfgFile(cfg) {}

unsigned short Configuration::parse() {
    if (!boost::filesystem::exists(cfgFile)) {
        std::cout <<"Unable to load configuration file: " << cfgFile <<". Exiting.";
        return 1;
    }

    std::unique_ptr<FILE, decltype(&fclose)> inFile (fopen(cfgFile.c_str(), "r"), &fclose);
    std::unique_ptr<char[]> readBuffer(new char[80000]);
    rapidjson::FileReadStream inputFileStream(inFile.get(), readBuffer.get(), 80000);
    rapidjson::Document cfg;

    if (cfg.Parse(readBuffer.get()).HasParseError()) {
        std::cout <<"Error in configuration file: " << cfgFile <<". Exiting.";
        return 1;
    }

    //loading db connections
    for (auto& cn:cfg["pg_connections"].GetObject()) {
        std::stringstream connectionStringStream;
        connectionStringStream << "dbname=" << cn.value["db"].GetString() << " host=" <<cn.value["host"].GetString()  <<
        " port="<< cn.value["port"].GetInt() << " user=" << cn.value["user"].GetString();
        if (cn.value["password"].IsString())
            connectionStringStream <<" password="<< cn.value["password"].GetString();

        std::string connectionString = connectionStringStream.str();

       if (Configuration::connectionIds.find(cn.name.GetString()) == Configuration::connectionIds.end())
            Configuration::connectionIds[cn.name.GetString()] = PGPool::PGConn::initConnectionPool(0, connectionString);
    }

    //db connection info
    statsInfo.schema        = cfg["statsinfo"]["schema"].GetString();
    statsInfo.tmpSchema     = cfg["statsinfo"]["tmp_schema"].GetString();
    statsInfo.connectionId  = cfg["statsinfo"]["connection_id"].GetString();
    statsInfo.exportId      = cfg["statsinfo"]["export_id"].GetString();
    statsInfo.memoryMB      = cfg["statsinfo"]["available_memory_mb"].GetInt();

    //filesystem
    filesystem.imageryPath          = cfg["filesystem"]["imagery_path"].GetString();
    filesystem.anomalyProductsPath  = cfg["filesystem"]["anomaly_products_path"].GetString();
    filesystem.tmpPath              = cfg["filesystem"]["tmp_path"].GetString();
    filesystem.mapserverPath        = cfg["filesystem"]["mapserver_data_path"].GetString();
    filesystem.mapFilePath          = cfg["filesystem"]["mapserver_mapfile_path"].GetString();

    //enabled products -- if null all products should be used
    if(!cfg["enabled_product_ids"].IsNull() && cfg["enabled_product_ids"].IsArray()){
        for (auto & id: cfg["enabled_product_ids"].GetArray())
            enabledProductIds.emplace_back(id.GetInt());
    }

    return 0;
}

Configuration::Pointer Configuration::New(std::string cfgPath) {
    return std::make_shared<Configuration>(cfgPath);
}

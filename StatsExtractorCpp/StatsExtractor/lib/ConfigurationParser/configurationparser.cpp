#include <boost/filesystem.hpp>
#include <fstream>
#include <iostream>
#include <memory>
#include <rapidjson/document.h>
#include <rapidjson/filereadstream.h>

#include "configurationparser.hxx"
#include "../PostgreSQL/postgresql.hxx"

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
            Configuration::connectionIds[cn.name.GetString()] = PGConn::initConnectionPool(20, connectionString);
    }

    //db connection info
    statsInfo.schema             = cfg["statsinfo"]["schema"].GetString();
    statsInfo.tmpSchema     = cfg["statsinfo"]["tmp_schema"].GetString();
    statsInfo.connectionId   = cfg["statsinfo"]["connection_id"].GetString();
    statsInfo.exportId           = cfg["statsinfo"]["export_id"].GetString();

    //filesystem
    filesystem.imageryPath                  = cfg["filesystem"]["imagery_path"].GetString();
    filesystem.anomalyProductsPath = cfg["filesystem"]["anomaly_products_path"].GetString();
    filesystem.tmpPath                         = cfg["filesystem"]["tmp_path"].GetString();
    filesystem.mapserverPath             = cfg["filesystem"]["mapserver_data_path"].GetString();

    return 0;
}

Configuration::Pointer Configuration::New(std::string cfgPath) {
    return std::make_shared<Configuration>(cfgPath);
}

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

#ifndef CONFIGURATIONPARSER_HXX
#define CONFIGURATIONPARSER_HXX
#include <boost/filesystem.hpp>
#include <map>
#include <memory>
#include <string>

struct StatsInfo {
    std::string schema, tmpSchema, connectionId, exportId;
    size_t memoryMB;
};

struct SFTPProxy {
    std::string host, user, ppasword;
    unsigned short port;
};

struct FileSystem {
    boost::filesystem::path imageryPath, anomalyProductsPath, tmpPath, mapserverPath;
};


class Configuration {
    std::string cfgFile;

public:
    Configuration();
    Configuration(std::string &cfg);

    using Pointer = std::shared_ptr<Configuration>;
    FileSystem filesystem;
    StatsInfo statsInfo;
    unsigned short parse();

    static Pointer New(std::string cfgPath);
    static std::map<std::string, std::size_t> connectionIds;

};


#endif // CONFIGURATIONPARSER_HXX
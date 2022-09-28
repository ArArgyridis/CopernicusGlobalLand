#ifndef CONFIGURATIONPARSER_HXX
#define CONFIGURATIONPARSER_HXX
#include <boost/filesystem.hpp>
#include <map>
#include <memory>
#include <string>

struct StatsInfo {
    std::string schema, tmpSchema, connectionId, exportId;
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

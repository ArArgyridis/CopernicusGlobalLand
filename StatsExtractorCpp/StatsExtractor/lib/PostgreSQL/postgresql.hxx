#ifndef POSTGRESQL_HXX
#define POSTGRESQL_HXX
#include <pqxx/pqxx>
#include <atomic>
#include <mutex>


namespace PGPool {
using CnType            = pqxx::connection;
using CnTypePtr     = std::shared_ptr<CnType>;

template <class T>
void pgArrayToVector(pqxx::array_parser value, std::vector<T> &vec) {
    for (std::pair<pqxx::array_parser::juncture, std::string> elem = value.get_next();elem.first != pqxx::array_parser::juncture::done; elem = value.get_next())
        if (elem.first == pqxx::array_parser::juncture::string_value)
            vec.emplace_back(elem.second);
}


class PGConn {

    class PGCountedConnType {
        CnTypePtr cn;
        unsigned short count;
        size_t connId;
    public:
        using Pointer   = std::shared_ptr<PGCountedConnType>;
        PGCountedConnType();
        PGCountedConnType(size_t& connId);

        CnTypePtr getConnection();
        unsigned short getCount();
        void reset();

        static Pointer New();
        static Pointer New(size_t& connId);
    };



    using PGPoolConnection  = std::pair<bool, PGCountedConnType::Pointer>;
    using PGPoolConnectionPtr = std::shared_ptr<PGPoolConnection>;
    static std::mutex poolLock;
    static std::vector<std::vector<PGPoolConnectionPtr>> connectionPool;
    static std::vector<std::string> connStr;

    PGPoolConnectionPtr currentConnection;

    static bool executeSingleQuery(pqxx::work& work, std::string& query);
    static PGPoolConnectionPtr createConnection(size_t& id, bool activeFlag=false);
    static PGPoolConnectionPtr getConnection(size_t& id);
    static std::string getConnectionString(size_t& id);
    static void releaseConnection(PGPoolConnectionPtr cn);
    void reset();

protected:
    PGConn(size_t id =0);

public:
    using Pointer   = std::unique_ptr<PGConn>;
    using PGRes     = pqxx::result;
    using PGRow     = pqxx::row;

    ~PGConn();
    PGRes fetchQueryResult(std::string& query, std::string workName="single query");
    CnTypePtr getRawConnection();
    void executeQueries(std::shared_ptr<std::vector<std::string>> args);
    void executeQuery(std::string& query);
    static size_t initConnectionPool(size_t cons, std::string& conStr);
    static Pointer New(size_t id =0);
    static void printConnectionStatus(size_t& id);
};
}






#endif // POSTGRESQL_HXX

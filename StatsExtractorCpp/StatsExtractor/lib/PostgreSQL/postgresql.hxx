#ifndef POSTGRESQL_HXX
#define POSTGRESQL_HXX
#include <pqxx/pqxx>
#include <atomic>
#include <mutex>



template <class T>
void pgArrayToVector(pqxx::array_parser value, std::vector<T> &vec) {
    for (std::pair<pqxx::array_parser::juncture, std::string> elem = value.get_next();elem.first != pqxx::array_parser::juncture::done; elem = value.get_next())
        if (elem.first == pqxx::array_parser::juncture::string_value)
            vec.emplace_back(elem.second);
}


class PGConn {
        using  PGConnType = pqxx::connection;
        using PGConnTypePtr = std::shared_ptr<PGConnType>;
        using PGPoolConnection = std::shared_ptr<std::pair<std::atomic<bool>, PGConnTypePtr>>;

        static std::mutex poolLock;
        static std::vector<std::vector<PGPoolConnection>> connectionPool;
        static std::string connStr;

        PGPoolConnection currentConnection;

        static bool executeSingleQuery(pqxx::work& work, std::string& query);
        static PGPoolConnection getConnection(size_t& id);
        static void releaseConnection(PGPoolConnection cn);
protected:
        PGConn(size_t id =0);

public:
        using Pointer = std::unique_ptr<PGConn>;
        using PGRes = pqxx::result;
        using PGRow = pqxx::row;

        ~PGConn();
        PGRes fetchQueryResult(std::string& query, std::string workName);
        PGConnTypePtr getCurrentConnection();
        void executeQueries(std::shared_ptr<std::vector<std::string>> args);
        void executeQuery(std::string& query);
        static size_t initConnectionPool(size_t cons, std::string& conStr);
        static Pointer New(size_t id =0);
        static void printConnectionStatus(size_t& id);
};







#endif // POSTGRESQL_HXX

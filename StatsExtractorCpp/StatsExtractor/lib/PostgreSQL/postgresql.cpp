#include "postgresql.hxx"
#include <iostream>

using namespace std;

vector<std::vector<PGPoolConnection>> PGConn::connectionPool;
mutex PGConn::poolLock;
string PGConn::connStr;

PGConn::PGConn(size_t id):currentConnection(PGConn::getConnection(id)) {}

PGConn::~PGConn() {
        PGConn::releaseConnection(currentConnection);
}

PGConn::Pointer PGConn::New(size_t id) {
    return std::unique_ptr<PGConn>(new PGConn(id));
}

PGPoolConnection PGConn::getConnection(size_t &id) {
        lock_guard<mutex> lock(poolLock);
        //cout << "Pool size: " << connectionPool.size() << endl;
        for( size_t i = 0; i < connectionPool.size(); i++) {
                if (!connectionPool[id][i].get()->first) {
                        connectionPool[id][i].get()->first = true;
                        return connectionPool[id][i];
                }
        }
        connectionPool[id].emplace_back(make_shared< pair<std::atomic<bool>, shared_ptr<PGConnType>>>( true, shared_ptr<PGConnType>(new PGConnType(connStr)) ) ) ;
        return connectionPool[id].back();
}

void PGConn::executeQueries(std::shared_ptr<std::vector<string> > args) {
        pqxx::work tmpWork(*getCurrentConnection(), "threaded query");
        try {
                for (string const& query: *args )
                        tmpWork.exec(query);

                tmpWork.commit();
        }
        catch (pqxx::deadlock_detected  const &e) {
                cout << "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n";
                cout << e.what() << endl;
                tmpWork.abort();
        }
        catch(pqxx::sql_error const &e) {
                cout << "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n";
                cout << e.what() << endl;
                tmpWork.abort();
                cout << "issue detected, retrying....\n";
        }

}

void PGConn::executeQuery(std::string &query) {
        pqxx::work tmpWork(*getCurrentConnection(), "single query");
        try {
                tmpWork.exec(query);
                tmpWork.commit();
        }
        catch (pqxx::deadlock_detected  const &e) {
            cout << "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n";
            cout << e.what() << endl;
            tmpWork.abort();
       }
        catch(pqxx::sql_error const &e) {
                cout << "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n";
                cout << e.what() << endl;
                tmpWork.abort();
                cout << "issue detected, retrying....\n";
        }

}

PGConn::PGRes PGConn::fetchQueryResult(std::string &query, std::string workName="single query") {
        pqxx::work tmpWork(*getCurrentConnection(), workName);
        PGConn::PGRes result;
        try {
                result = tmpWork.exec(query);
                tmpWork.commit();
                return result;
        }
        catch (pqxx::deadlock_detected  const &e) {
                cout << "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n";
                cout << e.what() << endl;
                tmpWork.abort();
                return result;
        }
        catch(pqxx::sql_error const &e) {
                cout << "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n";
                cout << e.what() << endl;
                tmpWork.abort();
                cout << "issue detected, retrying....\n";
                return result;
        }
}

PGConnTypePtr PGConn::getCurrentConnection() {
        return currentConnection->second;
}

size_t PGConn::initConnectionPool(size_t cons, std::string& conStr) {
        std::vector<PGPoolConnection> newPool;
        for (size_t i = 0; i < cons; i++)
                newPool.emplace_back(make_shared< pair<std::atomic<bool>, shared_ptr<PGConnType>>>( false, shared_ptr<PGConnType>(new PGConnType(conStr)) ) ) ;
        connectionPool.emplace_back(newPool);
        return connectionPool.size()-1;
}

void PGConn::printConnectionStatus(size_t &id) {
        for (size_t i = 0; i < connectionPool.size(); i++)
                cout << connectionPool[id][i]->first << endl;
}

void PGConn::releaseConnection(PGPoolConnection cn) {
        lock_guard<mutex> lock(poolLock);
        cn->first = false;
}

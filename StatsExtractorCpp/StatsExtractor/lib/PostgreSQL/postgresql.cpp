#include <iostream>
#include <memory>

#include "postgresql.hxx"

using namespace std;
using namespace PGPool;

vector<vector<PGConn::PGPoolConnectionPtr>> PGConn::connectionPool;
mutex PGConn::poolLock;
vector<string> PGConn::connStr;


PGConn::PGCountedConnType::PGCountedConnType():count(0){}

PGConn::PGCountedConnType::PGCountedConnType(size_t &connId): connId(connId){
    reset();
}


CnTypePtr PGConn::PGCountedConnType::getConnection() {
    count++;
    return cn;
}

unsigned short PGConn::PGCountedConnType::getCount() {
    return count;
}

void PGConn::PGCountedConnType::reset() {
    count = 0;
    cn = make_shared<CnType>(PGConn::getConnectionString(connId));
}

PGConn::PGCountedConnType::Pointer PGConn::PGCountedConnType::New() {
    return make_shared<PGConn::PGCountedConnType>();
}

PGConn::PGCountedConnType::Pointer PGConn::PGCountedConnType::New(size_t &id) {
    return make_shared<PGConn::PGCountedConnType>(id);
}

PGConn::PGConn(size_t id):currentConnection(PGConn::getConnection(id)){}

string PGConn::getConnectionString(size_t &id) {
    return connStr[id];
}

PGConn::~PGConn() {
    PGConn::releaseConnection(currentConnection);
}

PGConn::Pointer PGConn::New(size_t id) {
    return unique_ptr<PGConn>(new PGConn(id));
}

PGConn::PGPoolConnectionPtr PGConn::getConnection(size_t &id) {
    lock_guard<mutex> lock(poolLock);

    for( size_t i = 0; i < connectionPool[id].size(); i++) {
        if (!connectionPool[id][i].get()->first) {
            connectionPool[id][i].get()->first = true;
            return connectionPool[id][i];
        }
    }

    //could have an upper limit on how many connections could be created....
    connectionPool[id].emplace_back(PGConn::createConnection(id, true));
    return connectionPool[id].back();
}

void PGConn::executeQueries(shared_ptr<vector<string> > args) {
    pqxx::work tmpWork(*(getRawConnection()), "threaded query");
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

void PGConn::executeQuery(string &query) {
    pqxx::work tmpWork(*getRawConnection(), "single query");
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

PGConn::PGRes PGConn::fetchQueryResult(string &query, string workName) {
    pqxx::work tmpWork(*getRawConnection(), workName);
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

void PGConn::reset() {
    currentConnection->second->reset();
}


CnTypePtr PGConn::getRawConnection() {
    return currentConnection->second->getConnection();
}

size_t PGConn::initConnectionPool(size_t cons, string& conStr) {
    vector<PGPoolConnectionPtr> newPool;
    PGConn::connStr.emplace_back(conStr);
    size_t id = connStr.size()-1;

    for (size_t i = 0; i < cons; i++)
        newPool.emplace_back(PGConn::createConnection(id, false)) ;

    connectionPool.emplace_back(newPool);
    return connectionPool.size()-1;
}

void PGConn::printConnectionStatus(size_t &id) {
    for (size_t i = 0; i < connectionPool.size(); i++)
        cout << connectionPool[id][i]->first << endl;
}


PGConn::PGPoolConnectionPtr PGConn::createConnection(size_t& id, bool activeFlag) {
    PGConn::PGCountedConnType::Pointer cn = PGConn::PGCountedConnType::New(id);
    return make_shared<PGPoolConnection>(pair<bool, PGConn::PGCountedConnType::Pointer>(activeFlag, cn));
}


void PGConn::releaseConnection(PGPoolConnectionPtr cn) {
    lock_guard<mutex> lock(poolLock);
    if (cn->second->getCount() > 10)
        cn->second->reset();
    cn->first = false;
    //std::cout <<"count: " << cn->second->getCount() <<"\n";
}

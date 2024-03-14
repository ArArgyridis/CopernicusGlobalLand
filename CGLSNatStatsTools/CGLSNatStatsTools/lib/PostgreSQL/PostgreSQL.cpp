/*
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

#include <iostream>
#include <memory>

#include "PostgreSQL.h"

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

PGConn::UniquePtr PGConn::New(size_t id) {
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

    if (cn->second->getCount() > 20) {
        cn->second->reset();
    }
    cn->first = false;
}

std::vector<std::string> PGPool::arrayToVector(const PGConn::PGField &field) {
    std::vector<std::string> ret;
    auto arrayInfo = field.as_array();
    for (auto stInfo = arrayInfo.get_next(); stInfo.first != pqxx::array_parser::juncture::done; stInfo = arrayInfo.get_next()) {
        if(stInfo.first == pqxx::array_parser::juncture::row_start)
            std::cout << "@@@@@: " << field.as<std::string>() <<"\n";
        else if(stInfo.first == pqxx::array_parser::juncture::string_value)
            ret.emplace_back(stInfo.second);
    }
    return ret;
}

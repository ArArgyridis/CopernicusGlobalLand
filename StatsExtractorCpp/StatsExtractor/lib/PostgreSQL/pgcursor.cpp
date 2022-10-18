#include "pgcursor.hxx"
#include <iostream>

PGCursor::PGCursor() {}

PGCursor::PGCursor(size_t connId, std::string &query, std::string cursorName):cursorPos(0) {
    cn = PGPool::PGConn::New(connId);
    //cursorWork=std::make_unique<pqxx::work>(*cn->getConnection(), cursorName);
    //cursor = std::make_unique<StatelessCursor>(*cursorWork, query, "myCursor", false);
}

PGCursor::~PGCursor() {
    cursorWork->commit();
}


PGPool::PGConn::PGRes PGCursor::getNext() {
    PGPool::PGConn::PGRes result = cursor->retrieve(cursorPos, cursorPos+1);
    cursorPos++;
    return result;
}


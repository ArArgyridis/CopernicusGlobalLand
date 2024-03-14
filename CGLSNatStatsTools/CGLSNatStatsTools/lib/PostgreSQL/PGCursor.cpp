#include "PGCursor.h"
#include <iostream>

PGPool::PGCursor::PGCursor() {}

PGPool::PGCursor::PGCursor(size_t connId, std::string &query, std::string cursorName):cursorPos(0) {
    cn = PGPool::PGConn::New(connId);
    cursorWork=std::make_unique<pqxx::work>(*cn->getRawConnection(), cursorName);
    cursor = std::make_unique<StatelessCursor>(*cursorWork, query, "myCursor", false);
}

PGPool::PGCursor::~PGCursor() {
    cursorWork->commit();
}


PGPool::PGConn::PGRes PGPool::PGCursor::getNext() {
    PGPool::PGConn::PGRes result = cursor->retrieve(cursorPos, cursorPos+1);
    cursorPos++;
    return result;
}


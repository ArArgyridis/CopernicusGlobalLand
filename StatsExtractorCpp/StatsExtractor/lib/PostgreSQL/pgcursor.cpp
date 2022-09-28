#include "pgcursor.hxx"
#include <iostream>

PGCursor::PGCursor() {}

PGCursor::PGCursor(size_t connId, std::string &query, std::string cursorName):cursorPos(0) {
    cn = PGConn::New(connId);
    cursorWork=std::make_unique<pqxx::work>(*cn->getCurrentConnection(), cursorName);
    cursor = std::make_unique<StatelessCursor>(*cursorWork, query, "myCursor", false);
}

PGCursor::~PGCursor() {
    cursorWork->commit();
}


PGConn::PGRes PGCursor::getNext() {
    PGConn::PGRes result = cursor->retrieve(cursorPos, cursorPos+1);
    cursorPos++;
    return result;
}


#ifndef PGCURSOR_HXX
#define PGCURSOR_HXX

#include "PostgreSQL.h"

using StatelessCursor = pqxx::stateless_cursor<pqxx::cursor_base::read_only, pqxx::cursor_base::owned>;
using StatelessCursorPtr =  std::unique_ptr<StatelessCursor>;
using PGWorkPtr = std::unique_ptr<pqxx::work>;

namespace PGPool {
class PGCursor {
    StatelessCursorPtr cursor;
    size_t cursorPos;
    PGPool::PGConn::Pointer cn;
    PGWorkPtr cursorWork;
public:
    PGCursor();
    PGCursor(size_t connId, std::string& query, std::string cursorName="default cursor");
    ~PGCursor();

    PGPool::PGConn::PGRes getNext();

};
}

#endif // PGCURSOR_HXX

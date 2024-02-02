#include "Utils.h"

boost::posix_time::ptime getNextDekad(boost::posix_time::ptime &currentTime) {
    std::tm p = boost::posix_time::to_tm(currentTime);
    p.tm_mon += (p.tm_mday>=21);

    if (p.tm_mon > 11) {
        std::tm tm{};
        tm.tm_year = p.tm_year+1;
        tm.tm_mon = 0;
        tm.tm_mday =1;
        p = tm;
    }
    else
        p.tm_mday = (10+p.tm_mday)*(p.tm_mday < 21) + 1*(p.tm_mday>=21);
    return boost::posix_time::ptime_from_tm(p);
}

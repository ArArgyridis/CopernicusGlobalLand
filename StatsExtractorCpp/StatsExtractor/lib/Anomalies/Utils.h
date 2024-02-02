#ifndef UTILS_H
#define UTILS_H

#include <boost/date_time/posix_time/posix_time.hpp>
#include <boost/date_time/posix_time/posix_time_io.hpp>

boost::posix_time::ptime getNextDekad(boost::posix_time::ptime &currentTime);
#endif // UTILS_H

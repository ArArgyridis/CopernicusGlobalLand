/*
   Copyright (C) 2024  Argyros Argyridis arargyridis at gmail dot com
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

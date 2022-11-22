/**
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

#ifndef STATSEXTRACTOR_HXX
#define STATSEXTRACTOR_HXX

#include <boost/filesystem.hpp>

#include "../ConfigurationParser/ConfigurationParser.h"
#include "../Filters/Statistics/StatisticsFromLabelImageFilter.h"

class StatsExtractor {
    Configuration::Pointer config;
    std::string stratification;

public:
    StatsExtractor(Configuration::Pointer& cfg, std::string stratificationType);
    void process();
    void process(bool k);
};

#endif // STATSEXTRACTOR_HXX
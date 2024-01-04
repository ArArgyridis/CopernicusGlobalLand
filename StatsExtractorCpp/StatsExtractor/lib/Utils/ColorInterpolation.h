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

#ifndef COLORINTERPOLATION_H
#define COLORINTERPOLATION_H

#include <array>
#include <map>
#include <string>
#include <vector>
#include <rapidjson/document.h>

using RGBVal = std::array<unsigned char, 4>;

class ColorInterpolation {
    std::vector<size_t> keys;
    std::map<size_t, RGBVal> values;

public:
    ColorInterpolation();
    ColorInterpolation(rapidjson::Value& palette);

    RGBVal interpolateColor(long double areaPerc);
};



#endif // COLORINTERPOLATION_H

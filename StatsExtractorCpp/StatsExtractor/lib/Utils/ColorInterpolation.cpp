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

#include <algorithm>
#include <iostream>

#include "ColorInterpolation.h"

ColorInterpolation::ColorInterpolation() {}

ColorInterpolation::ColorInterpolation(rapidjson::Document &palette) {
    //getting all values

    for (auto it = palette.MemberBegin(); it != palette.MemberEnd(); it++) {
        keys.emplace_back(std::stoi(it->name.GetString()));

        auto valArray = it->value.GetArray();
        RGBVal tmp;
        for (size_t i = 0; i < 3; i++)
            tmp[i] = valArray[i].GetInt();
        values.insert(std::pair<size_t, RGBVal>(std::stoi(it->name.GetString()), tmp));
    }


    std::sort(keys.begin(), keys.end());
}

RGBVal ColorInterpolation::interpolateColor(long double areaPerc) {
    RGBVal ret;

    if (areaPerc == keys.front())
        ret = values[keys.front()];
    else if (areaPerc == keys.back())
        ret = values[keys.back()];
    else {
        size_t bins = values.size() -1;
        float valueRange = 100/bins;

        size_t mn = static_cast<int>(areaPerc/valueRange);
        size_t mx = mn+1;

        mn = keys[mn];
        mx = keys[mx];

        for (size_t i = 0; i < 3; i++)
            ret[i] = static_cast<int>( (values[mx][i] - values[mn][i])*(areaPerc-mn)/100 +values[mn][i]);


        return ret;
    }



    return ret;

}

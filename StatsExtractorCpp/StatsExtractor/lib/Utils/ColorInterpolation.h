#ifndef COLORINTERPOLATION_H
#define COLORINTERPOLATION_H

#include <array>
#include <map>
#include <string>
#include <vector>
#include <rapidjson/document.h>

using RGBVal = std::array<unsigned short int, 3>;

class ColorInterpolation {
    std::vector<size_t> keys;
    std::map<size_t, RGBVal> values;

public:
    ColorInterpolation();
    ColorInterpolation(rapidjson::Document& palette);

    RGBVal interpolateColor(long double areaPerc);
};



#endif // COLORINTERPOLATION_H

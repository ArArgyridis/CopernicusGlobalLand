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

#ifndef GLCRECLASSIFIER_H
#define GLCRECLASSIFIER_H

#include <array>
#include <vector>

template <class TInput, class TOutput>
class GLCReclassifier {
public:
    using TripletUCharArray = std::array<TInput, 3>;
    using SharedPtr = std::shared_ptr<GLCReclassifier>;

    GLCReclassifier(){}

    TOutput operator()(const TInput& in) {
        TOutput val  = 0;
        for (auto& triplet : GLCReclassifier::map)
            val += (triplet[0] <= in && triplet[1] >= in) * triplet[2];
        return val;
    }



private:
    static std::vector<TripletUCharArray> map;
};

template <class TInput, class TOutput>
typename GLCReclassifier<TInput, TOutput>::TripletUCharArray k;


template <class TInput, class TOutput>
std::vector<typename GLCReclassifier<TInput, TOutput>::TripletUCharArray> GLCReclassifier<TInput, TOutput>::map = {
    {0, 19, 0},
    {20, 39, 1},
    {40, 49, 2},
    {50, 59, 4},
    {60, 69, 6},
    {70, 89, 0},
    {90, 99, 5},
    {100, 109, 6},
    {110, 126, 3},
    {127, 255, 0}
};

#endif // GLCRECLASSIFIER_H

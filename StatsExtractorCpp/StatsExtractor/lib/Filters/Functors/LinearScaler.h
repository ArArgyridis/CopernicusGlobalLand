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

#ifndef LINEARSCALER_H
#define LINEARSCALER_H

template <class TInput, class TOutput>
class LinearScaler {
    double a, b, ignoreVal;
public:
    LinearScaler(double a, double b, double ignoreVal=255): a(a), b(b), ignoreVal(ignoreVal){}

    TOutput operator()(const TInput& in) {
        return (in==ignoreVal)*in + (in!= ignoreVal)*(a*in+b);
    }
};


#endif // LINEARSCALER_H

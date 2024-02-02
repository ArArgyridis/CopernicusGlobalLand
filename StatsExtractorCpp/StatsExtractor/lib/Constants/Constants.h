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
#ifndef CONSTANTS_HXX
#define CONSTANTS_HXX
#include <map>
#include <memory>
#include <rapidjson/document.h>
#include <string>

#include "../PostgreSQL/PostgreSQL.h"
#include "ProductInfo.h"



class Constants {
public:
    static std::map<std::size_t, ProductInfo::Pointer> productInfo;
    static std::map<std::size_t, ProductVariable::Pointer> variableInfo;
    Constants();
    static unsigned short load(Configuration::SharedPtr cfg);

};

#endif // CONSTANTS_HXX

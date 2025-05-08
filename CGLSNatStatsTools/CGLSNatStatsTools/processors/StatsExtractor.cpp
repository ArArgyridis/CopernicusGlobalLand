/*
   Copyright (C) 2023  Argyros Argyridis arargyridis at gmail dot com
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

#include <gdal_frmts.h>
#include <gdalwarper.h>
#include <iostream>
#include <otbImage.h>
#include <otbVectorImage.h>
#include <otbImageFileReader.h>
#include <otbImageFileWriter.h>

#include "../lib/StatsExtractor/StatsExtractor.h"

int main(int argc, char *argv[]) {
    if (argc < 3) {
        std::cout << "usage: StatsExtractor configuration_file stratification_id";
		return 1;
	}
	GDALAllRegister();
	
    std::string cfgFile(argv[1]);
    
    Configuration::SharedPtr config = Configuration::New(cfgFile);
	if (config->parse() != 0)
		return 1;
	
	if (Constants::load(config) != 0)
        return 1;

    StatsExtractor extractor(config, argv[2]);
	extractor.process();
    return 0;
}

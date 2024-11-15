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

#include <iostream>
#include <otbFunctorImageFilter.h>
#include <otbImageFileReader.h>
#include <otbImageFileWriter.h>

#include "../lib/Filters/Functors/GLCReclassifier.h"

using UCharImageType = otb::Image<unsigned char, 2>;
using UCharImageReader = otb::ImageFileReader<UCharImageType>;
using UCharImageWriter = otb::ImageFileWriter<UCharImageType>;

int main(int argc, char *argv[]) {
    if (argc < 3) {
        std::cout << "usage: GLCReclassifier image_file.tif out_image_file.tif \n";
        return 1;
    }

    UCharImageReader::Pointer reader = UCharImageReader::New();
    reader->SetFileName(argv[1]);

    auto reclassifier  = otb::NewFunctorFilter(GLCReclassifier<UCharImageType::PixelType, UCharImageType::PixelType>());
    reclassifier->SetInput(reader->GetOutput());

    UCharImageWriter::Pointer writer = UCharImageWriter::New();
    writer->SetInput(reclassifier->GetOutput());
    writer->SetFileName(std::string(argv[2])+"?&gdal:co:BIGTIFF=IF_NEEDED&gdal:co:TILED=YES&gdal:co:BLOCKXSIZE=512&gdal:co:BLOCKYSIZE=512&gdal:co:COMPRESS=LZW");
    writer->GetStreamingManager()->SetDefaultRAM(15000);
    writer->Update();

    return 0;
}

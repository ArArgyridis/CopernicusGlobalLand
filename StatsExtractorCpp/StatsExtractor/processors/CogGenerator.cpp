/**
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

#include <filesystem>
#include <fmt/format.h>
#include <gdal_frmts.h>
#include <gdalwarper.h>
#include <iostream>
#include <otbImage.h>
#include <otbVectorImage.h>
#include <otbImageFileReader.h>
#include <otbImageFileWriter.h>

#include "../lib/Constants/Constants.h"
#include "../lib/Filters/Visualization/WMSCogFilter.hxx"
#include "../lib/Filters/RasterReprojection/RasterReprojectionFilter.hxx"

int main(int argc, char *argv[]) {
    if (argc < 2) {
        std::cout <<"Usage: CogGenerator json_config_file";
        return 1;
    }

    GDALAllRegister();
    using UCharImage                = otb::Image<unsigned char, 2>;
    using UShortVectorImage         = otb::VectorImage<unsigned short, 2>;
    using UCharImageReader          = otb::ImageFileReader<UCharImage>;
    using UShortVectorImageWriter   = otb::ImageFileWriter<UShortVectorImage>;
    using WMSCogFilter              = otb::WMSCogFilter<UCharImage, UShortVectorImage>;
    using ReprojectionFilter        = otb::RasterReprojectionFilter<UShortVectorImage>;
    size_t noData                   = 65535;

    std::string cfgFile(argv[1]);

    Configuration::Pointer config = Configuration::New(cfgFile);
    if (config->parse() != 0)
        return 1;

    if (Constants::load(config) != 0)
        return 1;

    //clean up tmp directory before starting
    if(std::filesystem::exists(config->filesystem.tmpPath))
        std::filesystem::remove_all(config->filesystem.tmpPath);

    std::filesystem::create_directories(config->filesystem.tmpPath);

    char **tmpToCOGWarpOptions = nullptr;
    tmpToCOGWarpOptions = CSLSetNameValue(tmpToCOGWarpOptions, "BIGTIFF", "IF_NEEDED");
    tmpToCOGWarpOptions = CSLSetNameValue(tmpToCOGWarpOptions, "NUM_THREADS", "ALL_CPUS");

    for (auto& product:Constants::productInfo)
        for (auto& variable:product.second->variables) {
            std::string query = fmt::format(R"""(
                SELECT pf.id, pf.rel_file_path
                FROM product_file pf
                JOIN product_file_description pfd ON pf.product_file_description_id = pfd.id
                LEFT JOIN wms_file wf ON wf.product_file_id = pf.id AND wf.product_file_variable_id  = {0}
                WHERE wf.rel_file_path IS NULL AND pfd.id = {1})""", variable.second->id, product.second->id);

            PGPool::PGConn::Pointer cn  = PGPool::PGConn::New(Configuration::connectionIds[config->statsInfo.connectionId]);
            PGPool::PGConn::PGRes res   = cn->fetchQueryResult(query);
            for (size_t rowId = 0; rowId < res.size(); rowId++) {

                //create output paths
                std::filesystem::path filePath = res[rowId][1].as<std::string>();
                std::filesystem::path inFile      = variable.second->productAbsPath(filePath).string();


                //tmp output file
                std::filesystem::path tmpFile = config->filesystem.tmpPath/filePath;
                if (variable.second->variable.length() > 0) {
                    std::vector<std::string> splitPath = split(tmpFile.string(), "/");
                    splitPath.insert(splitPath.end()-1, variable.second->variable);
                    tmpFile = boost::algorithm::join(splitPath,"/");
                    filePath = std::filesystem::relative(tmpFile, config->filesystem.tmpPath);
                }

                tmpFile.replace_extension("tif");
                if(std::filesystem::exists(tmpFile))
                    std::filesystem::remove(tmpFile);
                createDirectoryForFile(tmpFile);

                //tmp cog file
                std::filesystem::path tmpCog(tmpFile);
                tmpCog.replace_extension(".cog.tif");
                if(std::filesystem::exists(tmpCog))
                    std::filesystem::remove(tmpCog);

                //destination cog file
                std::filesystem::path outCog = config->filesystem.mapserverPath/filePath;
                outCog.replace_extension(".tif");
                //check if a file exists
                if(std::filesystem::exists(outCog))
                    std::filesystem::remove(outCog);
                createDirectoryForFile(outCog);
                //std::cout << tmpFile << "\n" << tmpCog <<"\n" << outCog <<"\n\n";

                std::cout << "Building COG File for: " << inFile << "\n";

                UCharImageReader::Pointer reader = UCharImageReader::New();
                reader->SetFileName(inFile.string());
                reader->UpdateOutputInformation();

                WMSCogFilter::Pointer wmsFltr = WMSCogFilter::New();
                wmsFltr->SetInput(reader->GetOutput());
                wmsFltr->setProduct(product.second, variable.second);
                wmsFltr->UpdateOutputInformation();

                ReprojectionFilter::Pointer reproject = ReprojectionFilter::New();
                reproject->SetInput(wmsFltr->GetOutput());
                reproject->SetInputProjection(4326);
                reproject->SetOutputProjection(3857);
                reproject->UpdateOutputInformation();

                UShortVectorImageWriter::Pointer writer = UShortVectorImageWriter::New();
                writer->SetFileName(tmpFile.string()+"?&gdal:co:BIGTIFF=YES&gdal:co:TILED=YES&gdal:co:BLOCKXSIZE=512&gdal:co:BLOCKYSIZE=512");
                writer->SetInput(reproject->GetOutput());
                writer->GetStreamingManager()->SetDefaultRAM(config->statsInfo.memoryMB);
                writer->Update();

                std::cout << "Transforming to tmp cog\n";

                //transform output file to cog
                GDALDatasetUniquePtr inData, tmpCogData;
                inData  = GDALDatasetUniquePtr(GDALDataset::FromHandle(GDALOpen(tmpFile.c_str(), GA_ReadOnly)));
                GDALDriver *poDriver;
                poDriver = GetGDALDriverManager()->GetDriverByName("COG");


                tmpCogData = GDALDatasetUniquePtr(poDriver->CreateCopy(tmpCog.c_str(), inData.get(),
                                                                       FALSE, tmpToCOGWarpOptions, nullptr, nullptr));
                tmpCogData = nullptr;
                std::filesystem::remove(tmpFile);

                std::cout << "Copy to destination\n";
                //copy file to destination directory
                std::filesystem::copy(tmpCog, outCog);
                //delete tmp file
                std::filesystem::remove(tmpCog);

                //update db
                std::string updateQuery = fmt::format(R"""(
                INSERT INTO wms_file(product_file_id, product_file_variable_id, rel_file_path)
                VALUES({0},{1},'{2}') ON CONFLICT(product_file_id,product_file_variable_id) DO UPDATE SET rel_file_path=EXCLUDED.rel_file_path;
                )""", res[rowId][0].as<size_t>(), variable.second->id, (std::filesystem::relative(outCog, config->filesystem.mapserverPath)).string());
                cn->executeQuery(updateQuery);

            }
        }

    CSLDestroy(tmpToCOGWarpOptions);
    return 0;
}

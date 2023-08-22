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

int main(int argc, char *argv[]) {
    if (argc < 2) {
        std::cout <<"Usage: CogGenerator json_config_file";
        return 1;
    }


    GDALAllRegister();
    using UCharImage                = otb::Image<unsigned char, 2>;
    using UCharVectorImage          = otb::VectorImage<unsigned short, 2>;
    using UCharImageReader          = otb::ImageFileReader<UCharImage>;
    using UCharVectorImageWriter    = otb::ImageFileWriter<UCharVectorImage>;
    using WMSCogFilter              = otb::WMSCogFilter<UCharImage, UCharVectorImage>;


    std::string cfgFile(argv[1]);

    Configuration::Pointer config = Configuration::New(cfgFile);
    if (config->parse() != 0)
        return 1;

    if (Constants::load(config) != 0)
        return 1;

    boost::filesystem::create_directories(config->filesystem.tmpPath);

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
                boost::filesystem::path filePath = res[rowId][1].as<std::string>();
                boost::filesystem::path inFile      = variable.second->productAbsPath(filePath).string();

                //tmp output file
                boost::filesystem::path tmpFile     = config->filesystem.tmpPath/filePath;
                tmpFile.replace_extension("tif");
                if(boost::filesystem::exists(tmpFile))
                    boost::filesystem::remove(tmpFile);
                createDirectoryForFile(tmpFile);

                //tmp cog file
                boost::filesystem::path tmpCog(tmpFile);
                tmpCog.replace_extension(".cog.tif");
                if(boost::filesystem::exists(tmpCog))
                    boost::filesystem::remove(tmpCog);

                //destination cog file
                boost::filesystem::path outCog = config->filesystem.mapserverPath/filePath;
                outCog.replace_extension(".tif");
                //check if a file exists
                if(boost::filesystem::exists(outCog))
                    boost::filesystem::remove(outCog);
                createDirectoryForFile(outCog);

                std::cout << "Building COG File for: " << inFile << "\n";

                UCharImageReader::Pointer reader = UCharImageReader::New();
                reader->SetFileName(inFile.string());

                WMSCogFilter::Pointer wmsFltr = WMSCogFilter::New();
                wmsFltr->SetInput(reader->GetOutput());
                wmsFltr->setProduct(product.second, variable.second);

                UCharVectorImageWriter::Pointer writer = UCharVectorImageWriter::New();
                writer->SetFileName(tmpFile.string());
                writer->SetInput(wmsFltr->GetOutput());
                writer->GetStreamingManager()->SetDefaultRAM(config->statsInfo.memoryMB);
                writer->Update();

                //transform output file to cog
                GDALDatasetUniquePtr inData, tmpCogData;
                inData  = GDALDatasetUniquePtr(GDALDataset::FromHandle(GDALOpen(tmpFile.c_str(), GA_ReadOnly)));
                GDALDriver *poDriver;
                poDriver = GetGDALDriverManager()->GetDriverByName("COG");

                //enable BIGTIFF
                std::unique_ptr<char*, void(*)(char**)> papszOptions(nullptr, CSLDestroy);
                papszOptions.reset(CSLAddNameValue(papszOptions.get(), "BIGTIFF", "YES"));

                tmpCogData = GDALDatasetUniquePtr(poDriver->CreateCopy(tmpCog.c_str(), inData.get(), FALSE, papszOptions.get(), nullptr, nullptr));
                tmpCogData = nullptr;
                boost::filesystem::remove(tmpFile);

                //copy file to destination directory
                boost::filesystem::copy(tmpCog, outCog);
                //delete tmp file
                boost::filesystem::remove(tmpCog);

                //update db
                std::string updateQuery = fmt::format(R"""(
                INSERT INTO wms_file(product_file_id, product_file_variable_id, rel_file_path)
                VALUES({0},{1},'{2}') ON CONFLICT(product_file_id,product_file_variable_id) DO UPDATE SET rel_file_path=EXCLUDED.rel_file_path;
                )""", res[rowId][0].as<size_t>(), variable.second->id, (boost::filesystem::relative(outCog, config->filesystem.mapserverPath)).string());
                cn->executeQuery(updateQuery);
            }
        }
    return 0;

}

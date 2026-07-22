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

#include <filesystem>
#include <fmt/format.h>
#include <gdal_frmts.h>
#include <gdalwarper.h>
#include <iostream>
#include <otbImage.h>
#include <otbVectorImage.h>
#include <otbMultiToMonoChannelExtractROI.h>
#include <otbImageFileReader.h>
#include <otbImageFileWriter.h>

#include "../lib/Constants/Constants.h"
#include "../lib/Filters/Visualization/WMSCogFilter.h"
#include "../lib/Filters/RasterReprojection/RasterReprojectionFilter.h"

template <class TInput>
void processFile(std::filesystem::path &inFile, const size_t productFileId, std::filesystem::path filePath, ProductInfo::SharedPtr product, ProductVariable::SharedPtr variable, Configuration::SharedPtr config){
    using TInputImage           = otb::VectorImage<TInput, 2>;
    using TInputImageBand       = otb::Image<TInput,2>;
    using TOutputImage          = otb::VectorImage<unsigned char, 2>;
    using TInputImageReader     = otb::ImageFileReader<TInputImage>;
    using TOutputImageWriter    = otb::ImageFileWriter<TOutputImage>;
    using BandExtractorFilter   = otb::MultiToMonoChannelExtractROI<typename TInputImage::IOPixelType, typename TInputImageBand::IOPixelType>;
    using WMSCogFilter          = otb::WMSCogFilter<TInputImageBand, TOutputImage>;
    using ReprojectionFilter    = otb::RasterReprojectionFilter<TOutputImage>;
    typename TInputImageReader::Pointer reader = TInputImageReader::New();

    char **tmpToCOGWarpOptions = nullptr;
    tmpToCOGWarpOptions = CSLSetNameValue(tmpToCOGWarpOptions, "BIGTIFF", "YES");
    tmpToCOGWarpOptions = CSLSetNameValue(tmpToCOGWarpOptions, "NUM_THREADS", "ALL_CPUS");

    reader->SetFileName(inFile.string());
    reader->UpdateOutputInformation();
    std::cout << "data loaded!\n";
    std::cout << reader->GetOutput()->GetNumberOfComponentsPerPixel() << "\n";
    GDALDriver *poDriver = GetGDALDriverManager()->GetDriverByName("COG");

    for(unsigned int bndId = 1; bndId <= reader->GetOutput()->GetNumberOfComponentsPerPixel(); bndId++) {
        //tmp output file
        std::filesystem::path tmpFile = config->filesystem.tmpPath/filePath;

        std::filesystem::path dstFilePath = filePath.c_str();

        if (variable->variable.length() > 0) {
            std::vector<std::string> splitPath = split(tmpFile.string(), "/");
            splitPath.insert(splitPath.end()-1, variable->variable);

            if(variable->bandCount > 1)
                splitPath.insert(splitPath.end()-1, "band_"+std::to_string(bndId));


            tmpFile = boost::algorithm::join(splitPath,"/");
            dstFilePath = std::filesystem::relative(tmpFile, config->filesystem.tmpPath);

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

        typename BandExtractorFilter::Pointer bandExtractor = BandExtractorFilter::New();
        bandExtractor->SetInput(0, reader->GetOutput());
        bandExtractor->SetChannel(bndId);
        //bandExtractor->Update();

        typename WMSCogFilter::Pointer wmsFltr = WMSCogFilter::New();
        wmsFltr->SetInput(bandExtractor->GetOutput());
        wmsFltr->setProduct(product, variable);
        wmsFltr->UpdateOutputInformation();

        typename ReprojectionFilter::Pointer reproject = ReprojectionFilter::New();
        reproject->SetInput(wmsFltr->GetOutput());
        reproject->SetInputProjection(4326);
        reproject->SetOutputProjection(3857);
        reproject->UpdateOutputInformation();

        typename TOutputImageWriter::Pointer writer = TOutputImageWriter::New();
        writer->SetFileName(tmpFile.string()+"?&gdal:co:BIGTIFF=IF_NEEDED&gdal:co:TILED=YES&gdal:co:BLOCKXSIZE=512&gdal:co:BLOCKYSIZE=512");
        writer->SetInput(reproject->GetOutput());
        writer->GetStreamingManager()->SetDefaultRAM(config->statsInfo.memoryMB);
        writer->Update();
        writer->ResetPipeline();

        //destination cog file
        std::filesystem::path outCog = config->filesystem.mapserverPath/dstFilePath;
        outCog.replace_extension(".tif");
        //check if a file exists
        if(std::filesystem::exists(outCog))
            std::filesystem::remove(outCog);
        createDirectoryForFile(outCog);
        //std::cout << tmpFile << "\n" << tmpCog <<"\n" << outCog <<"\n\n";

        std::cout << "Transforming to tmp cog\n";

        //transform output file to cog
        GDALDatasetUniquePtr inData, tmpCogData;
        inData  = GDALDatasetUniquePtr(GDALDataset::FromHandle(GDALOpen(tmpFile.c_str(), GA_ReadOnly)));


        tmpCogData = GDALDatasetUniquePtr(poDriver->CreateCopy(tmpCog.c_str(), inData.get(), FALSE, tmpToCOGWarpOptions, nullptr, nullptr));
        tmpCogData = nullptr;
        std::filesystem::remove(tmpFile);

        std::cout << "Copy to destination\n";
        //copy file to destination directory
        std::filesystem::copy(tmpCog, outCog);
        //delete tmp file
        std::filesystem::remove(tmpCog);

        //update db
        std::string updateQuery = fmt::format(R"""(
        INSERT INTO wms_file(product_file_id, product_file_variable_id, band_id, rel_file_path)
        VALUES({0},{1},{2},'{3}') ON CONFLICT(product_file_id,product_file_variable_id,band_id) DO UPDATE SET rel_file_path=EXCLUDED.rel_file_path;
        )""", productFileId, variable->id, bndId, (std::filesystem::relative(outCog, config->filesystem.mapserverPath)).string());

        PGPool::PGConn::UniquePtr cn  = PGPool::PGConn::New(Configuration::connectionIds[config->statsInfo.connectionId]);
        cn->executeQuery(updateQuery);
    }
    CSLDestroy(tmpToCOGWarpOptions);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        std::cout <<"Usage: CogGenerator json_config_file";
        return 1;
    }
    std::string cfgFile(argv[1]);
    GDALAllRegister();

    Configuration::SharedPtr config = Configuration::New(cfgFile);
    if (config->parse() != 0)
        return 1;

    if (Constants::load(config) != 0)
        return 1;

    //clean up tmp directory before starting
    if(std::filesystem::exists(config->filesystem.tmpPath))
        std::filesystem::remove_all(config->filesystem.tmpPath);

    std::filesystem::create_directories(config->filesystem.tmpPath);


    std::vector<std::string> validProductTypes = {"raw", "anomaly"};
    for (auto& product:Constants::productInfo) {
        if(std::find(validProductTypes.begin(), validProductTypes.end(), *product.second->productType) == validProductTypes.end() ) //skipping products for which there is no need to create a cog
            continue;
        for (auto& variable:product.second->variables) {
            //getting image datatype
            otb::ImageIOBase::IOComponentType inImageType;
            otb::ImageIOBase::Pointer imageIO = otb::ImageIOFactory::CreateImageIO(variable.second->firstProductVariablePath->c_str(), otb::ImageIOFactory::ReadMode);
            imageIO->ReadImageInformation();

            std::string query = fmt::format(R"""(
                WITH counted AS(
                    SELECT wf.product_file_id, pf.rel_file_path, COUNT(*) cnt, pfv.band_count, pf.date
                    FROM wms_file wf
                    JOIN product_file pf ON pf.id = wf.product_file_id
                    JOIN product_file_description pfd ON pf.product_file_description_id = pfd.id
                    JOIN product_file_variable pfv ON pfd.id = pfv.product_file_description_id
                    WHERE  wf.product_file_variable_id  = {0}
                    GROUP BY product_file_id, pf.rel_file_path, pfv.band_count,pf.date
                )
                SELECT * FROM (
                    SELECT pf.id, pf.rel_file_path, wf.rel_file_path, pf.date
                    FROM product_file pf
                    JOIN product_file_description pfd ON pf.product_file_description_id = pfd.id
                    LEFT JOIN wms_file wf ON wf.product_file_id = pf.id AND wf.product_file_variable_id  = {0}
                    WHERE wf.rel_file_path IS NULL AND pfd.id = {1}
                    UNION ALL
                    SELECT c.product_file_id, c.rel_file_path, NULL, date
                    FROM counted c
                    WHERE cnt < band_count
                ) as a ORDER BY date)""", variable.second->id, product.second->id);

            std::cout << query << "\n";
            PGPool::PGConn::UniquePtr cn  = PGPool::PGConn::New(Configuration::connectionIds[config->statsInfo.connectionId]);
            PGPool::PGConn::PGRes res   = cn->fetchQueryResult(query);
            for (size_t rowId = 0; rowId < res.size(); rowId++) {

                //create output paths
                std::filesystem::path filePath = res[rowId][1].as<std::string>();
                std::filesystem::path inFile      = variable.second->productAbsPath(filePath).string();

                std::cout << "Building COG File for: " << inFile << "\n";
                if (imageIO->GetComponentType() == otb::ImageIOBase::UCHAR)
                    processFile<unsigned char>(inFile, res[rowId][0].as<size_t>(), filePath, product.second, variable.second, config);
                else if (imageIO->GetComponentType() == otb::ImageIOBase::SHORT)
                    processFile<short>(inFile,res[rowId][0].as<size_t>(), filePath, product.second, variable.second, config);
                else if (imageIO->GetComponentType() == otb::ImageIOBase::USHORT)
                    processFile<unsigned short>(inFile, res[rowId][0].as<size_t>(), filePath, product.second, variable.second, config);
            }
        }
    }
    return 0;
}

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

#ifndef PRODUCTORDERPROCESSOR_H
#define PRODUCTORDERPROCESSOR_H

#include <boost/algorithm/string/join.hpp>
#include <boost/filesystem/path.hpp>
#include <gdal.h>
#include <gdal_alg.h>
#include <gdalwarper.h>
#include <memory>
#include <otbExtractROI.h>
#include <otbImage.h>
#include <otbImageFileReader.h>
#include <otbImageFileWriter.h>

#include "../../lib/ConfigurationParser/ConfigurationParser.h"
#include "../../lib/Constants/Constants.h"
#include "../../lib/Filters/IO/VectorWktToLabelImageFilter.h"
#include "../../lib/Filters/OTBImageDefs.h"
#include "../../lib/PostgreSQL/PostgreSQL.h"
#include "../../lib/Utils/Utils.hxx"

class ProductOrderProcessor {
    using JSONObjectMember  = rapidjson::GenericMember<rapidjson::UTF8<>, rapidjson::MemoryPoolAllocator<>>;

    struct AOINfo {
        OGREnvelope envelope;
        otb::UCharImageType::RegionType::IndexType originIdx;
        otb::UCharImageType::RegionType::SizeType size;
        AOINfo();
    };

    std::mutex cropMtx, labelMtx;
    
    Configuration::SharedPtr config;
    void compressAndEMail(std::filesystem::path &tmpOrderPath, std::string orderId, std::string email);
    void computeStatistics(PGPool::PGConn::UniquePtr& cn, std::filesystem::path& tmpOrderPath,  PGPool::PGConn::PGRes& processFiles, std::map<size_t, AOINfo>& maskInfo, std::string& orderId, JSONObjectMember& orderParams);
    template <class TInputImage>
    void crop(std::filesystem::path &inImage, std::filesystem::path &outImage, AOINfo &mask, bool scale=false, double a=0, double b=0);
    std::string createAnomaliesDataQuery(JSONObjectMember& dataReq);
    std::string createRawDataQuery(JSONObjectMember& dataReq);
    void createRasterOutput(std::filesystem::path inRelFile, std::filesystem::path &orderPath, AOINfo& maskInfo, size_t& variableId);
    void cropSingleRasterFile(std::filesystem::path& inFile, std::filesystem::path& tmpOrderPath, std::filesystem::path& inRelFile, AOINfo& maskInfo, std::string variable="");
    void generateRasterData(std::map<size_t, AOINfo> &maskInfo, size_t& variableId, std::filesystem::path& tmpOrderPath, PGPool::PGConn::PGRes& processFiles);
    void polyStatsExtractor(std::string& orderId, JSONObjectMember& orderParams, JsonDocumentSharedPtr polyIds, size_t &variableId, JsonValue& imagesArray, std::map<size_t, AOINfo>& maskInfo, std::filesystem::path &dstDir );
    template <class TInputImage>
    AOINfo alignAOI(PathSharedPtr imgPath, OGREnvelope& aoiEnvelope);

protected:
    ProductOrderProcessor(Configuration::SharedPtr& cfg);

public:
    using SharedPtr = std::shared_ptr<ProductOrderProcessor>;
    using UniquePtr = std::unique_ptr<ProductOrderProcessor>;

    void process();
    
    static SharedPtr NewShared(Configuration::SharedPtr& cfg);
    static UniquePtr NewUnique(Configuration::SharedPtr& cfg);
};

#endif // PRODUCTORDERPROCESSOR_H

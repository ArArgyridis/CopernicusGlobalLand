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

#include <fmt/format.h>
#include <gdal.h>
#include <iostream>

#include "../lib/Anomalies/Utils.h"
#include "../lib/Anomalies/ZScoreProcessor/ZScoreProcessor.h"
#include "../lib/Constants/Constants.h"
#include "../lib/Utils/Utils.hxx"
#include "../lib/Filters/RasterReprojection/RasterReprojectionFilter.h"

#include <otbImage.h>
#include <otbImageFileWriter.h>

int main()
{
    using PixelType = float;
    constexpr unsigned int Dimension = 2;
    using ImageType = otb::Image<PixelType, Dimension>;

    // Create image
    ImageType::Pointer image = ImageType::New();
    ImageType::RegionType region;
    ImageType::IndexType start = {0, 0};
    ImageType::SizeType size = {100, 100};

    region.SetSize(size);
    region.SetIndex(start);
    image->SetRegions(region);
    image->Allocate();
    image->FillBuffer(42.0); // Fill with dummy data

    // Writer
    using WriterType = otb::ImageFileWriter<ImageType>;
    WriterType::Pointer writer = WriterType::New();
    writer->SetFileName("NETCDF:\"output.nc\":variable_name"); // NetCDF file
    writer->SetInput(image);

    try {
        writer->Update();
    } catch (itk::ExceptionObject & err) {
        std::cerr << "Exception caught: " << err << std::endl;
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}


int _main(int argc, char* argv[]) {
    if (argc < 3) {
        std::cout << "usage: AnomalyExtractor configuration_file anomaly_product_file_description_id";
        return 1;
    }

    GDALAllRegister();

    std::string cfgFile(argv[1]);
    size_t anomalyProductId = atoi(argv[2]);

    Configuration::SharedPtr config = Configuration::New(cfgFile);
    if (config->parse() != 0)
        return 1;

    if (Constants::load(config) != 0)
        return 1;

    std::string query = fmt::format(
        R"""(SELECT min(date), max(date), ltai.raw_product_variable_id
        FROM product_file_description pfd
        JOIN product_file_variable pfv ON pfd.id = pfv.product_file_description_id
        JOIN long_term_anomaly_info ltai ON pfv.id = ltai.anomaly_product_variable_id
        JOIN product_file_variable pfvraw ON ltai.raw_product_variable_id  = pfvraw.id
        JOIN product_file_description pfdraw ON pfvraw.product_file_description_id  = pfdraw.id
        JOIN product_file pf ON pfdraw.id = pf.product_file_description_id
        WHERE pfd.id = {0} GROUP BY ltai.raw_product_variable_id)""", argv[2]);

    PGPool::PGConn::UniquePtr cn  = PGPool::PGConn::New(Configuration::connectionIds[config->statsInfo.connectionId]);
    PGPool::PGConn::PGRes res   = cn->fetchQueryResult(query);

    if (res.size() == 0 || res[0][0].is_null()) {
        std::cout << "Anomalies cannot be computed!";
        return 1;
    }

    //std::cout << res[0][1].as<std::string>() << "\n";

    auto timeStart = iso8601ToUTCTimestamp(res[0][0].as<std::string>());
    auto p = boost::posix_time::to_tm(timeStart);
    //set day to closest dekad
    p.tm_mday = 1*(p.tm_mday >=1) + 10*(p.tm_mday >=11) + 10*(p.tm_mday >=21);
    timeStart = boost::posix_time::ptime_from_tm(p);

    auto timeEnd = iso8601ToUTCTimestamp(res[0][1].as<std::string>()) + boost::gregorian::date_duration(1);
    std::vector<int> dekads = {1,11,21};
    //std::cout << timeStart.date() << "\n";
    for (boost::posix_time::ptime currentTime = timeStart; currentTime < timeEnd; currentTime=getNextDekad(currentTime)) {
        auto dtEnd = getNextDekad(currentTime);
        //std::cout << currentTime.date() << "\t" << dtEnd.date() << "\n";

        for (auto variable: Constants::productInfo[anomalyProductId]->variables){
            //std::cout  << variable.second->id <<"\n";
            ZScoreProcessor zscore(currentTime, dtEnd, config, Constants::productInfo[anomalyProductId], variable.second, Constants::variableInfo[res[0][2].as<size_t>()]);
            zscore.process();
        }
    }
    return 0;
}


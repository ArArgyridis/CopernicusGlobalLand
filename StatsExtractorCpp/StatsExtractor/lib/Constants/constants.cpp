#include <iostream>
#include <sstream>

#include "constants.hxx"
#include "../PostgreSQL/postgresql.hxx"

std::map<std::size_t, ProductInfoPtr> Constants::productInfo;

ProductInfo::ProductInfo(){}

ProductInfo::ProductInfo(PGConn::PGRow row, Configuration::Pointer cfg):scaler(noScalerFunc), scaleFactor(1), addOffset(0) {
    auto productNamesArr = row[0].as_array();
    pgArrayToVector<std::string>(productNamesArr, productNames);

    //productNames = row[0].as<pqxx::array_parser>();
    productType = row[1].as<std::string>();
    rootPath = cfg->filesystem.imageryPath;
    if (productType == "anomaly")
        rootPath = cfg->filesystem.anomalyProductsPath;

    id = row[2].as<size_t>();
    pattern = row[3].as<std::string>();
    types = row[4].as<std::string>();
    dateptr = row[5].as<std::string>();

    if (!row[6].is_null())
        variable = row[6].as<std::string>();

    if (!row[7].is_null())
        style = row[7].as<std::string>();

    if (!row[9].is_null()) {
        valueRange.low = row[9].as<float>();
        valueRange.mid = row[10].as<float>();
        valueRange.high = row[11].as<float>();
    }

    if (!row[12].is_null()) {
        novalColorRamp.Parse(row[12].as<std::string>().c_str());
        noVal = ColorInterpolation(novalColorRamp);
    }

    if (!row[13].is_null()) {
        sparsevalColorRamp.Parse(row[13].as<std::string>().c_str());
        sparseVal = ColorInterpolation(sparsevalColorRamp);
    }


    if (!row[14].is_null()) {
        midvalColorRamp.Parse(row[14].as<std::string>().c_str());
        mildVal = ColorInterpolation(midvalColorRamp);
    }

    if (!row[15].is_null()) {
        highvalColorRamp.Parse(row[15].as<std::string>().c_str());
        denseVal = ColorInterpolation(highvalColorRamp);
    }

    if (!row[16].is_null())
        minMaxValues[0] = row[16].as<float>();

    if (!row[17].is_null())
        minMaxValues[1] = row[17].as<float>();

    if (!row[19].is_null())
        fileNameCreationPattern = row[19].as<std::string>();

    if (!row[20].is_null()) {
        boost::filesystem::path relPath = row[20].as<std::string>();
        firstProductPath =productAbsPath(relPath);
    }
    loadMetadata();
}

long double ProductInfo::convertPixelsToArea(long double pixels) {
    return pixelsToArea(pixels, pixelSize);
}

void ProductInfo::loadMetadata() {
    if (firstProductPath.empty())
        return;

    scaler = &noScalerFunc;
    metadata = getMetadata(firstProductPath);
    if (productType =="raw") {
        scaleFactor = std::stod((*metadata)[variable+"#scale_factor"]);
        addOffset = std::stod((*metadata)[variable+"#add_offset"]);
        scaler = &scalerFunc;
    }
    if ((*metadata)["MY_UNIT"]== "degree")
        pixelsToArea = &pixelsToAreaM2Degrees;
    else
        pixelsToArea = &pixelsToAreaM2Meters;
    pixelSize = stof((*metadata)["MY_PIXEL_SIZE"]);

    lutProductValues.reserve(minMaxValues[1]-minMaxValues[0]+1);
    lutProductValues.resize(minMaxValues[1]-minMaxValues[0]+1);

    for (size_t i = 0; i < lutProductValues.size()+1; i++)
        lutProductValues[i] = scaler(minMaxValues[0]+(int)i, scaleFactor, addOffset);
}

boost::filesystem::path ProductInfo::productAbsPath(boost::filesystem::path &relPath) {
    boost::filesystem::path retPath;
    if(productType == "raw")
        retPath = std::string("NETCDF:") + (rootPath/relPath).string() +":"+variable;
    else
        retPath = rootPath/relPath;

    return retPath;
}

float ProductInfo::scaleValue(float value) {
    return scaler(value, scaleFactor, addOffset);
}




Constants::Constants() {}

unsigned short Constants::load(Configuration::Pointer cfg) {


    std::stringstream queryStream;
    queryStream << "WITH tmp_file_id AS("
                   " SELECT pf.product_description_id, min(pf.id) tid"
                   " FROM product_file_description pfd"
                   " JOIN product_file pf ON pfd.id = pf.product_description_id"
                   " WHERE pfd.pattern LIKE '%.nc' OR pfd.pattern LIKE '%.tif'"
                   " GROUP BY pf.product_description_id"
                   " )"
                   "SELECT p.name, p.type, pfd.*, pf.rel_file_path"
                << " FROM " << cfg->statsInfo.schema <<".product p"
                << " LEFT JOIN "<< cfg->statsInfo.schema <<".product_file_description pfd on p.id = pfd.product_id"
                <<" LEFT JOIN tmp_file_id tmp ON tmp.product_description_id = pfd.id"
               <<" LEFT JOIN "<< cfg->statsInfo.schema <<".product_file pf ON pf.id = tmp.tid"
              << " WHERE p.id IN(1) ORDER BY p.id";

    std::string query = queryStream.str();
    PGConn::Pointer cn = PGConn::New(Configuration::connectionIds[cfg->statsInfo.connectionId]);
    PGConn::PGRes res = cn->fetchQueryResult(query, "");
    for (size_t i = 0; i < res.size(); i++)
        Constants::productInfo[res[i][2].as<size_t>()] = std::make_shared<ProductInfo>(PGConn::PGRow(res[i]), cfg);


    return 0;
}


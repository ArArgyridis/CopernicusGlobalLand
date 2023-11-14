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

#include <boost/algorithm/string/join.hpp>
#include <boost/filesystem/operations.hpp>
#include <iostream>
#include <libxml/xpathInternals.h>
#include <sstream>

#include "Utils.hxx"

std::string bytesToMaxUnit(unsigned long long &bytes){
    std::vector<std::string> units = {"Bytes","KB", "MB", "GB", "TB"};
    if (bytes == 0)
        return "OB";

    double retSize;
    size_t unId = 0;
    for(unId = 0; unId < units.size() && bytes > 0 && bytes / static_cast<unsigned long long>(pow(1024, unId)) > 0; unId++) {
        continue;
    }
    std::stringstream out;
    out << std::setprecision(2) << std::fixed << round(bytes /pow(1024, --unId)*100)/100 << units[unId];
    return out.str();
}

void createDirectoryForFile(std::filesystem::path dstFile) {
    auto splitDir = split(dstFile.string(), "/");
    splitDir.pop_back();
    std::string outPath = boost::algorithm::join(splitDir,"/");
    std::filesystem::create_directories(outPath);
}

unsigned long long getFolderSizeOnDisk(std::filesystem::path &dataPath) {
    unsigned long long size = 0;
    for (const auto& dirEntry : std::filesystem::recursive_directory_iterator(dataPath)) {

        if (std::filesystem::is_directory(dirEntry))
            continue;
        size += std::filesystem::file_size(dirEntry);
    }

    return size;
}

MetadataDictPtr getMetadata(std::filesystem::__cxx11::path &dataPath) {
    GDALDatasetUniquePtr tmpDataset =  GDALDatasetUniquePtr(GDALDataset::FromHandle(GDALOpen( dataPath.c_str(), GA_ReadOnly)));
    char **meta = tmpDataset->GetMetadata();

    MetadataDictPtr bandMetadata = std::make_unique<MetadataDict>();

    for (char** i = meta; *i; i++) {
        std::stringstream s;
        std::string key;
        for (char *j = *i; *j !='\0'; j++) {
            if(*j == '=') {
                key = s.str();
                s.str("");
            }
            else {
                s << *j;
            }
        }
        (*bandMetadata)[key] = s.str();
    }

    //adding projection type info
    const char* proj =tmpDataset->GetProjectionRef();
    OGRSpatialReference sr;
    sr.importFromWkt(proj);
    (*bandMetadata)["MY_UNIT"] = sr.GetAttrValue("UNIT");

    //adding pixel size
    double gt[6];
    tmpDataset->GetGeoTransform(gt);
    (*bandMetadata)["MY_PIXEL_SIZE"] = std::to_string(gt[1]);
    (*bandMetadata)["MY_NO_DATA_VALUE"] = std::to_string(tmpDataset->GetRasterBand(1)->GetNoDataValue());
    (*bandMetadata)["GDAL_RASTER_TYPE"] = std::to_string(tmpDataset->GetRasterBand(1)->GetRasterDataType());
    meta = nullptr;
    return bandMetadata;
}

OGRPolygon envelopeToGeometry(OGREnvelope &envelope) {
    OGRPolygon retPoly;
    OGRLinearRing ring;

    ring.addPoint(envelope.MinX, envelope.MinY);
    ring.addPoint(envelope.MinX, envelope.MaxY);
    ring.addPoint(envelope.MaxX, envelope.MaxY);
    ring.addPoint(envelope.MaxX, envelope.MinY);

    ring.closeRings();
    retPoly.addRing(&ring);

    return retPoly;
}

long double pixelsToAreaM2Degrees(long double &pixelCount, long double pixelSize) {
    return pixelCount*1.0*pow(pixelSize*M_PI/180.0*6371000, 2);
}

long double pixelsToAreaM2Meters(long double &pixelCount, long double pixelSize) {
    return pixelCount*1.0*pixelSize*pixelSize;
}

float noScalerFunc(float x, float& scale, float& offset) {
    return x;
}

size_t reverseNoScalerFunc(float x, float &scale, float &offset) {
    return static_cast<size_t>(round(x));
}

size_t reverseScalerFunc(float x, float &scale, float &offset) {
    return static_cast<size_t>(round( (x-offset)/scale));
}

std::string randomString(size_t len) {
    static const char alphanum[] =
        "0123456789"
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        "abcdefghijklmnopqrstuvwxyz";
    std::string tmp;
    tmp.reserve(len);

    for (int i = 0; i < len; ++i) {
        tmp += alphanum[rand() % (sizeof(alphanum) - 1)];
    }
    return tmp;
}


std::string rgbToArrayString(RGBVal &array) {
    std::stringstream k;
    k <<"[";
    for(auto& it:array)
        k << it <<",";

    k.seekp(-1, std::ios_base::end);
    k <<"]";
    return k.str();
}



float scalerFunc(float x, float& scale, float& offset) {
    return x*scale+offset;
}

std::vector<std::string> split(std::string s, std::string delimiter) {
    size_t pos_start = 0, pos_end, delim_len = delimiter.length();
    std::string token;
    std::vector<std::string> res;

    while ((pos_end = s.find(delimiter, pos_start)) != std::string::npos) {
        token = s.substr (pos_start, pos_end - pos_start);
        pos_start = pos_end + delim_len;
        res.push_back (token);
    }

    res.push_back (s.substr (pos_start));
    return res;
}


std::string stringstreamToString(std::stringstream &stream) {
        stream.seekp(-1, stream.cur);
        stream << ' ';
        return stream.str();
}

std::vector<RGBVal> styleColorParser(std::string &style) {
    std::vector<RGBVal> styleColors;

    XmlDocPtr doc = XmlDocPtr(xmlReadMemory(style.c_str(), style.size(), "tmp.xml", nullptr, 0), xmlFreeDoc);

    XmlXPathContextPtr ctx = XmlXPathContextPtr(xmlXPathNewContext(doc.get()), xmlXPathFreeContext);
    xmlXPathRegisterNs(ctx.get(), reinterpret_cast<const unsigned char *>(""), reinterpret_cast<const unsigned char *>("http://www.opengis.net/sld"));
    xmlXPathRegisterNs(ctx.get(), reinterpret_cast<const unsigned char *>("sld"), reinterpret_cast<const unsigned char *>("http://www.opengis.net/sld"));
    xmlXPathRegisterNs(ctx.get(), reinterpret_cast<const unsigned char *>("gml"), reinterpret_cast<const unsigned char *>("http://www.opengis.net/gml"));

    XmlXpathObjectPtr res = XmlXpathObjectPtr(xmlXPathEvalExpression(reinterpret_cast<const unsigned char *>("//sld:ColorMapEntry"), ctx.get()), xmlXPathFreeObject);
    if (res != nullptr) {

        styleColors.resize(res->nodesetval->nodeNr);
        styleColors.reserve(res->nodesetval->nodeNr);

        for (size_t i = 0; i < res->nodesetval->nodeNr; i++) {
            if(res->nodesetval->nodeTab[i]->type == XML_ELEMENT_NODE) {
                xmlNodePtr tmpNode = res->nodesetval->nodeTab[i];
                sscanf(reinterpret_cast<const char*>(xmlGetProp(tmpNode, reinterpret_cast<const unsigned char *>("color"))), "#%2hx%2hx%2hx", &styleColors[i][0], &styleColors[i][1], &styleColors[i][2]);
            }
        }
    }
    return styleColors;
}



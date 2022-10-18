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

#include <iostream>
#include <sstream>

#include "Utils.hxx"


MetadataDictPtr getMetadata(boost::filesystem::path &dataPath) {
    GDALDatasetPtr tmpDataset =  GDALDatasetPtr(reinterpret_cast<GDALDataset*>(GDALOpenEx( dataPath.string().c_str(), GDAL_OF_RASTER, NULL, NULL, NULL )), GDALClose);

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

long double pixelsToAreaM2Degrees(long double &pixelCount, float pixelSize) {
    return pixelCount*1.0*pow(pixelSize*M_PI/180.0*6371000, 2);
}
long double pixelsToAreaM2Meters(long double &pixelCount, float pixelSize) {
    return pixelCount*1.0*pixelSize*pixelSize;
}


float noScalerFunc(float x, float& scale, float& offset) {
    return x;
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




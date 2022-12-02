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

#ifndef UTILS_HXX
#define UTILS_HXX

#include <boost/filesystem/path.hpp>
#include <gdal_priv.h>
#include <itkPoint.h>
#include <libxml2/libxml/tree.h>
#include <libxml/xpath.h>
#include <memory>
#include <ogr_core.h>
#include <ogr_feature.h>
#include<ogr_geometry.h>
#include <rapidjson/document.h>
#include <rapidjson/writer.h>
#include <set>

#include "ColorInterpolation.h"


using MetadataDict      = std::map<std::string, std::string>;
using MetadataDictPtr   = std::unique_ptr<MetadataDict>;

/** Typedefs to handle GDAL structures through smart pointers */
using GDALDatasetPtr    = std::unique_ptr<GDALDataset, void(*)(GDALDatasetH) > ;
using OGRFeaturePtr     = std::unique_ptr<OGRFeature, void(*)( OGRFeature * )>;
using OGRGeometryPtr    = std::unique_ptr<OGRGeometry, void(*)( OGRGeometry * )> ;

using OGRSpatialReferencePtr    = std::unique_ptr<OGRSpatialReference> ;
using OGRFeatureDefnPtr         = std::unique_ptr<OGRFeatureDefn> ;

/** Typedefs to handle JSON data */
using JsonDocument      = rapidjson::Document;
using JsonDocumentPtr   = std::unique_ptr<JsonDocument>;

using JsonValue     = rapidjson::Value;
using JsonValuePtr  = std::unique_ptr<JsonValue>;

/** Double precision Point coordinates */
using point2d = itk::Point<double, 2>;

/** typedef for labels */
using LabelsArray       = std::vector<size_t>;
using LabelsArrayPtr    = std::shared_ptr<LabelsArray>;

/** typedefs for XML */
using XmlDocPtr                 = std::unique_ptr<xmlDoc, void(*)(xmlDocPtr)>;
using XmlXPathContextPtr        = std::unique_ptr<xmlXPathContext, void(*)(xmlXPathContextPtr)>;
using XmlXpathObjectPtr         = std::unique_ptr<xmlXPathObject, void(*)(xmlXPathObjectPtr)>;

/** Image statistics Info */

MetadataDictPtr getMetadata(boost::filesystem::path &dataPath);
OGRPolygon envelopeToGeometry(OGREnvelope& envelope);
long double pixelsToAreaM2Degrees(long double& pixelCount, long double pixelSize);
long double pixelsToAreaM2Meters(long double& pixelCount, long double pixelSize);

float noScalerFunc(float x, float& scale, float& offset);

std::string rgbToArrayString(RGBVal& array);

size_t reverseNoScalerFunc(float x, float &scale, float &offset);
size_t reverseScalerFunc(float x, float& scale, float& offset);

float scalerFunc(float x, float& scale, float& offset);


//template functions


template <class TInputImage>
OGREnvelope regionToEnvelope(typename TInputImage::Pointer inputImage, typename TInputImage::RegionType region) {

    typename TInputImage::RegionType::IndexType upperLeftIdx = region.GetIndex(), lowerRightIdx = region.GetUpperIndex();
    point2d upperLeft, lowerRight;
    inputImage->TransformIndexToPhysicalPoint(upperLeftIdx, upperLeft);
    inputImage->TransformIndexToPhysicalPoint(lowerRightIdx, lowerRight);

    OGREnvelope envelope;
    envelope.MinX = upperLeft[0]  - inputImage->GetSignedSpacing()[0]/2;
    envelope.MinY = lowerRight[1] - abs(inputImage->GetSignedSpacing()[1]/2);
    envelope.MaxX = lowerRight[0] + inputImage->GetSignedSpacing()[0]/2;
    envelope.MaxY = upperLeft[1]  + abs(inputImage->GetSignedSpacing()[1]/2);
    //std::cout << maxEnvelope.MinX <<","<<maxEnvelope.MaxY<<"\n" <<maxEnvelope.MaxX <<","<<maxEnvelope.MinY <<"\n";
    return envelope;

}

template <class JSONType>
std::string jsonToString(JSONType& json, size_t decimalPlaces=2) {
    rapidjson::StringBuffer buf;
    rapidjson::Writer<rapidjson::StringBuffer> writer(buf);
    writer.SetMaxDecimalPlaces(decimalPlaces);
    json.Accept(writer);
    return  buf.GetString();
}

std::string stringstreamToString(std::stringstream &stream);

#endif // UTILS_HXX

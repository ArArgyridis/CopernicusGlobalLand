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

#include <boost/date_time/posix_time/posix_time.hpp>
#include <boost/date_time/posix_time/posix_time_io.hpp>
#include <boost/filesystem/path.hpp>
#include <filesystem>
#include <gdal_priv.h>
#include <itkPoint.h>
#include <libxml2/libxml/tree.h>
#include <libxml/xpath.h>
#include <memory>
#include <ogr_core.h>
#include <ogr_feature.h>
#include <ogr_geometry.h>
#include <otbGdalDataTypeBridge.h>
#include <rapidjson/document.h>
#include <rapidjson/writer.h>
#include <set>

#include "ColorInterpolation.h"
#include "itkVariableLengthVector.h"


using MetadataDict      = std::map<std::string, std::string>;
using MetadataDictPtr   = std::unique_ptr<MetadataDict>;

/** Typedefs to handle GDAL structures through smart pointers */
using GDALDatasetPtr    = std::unique_ptr<GDALDataset>;
using OGRFeaturePtr     = std::unique_ptr<OGRFeature,  void(*)(OGRFeature *)>;
using OGRGeometryPtr    = std::unique_ptr<OGRGeometry, void(*)(OGRGeometry *)>;

using OGRSpatialReferencePtr    = std::unique_ptr<OGRSpatialReference> ;
using OGRFeatureDefnPtr         = std::unique_ptr<OGRFeatureDefn> ;

/** Typedefs to handle JSON data */
using JsonDocument            = rapidjson::Document;
using JsonDocumentUniquePtr   = std::unique_ptr<JsonDocument>;
using JsonDocumentSharedPtr   = std::shared_ptr<JsonDocument>;


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

/** typedef for String Pointer */
using StringPtr                 = std::shared_ptr<std::string>;

/** typedef for Paths */
using PathSharedPtr             = std::shared_ptr<std::filesystem::path>;

/** Image statistics Info */

std::string bytesToMaxUnit(unsigned long long& bytes);

void createDirectoryForFile(std::filesystem::path dstFile);

unsigned long long getFolderSizeOnDisk(std::filesystem::path &dataPath);
MetadataDictPtr getMetadata(std::filesystem::path &dataPath, int forcedEPSG=4326);
OGRPolygon envelopeToGeometry(OGREnvelope& envelope);
long double pixelsToAreaM2Degrees(long double& pixelCount, long double pixelSize);
long double pixelsToAreaM2Meters(long double& pixelCount, long double pixelSize);

float noScalerFunc(float x, float& scale, float& offset);

std::string randomString(size_t len);
std::string rgbToArrayString(RGBVal& array);

size_t reverseNoScalerFunc(float x, float &scale, float &offset);
size_t reverseScalerFunc(float x, float& scale, float& offset);

float scalerFunc(float x, float& scale, float& offset);

std::vector<std::string> split(std::string s, std::string delimiter);




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
    return envelope;

}

template <class JSONType>
std::string jsonToString(JSONType& json, size_t decimalPlaces=2) {
    rapidjson::StringBuffer buf;
    rapidjson::Writer<rapidjson::StringBuffer> writer(buf);
    writer.SetMaxDecimalPlaces(decimalPlaces);
    json.Accept(writer);
    return buf.GetString();
}

std::string stringstreamToString(std::stringstream &stream);
std::vector<RGBVal> styleColorParser(std::string& style);

template <class TImage>
GDALDatasetUniquePtr createGDALMemoryDatasetFromOTBImageRegion(TImage* image, typename TImage::RegionType region) {
    std::stringstream stream;
    size_t nBands = image->GetNumberOfComponentsPerPixel();
    typename TImage::PointType origin = image->GetOrigin();
    typename TImage::SpacingType spacing = image->GetSignedSpacing();
    typename TImage::RegionType::IndexType originIdx = region.GetIndex();
    typename TImage::RegionType::IndexType bufferedRegionIndex = image->GetBufferedRegion().GetIndex();

    auto dif = originIdx - bufferedRegionIndex;
    stream << "MEM:::"
           << "DATAPOINTER=" << (uintptr_t)(image->GetBufferPointer()+(dif[0]+image->GetBufferedRegion().GetSize()[0]*dif[1])*nBands) << ","
           << "PIXELS=" << region.GetSize()[0] << ","
           << "LINES=" << region.GetSize()[1] << ","
           << "BANDS=" << nBands << ","
           << "DATATYPE=" << GDALGetDataTypeName(otb::GdalDataTypeBridge::GetGDALDataType<typename TImage::InternalPixelType>()) << ","
           << "PIXELOFFSET=" << sizeof(typename TImage::InternalPixelType) * nBands << ","
           << "LINEOFFSET=" << sizeof(typename TImage::InternalPixelType) * nBands * region.GetSize()[0] << ","
           << "BANDOFFSET=" << sizeof(typename TImage::InternalPixelType);

    GDALDatasetUniquePtr memRasterDataset;
    memRasterDataset = GDALDatasetUniquePtr(GDALDataset::FromHandle(GDALOpen(stream.str().c_str(), GA_Update )));

    //projection
    memRasterDataset->SetProjection(image->GetProjectionRef().c_str());

    //geoTransform
    itk::VariableLengthVector<double> geoTransform(6);
    geoTransform.Fill(0); //rotation parameters ignored
    geoTransform[0] = origin[0] + originIdx[0]*spacing[0];
    geoTransform[3] = origin[1] + originIdx[1]*spacing[1];
    geoTransform[1] = spacing[0];
    geoTransform[5] = spacing[1];

    memRasterDataset->SetGeoTransform(const_cast<double*>(geoTransform.GetDataPointer()));

    return std::move(memRasterDataset);
}

template <class TInputImage>
OGREnvelope alignAOIToImage(OGREnvelope &envlp, typename TInputImage::Pointer inputImage){
    //aligning aoi to image
    OGREnvelope aoi = envlp;

    point2d upperLeft, lowerRight;
    typename TInputImage::IndexType upperLeftIdx, lowerRightIdx;
    upperLeft[0]    = aoi.MinX;
    upperLeft[1]    = aoi.MaxY;

    lowerRight[0]   = aoi.MaxX;
    lowerRight[1]   = aoi.MinY;

    //anchoring to indexes
    //TInputImagePointer inputImage = this->GetReferenceImage();

    inputImage->TransformPhysicalPointToIndex(upperLeft, upperLeftIdx);
    inputImage->TransformPhysicalPointToIndex(lowerRight, lowerRightIdx);

    //getting centroid coordinates
    inputImage->TransformIndexToPhysicalPoint(upperLeftIdx, upperLeft);
    inputImage->TransformIndexToPhysicalPoint(lowerRightIdx, lowerRight);

    typename TInputImage::SpacingType spacing;
    spacing     = inputImage->GetSignedSpacing();

    aoi.MinX    = upperLeft[0] - spacing[0]/2;
    aoi.MaxY    = upperLeft[1] + abs(spacing[1]/2);

    aoi.MaxX    = lowerRight[0] + spacing[0]/2;
    aoi.MinY    = lowerRight[1] - abs(spacing[1]/2);

    //get aoi from input image
    OGREnvelope imageEnvelope = regionToEnvelope<TInputImage>(inputImage, inputImage->GetLargestPossibleRegion());

    //when data fall completely outside of product aoi
    if (!aoi.Intersects(imageEnvelope))
        aoi.MinX = aoi.MaxY = aoi.MaxX = aoi.MinY = 0;
    else //intersect two aois to get the common one-> this is the actual aoi
        aoi.Intersect(imageEnvelope);

    return aoi;
}

boost::posix_time::ptime iso8601ToUTCTimestamp(std::string date);

#endif // UTILS_HXX

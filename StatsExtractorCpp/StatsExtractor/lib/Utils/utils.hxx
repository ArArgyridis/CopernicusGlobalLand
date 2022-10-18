#ifndef UTILS_HXX
#define UTILS_HXX

#include <boost/filesystem/path.hpp>
#include <gdal_priv.h>
#include <itkPoint.h>
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

/** Typedefs for labels */
using LabelSet      =  std::vector<std::size_t>;
using LabelSetPtr   = std::shared_ptr<LabelSet>;

/** Double precision Point coordinates */
using point2d = itk::Point<double, 2>;


MetadataDictPtr getMetadata(boost::filesystem::path &dataPath);
OGRPolygon envelopeToGeometry(OGREnvelope& envelope);
long double pixelsToAreaM2Degrees(long double& pixelCount, float pixelSize);
long double pixelsToAreaM2Meters(long double& pixelCount, float pixelSize);


float noScalerFunc(float x, float& scale, float& offset);
std::string rgbToArrayString(RGBVal& array);
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
std::string jsonToString(JSONType& json) {
    rapidjson::StringBuffer buf;
    rapidjson::Writer<rapidjson::StringBuffer> writer(buf);
    json.Accept(writer);
    return  buf.GetString();
}




#endif // UTILS_HXX

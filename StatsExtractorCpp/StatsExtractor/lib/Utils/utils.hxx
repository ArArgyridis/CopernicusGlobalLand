#ifndef UTILS_HXX
#define UTILS_HXX

#include <boost/filesystem/path.hpp>
#include <gdal_priv.h>
#include <memory>
#include <ogr_core.h>
#include <ogr_feature.h>
#include<ogr_geometry.h>
#include <rapidjson/document.h>


using MetadataDict = std::map<std::string, std::string>;
using MetadataDictPtr = std::unique_ptr<MetadataDict>;

/** Typedefs to handle GDAL structures through smart pointers */
using GDALDatasetPtr = std::unique_ptr<GDALDataset, void(*)(GDALDatasetH) > ;
using OGRFeaturePtr = std::unique_ptr<OGRFeature, void(*)( OGRFeature * )>;
using OGRGeometryPtr = std::unique_ptr<OGRGeometry, void(*)( OGRGeometry * )> ;

using OGRSpatialReferencePtr = std::unique_ptr<OGRSpatialReference> ;
using OGRFeatureDefnPtr = std::unique_ptr<OGRFeatureDefn> ;

MetadataDictPtr getNetCDFMetadata(boost::filesystem::path &dataPath);
OGRPolygon envelopeToGeometry(OGREnvelope& envelope);
long double pixelsToAreaM2Degrees(long double pixelCount, float pixelSize);

float noScalerFunc(float x, float& scale, float& offset);
float scalerFunc(float x, float& scale, float& offset);





#endif // UTILS_HXX

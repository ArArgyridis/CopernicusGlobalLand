#include <iostream>
#include <sstream>

#include "utils.hxx"


MetadataDictPtr getNetCDFMetadata(boost::filesystem::path &dataPath) {
    GDALAllRegister();
    GDALDatasetPtr tmpDataset =  GDALDatasetPtr(reinterpret_cast<GDALDataset*>(GDALOpenEx( dataPath.string().c_str(),
                                                                                                                                       GDAL_OF_RASTER, NULL, NULL, NULL )), GDALClose);
    char** meta = tmpDataset->GetMetadata();

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

long double pixelsToAreaM2Degrees(long double pixelCount, float pixelSize) {
    return pixelCount*1.0*pow(pixelSize*M_PI/180.0*6371000, 2);
}

float noScalerFunc(float x, float& scale, float& offset) {
    return x;
}
float scalerFunc(float x, float& scale, float& offset) {
    return x*scale+offset;
}



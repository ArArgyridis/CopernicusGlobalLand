#ifndef VECTORDATA_H
#define VECTORDATA_H

#include <ogr_geometry.h>
#include <otbVectorData.h>

namespace otb {
template <class PrecissionType>
class OGRVectorData: public otb::VectorData<PrecissionType, 2> {
public:
  /** Standard class typedefs */
  using Self                     =    OGRVectorData<PrecissionType>;
  using Superclass        = itk::DataObject;
  using Pointer              = itk::SmartPointer<Self>;
  using ConstPointer    = itk::SmartPointer<const Self>;

    /** Standard macros */
    itkNewMacro(Self);
    itkTypeMacro(VectorData, DataObject);
    itkStaticConstMacro(Dimension, unsigned int, 2);

    OGREnvelope getEnvelope(){
        return envelope;
    }

    int getEPSG() {
        return epsg;
    }
    OGRwkbGeometryType getGeomType() {
        return geomType;
    }

    std::string getIDField(){
        return idField;
    }

    void setIDField(std::string id) {
        this->idField = id;
    }

    void SetEPSG(int epsg) {
        this->epsg = epsg;
    }

    void SetGeomType(OGRwkbGeometryType &geom) {
        this->geomType = geom;
    }

protected:
    OGRVectorData():otb::VectorData<PrecissionType ,2>(), epsg(4326), idField("id"), geomType(wkbPolygon) {};
    ~OGRVectorData() {};
private:
    OGREnvelope envelope;
    int epsg;
    std::string idField;
    OGRwkbGeometryType geomType;
};
};



#endif // VECTORDATA_H

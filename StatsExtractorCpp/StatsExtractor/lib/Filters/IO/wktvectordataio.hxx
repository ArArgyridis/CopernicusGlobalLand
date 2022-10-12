#ifndef WKTVECTORDATAIO_HXX
#define WKTVECTORDATAIO_HXX
#include <float.h>
#include <otbOGRIOHelper.h>
#include <otbOGRVectorDataIO.h>
#include <otbVectorData.h>
#include <vector>

#include "../../Utils/utils.hxx"

namespace otb {
class WKTVectorDataIO : public OGRVectorDataIO {
public:
    /** Standard class typedefs. */
    typedef WKTVectorDataIO               Self;
    typedef VectorDataIOBase              Superclass;
    typedef itk::SmartPointer<Self>       Pointer;
    typedef itk::SmartPointer<const Self> ConstPointer;

    /** Method for creation through the object factory. */
    itkNewMacro(WKTVectorDataIO);

    /** Run-time type information (and related methods). */
    itkTypeMacro(WKTVectorDataIO, OGRVectorDataIO);

    /** Byte order typedef */
    typedef Superclass::ByteOrder ByteOrder;

    /** Data typedef */
    typedef VectorData<double, 2> VectorDataType;
    typedef VectorDataType::DataTreeType           DataTreeType;
    typedef DataTreeType::TreeNodeType             InternalTreeNodeType;
    typedef InternalTreeNodeType::ChildrenListType ChildrenListType;
    typedef DataTreeType::Pointer                  DataTreePointerType;
    typedef DataTreeType::ConstPointer             DataTreeConstPointerType;
    typedef VectorDataType::DataNodeType           DataNodeType;
    typedef DataNodeType::Pointer                  DataNodePointerType;
    typedef DataNodeType::PointType                PointType;
    typedef DataNodeType::LineType                 LineType;
    typedef LineType::VertexListType               VertexListType;
    typedef VertexListType::ConstPointer           VertexListConstPointerType;
    typedef LineType::Pointer                      LinePointerType;
    typedef DataNodeType::PolygonType              PolygonType;
    typedef PolygonType::Pointer                   PolygonPointerType;
    typedef DataNodeType::PolygonListType          PolygonListType;
    typedef PolygonListType::Pointer               PolygonListPointerType;
    typedef VectorDataType::Pointer                VectorDataPointerType;
    typedef VectorDataType::ConstPointer           VectorDataConstPointerType;
    typedef Superclass::SpacingType                SpacingType;
    typedef Superclass::PointType                  OriginType;

    void AppendData(std::string wkt, size_t i);
    void AppendData(std::vector<std::pair<std::string, std::size_t>>& wktVector);
    bool CanReadFile(const char*) const override;
    LabelSetPtr GetLabels();
    OGREnvelope GetOutEnevelope();
    void Read(itk::DataObject* datag) override;
    void SetGeometryMetaData(int epsg=4326, OGRwkbGeometryType type=wkbMultiPolygon, std::string idField="id");

protected:
    WKTVectorDataIO();

private:

    std::vector<std::pair<std::string, size_t>> wktGeoms;
    int epsg;
    std::string idField;
    OGRwkbGeometryType geomType;
    OGREnvelope outEnvelope, maxEnvelope;
    OGRPolygon maxEnvelopePoly;
    LabelSetPtr validPolyIds;
};
}
#endif // WKTVECTORDATAIO_HXX

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
    typedef std::set<std::size_t>                                 LabelSet;
    typedef std::shared_ptr<std::set<std::size_t>> LabelSetPtr;

    template <class TInputImage>
    typename TInputImage::SizeType AllignToImage(itk::DataObject* datag, typename TInputImage::Pointer inputImage) {
        VectorDataPointerType data = dynamic_cast<VectorDataType*>(datag);
        typename TInputImage::SpacingType spacing = inputImage->GetSignedSpacing();

        itk::Point<double, 2> originPnt;
        originPnt[0] = outEnvelope.MinX;
        originPnt[1] = outEnvelope.MaxY;

        typename TInputImage::IndexType originIdx;

        //anchoring origin to the closet grid edge
        inputImage->TransformPhysicalPointToIndex(originPnt, originIdx);
        inputImage->TransformIndexToPhysicalPoint(originIdx, originPnt);
        data->SetOrigin(originPnt);
        data->SetSpacing(inputImage->GetSignedSpacing());


        typename TInputImage::SizeType outSize;
        outSize[0] = (outEnvelope.MaxX-outEnvelope.MinX)/spacing[0]+1;
        outSize[1] = (outEnvelope.MaxY-outEnvelope.MinY)/abs(spacing[1])+1;

        //cropping to image region extents
        typename TInputImage::RegionType outRegion;
        outRegion.SetIndex(originIdx);
        outRegion.SetSize(outSize);
        outRegion.Crop(inputImage->GetLargestPossibleRegion());

        if (!inputImage->GetLargestPossibleRegion().IsInside(outRegion)) {
            outSize[0] = 0;
            outSize[1] = 0;
        }
        else
            outSize = outRegion.GetSize();

       return outSize;
    }

    void AppendData(std::string wkt, size_t i);
    void AppendData(std::vector<std::pair<std::string, std::size_t>>& wktVector);
    bool CanReadFile(const char*) const override;
    LabelSetPtr GetLabels();
    void Read(itk::DataObject* datag) override;
    void SetGeometryMetaData(int epsg=4326, OGRwkbGeometryType type=wkbMultiPolygon, std::string idField="id");

    template <class TInputImage>
    void SetExtentsFromImage(typename TInputImage::Pointer inputImage) {

        typename TInputImage::RegionType::IndexType upperLeftIdx, lowerRightIdx;
        upperLeftIdx.Fill(0);
        lowerRightIdx = inputImage->GetLargestPossibleRegion().GetUpperIndex();
        itk::Point<double, 2> upperLeft, lowerRight;
        inputImage->TransformIndexToPhysicalPoint(upperLeftIdx, upperLeft);
        inputImage->TransformIndexToPhysicalPoint(lowerRightIdx, lowerRight);

        maxEnvelope.MinX = upperLeft[0];
        maxEnvelope.MinY = lowerRight[1];
        maxEnvelope.MaxX = lowerRight[0];
        maxEnvelope.MaxY = upperLeft[1];

        //updating max envelope geometry
        maxEnvelopePoly = envelopeToGeometry(maxEnvelope);
    }

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

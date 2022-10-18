#ifndef VECTORWKTTOLABELIMAGEFILTER_H
#define VECTORWKTTOLABELIMAGEFILTER_H

#include <gdal.h>
#include <itkImageSource.h>
#include <ogr_geometry.h>
#include <otbMacro.h>

#include "../../Utils/utils.hxx"

namespace otb {
template <class TOutputImage>
class VectorWktToLabelImageFilter : public itk::ImageSource<TOutputImage> {
public:
    using Self          = VectorWktToLabelImageFilter;
    using Superclass    = itk::ImageSource<TOutputImage>;
    using Pointer       = itk::SmartPointer<Self>;
    using ConstPointer  = itk::SmartPointer<const Self> ;


    /** Output Image types. */
      using OutputImagePointer              = typename TOutputImage::Pointer;
      using OutputSizeType                  = typename TOutputImage::SizeType;
      using OutputIndexType                 = typename TOutputImage::IndexType;
      using OutputSpacingType               = typename TOutputImage::SpacingType;
      using OutputOriginType                = typename TOutputImage::PointType;
      using OutputImageRegionType           = typename TOutputImage::RegionType;
      using OutputImagePixelType            = typename  TOutputImage::PixelType;
      using OutputImageInternalPixelType    = typename TOutputImage::InternalPixelType;

    /** Macros to create set/get methods for some parameters*/
    itkGetConstReferenceMacro(OutputOrigin, OutputOriginType);

    itkSetMacro(AllTouchedMode, bool);
    itkSetMacro(BackgroundValue, OutputImageInternalPixelType);
    itkSetMacro(OutputOrigin, OutputOriginType);
    itkSetMacro(OutputProjectionRef, std::string);
    itkSetMacro(OutputRegion, OutputImageRegionType);
    itkSetMacro(OutputSignedSpacing, OutputSpacingType);



    /** Run-time type information (and related methods). */
    itkTypeMacro(VectorWktToLabelImageFilter, itk::ImageSource);

    /** Method for creation through the object factory. */
    itkNewMacro(Self);

    /** Method to add single wkt geometry with it's respective id*/
    void AppendData(std::string wkt, size_t i);

    /** Getting valid features **/
    size_t GetFeatureCount();

    /** Method to set layer metadata*/
    void SetGeometryMetaData(int epsg=4326, OGRwkbGeometryType type=wkbMultiPolygon, std::string idField="id");

protected:

    virtual void GenerateData();
    virtual void GenerateOutputInformation(void) override;
    VectorWktToLabelImageFilter();
    virtual ~VectorWktToLabelImageFilter();

private:
    bool                            m_AllTouchedMode;
    OutputImageInternalPixelType    m_BackgroundValue;
    std::vector<int>                m_BandsToBurn;
    std::string                     m_OutputProjectionRef;
    OutputSpacingType               m_OutputSignedSpacing{0.0};
    OutputOriginType                m_OutputOrigin{0.0};
    OutputSizeType                  m_OutputSize{0,0};
    OutputImageRegionType           m_OutputRegion;
    OutputIndexType                 m_OutputStartIndex;
    size_t                          epsg;
    std::string                     idField;
    std::vector<double>             burnValues;
    OGRwkbGeometryType              geomType;
    OGREnvelope                     outEnvelope, maxEnvelope;
    OGRPolygon                      maxEnvelopePoly;
    LabelSetPtr                     validPolyIds;
    OGRSpatialReferencePtr          srs;
    std::vector<OGRGeometryH>       burnGeoms;

    std::mutex  mtx;

};
}
#endif // VECTORWKTTOLABELIMAGEFILTER_H

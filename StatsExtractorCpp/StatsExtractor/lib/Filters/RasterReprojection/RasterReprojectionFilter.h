#ifndef RASTERREPROJECTFILTER_H
#define RASTERREPROJECTFILTER_H

#include <gdalwarper.h>
#include <itkImageToImageFilter.h>
#include <itkImageRegionConstIterator.h>
#include <itkImageRegionIterator.h>
#include <ogr_spatialref.h>
#include <mutex>

namespace otb {


template <class TInputImage>
class RasterReprojectionFilter:public itk::ImageToImageFilter<TInputImage, TInputImage> {
public:
    /** Standard typedefs */
    using Self          = RasterReprojectionFilter;
    using Superclass    = itk::ImageToImageFilter<TInputImage, TInputImage>;
    using Pointer       = itk::SmartPointer<Self>;
    using ConstPointer  = itk::SmartPointer<const Self>;

    using InputImageConstIterator  = itk::ImageRegionConstIterator<TInputImage>;
    using OutputIterator            = itk::ImageRegionIterator<TInputImage>;
    using TInputImagePointer        = typename TInputImage::Pointer;
    using InputRegionType           = typename TInputImage::RegionType;
    using OutputRegionType          = typename Superclass::OutputImageRegionType;
    using OGRTransform              = std::unique_ptr<OGRCoordinateTransformation, void(*)(OGRCoordinateTransformation*)>;
    using GDALWarpOptionsPtr        = std::unique_ptr<GDALWarpOptions, void(*)(GDALWarpOptions*)>;
    using PointType2f               = itk::Point<double, 2>;

    /** Type macro */
    itkNewMacro(Self);

    /** Creation through object factory macro */
    itkTypeMacro(TInputImage, itk::ImageToImageFilter);

    void SetExtent(double minX, double minY, double maxX, double maxY);
    void SetInputProjection(size_t epsg);
    void SetOutputProjection(size_t epsg);
    void SetOutputSpacing(typename TInputImage::SpacingType spacing);

protected:
    RasterReprojectionFilter();
    ~RasterReprojectionFilter(){};

    void GenerateInputRequestedRegion() override;
    void GenerateOutputInformation() override;

    virtual void ThreadedGenerateData(const OutputRegionType& outputRegionForThread, itk::ThreadIdType threadId) override;

    /** overiding to avoid bound checking **/
    virtual void VerifyInputInformation() override{}



private:
    size_t inEPSG, dstEPSG;

    std::vector<bool>   noDataFlags;
    std::vector<double> noDataValues;
    OGRTransform directTransform, inverseTransform;
    OGRSpatialReference inSRS, dstSRS;
    std::mutex mtx;
    OGREnvelope dstEnvelope;
    typename TInputImage::SpacingType dstSpacing;

    InputRegionType computeInputRegionFromOutput(const OutputRegionType& outputRegion);

};
}

#ifndef OTB_MANUAL_INSTANTIATION
#include "RasterReprojectionFilter.hxx"
#endif


#endif // RASTERREPROJECTFILTER_H



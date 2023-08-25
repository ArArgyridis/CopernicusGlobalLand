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
    using OGRTransform              = std::unique_ptr<OGRCoordinateTransformation, void(*)(OGRCoordinateTransformation*)>;
    using GDALWarpOptionsPtr        = std::unique_ptr<GDALWarpOptions, void(*)(GDALWarpOptions*)>;
    using PointType2f               = itk::Point<double, 2>;

    /** Type macro */
    itkNewMacro(Self);

    /** Creation through object factory macro */
    itkTypeMacro(TInputImage, itk::ImageToImageFilter);


    void SetInputProjection(size_t epsg);
    void SetOutputProjection(size_t epsg);

protected:
    RasterReprojectionFilter();
    ~RasterReprojectionFilter(){};

    void BeforeThreadedGenerateData() override;

    void GenerateInputRequestedRegion() override;
    void GenerateOutputInformation() override;

    virtual void ThreadedGenerateData(const typename Superclass::OutputImageRegionType& outputRegionForThread, itk::ThreadIdType threadId) override{};

    /** overiding to avoid bound checking **/
    virtual void VerifyInputInformation() override{}



private:
    size_t inEPSG, dstEPSG;

    std::vector<bool>   noDataFlags;
    std::vector<double> noDataValues;
    OGRTransform directTransform, inverseTransform;
    OGRSpatialReference inSRS, dstSRS;
    std::mutex mtx;
    typename TInputImage::PixelType nullPxl;

};





}
#endif // RASTERREPROJECTFILTER_H



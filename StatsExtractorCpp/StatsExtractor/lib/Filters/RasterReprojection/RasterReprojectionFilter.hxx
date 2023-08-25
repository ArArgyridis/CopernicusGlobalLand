#ifndef RASTERREPROJECTIONFILTER_HXX
#define RASTERREPROJECTIONFILTER_HXX

#include <otbNoDataHelper.h>
#include <otbGeometriesProjectionFilter.h>
#include <otbGeometriesSet.h>

#include "RasterReprojectionFilter.h"
#include "../../Utils/Utils.hxx"

namespace otb {

template <class TInputImage>
RasterReprojectionFilter<TInputImage>::RasterReprojectionFilter():inEPSG(0),dstEPSG(0),
    directTransform(nullptr, &OGRCoordinateTransformation::DestroyCT),
    inverseTransform(nullptr, &OGRCoordinateTransformation::DestroyCT) {

    this->SetNumberOfRequiredInputs(1);
    this->SetNumberOfRequiredOutputs(1);
    inSRS.SetAxisMappingStrategy(OAMS_TRADITIONAL_GIS_ORDER);
    dstSRS.SetAxisMappingStrategy(OAMS_TRADITIONAL_GIS_ORDER);
}

template <class TInputImage>
void RasterReprojectionFilter<TInputImage>::BeforeThreadedGenerateData() {
    //this->GetOutput()->FillBuffer(nullPxl);

    auto inMemDt    = createGDALMemoryDatasetFromOTBImageRegion<TInputImage>(const_cast<TInputImage*>(this->GetInput()));
    auto outMemDt   = createGDALMemoryDatasetFromOTBImageRegion<TInputImage>(const_cast<TInputImage*>(this->GetOutput()));

    size_t nBands = this->GetInput()->GetNumberOfComponentsPerPixel();

    // Setup warp options.
    GDALWarpOptionsPtr warpOptions(GDALCreateWarpOptions(),&GDALDestroyWarpOptions);

    warpOptions->hSrcDS = inMemDt.get();
    warpOptions->hDstDS = outMemDt.get();
    warpOptions->nBandCount = nBands;
    warpOptions->panSrcBands =(int *)CPLMalloc(sizeof(int) * warpOptions->nBandCount);
    warpOptions->panDstBands =(int *)CPLMalloc(sizeof(int) * warpOptions->nBandCount);
    for (size_t i = 0; i < nBands; ++i) {
        warpOptions->panSrcBands[i] = i + 1;  // Assuming band indices start from 1
        warpOptions->panDstBands[i] = i + 1;
    }


    warpOptions->pfnProgress = GDALTermProgress;
    warpOptions->pTransformerArg =
        GDALCreateGenImgProjTransformer(warpOptions->hSrcDS,
                                        GDALGetProjectionRef(warpOptions->hSrcDS),
                                        warpOptions->hDstDS,
                                        GDALGetProjectionRef(warpOptions->hDstDS),
                                        FALSE, 0.0, 1 );
    warpOptions->pfnTransformer = GDALGenImgProjTransform;

    // Initialize warp operation and perform warp
    GDALWarpOperation oWarper;
    oWarper.Initialize(warpOptions.get());
    oWarper.ChunkAndWarpImage(0, 0, outMemDt->GetRasterXSize(), outMemDt->GetRasterYSize());

}


template <class TInputImage>
void RasterReprojectionFilter<TInputImage>::GenerateInputRequestedRegion() {
    Superclass::GenerateInputRequestedRegion();
    typename TInputImage::Pointer output    = this->GetOutput();
    auto input = const_cast<TInputImage*>(this->GetInput());

    InputRegionType requestedOutputRegion = output->GetRequestedRegion();

    typename TInputImage::IndexType startIndex = requestedOutputRegion.GetIndex();
    typename InputRegionType::SizeType size = requestedOutputRegion.GetSize();

    OGRGeometryCollection inImgBoundary;
    std::vector<OGRPoint> inCorners(4);
    for (size_t i = 0; i < 2; i++)
        for (size_t j = 0; j < 2; j++) {
            typename TInputImage::IndexType idx;
            idx[0] = startIndex[0] + i*size[0];
            idx[1] = startIndex[1] + j*size[1];

            PointType2f tmpPnt;
            output->TransformIndexToPhysicalPoint(idx, tmpPnt);

            OGRPoint dstPnt(tmpPnt[0], tmpPnt[1]);
            dstPnt.transform(inverseTransform.get());
            tmpPnt[0] = dstPnt.getX();
            tmpPnt[1] = dstPnt.getY();

            input->TransformPhysicalPointToIndex(tmpPnt, idx);

            OGRPoint ogrIdx(idx[0], idx[1]);
            inImgBoundary.addGeometry(&ogrIdx);
        }
    OGREnvelope inEnvelope;
    inImgBoundary.getEnvelope(&inEnvelope);

    typename TInputImage::IndexType inIdx;
    inIdx[0] = inEnvelope.MinX;
    inIdx[1] = inEnvelope.MinY;

    typename InputRegionType::SizeType inSize;
    inSize[0] = static_cast<size_t>(inEnvelope.MaxX - inEnvelope.MinX);
    inSize[1] = static_cast<size_t>(inEnvelope.MaxY - inEnvelope.MinY);

    InputRegionType inImgRegion;
    inImgRegion.SetIndex(inIdx);
    inImgRegion.SetSize(inSize);
    input->SetRequestedRegion(inImgRegion);
}

template <class TInputImage>
void RasterReprojectionFilter<TInputImage>::GenerateOutputInformation(){
    Superclass::GenerateOutputInformation();

    typename TInputImage::Pointer output = this->GetOutput();
    auto input = const_cast<TInputImage*>(this->GetInput());


    //writing metadata
    ReadNoDataFlags(input->GetImageMetadata(), noDataFlags, noDataValues);
    WriteNoDataFlags(noDataFlags, noDataValues, output->GetImageMetadata());

    //setting no data pixel
    nullPxl.SetSize(this->GetInput()->GetNumberOfComponentsPerPixel());
    for(size_t i = 0; i < noDataValues.size(); i++)
        nullPxl[i] = static_cast<typename TInputImage::PixelType::ValueType>(noDataValues[i]);


    //getting input epsg if it is not set
    if(inEPSG == 0) {
        inSRS.importFromWkt(input->GetProjectionRef().c_str());
        inEPSG  = inSRS.GetEPSGGeogCS();
    }
    else {
        //enforce the specified EPSG
        char* wkt = nullptr;
        inSRS.exportToWkt(&wkt);
        std::string tmpRef2(wkt);
        input->SetProjectionRef(tmpRef2);
        CPLFree(wkt);
    }

    typename InputRegionType::SizeType size = input->GetLargestPossibleRegion().GetSize();

    directTransform     = OGRTransform(OGRCreateCoordinateTransformation(&inSRS, &dstSRS), &OGRCoordinateTransformation::DestroyCT);
    inverseTransform    = OGRTransform(OGRCreateCoordinateTransformation(&dstSRS, &inSRS), &OGRCoordinateTransformation::DestroyCT);

    OGRGeometryCollection dstImgBoundary;
    std::vector<OGRPoint> dstCorners(4);

    //valid CRS bounds
    OGREnvelope wgs84ValidEnvelope;
    dstSRS.GetAreaOfUse(&wgs84ValidEnvelope.MinX, &wgs84ValidEnvelope.MinY, &wgs84ValidEnvelope.MaxX, &wgs84ValidEnvelope.MaxY, nullptr);
    OGRSpatialReference wgs84;
    wgs84.importFromEPSG(4326);
    wgs84.SetAxisMappingStrategy(OAMS_TRADITIONAL_GIS_ORDER);

    OGRTransform wgs84Transform = OGRTransform(OGRCreateCoordinateTransformation(&inSRS, &wgs84), &OGRCoordinateTransformation::DestroyCT);
    //product bounds are cropped to the maximum extent of the destination crs
    for (size_t i = 0; i < 2; i++)
        for (size_t j = 0; j < 2; j++) {
            typename TInputImage::IndexType idx;
            idx[0] = i*size[0];
            idx[1] = j*size[1];

            PointType2f tmpPnt;
            input->TransformIndexToPhysicalPoint(idx, tmpPnt);

            OGRPoint wgs84Pnt(tmpPnt[0], tmpPnt[1]);
            wgs84Pnt.transform(wgs84Transform.get());

            wgs84Pnt.setX(fmin(fmax(wgs84Pnt.getX(), wgs84ValidEnvelope.MinX),wgs84ValidEnvelope.MaxX));
            wgs84Pnt.setY(fmin(fmax(wgs84Pnt.getY(), wgs84ValidEnvelope.MinY),wgs84ValidEnvelope.MaxY));

            dstCorners[2*i+j] = wgs84Pnt;
            dstCorners[2*i+j].transform(directTransform.get());
            dstImgBoundary.addGeometry(&dstCorners[2*i+j]);
        }

    OGREnvelope dstEnvelope;
    dstImgBoundary.getEnvelope(&dstEnvelope);

    //setting output spacing
    typename TInputImage::SpacingType dstSpacing;
    dstSpacing[0] = (dstCorners[2].getX()-dstCorners[0].getX())/size[0];
    dstSpacing[1] = (dstCorners[1].getY()-dstCorners[0].getY())/size[1];

    //output origin
    PointType2f dstOrigin;
    dstOrigin[0] = dstEnvelope.MinX;
    dstOrigin[1] = dstEnvelope.MaxY;

    //computing output size
    typename InputRegionType::SizeType dstSize;
    dstSize[0] = static_cast<size_t>((dstEnvelope.MaxX - dstEnvelope.MinX)/dstSpacing[0]);
    dstSize[1] = static_cast<size_t>((dstEnvelope.MinY - dstEnvelope.MaxY)/dstSpacing[1]);

    //setting output region
    InputRegionType region;
    typename InputRegionType::IndexType idx;
    idx.Fill(0);
    region.SetIndex(idx);
    region.SetSize(dstSize);
    output->SetLargestPossibleRegion(region);
    output->SetOrigin(dstOrigin);
    output->SetSignedSpacing(dstSpacing);
    output->SetNumberOfComponentsPerPixel(input->GetNumberOfComponentsPerPixel());

    //std::unique_ptr<char, void(*)(void*)> wkt2(nullptr, &CPLFree);
    //setting the output projection system
    char* wkt = nullptr;
    dstSRS.exportToWkt(&wkt);
    std::string tmpRef(wkt);
    output->SetProjectionRef(tmpRef);
    CPLFree(wkt);

}


template <class TInputImage>
void RasterReprojectionFilter<TInputImage>::SetInputProjection(size_t epsg) {
    inEPSG = epsg;
    inSRS.importFromEPSG(epsg);
}

template <class TInputImage>
void RasterReprojectionFilter<TInputImage>::SetOutputProjection(size_t epsg) {
    dstEPSG = epsg;
    dstSRS.importFromEPSG(epsg);
}

}


#endif // RASTERREPROJECTIONFILTER_HXX

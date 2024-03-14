/*
   Copyright (C) 2024  Argyros Argyridis arargyridis at gmail dot com
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef RASTERREPROJECTIONFILTER_HXX
#define RASTERREPROJECTIONFILTER_HXX

#include <limits>
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

    dstEnvelope.MinX = dstEnvelope.MaxX = dstEnvelope.MinY = dstEnvelope.MaxY = std::numeric_limits<double>::max();
    dstSpacing[0] = dstSpacing[1] = std::numeric_limits<float>::max();
}

template <class TInputImage>
void RasterReprojectionFilter<TInputImage>::ThreadedGenerateData(const OutputRegionType &outputRegionForThread, itk::ThreadIdType threadId) {
    auto inRegionForThread = computeInputRegionFromOutput(outputRegionForThread);
    auto inMemDt    = createGDALMemoryDatasetFromOTBImageRegion<TInputImage>(const_cast<TInputImage*>(this->GetInput()), inRegionForThread);
    auto outMemDt   = createGDALMemoryDatasetFromOTBImageRegion<TInputImage>(const_cast<TInputImage*>(this->GetOutput()), outputRegionForThread);

    // Setup warp options.
    GDALWarpOptionsPtr warpOptions(GDALCreateWarpOptions(),&GDALDestroyWarpOptions);

    warpOptions->papszWarpOptions = nullptr;
    warpOptions->papszWarpOptions = CSLSetNameValue(warpOptions->papszWarpOptions, "NUM_THREADS", "ALL_CPUS");

    warpOptions->hSrcDS = inMemDt.get();
    warpOptions->hDstDS = outMemDt.get();
    warpOptions->nBandCount = this->GetInput()->GetNumberOfComponentsPerPixel();
    warpOptions->panSrcBands =(int *)CPLMalloc(sizeof(int) * warpOptions->nBandCount);
    warpOptions->panDstBands =(int *)CPLMalloc(sizeof(int) * warpOptions->nBandCount);
    for (size_t i = 0; i < warpOptions->nBandCount; ++i) {
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
    auto input = const_cast<TInputImage*>(this->GetInput());
    input->SetRequestedRegion(computeInputRegionFromOutput(this->GetOutput()->GetRequestedRegion()));
}

template <class TInputImage>
void RasterReprojectionFilter<TInputImage>::GenerateOutputInformation(){
    Superclass::GenerateOutputInformation();

    typename TInputImage::Pointer output = this->GetOutput();
    auto input = const_cast<TInputImage*>(this->GetInput());


    //writing metadata
    ReadNoDataFlags(input->GetImageMetadata(), noDataFlags, noDataValues);
    WriteNoDataFlags(noDataFlags, noDataValues, output->GetImageMetadata());

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

    //if a bounding box is not spacified, then the dataset should be cropped to the maximum possible extent of the provided CRS
    if (dstEnvelope.MinX == std::numeric_limits<double>::max() && dstEnvelope.MinX == dstEnvelope.MaxX) {
        //valid CRS bounds
        OGREnvelope wgs84ValidEnvelope;
        dstSRS.GetAreaOfUse(&wgs84ValidEnvelope.MinX, &wgs84ValidEnvelope.MinY, &wgs84ValidEnvelope.MaxX, &wgs84ValidEnvelope.MaxY, nullptr);
        OGRSpatialReference wgs84;
        wgs84.importFromEPSG(4326);
        wgs84.SetAxisMappingStrategy(OAMS_TRADITIONAL_GIS_ORDER);

        OGRTransform wgs84Transform = OGRTransform(OGRCreateCoordinateTransformation(&inSRS, &wgs84), &OGRCoordinateTransformation::DestroyCT);
        OGRTransform wgsToDstTransform = OGRTransform(OGRCreateCoordinateTransformation(&wgs84, &dstSRS), &OGRCoordinateTransformation::DestroyCT);
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
                dstCorners[2*i+j].transform(wgsToDstTransform.get());
                dstImgBoundary.addGeometry(&dstCorners[2*i+j]);
            }
        dstImgBoundary.getEnvelope(&dstEnvelope);
    }
    //setting output spacing if it is not specified
    if (dstSpacing[0] == std::numeric_limits<float>::max()) { //estimate it
        dstSpacing[0] = (dstEnvelope.MaxX - dstEnvelope.MinX)/size[0];
        dstSpacing[1] = (dstEnvelope.MinY - dstEnvelope.MaxY)/size[1];
    }

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
void RasterReprojectionFilter<TInputImage>::SetExtent(double minX, double minY, double maxX, double maxY){
    dstEnvelope.MinX = minX;
    dstEnvelope.MinY = minY;
    dstEnvelope.MaxX = maxX;
    dstEnvelope.MaxY = maxY;
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

template <class TInputImage>
void RasterReprojectionFilter<TInputImage>::SetOutputSpacing(typename TInputImage::SpacingType spacing) {
    dstSpacing = spacing;
}

template <class TInputImage>
typename RasterReprojectionFilter<TInputImage>::InputRegionType RasterReprojectionFilter<TInputImage>::computeInputRegionFromOutput(const OutputRegionType& requestedOutputRegion) {
    //InputRegionType requestedOutputRegion = output->GetRequestedRegion();

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
            this->GetOutput()->TransformIndexToPhysicalPoint(idx, tmpPnt);

            OGRPoint dstPnt(tmpPnt[0], tmpPnt[1]);
            dstPnt.transform(inverseTransform.get());
            tmpPnt[0] = dstPnt.getX();
            tmpPnt[1] = dstPnt.getY();

            this->GetInput()->TransformPhysicalPointToIndex(tmpPnt, idx);

            OGRPoint ogrIdx(idx[0], idx[1]);
            inImgBoundary.addGeometry(&ogrIdx);
        }
    OGREnvelope inEnvelope;
    inImgBoundary.getEnvelope(&inEnvelope);

    typename TInputImage::IndexType inIdx;
    inIdx[0] = inEnvelope.MinX;
    inIdx[1] = inEnvelope.MinY;

    //working in pixels, so no need to divide with spacing...
    typename InputRegionType::SizeType inSize;
    inSize[0] = static_cast<size_t>((inEnvelope.MaxX - inEnvelope.MinX));
    inSize[1] = static_cast<size_t>((inEnvelope.MaxY - inEnvelope.MinY));

    InputRegionType inImgRegion;
    inImgRegion.SetIndex(inIdx);
    inImgRegion.SetSize(inSize);

    inImgRegion.Crop(this->GetInput()->GetLargestPossibleRegion());
    return inImgRegion;
}

}


#endif // RASTERREPROJECTIONFILTER_HXX

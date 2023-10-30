/**
   Copyright (C) 2021  Argyros Argyridis arargyridis at gmail dot com
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

#include <gdal_alg.h>
#include <otbGdalDataTypeBridge.h>
#include <iomanip>

#include "VectorWktToLabelImageFilter.h"

//public
namespace otb {
template <class TOutputImage>
void VectorWktToLabelImageFilter<TOutputImage>::AppendData(std::string wkt, typename TOutputImage::ValueType id) {

    OGRGeometryH geom;
    if (this->geomType == wkbMultiPolygon)
        geom = new OGRMultiPolygon();
    else if (this->geomType == wkbPolygon)
        geom = new OGRPolygon();

    std::unique_ptr<const char*> tmpGeom = std::make_unique<const char*>(const_cast<char*>(wkt.c_str()));
    reinterpret_cast<OGRGeometry*>(geom)->importFromWkt(tmpGeom.get());
    //skipping geometries if empty or outside maximum envelope
    if (reinterpret_cast<OGRGeometry*>(geom)->IsEmpty()) {
        std::cout << "Polygon with id: " << id <<" is empty. Skipping\n";
        return;
    }

    burnGeoms.push_back(geom);
    burnValues.emplace_back(static_cast<double>(id));
}

template <class TOutputImage>
size_t VectorWktToLabelImageFilter<TOutputImage>::GetFeatureCount() {
    return burnGeoms.size();
}

/** this method should be called before any other!!!!! */
template <class TOutputImage>
void VectorWktToLabelImageFilter<TOutputImage>::SetGeometryMetaData(int epsg, OGRwkbGeometryType type, std::string idField) {
    this->epsg = epsg;
    this->geomType = type;
    this->idField = idField;
}

template <class TOutputImage>
void VectorWktToLabelImageFilter<TOutputImage>::GenerateData() {
    this->AllocateOutputs();
    std::cout << "hereeeeeee\n";

    typename TOutputImage::Pointer out = this->GetOutput();

    // Fill the buffer with the background value
    out->FillBuffer(m_BackgroundValue);

    // Get the buffered region
    OutputImageRegionType bufferedRegion = out->GetBufferedRegion();
    auto idx = bufferedRegion.GetIndex();
    OutputOriginType origin;
    out->TransformIndexToPhysicalPoint(idx, origin);

    std::ostringstream stream;
    size_t nbBands = m_BandsToBurn.size();
    stream << "MEM:::"
           << "DATAPOINTER=" << (uintptr_t)(this->GetOutput()->GetBufferPointer()) << ","
           << "PIXELS=" << bufferedRegion.GetSize()[0] << ","
           << "LINES=" << bufferedRegion.GetSize()[1] << ","
           << "BANDS=" << nbBands << ","
           << "DATATYPE=" << GDALGetDataTypeName(GdalDataTypeBridge::GetGDALDataType<OutputImageInternalPixelType>()) << ","
           << "PIXELOFFSET=" << sizeof(OutputImageInternalPixelType) * nbBands << ","
           << "LINEOFFSET=" << sizeof(OutputImageInternalPixelType) * nbBands * bufferedRegion.GetSize()[0] << ","
           << "BANDOFFSET=" << sizeof(OutputImageInternalPixelType);

    GDALDatasetUniquePtr memRasterDataset;
    memRasterDataset = GDALDatasetUniquePtr(GDALDataset::FromHandle(GDALOpen( stream.str().c_str(), GA_Update )));

    //projection
    memRasterDataset->SetProjection(m_OutputProjectionRef.c_str());

    //geoTransform
    itk::VariableLengthVector<double> geoTransform(6);
    geoTransform.Fill(0); //rotation parameters ignored
    geoTransform[0] = m_OutputOrigin[0] - 0.5*m_OutputSignedSpacing[0];
    geoTransform[3] = m_OutputOrigin[1] - 0.5*m_OutputSignedSpacing[1];
    geoTransform[1] = m_OutputSignedSpacing[0];
    geoTransform[5] = m_OutputSignedSpacing[1];

    memRasterDataset->SetGeoTransform(const_cast<double*>(geoTransform.GetDataPointer()));

    char** options = nullptr;
    if (m_AllTouchedMode)
        options = CSLSetNameValue(options, "ALL_TOUCHED", "TRUE");

    GDALRasterizeGeometries(memRasterDataset.get(), m_BandsToBurn.size(), &(m_BandsToBurn[0]), burnGeoms.size(), &(burnGeoms[0]), nullptr, nullptr,
                                &(burnValues[0]), options, GDALDummyProgress, nullptr);

    CSLDestroy(options);

}

template <class TOutputImage>
void VectorWktToLabelImageFilter<TOutputImage>::GenerateOutputInformation() {
    Superclass::GenerateOutputInformation();
    typename TOutputImage::Pointer out = this->GetOutput();
    OutputImageRegionType region = m_OutputRegion;
    typename TOutputImage::IndexType idx;
    idx.Fill(0);
    region.SetIndex(idx);

    out->SetLargestPossibleRegion(region);
    out->SetSignedSpacing(m_OutputSignedSpacing);
    out->SetProjectionRef(m_OutputProjectionRef);
    out->SetOrigin(m_OutputOrigin);
}


template <class TOutputImage>
VectorWktToLabelImageFilter<TOutputImage>::VectorWktToLabelImageFilter():m_AllTouchedMode(true), m_BackgroundValue(0),m_BandsToBurn(1, 1), epsg(4326), idField("id"), geomType(wkbPolygon) {}

template <class TOutputImage>
VectorWktToLabelImageFilter<TOutputImage>::~VectorWktToLabelImageFilter() {
    //close geometries
    for (auto& geom: burnGeoms)
        OGRFeature::DestroyFeature(reinterpret_cast<OGRFeature*>(geom));
}



}

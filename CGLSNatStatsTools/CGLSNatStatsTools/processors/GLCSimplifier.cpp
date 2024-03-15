#include <algorithm>
#include <cmath>
#include <filesystem>
#include <fmt/format.h>
#include <iostream>
#include <memory>
#include <ogrsf_frmts.h>
#include <omp.h>
#include <stdio.h>
#include <mutex>

using OGRFeaturePtr = std::unique_ptr<OGRFeature, void(*)(OGRFeature*)>;


int main(int argc, char* argv[]) {
    GDALAllRegister();

    std::string dataPath = "/home/argyros/Projects/JRC/Land Cover 2019/to_merge/global_land_cover_2019_subset.gdb";
    std::string dataPathBK = "/home/argyros/Projects/JRC/Land Cover 2019/to_merge/global_land_cover_2019_subset_bk.gdb";

    std::filesystem::remove_all(dataPath);
    std::filesystem::copy(dataPathBK, dataPath);

    double smallestArea = 5*pow(0.0009920634920634887558,2);

    GDALDatasetUniquePtr tmpDataset =  GDALDatasetUniquePtr(GDALDataset::FromHandle(GDALOpenEx( dataPath.c_str(), GDAL_OF_VECTOR| GDAL_OF_UPDATE, nullptr, nullptr, nullptr)));
    GIntBig ftId, nFeatures = tmpDataset->GetLayer(0)->GetFeatureCount();
    size_t nThreads = omp_get_max_threads();

    std::vector<std::vector<GIntBig>>tmpRetainFeatures(omp_get_max_threads());
    std::vector<GIntBig>retainFeatures;

#pragma omp parallel num_threads(nThreads)
    {
        int tid = omp_get_thread_num();
        GDALDatasetUniquePtr dataset =  GDALDatasetUniquePtr(GDALDataset::FromHandle(GDALOpenEx( dataPath.c_str(), GDAL_OF_VECTOR | GDAL_OF_UPDATE, nullptr, nullptr, nullptr)));
        auto layer = dataset->GetLayer(0);
#pragma omp for private(ftId)
        for (ftId = 1; ftId < nFeatures+1; ftId++) {
            auto ft = OGRFeaturePtr(layer->GetFeature(ftId), &OGRFeature::DestroyFeature);
            /*
            if (ft == nullptr) {
                printf("null feature detected in: %d\t (%d)\n", tid, ftId);
                continue;
            }
            */

            OGRMultiPolygon *poly = reinterpret_cast<OGRMultiPolygon*>(ft.get()->GetGeometryRef());
            /*
            if (poly == nullptr) {
                printf("null geometry detected in: %d\t (%d)\n", tid, ftId);
                continue;
            }
            */
            double area = poly->get_Area();
            ft.get()->SetField("area", area);
            layer->SetFeature(ft.get());
            if (area > smallestArea)
                tmpRetainFeatures[tid].emplace_back(ftId);
        }
    }
    size_t i = 0;
    for (auto& set: tmpRetainFeatures) {
        i += set.size();
        retainFeatures.insert(retainFeatures.end(), std::make_move_iterator(set.begin()), std::make_move_iterator(set.end()));
    }
    std::cout << retainFeatures.size() << "\n";
    std::sort(retainFeatures.begin(), retainFeatures.end());
    std::string filter = fmt::format("area <= {0}", smallestArea);

//#pragma omp parallel num_threads(nThreads)
    {
        int tid = omp_get_thread_num();
        GDALDatasetUniquePtr dataset =  GDALDatasetUniquePtr(GDALDataset::FromHandle(GDALOpenEx( dataPath.c_str(), GDAL_OF_VECTOR | GDAL_OF_UPDATE, nullptr, nullptr, nullptr)));
        auto layer = dataset->GetLayer(0);
        size_t rtFeaturesCount = retainFeatures.size();
//#pragma omp for private(ftId)
        for (ftId = 0; ftId < rtFeaturesCount; ftId++) {
            auto rtFtId = retainFeatures[ftId];
            std::cout << "Processing: " << rtFtId << "\n";
            auto rtFt = OGRFeaturePtr(layer->GetFeature(rtFtId)->Clone(), &OGRFeature::DestroyFeature);
            auto rtGeomMulti = static_cast<OGRMultiPolygon*>(rtFt->GetGeometryRef()->clone());

            bool create = false;
            size_t processed = 0;
            for(int rtGeomId = 0; rtGeomId < rtGeomMulti->getNumGeometries(); rtGeomId++ ) {
                OGRPolygon* rtGeom = static_cast<OGRPolygon*>(rtGeomMulti->getGeometryRef(rtGeomId)->clone());
                for (int rtGeomRingId = 0; rtGeomRingId < rtGeom->getNumInteriorRings(); ++rtGeomRingId) {

                    OGRPoint rtGeomRingCentroid;
                    auto rtGeomRing = rtGeom->getInteriorRing(rtGeomRingId);
                    OGRPolygon rtGeomRingPoly;
                    rtGeomRingPoly.addRing(rtGeomRing);

                    rtGeomRingPoly.Centroid(&rtGeomRingCentroid);
                    layer->ResetReading();
                    layer->SetSpatialFilter(&rtGeomRingCentroid);
                    layer->SetAttributeFilter(filter.c_str());

                    bool stop = false;
                    for(auto candidate = OGRFeaturePtr(layer->GetNextFeature(), &OGRFeature::DestroyFeature); !stop && candidate.get() != nullptr; candidate = OGRFeaturePtr(layer->GetNextFeature(), &OGRFeature::DestroyFeature)) {
                        if(rtGeomRingPoly.Contains(candidate->GetGeometryRef()) && candidate->GetGeometryRef()->Contains(&rtGeomRingPoly)) {
                            create = stop = true;
                            std::cout << rtGeomRingId << "\t:";
                            std::cout << "contained!!!!!\t:";
                            layer->DeleteFeature(candidate->GetFID());
                            rtGeom->removeRing(rtGeomRingId);
                            rtGeomRingId--;
                            std::cout << rtGeomRingId << "\n";
                            rtGeomMulti->removeGeometry(rtGeomId);
                            rtGeomMulti->addGeometry(rtGeom);
                        }
                    }
                }
            }

            if(create) {
                //#pragma omp critical
                {
                    rtFt->SetGeometryDirectly(rtGeomMulti);
                    //delete rtGeomMulti;
                    std::cout << "Refreshing: " << rtFt->GetFID() <<"\n";
                    tmpDataset->GetLayer(0)->DeleteFeature(rtFt->GetFID());
                    tmpDataset->GetLayer(0)->CreateFeature(rtFt.get());
                    processed++;
                    if (processed = 10) {
                        tmpDataset->GetLayer(0)->SyncToDisk();
                        processed = 0;
                    }
                }
            }
        }

    }
    tmpDataset->FlushCache();
    return 0;
}

#include <iostream>

#include <otbImage.h>
#include <otbImageFileReader.h>
#include <otbImageFileWriter.h>
#include <otbExtractROI.h>
#include <otbOGRVectorDataIO.h>
#include <otbVectorDataToLabelImageFilter.h>
#include <otbVectorImage.h>
#include <rapidjson/document.h>
#include <gdal.h>

#include "statsextractor.hxx"
#include "../Constants/constants.hxx"
#include "../PostgreSQL/pgcursor.hxx"
#include "../Filters/IO/wktvectordataio.hxx"
#include "../Filters/Statistics/StreamedStatisticsFromLabelImageFilter.h"
#include <fstream>


using labelType = unsigned long;
using dataType = short int;
const short Dimension = 2;
using LabelImageType = otb::Image< labelType, Dimension >;
using RawDataImageType = otb::Image<dataType, Dimension>;

using VectorDataToLabelImageFilterType = otb::VectorDataToLabelImageFilter<VectorDataType, LabelImageType>;
using ULongImageReaderType = otb::ImageFileReader<LabelImageType>;
using ULongImageWriterType = otb::ImageFileWriter<LabelImageType>;

using RawDataImageReaderType = otb::ImageFileReader<RawDataImageType>;
using RawDataImageWriterType = otb::ImageFileWriter<RawDataImageType>;


using StreamedStatisticsType = otb::StreamedStatisticsFromLabelImageFilter<RawDataImageType, LabelImageType>;

using ExtractROIFilter = otb::ExtractROI<RawDataImageType::PixelType, RawDataImageType::PixelType>;


StatsExtractor::StatsExtractor(Configuration::Pointer cfg, std::string stratificationType):config(cfg), stratificationType(stratificationType) {}

void StatsExtractor::process() {
    for (auto& product: Constants::productInfo) {

        std::cout <<"Retrieving info for product " <<product.second->productNames[0] <<" (id: " << product.second->id <<")\n";
        std::string query = " SELECT sg.id, pfd.id, ARRAY_TO_JSON(ARRAY_AGG(JSON_BUILD_ARRAY(pf.rel_file_path, pf.id))) images, ST_ASTEXT(sg.geom) , ST_SRID(sg.geom)"
                            " FROM stratification s"
                            " JOIN stratification_geom sg ON s.id = sg.stratification_id"
                            " JOIN product p ON TRUE"
                            " JOIN product_file_description pfd ON p.id = pfd.product_id AND pfd.id =" + pqxx::to_string(product.second->id) +
                " JOIN product_file pf ON pfd.id = pf.product_description_id"
                " LEFT JOIN poly_stats ps ON ps.poly_id = sg.id AND ps.product_file_id = pf.id"
                " WHERE /*sg.id IN(74,228,47,94,199)*/ sg.id=47 AND  s.description ='"+ stratificationType +"' AND ((p.type='raw'AND pfd.variable IS NOT NULL) OR p.type='anomaly') AND ps.id IS NULL GROUP BY sg.id, pfd.id ORDER BY pfd.id, sg.id";


        //std::cout << query <<"\n";
        PGCursor cursor(Configuration::connectionIds[config->statsInfo.connectionId], query);
        PGConn::PGRes processInfo = cursor.getNext();
        if (processInfo.empty())
            continue;

        //loading image reference
        RawDataImageReaderType::Pointer referenceImageReader = RawDataImageReaderType::New();
        referenceImageReader->SetFileName(product.second->firstProductPath.string());
        referenceImageReader->UpdateOutputInformation();

        //map of images to avoid re-reading metadata
        //std::map<size_t, RawDataImageReaderType::Pointer> inImagesMap;

        for (true; !processInfo.empty(); processInfo = cursor.getNext()) {
            PGConn::PGRow row = processInfo[0];
            rapidjson::Document images;
            if (images.Parse(row[2].as<std::string>().c_str()).HasParseError() ) {
                std::cout << "Unable to parse images or no images found. Continuing\n";
                continue;
            }

            //loading polygon
            VectorDataType::Pointer polyData = VectorDataType::New();
            otb::WKTVectorDataIO::Pointer wkt = otb::WKTVectorDataIO::New();
            wkt->SetGeometryMetaData();
            wkt->SetExtentsFromImage<RawDataImageType>(referenceImageReader->GetOutput());
            wkt->AppendData(row[3].as<std::string>(), row[0].as<size_t>());
            wkt->Read(polyData);

            if(polyData->GetDataTree()->GetRoot()->CountChildren() == 0) {
                std::cout << "No polygons could be used. Continuing\n";
                continue;
            }

            otb::WKTVectorDataIO::LabelSetPtr labels = wkt->GetLabels();
            LabelImageType::SizeType size = wkt->AllignToImage<RawDataImageType>(polyData, referenceImageReader->GetOutput());
            if (size[0] < 1) {
                std::cout <<"Polygons fall outside of provided dataset. Continuing\n";
                continue;
            }
            std::cout << "Starting rasterization\n";
            //rastering polygons and keeping in memory. It is going to be used by all images from now on
            VectorDataToLabelImageFilterType::Pointer labelImageFilter = VectorDataToLabelImageFilterType::New();
            labelImageFilter->AddVectorData(polyData);
            labelImageFilter->SetOutputSize(size);
            labelImageFilter->SetOutputOrigin(polyData->GetOrigin());
            labelImageFilter->SetOutputSpacing(polyData->GetSpacing());
            labelImageFilter->SetBurnAttribute("id");

            labelImageFilter->SetOutputProjectionRef(referenceImageReader->GetOutput()->GetProjectionRef());
            labelImageFilter->Update();
            std::cout << "Rasterization finished!\n";
            RawDataImageType::RegionType::IndexType originIdx;

            referenceImageReader->GetOutput()->TransformPhysicalPointToIndex(polyData->GetOrigin(), originIdx);
            //computing stats for each image

            for (auto& image:images.GetArray()) {
                //build absolute path
                size_t imgID = image.GetArray()[1].GetInt64();
                /*
                if (inImagesMap.find(imgID) == inImagesMap.end()) {
                    boost::filesystem::path relPath = image.GetArray()[0].GetString();
                    RawDataImageReaderType::Pointer imgReader= RawDataImageReaderType::New();
                    imgReader->SetFileName(product.second->productAbsPath(relPath).c_str());
                    //imgReader->UpdateOutputInformation();
                    inImagesMap.insert(std::pair<size_t, RawDataImageReaderType::Pointer>(imgID, imgReader));
                }
                */

                boost::filesystem::path relPath = image.GetArray()[0].GetString();
                std::cout <<"Processing image: " <<relPath <<"(poly id :" << row[0].as<size_t>()  << ")\n";

                RawDataImageReaderType::Pointer imgReader= RawDataImageReaderType::New();
                imgReader->SetFileName(product.second->productAbsPath(relPath).c_str());

                ExtractROIFilter::Pointer roi = ExtractROIFilter::New();
                roi->SetInput(imgReader->GetOutput());
                roi->SetStartX(originIdx[0]);
                roi->SetStartY(originIdx[1]);
                roi->SetSizeX(labelImageFilter->GetOutput()->GetLargestPossibleRegion().GetSize()[0]);
                roi->SetSizeY(labelImageFilter->GetOutput()->GetLargestPossibleRegion().GetSize()[1]);
                roi->UpdateOutputInformation();

                StreamedStatisticsType::Pointer stats = StreamedStatisticsType::New();
                stats->SetInputDataImage(roi->GetOutput());
                stats->SetInputLabelImage(labelImageFilter->GetOutput());
                stats->SetInputLabels(*labels);
                stats->SetInputProduct(product.second);
                stats->GetStreamer()->GetStreamingManager()->SetDefaultRAM(4000);
                //stats->GetStreamer()->SetAutomaticAdaptativeStreaming(256);
                stats->Update();
                //stats->GetFilter()->GetOutput()->ReleaseData();

                //empty raw data kept in RAM
                //inImagesMap[imgID]->GetOutput()->ReleaseData();

                std::cout << "Finished!\n";





            }




        }








    }
}

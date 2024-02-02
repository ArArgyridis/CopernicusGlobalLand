#include <fmt/format.h>
#include <itkComposeImageFilter.h>
#include <otbFunctorImageFilter.h>
#include <otbImage.h>
#include <otbImageFileReader.h>
#include <otbImageFileWriter.h>
#include <otbVectorImage.h>
#include <rapidjson/rapidjson.h>

#include "ZScoreProcessor.h"
#include "../Utils.h"
#include "../../Constants/Constants.h"
#include "../../Filters/RasterReprojection/RasterReprojectionFilter.h"
#include "../../Filters/Reductors/MeanReductor.h"
#include "../../Filters/Reductors/SquareRootReductor.h"
#include "../../Filters/Functors/LinearScaler.h"
#include "../../Filters/Functors/ZNormalization.h"

using FloatImageType = otb::Image<float, 2>;
using UCharImageType = otb::Image<unsigned char, 2>;
using UCharVectorImageType = otb::VectorImage<unsigned char, 2>;

using UCharImageReader = otb::ImageFileReader<UCharImageType>;
using UCharImageWriter = otb::ImageFileWriter<UCharImageType>;

using FloatImageWriter = otb::ImageFileWriter<FloatImageType>;

using ComposeUCharImageFilter = itk::ComposeImageFilter<UCharImageType, UCharVectorImageType>;
using MeanReductorFilter = otb::MeanReductor<UCharVectorImageType, FloatImageType::PixelType>;
using SquareRootReductorFilter = otb::SquareRootReductor<UCharVectorImageType, FloatImageType::PixelType>;
using UCharImageReprojectionFilter = otb::RasterReprojectionFilter<UCharImageType>;
using UCharVectorImageWriter = otb::ImageFileWriter<UCharVectorImageType>;

ZScoreProcessor::ZScoreProcessor():product(nullptr), anomalyVariable(nullptr) {}

ZScoreProcessor::ZScoreProcessor(boost::posix_time::ptime dateStart, boost::posix_time::ptime dateEnd, Configuration::SharedPtr cfg, ProductInfo::Pointer product, ProductVariable::Pointer anomalyVariable, ProductVariable::Pointer productVariable):
    dateStart(dateStart), dateEnd(dateEnd), config(cfg), product(product), anomalyVariable(anomalyVariable), productVariable(productVariable){
    tmpFolder = config->filesystem.tmpPath/anomalyVariable->getProductInfo()->productNames[0];
    if(std::filesystem::exists(tmpFolder))
        std::filesystem::remove_all(tmpFolder);
}

ZScoreProcessor::~ZScoreProcessor(){
    if(std::filesystem::exists(tmpFolder))
        std::filesystem::remove_all(tmpFolder);
}

void ZScoreProcessor::process() {
    std::string fileFetchQuery = fmt::format(R"""(WITH prodfiles AS(
                SELECT ARRAY_TO_JSON(ARRAY_AGG(DISTINCT pfcur.rel_file_path)) prodfiles,
                ARRAY_AGG(DISTINCT to_char(pfcur.date, 'mmdd')) daymonths,
                MIN(pfcur.date) reference_date,
                variable, pfcur.rt_flag,
                ltai.*
                FROM product_file_variable pfvcur
                JOIN product_file_description pfdcur ON pfvcur.product_file_description_id = pfdcur.id
                JOIN product_file pfcur ON pfcur.product_file_description_id = pfdcur.id
                JOIN long_term_anomaly_info ltai ON pfvcur.id = ltai.raw_product_variable_id
                WHERE pfcur."date"  >= '{0}'::date AND pfcur."date" < '{1}'::date AND ltai.anomaly_product_variable_id = {2}
                GROUP BY pfvcur.variable, pfcur.rt_flag,  ltai.id, ltai.anomaly_product_variable_id, ltai.mean_variable_id, ltai.stdev_variable_id,
                ltai.raw_product_variable_id
            ),anom_product AS(
                SELECT pfanom.rel_file_path, prodfiles.*
                FROM prodfiles
                JOIN product_file_variable pfvanom ON prodfiles.anomaly_product_variable_id  = pfvanom.id
                JOIN product_file_description pfdanom ON pfvanom.product_file_description_id = pfdanom.id
                LEFT JOIN product_file pfanom ON pfanom.product_file_description_id = pfdanom.id AND pfanom."date" = prodfiles.reference_date
                AND CASE WHEN prodfiles.rt_flag IS NULL THEN TRUE ELSE prodfiles.rt_flag = pfanom.rt_flag END
            ),statsfiles AS(
                SELECT ARRAY_TO_JSON(ARRAY_AGG(ARRAY_TO_JSON(array[pfmean.rel_file_path, pfvmean.variable, pfstdev.rel_file_path, pfvstdev.variable]))) statsfiles, pfmean.rt_flag, pfdmean.id meanid, pfdstdev.id stdevid
                FROM anom_product ap
                JOIN product_file_variable pfvmean ON ap.mean_variable_id = pfvmean.id
                JOIN product_file_description pfdmean ON pfvmean.product_file_description_id = pfdmean.id
                JOIN product_file pfmean ON pfmean.product_file_description_id = pfdmean.id AND CASE WHEN ap.rt_flag IS NULL THEN TRUE ELSE ap.rt_flag = pfmean.rt_flag END

                JOIN product_file_variable pfvstdev ON ap.stdev_variable_id = pfvstdev.id
                JOIN product_file_description pfdstdev ON pfvstdev.product_file_description_id = pfdstdev.id
                JOIN product_file pfstdev ON pfstdev.product_file_description_id = pfdstdev.id AND CASE WHEN pfmean.rt_flag IS NULL THEN TRUE ELSE pfmean.rt_flag = pfstdev.rt_flag END

                WHERE to_char(pfmean."date", 'mmdd') = ANY(ap.daymonths) and to_char(pfstdev."date", 'mmdd') = ANY(ap.daymonths)
                GROUP BY pfmean.rt_flag, pfdmean.id, pfdstdev.id
            )
            SELECT ap.rel_file_path, statsfiles, ap.prodfiles, ap.variable,  statsfiles.rt_flag, ap.reference_date, statsfiles.meanid, statsfiles.stdevid
            FROM anom_product ap
            JOIN statsfiles ON CASE WHEN statsfiles.rt_flag IS NULL THEN TRUE
            ELSE statsfiles.rt_flag = ap.rt_flag END)""", boost::posix_time::to_iso_extended_string(dateStart),
                                             boost::posix_time::to_iso_extended_string(dateEnd), anomalyVariable->id);
    //std::cout << fileFetchQuery <<"\n";
    PGPool::PGConn::Pointer cn              = PGPool::PGConn::New(Configuration::connectionIds[config->statsInfo.connectionId]);
    PGPool::PGConn::PGRes processFiles      = cn->fetchQueryResult(fileFetchQuery);
    if(processFiles.empty())
        return;

    for(const auto& batch : processFiles) {
        if(!batch[0].is_null())
            continue;
        std::cout << "Starting computing anomalies\n";
        std::string statsFilesDB = batch[1].as<std::string>();
        rapidjson::Document statsFilesDBJson;
        statsFilesDBJson.Parse(statsFilesDB);

        ComposeUCharImageFilter::Pointer ltsMeanComposer = ComposeUCharImageFilter::New(), ltsStdevComposer = ComposeUCharImageFilter::New();
        std::vector<UCharImageReader::Pointer> ltsMeanReaders, ltsStdevReaders;
        MeanReductorFilter::Pointer ltsMeanReductor;
        SquareRootReductorFilter::Pointer ltsStdevReductor;
        size_t ltsFileId = 0;
        std::string meanField = statsFilesDBJson.GetArray()[0].GetArray()[1].GetString();
        std::string stdevField = statsFilesDBJson.GetArray()[0].GetArray()[3].GetString();

        auto meanVar = Constants::productInfo[batch[6].as<size_t>()]->variables[meanField];
        auto stdevVar = Constants::productInfo[batch[6].as<size_t>()]->variables[stdevField];

        auto meanScaler     = otb::NewFunctorFilter(LinearScaler<UCharImageType::PixelType, FloatImageType::PixelType>(meanVar->getScaleFactor(),meanVar->getOffset(), stod((*meanVar->metadata)["MY_NO_DATA_VALUE"])));
        auto stdevScaler    = otb::NewFunctorFilter(LinearScaler<UCharImageType::PixelType, FloatImageType::PixelType>(stdevVar->getScaleFactor(),stdevVar->getOffset(), stod((*stdevVar->metadata)["MY_NO_DATA_VALUE"])));

        for(auto& statsFileGroup: statsFilesDBJson.GetArray()) {
            std::filesystem::path ltsMean = meanVar->productAbsPath(statsFileGroup.GetArray()[0].GetString());
            std::filesystem::path ltsStdev = stdevVar->productAbsPath(config->filesystem.ltsPath / statsFileGroup.GetArray()[2].GetString());

            //mean values
            ltsMeanReaders.push_back( UCharImageReader::New());
            ltsMeanReaders.back()->SetFileName(ltsMean);
            ltsMeanReaders.back()->UpdateOutputInformation();
            ltsMeanComposer->SetInput(ltsFileId, ltsMeanReaders.back()->GetOutput());

            //stdev valus
            ltsStdevReaders.push_back(UCharImageReader::New());
            ltsStdevReaders.back()->SetFileName(ltsStdev);
            ltsStdevReaders.back()->UpdateOutputInformation();
            ltsStdevComposer->SetInput(ltsFileId, ltsStdevReaders.back()->GetOutput());

            ltsFileId++;
        }

        FloatImageType::Pointer mean, stdev;
        //if we use a single-dekad, just scale the images, otherwise reduce them
        if(ltsMeanReaders.size() == 1) {
            meanScaler->SetInput(ltsMeanReaders.back()->GetOutput());
            meanScaler->UpdateOutputInformation();
            mean = meanScaler->GetOutput();

            stdevScaler->SetInput(ltsStdevReaders.back()->GetOutput());
            stdevScaler->UpdateOutputInformation();
            stdev = stdevScaler->GetOutput();
        }
        else {
            ltsMeanReductor = MeanReductorFilter::New();
            ltsMeanReductor->SetInput(ltsMeanComposer->GetOutput());
            ltsMeanReductor->SetParams(meanVar);
            ltsMeanReductor->UpdateOutputInformation();
            mean = ltsMeanReductor->GetOutput();

            ltsStdevReductor = SquareRootReductorFilter::New();
            ltsStdevReductor->SetInput(ltsStdevComposer->GetOutput());
            ltsStdevReductor->SetParams(stdevVar);
            ltsStdevReductor->UpdateOutputInformation();
            stdev = ltsStdevReductor->GetOutput();
        }

        //all mean, stdev, and products must occupy the same physical space
        UCharImageReader::Pointer firstProductRearder = UCharImageReader::New();
        firstProductRearder->SetFileName(productVariable->firstProductVariablePath->c_str());
        firstProductRearder->UpdateOutputInformation();

        //ensuring that gt match
        bool matchedSpace = true;
        auto meanGt = mean->GetGeoTransform();
        auto stdevGt = stdev->GetGeoTransform();
        auto prodGt = firstProductRearder->GetOutput()->GetGeoTransform();
        auto meanSize = mean->GetLargestPossibleRegion().GetSize();
        auto stdevSize = stdev->GetLargestPossibleRegion().GetSize();
        auto prodSize = firstProductRearder->GetOutput()->GetLargestPossibleRegion().GetSize();


        for (size_t it = 0; it < meanGt.size(); it++)
            matchedSpace = matchedSpace && prodGt[it] == meanGt[it] && prodGt[it] == stdevGt[it];

        //checking size
        matchedSpace = matchedSpace && prodSize == meanSize && prodSize == stdevSize;
        //checking projection
        matchedSpace = matchedSpace && firstProductRearder->GetOutput()->GetProjectionRef() == mean->GetProjectionRef() && firstProductRearder->GetOutput()->GetProjectionRef() == stdev->GetProjectionRef();

        //reading info from product files for the anomalies
        std::string prodFilesDB = batch[2].as<std::string>();
        rapidjson::Document prodFilesDBJson;
        prodFilesDBJson.Parse(prodFilesDB);
        for(auto& prodFile: prodFilesDBJson.GetArray()) {
            UCharImageReader::Pointer prodReader = UCharImageReader::New();
            prodReader->SetFileName(productVariable->productAbsPath(prodFile.GetString()));
            UCharImageType::Pointer inProdImg = prodReader->GetOutput();

            UCharImageReprojectionFilter::Pointer reproject = UCharImageReprojectionFilter::New();
            if(!matchedSpace && ltsMeanReaders.size() == 1) { //warp product image so it matches the lts ones
                reproject->SetInput(prodReader->GetOutput());
                reproject->SetInputProjection(4326);
                reproject->SetOutputProjection(4326);
                reproject->SetExtent(meanGt[0], meanGt[3]+meanSize[0]*meanGt[4]+meanSize[1]*meanGt[5], meanGt[0]+meanSize[0]*meanGt[1]+meanSize[1]*meanGt[2], meanGt[3]);
                reproject->SetOutputSpacing(mean->GetSignedSpacing());
                reproject->UpdateOutputInformation();
                inProdImg = reproject->GetOutput();
            } else if(!matchedSpace && ltsMeanReaders.size() > 1) {
                std::cerr << "NOT IMPLEMENTED!!!!!!! ===> the smallest image in terms of pixels should be reprojected!\n";
                return;
            }

            //scale product
            auto prodScaler = otb::NewFunctorFilter(LinearScaler<UCharImageType::PixelType, FloatImageType::PixelType>(productVariable->getScaleFactor(),productVariable->getOffset(), stod((*productVariable->metadata)["MY_NO_DATA_VALUE"])));
            prodScaler->SetInput(inProdImg);
            //now we can finally compute the anomaly

            auto zNormalizer = otb::NewFunctorFilter(ZNormalizationQ<FloatImageType::PixelType, FloatImageType::PixelType, FloatImageType::PixelType>(
                stof((*meanVar->metadata)["MY_NO_DATA_VALUE"]), stof((*stdevVar->metadata)["MY_NO_DATA_VALUE"]),  stof((*productVariable->metadata)["MY_NO_DATA_VALUE"])));
            zNormalizer->SetInputs(mean, stdev, prodScaler->GetOutput());

            //creating output file name
            std::string outFile;
            std::string dtStart = boost::posix_time::to_iso_extended_string(dateStart).substr(0,10);
            std::string dtEnd   = boost::posix_time::to_iso_extended_string(dateEnd).substr(0,10);
            if(batch[4].is_null())
                outFile = fmt::format(anomalyVariable->getProductInfo()->fileNameCreationPattern, dtStart, dtEnd);
            else
                outFile = fmt::format(anomalyVariable->getProductInfo()->fileNameCreationPattern, batch[4].as<std::string>(), dtStart, dtEnd);

            std::filesystem::path tmpImg = tmpFolder / outFile;
            createDirectoryForFile(tmpImg);

            UCharImageWriter::Pointer tmpImgWriter = UCharImageWriter::New();
            tmpImgWriter->SetFileName(tmpImg.string()+"?&gdal:co:BIGTIFF=IF_NEEDED&gdal:co:TILED=YES&gdal:co:BLOCKXSIZE=512&gdal:co:BLOCKYSIZE=512&gdal:co:COMPRESS=LZW");
            tmpImgWriter->SetInput(zNormalizer->GetOutput());
            tmpImgWriter->GetStreamingManager()->SetDefaultRAM(config->statsInfo.memoryMB);
            tmpImgWriter->Update();

            //copy to destination
            std::filesystem::path outImg = this->config->filesystem.anomalyProductsPath/anomalyVariable->getProductInfo()->productNames[0]/dtStart.substr(0,4)/outFile;
            createDirectoryForFile(tmpImg);
            std::cout << "Copy to destination\n";
            //copy file to destination directory
            if(std::filesystem::exists(outImg))
                std::filesystem::remove(outImg);
            createDirectoryForFile(outImg);
            std::filesystem::copy(tmpImg, outImg);
            //delete tmp file
            std::filesystem::remove(tmpImg);

            //update db
            std::string rtFlag = "NULL";
            if(!batch[4].is_null())
                rtFlag = batch[4].as<std::string>();

            std::string anomalyInfoQuery = fmt::format(R"""(INSERT INTO product_file(product_file_description_id, rel_file_path, date, rt_flag) VALUES ({0},'{1}','{2}',{3})
                        ON CONFLICT(product_file_description_id, "date", rt_flag) DO UPDATE set rel_file_path=EXCLUDED.rel_file_path)""",anomalyVariable->getProductInfo()->id,
                                                       std::filesystem::relative(outImg, config->filesystem.anomalyProductsPath).string(), batch[5].as<std::string>(), rtFlag);
            cn->executeQuery(anomalyInfoQuery);
        }
    }



}

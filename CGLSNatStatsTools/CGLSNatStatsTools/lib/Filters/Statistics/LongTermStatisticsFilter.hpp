#ifndef LONGTERMSTATISTICSFILTER_HPP
#define LONGTERMSTATISTICSFILTER_HPP

#include <itkImageToImageFilter.h>
#include <itkImageRegionConstIterator.h>
#include <itkImageRegionIterator.h>
#include <otbImage.h>
#include <otbNoDataHelper.h>
#include <mutex>

#include "../../Constants/ProductVariable.h"


namespace otb {

template <class TInputImage, class TOutputImage = Image<float, 2>>
class LongTermStatisticsFilter:public itk::ImageToImageFilter<TInputImage, TOutputImage> {
public:
    /** Standard Self typedef */
    using Self          = LongTermStatisticsFilter;
    using Superclass    = itk::ImageToImageFilter<TInputImage, TOutputImage>;
    using Pointer       = itk::SmartPointer<Self>;
    using ConstPointer  = itk::SmartPointer<const Self>;

    using TInputImageConstIterator          =  itk::ImageRegionConstIterator<TInputImage>;
    using TInputLabelImageConstIterator     =  itk::ImageRegionConstIterator<TInputImage>;
    using OutputIterator                    =  itk::ImageRegionIterator<TOutputImage>;
    using RegionType                        = typename TInputImage::RegionType;

    /** Method for creation through the object factory. */
    itkNewMacro(Self)
    itkSetMacro(Variable, ProductVariable::SharedPtr)

    /** Runtime information support. */
    itkTypeMacro(StreamedStatisticsFromLabelImageFilter, ImageToImageFilter)


    void SetNthInput(const size_t& id, TInputImage* img) {
        this->SetInput(id, img);
        std::cout <<"nInputs: " << this->GetNumberOfInputs() << "\n";
    }


protected:

    size_t nOutputs;
    std::vector<double> noDataValues;
    std::vector<bool>   noDataFlags;
    std::mutex mtx;
    ProductVariable::SharedPtr m_Variable;

    LongTermStatisticsFilter():nOutputs(4) {
        for(size_t i = 1; i < nOutputs; i++)
            this->SetNthOutput(i, this->MakeOutput(i));
    }
    ~LongTermStatisticsFilter() override {}

    void GenerateOutputInformation() override {
        Superclass::GenerateOutputInformation();
        otb::ReadNoDataFlags(this->GetInput()->GetImageMetadata(), noDataFlags, noDataValues);

        for(size_t i = 0; i< nOutputs; i++)
            otb::WriteNoDataFlags(noDataFlags, noDataValues, this->GetOutput(i)->GetImageMetadata());

    }

    void ThreadedGenerateData(const RegionType &outputRegionForThread, itk::ThreadIdType threadId) override {
        std::cout << "START COMPUTATION!\n";

        std::vector<OutputIterator> outputIterators(nOutputs);
        for(size_t idx = 0; idx < nOutputs; idx++) outputIterators[idx] = OutputIterator(this->GetOutput(idx), outputRegionForThread);

        std::vector<TInputImageConstIterator> inputIterators(this->GetNumberOfInputs());

        for (size_t idx = 0; idx < this->GetNumberOfInputs(); idx++)
             inputIterators[idx] = TInputLabelImageConstIterator(this->GetInput(idx), outputRegionForThread);

        std::vector<typename TInputImage::IOPixelType> tmpDt(this->GetNumberOfInputs());

        for (size_t idx = 0; idx < nOutputs; idx++) outputIterators[idx].GoToBegin();
        for (size_t idx = 0; idx < this->GetNumberOfInputs(); idx++) inputIterators[idx].GoToBegin();

        //typename TOutputImage::PixelType noData = noDataValues[0];

        //moving output iterators
        for(outputIterators[0].GoToBegin(); !outputIterators[0].IsAtEnd(); ++outputIterators[0]){
            for(size_t idx = 1; idx < nOutputs; idx++) ++outputIterators[idx];//.SetIndex(outputIterators[0].GetIndex());


            //moving input iterators
            size_t validObservations = 0;
            for (size_t idx = 0; idx < this->GetNumberOfInputs(); idx++) {
                inputIterators[idx].SetIndex(outputIterators[0].GetIndex());
                auto val = inputIterators[idx].Get();
                if (val != noDataValues[0]) {
                    tmpDt[validObservations] = val;
                    validObservations++;
                }
            }


            if (validObservations == 0) {
                for(size_t idx = 0; idx < nOutputs; idx++)
                outputIterators[idx].Set(noDataValues[0]);
                continue;
            }
            //statsPxl[0] = static_cast<typename TOutputImage::IOPixelType>(validObservations);

            outputIterators[0].Set(static_cast<typename TOutputImage::PixelType>(validObservations));


            //sorting values
            size_t medianIdx = validObservations/2;
            std::sort(tmpDt.begin(), tmpDt.begin()+validObservations, std::greater<>());
            outputIterators[1].Set(m_Variable->scaleValue(tmpDt[medianIdx]));
            //statsPxl[1] = tmpDt[medianIdx];

            typename TOutputImage::IOPixelType mn = 0, sd = 0;
            //mean and std values
            for(size_t idx = 0; idx < validObservations; idx++) {
                mn += tmpDt[idx]*1.0/validObservations;
                sd += tmpDt[idx]*tmpDt[idx]*1.0/validObservations;
            }

            //statsPxl[2] = mn;
            outputIterators[2].Set(m_Variable->scaleValue(mn));

            if (validObservations > 1) {
                sd = sqrt(sd - mn*mn);
                outputIterators[3].Set(m_Variable->scaleValue(sd));
                //statsPxl[3] = sd;
            }
            else {
                //statsPxl[3] = noDataValues[0];
                outputIterators[3].Set(noDataValues[0]);
            }

            /*
            {
                std::lock_guard<std::mutex>lck(mtx);
                std::cout << outputIterators[0].Get() <<"," << outputIterators[1].Get() << outputIterators[2].Get() <<"," << outputIterators[3].Get() <<"\n";
                         //outIt.Set(statsPxl);
            }
            */
        }
        std::cout << "END COMPUTATION!\n";


    }


};
}



#endif // LONGTERMSTATISTICSFILTER_HPP

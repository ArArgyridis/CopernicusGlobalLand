#ifndef ZNORMALIZATION_H
#define ZNORMALIZATION_H

#include <iostream>

template <class TInput1, class TInput2, class TInput3, class TOutput>
class ZNormalization {
protected:
    TInput1 meanNull;
    TInput2 stdevNull;
    TInput3 prodNull;
public:
    ZNormalization(TInput1 meanNull=255, TInput2 stdevNull=255, TInput3 prodNull=255):meanNull(meanNull), stdevNull(stdevNull), prodNull(prodNull){}

    TOutput operator()(const TInput1& mean, const TInput2 &stdev, const TInput3 &prdVal) {
        bool isNull = (mean == meanNull || stdev == stdevNull || prdVal == prodNull);

        return isNull*prdVal + !(isNull)*(mean-prdVal)/stdev;
    }
};

template <class TInput1, class TInput2, class TInput3>
class ZNormalizationQ:public ZNormalization<TInput1, TInput2, TInput3, double> {
public:
    ZNormalizationQ(TInput1 meanNull=255, TInput2 stdevNull=255, TInput3 prodNull=255):ZNormalization<TInput1, TInput2, TInput3, double>(meanNull, stdevNull, prodNull){}

    unsigned char operator()(const TInput1& mean, const TInput2 &stdev, const TInput3 &prdVal) {
        bool isNull = (mean == this->meanNull || stdev == this->stdevNull || prdVal == this->prodNull);
        TInput1 val = (mean - prdVal)/stdev;
        return isNull*255 + (!isNull)*(((val < -3)*0 + (val >= -3 && val < -2)*1 + (val >= -2 && val < -1)*2 + (val >= -1 && val < 1)*3 + (val >=1 && val < 2)*4 + (val >=2 && val < 3)*5 + (val >= 3)*6));
    }

};


#endif // ZNORMALIZATION_H

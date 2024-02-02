#ifndef LINEARSCALER_H
#define LINEARSCALER_H

template <class TInput, class TOutput>
class LinearScaler {
    double a, b, ignoreVal;
public:
    LinearScaler(double a, double b, double ignoreVal=255): a(a), b(b), ignoreVal(ignoreVal){}

    TOutput operator()(const TInput& in) {
        return (in==ignoreVal)*in + (in!= ignoreVal)*(a*in+b);
    }
};


#endif // LINEARSCALER_H

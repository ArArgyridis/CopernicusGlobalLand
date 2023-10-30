#ifndef LINEARSCALER_H
#define LINEARSCALER_H

template <class TInput, class TOutput>
class LinearScaler {
    double a, b;
public:
    LinearScaler(double a, double b): a(a), b(b){}
    /*
    void setParams(double a, double b) {
        this->a = a;
        this->b = b;
    }
    */
    TOutput operator()(const TInput& in) {
        return a*in+b;
    }
};


#endif // LINEARSCALER_H

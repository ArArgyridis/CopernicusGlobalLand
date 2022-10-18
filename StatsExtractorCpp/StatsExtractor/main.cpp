#include <iostream>
#include "lib/Constants/constants.hxx"
#include "lib/StatsExtractor/statsextractor.hxx"
#include <gdal_frmts.h>

using namespace std;

int main(int argc, char *argv[]) {
    if (argc < 3) {
        cout << "usage: StatsExtractor configuration_file stratification_description";
        return 1;
    }
    GDALAllRegister();

    std::string cfgFile(argv[1]), stratification(argv[2]);

    Configuration::Pointer config = Configuration::New(cfgFile);
    if (config->parse() != 0)
        return 1;

    if (Constants::load(config) != 0)
        return 1;

    StatsExtractor extractor(config, stratification);
    extractor.process();


    cout << "Hello World!" << endl;
    return 0;
}

#ifndef OTBIMAGEDEFS_H
#define OTBIMAGEDEFS_H

#include <otbImage.h>
#include <otbVectorImage.h>

namespace otb {
using UCharImageType    = otb::Image<unsigned char, 2>;
using FloatImageType    = otb::Image<float, 2>;
using ShortImageType    = otb::Image<short, 2>;
using ULongImageType    = otb::Image<unsigned long, 2>;
using UShortImageType   = otb::Image<unsigned short, 2>;

using UCharVectorImageType  = otb::VectorImage<unsigned char, 2>;
using FloatVectorImageType  = otb::VectorImage<float, 2>;
using ShortVectorImageType  = otb::VectorImage<short, 2>;
using UShortVectorImageType = otb::VectorImage<unsigned short, 2>;
using ULongVectorImageType  = otb::VectorImage<unsigned long, 2>;
}


#endif // OTBIMAGEDEFS_H

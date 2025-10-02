cmake_minimum_required(VERSION 3.5)
project(CGLSNatStatsTools LANGUAGES CXX)
#add_definitions("-DRAPIDJSON_SCHEMA_USE_INTERNALREGEX=0")
add_definitions("-DRAPIDJSON_HAS_STDSTRING=1")


find_package(OTB REQUIRED)
if(OTB_FOUND)
  include(${OTB_USE_FILE})
else(OTB_FOUND)
  message(FATAL_ERROR "Cannot build OTB project without OTB. Please set OTB_DIR.")
endif(OTB_FOUND)


SET (PQXX_DIR .)
SET (POSTGRES_DIR .)
find_package(PostgreSQL REQUIRED)
find_package(CURL REQUIRED)
find_package(Threads REQUIRED)
find_package(fmt REQUIRED)
find_package(OpenMP)
find_package(LibZip REQUIRED)
#find_library(PQXX_LIBRARY pqxx)
find_package(PQXX REQUIRED)

set(Boost_USE_STATIC_LIBS OFF)
set(Boost_USE_MULTITHREADED ON)
set(Boost_USE_STATIC_RUNTIME OFF)
find_package(Boost REQUIRED COMPONENTS serialization filesystem date_time)
if(Boost_FOUND)
    include_directories(${Boost_INCLUDE_DIRS})
endif()



find_package(LibXml2 REQUIRED)
if (LIBXML2_FOUND)
    include_directories(${LIBXML2_INCLUDE_DIR})
endif()


find_package(OpenMP)
if (OPENMP_FOUND)
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
    set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${OpenMP_EXE_LINKER_FLAGS}")
endif()
set(SOURCE
    lib/Anomalies/Utils.cpp
    lib/Anomalies/ZScoreProcessor/ZScoreProcessor.cpp
    lib/ConfigurationParser/ConfigurationParser.cpp
    lib/Constants/Constants.cpp
    lib/Constants/ProductInfo.cpp
    lib/Constants/ProductVariable.cpp
    lib/Filters/Statistics/PolygonStats.cpp
    lib/PostgreSQL/PostgreSQL.cpp
    lib/ProductOrderProcessor/ProductOrderProcessor.cpp
    lib/StatsExtractor/StatsExtractor.cpp
    lib/Utils/ColorInterpolation.cpp
    lib/Utils/EmailClient/SmtpServer.cpp
    lib/Utils/Utils.cpp
)

set (HEADERS
    lib/Anomalies/Utils.h
    lib/Anomalies/ZScoreProcessor/ZScoreProcessor.h
    lib/ConfigurationParser/ConfigurationParser.h
    lib/Constants/Constants.h
    lib/Constants/ProductInfo.h
    lib/Constants/ProductVariable.h
    lib/Filters/Functors/GLCReclassifier.h
    lib/Filters/Functors/LinearScaler.h
    lib/Filters/Functors/ZNormalization.h
    lib/Filters/IO/VectorWktToLabelImageFilter.h
    lib/Filters/IO/VectorWktToLabelImageFilter.hxx
    lib/Filters/OTBImageDefs.h
    lib/Filters/RasterReprojection/RasterReprojectionFilter.h
    lib/Filters/RasterReprojection/RasterReprojectionFilter.hxx
    lib/Filters/Reductors/MeanReductor.h
    lib/Filters/Reductors/MeanReductor.hxx
    lib/Filters/Reductors/SquareRootReductor.h
    lib/Filters/Reductors/SquareRootReductor.hxx
    lib/Filters/Statistics/PolygonStats.h
    lib/Filters/Statistics/StatisticsFromLabelImageFilter.h
    lib/Filters/Statistics/StatisticsFromLabelImageFilter.hxx
    lib/Filters/Statistics/StreamedStatisticsFromLabelImageFilter.h
    lib/Filters/Statistics/StratificationStatistics/OrderStatisticsFilter.hxx
    lib/Filters/Statistics/StratificationStatistics/StreamedSystemStratificationStatisticsFilter.h
    lib/Filters/Statistics/StratificationStatistics/SystemStratificationStatisticsFilter.h
    lib/Filters/Statistics/StratificationStatistics/SystemStratificationStatisticsFilter.hxx
    lib/Filters/Visualization/WMSCogFilter.h
    lib/Filters/Visualization/WMSCogFilter.hxx
    lib/PostgreSQL/PostgreSQL.h
    lib/ProductOrderProcessor/Crop.hxx
    lib/ProductOrderProcessor/ProductOrderProcessor.h
    lib/StatsExtractor/StatsExtractor.h
    lib/Utils/ColorInterpolation.h
    lib/Utils/EmailClient/SmtpServer.h
    lib/Utils/Utils.hxx
)

#add_compile_options(-fsanitize=address)
#add_link_options(-fsanitize=address)

include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-march=native" COMPILER_SUPPORTS_MARCH_NATIVE)
if(COMPILER_SUPPORTS_MARCH_NATIVE)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=native")
endif()


set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)


add_library(${PROJECT_NAME} ${SOURCE} ${HEADERS})

set (PROCESSORS
    processors/CogGenerator.cpp
    processors/StatsExtractor.cpp
    processors/OrderProcessor.cpp
    processors/AnomalyExtractor.cpp
    processors/GLCReclassifier.cpp
    processors/GLCSimplifier.cpp
)

foreach(sourceFile IN LISTS PROCESSORS)
    get_filename_component(fileName ${sourceFile} NAME_WE)
    message("creating: ${fileName}")
    add_executable(${fileName} ${sourceFile})
    target_include_directories(${fileName} PRIVATE ${LIBZIP_INCLUDE_DIR} ${PQXX_INCLUDE_DIRS})
    target_link_libraries(${fileName} ${PROJECT_NAME} ${LIBZIP_LIBRARY} ${PQXX_LIBRARIES} ${OTB_LIBRARIES}
            ${Boost_LIBRARIES} ${LIBXML2_LIBRARIES} fmt::fmt-header-only OpenMP::OpenMP_CXX CURL::libcurl )
endforeach()












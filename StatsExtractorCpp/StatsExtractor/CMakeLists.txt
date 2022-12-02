cmake_minimum_required(VERSION 3.5)
project(StatsExtractor LANGUAGES CXX)
#add_definitions("-DRAPIDJSON_SCHEMA_USE_INTERNALREGEX=0")



find_package(OTB REQUIRED)
if(OTB_FOUND)
  include(${OTB_USE_FILE})
else(OTB_FOUND)
  message(FATAL_ERROR "Cannot build OTB project without OTB.  Please set OTB_DIR.")
endif(OTB_FOUND)


SET (PQXX_DIR .)
SET (POSTGRES_DIR .)
add_subdirectory(fmt)


find_package(Threads REQUIRED)



set(Boost_USE_STATIC_LIBS OFF)
set(Boost_USE_MULTITHREADED ON)
set(Boost_USE_STATIC_RUNTIME OFF)
find_package(Boost REQUIRED COMPONENTS serialization filesystem)
if(Boost_FOUND)
    include_directories(${Boost_INCLUDE_DIRS})
endif()

find_package(PQXX REQUIRED)
find_package(fmt)

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
    lib/PostgreSQL/PostgreSQL.cpp
    lib/ConfigurationParser/ConfigurationParser.cpp
    lib/Constants/Constants.cpp
    lib/StatsExtractor/StatsExtractor.cpp
    lib/Utils/Utils.cpp
    lib/Filters/Statistics/PolygonStats.cpp
    lib/Utils/ColorInterpolation.cpp
)
set (HEADERS
    lib/PostgreSQL/PostgreSQL.h
    lib/ConfigurationParser/ConfigurationParser.h
    lib/Constants/Constants.h
    lib/StatsExtractor/StatsExtractor.h
    lib/Utils/Utils.hxx
    lib/Filters/Statistics/StatisticsFromLabelImageFilter.h
    lib/Filters/Statistics/StatisticsFromLabelImageFilter.hxx
    lib/Filters/Statistics/StreamedStatisticsFromLabelImageFilter.h
    lib/Filters/Statistics/PolygonStats.h
    lib/Filters/IO/VectorWktToLabelImageFilter.h
    lib/Filters/IO/VectorWktToLabelImageFilter.hxx
    lib/Utils/ColorInterpolation.h
    lib/Filters/ProcessingChainFilter.h
    lib/Filters/ProcessingChainFilter.hxx
    lib/Filters/StreamedProcessingChainFilter.h
)

#add_compile_options(-fsanitize=address)
#add_link_options(-fsanitize=address)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(${PROJECT_NAME} ${SOURCE} ${HEADERS} "main.cpp" )
target_link_libraries(${PROJECT_NAME}  ${PQXX_LIBRARIES} ${OTB_LIBRARIES} ${Boost_LIBRARIES} ${LIBXML2_LIBRARIES} fmt::fmt-header-only)


install(TARGETS StatsExtractor
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})

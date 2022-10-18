cmake_minimum_required(VERSION 3.5)
project(StatsExtractor LANGUAGES CXX)
#add_definitions("-DRAPIDJSON_SCHEMA_USE_INTERNALREGEX=0")



find_package(OTB REQUIRED)
if(OTB_FOUND)
  include(${OTB_USE_FILE})
else(OTB_FOUND)
  message(FATAL_ERROR "Cannot build OTB project without OTB.  Please set OTB_DIR.")
endif(OTB_FOUND)


set(Boost_USE_STATIC_LIBS OFF)
set(Boost_USE_MULTITHREADED ON)
set(Boost_USE_STATIC_RUNTIME OFF)

SET (PQXX_DIR .)
SET (POSTGRES_DIR .)
add_subdirectory(fmt)


find_package(Threads REQUIRED)
find_package(Boost REQUIRED COMPONENTS serialization filesystem)
find_package(PQXX REQUIRED)
find_package(fmt)

include_directories(${Boost_INCLUDE_DIRS})

find_package(OpenMP)
if (OPENMP_FOUND)
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
    set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${OpenMP_EXE_LINKER_FLAGS}")
endif()

set(SOURCE
    lib/PostgreSQL/postgresql.cpp
    lib/PostgreSQL/pgcursor.cpp
    lib/ConfigurationParser/configurationparser.cpp
    lib/Constants/constants.hxx lib/Constants/constants.cpp
    lib/StatsExtractor/statsextractor.hxx lib/StatsExtractor/statsextractor.cpp
    lib/Utils/utils.cpp
    lib/Filters/IO/wktvectordataio.cpp
    lib/Filters/Statistics/polygonstats.cpp
    lib/Utils/ColorInterpolation.cpp
)
set (HEADERS
    lib/PostgreSQL/postgresql.hxx
    lib/PostgreSQL/pgcursor.hxx
    lib/ConfigurationParser/configurationparser.hxx
    lib/Constants/constants.hxx lib/Constants/constants.hxx
    lib/StatsExtractor/statsextractor.hxx lib/StatsExtractor/statsextractor.hxx
    lib/Utils/utils.hxx
    lib/Filters/IO/wktvectordataio.hxx
    lib/Filters/Statistics/StatisticsFromLabelImageFilter.h
    lib/Filters/Statistics/StatisticsFromLabelImageFilter.hxx
    lib/Filters/Statistics/StreamedStatisticsFromLabelImageFilter.h
    lib/Filters/Statistics/polygonstats.hxx
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
target_link_libraries(${PROJECT_NAME}  ${PQXX_LIBRARIES} ${OTB_LIBRARIES} ${Boost_LIBRARIES} fmt::fmt-header-only)


install(TARGETS StatsExtractor
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})

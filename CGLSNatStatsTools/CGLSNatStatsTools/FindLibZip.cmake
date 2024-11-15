# Try to find libzip package
find_path(LIBZIP_INCLUDE_DIR NAMES zip.h)
find_library(LIBZIP_LIBRARY NAMES zip)

if (LIBZIP_INCLUDE_DIR AND LIBZIP_LIBRARY)
    set(LIBZIP_FOUND TRUE)
endif ()

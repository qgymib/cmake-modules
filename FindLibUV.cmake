# Standard FIND_PACKAGE module for libuv, sets the following variables:
#   - LIBUV_FOUND
#   - LIBUV_INCLUDE_DIRS (only if LIBUV_FOUND)
#   - LIBUV_LIBRARIES (only if LIBUV_FOUND)
#
# If LIBUV_FOUND, target `libuv` is exported. Use following code to link with
# libuv:
#
# ```
# target_link_libraries(Foo PRIVATE libuv)
# ```

# Try to find the header
FIND_PATH(LIBUV_INCLUDE_DIR NAMES uv.h)

# Try to find the library
FIND_LIBRARY(LIBUV_LIBRARY NAMES uv_a uv libuv)

# Handle the QUIETLY/REQUIRED arguments, set LIBUV_FOUND if all variables are
# found
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(LibUV
        REQUIRED_VARS
        LIBUV_LIBRARY
        LIBUV_INCLUDE_DIR)

# Hide internal variables
MARK_AS_ADVANCED(LIBUV_INCLUDE_DIR LIBUV_LIBRARY)

# Set standard variables
IF (NOT LIBUV_LIBRARY)
    return()
ENDIF()

SET(LIBUV_INCLUDE_DIRS "${LIBUV_INCLUDE_DIR}")
SET(LIBUV_LIBRARIES "${LIBUV_LIBRARY}")

function (libuv_setup_target_as_win32)
    get_filename_component(_FILE_NAME ${LIBUV_LIBRARY} NAME_WLE)
    if (_FILE_NAME STREQUAL uv_a)
        add_library(libuv STATIC IMPORTED)
        set_target_properties(libuv PROPERTIES
            INTERFACE_LINK_LIBRARIES "psapi;user32;advapi32;iphlpapi;userenv;ws2_32"
        )
    elseif (_FILE_NAME STREQUAL uv)
        add_library(libuv SHARED IMPORTED)
        set_target_properties(libuv PROPERTIES
            INTERFACE_COMPILE_DEFINITIONS "USING_UV_SHARED=1"
            INTERFACE_LINK_LIBRARIES "psapi;user32;advapi32;iphlpapi;userenv;ws2_32"
        )
    else ()
        message(FATAL_ERROR "unknown libuv library name")
    endif ()
    set(_FILE_NAME)
endfunction ()

function (libuv_setup_target_as_unix)
    get_filename_component(_EXT_NAME ${LIBUV_LIBRARY} LAST_EXT)
    if (_EXT_NAME STREQUAL "so")
        add_library(libuv SHARED IMPORTED)
    else ()
        add_library(libuv STATIC IMPORTED)
    endif()
    set(_EXT_NAME)
endfunction ()

if (WIN32)
    libuv_setup_target_as_win32()
else ()
    libuv_setup_target_as_unix()
endif ()

set_target_properties(libuv PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${LIBUV_INCLUDE_DIR}"
    IMPORTED_LOCATION "${LIBUV_LIBRARY}"
)

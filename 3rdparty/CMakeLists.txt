# Rules to build 3rd-party libraries.
#
# Copyright (c) 2015-2023, Gilles Caulier, <caulier dot gilles at gmail dot com>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.25.0)

cmake_policy(SET CMP0141 NEW)

IF(WIN32)

    SET(CMAKE_SYSTEM_VERSION ${WINDOWS_TARGET_VERSION} CACHE TYPE INTERNAL FORCE)
    MESSAGE(STATUS "Windows version for backward compatibility: ${WINDOWS_TARGET_VERSION}")

ENDIF()

PROJECT(installdeps)

SET(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/modules ${CMAKE_MODULE_PATH})

FUNCTION(JoinListAsString VALUES GLUE OUTPUT)

    STRING(REPLACE ";" "${GLUE}" _TMP_STR "${VALUES}")
    SET(${OUTPUT} "${_TMP_STR}" PARENT_SCOPE)

ENDFUNCTION()

# Check Compile requirements

FIND_PACKAGE(Perl         REQUIRED)
FIND_PACKAGE(PythonInterp REQUIRED)

IF(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)

    MESSAGE(FATAL_ERROR "Compiling in the source directory is not supported. Use for example 'mkdir build; cd build; cmake ..'.")

ENDIF()

# Tools must be obtained to work with
INCLUDE(ExternalProject)

# allow specification of a directory with pre-downloaded requirements
if(NOT IS_DIRECTORY ${EXTERNALS_DOWNLOAD_DIR})

    message(FATAL_ERROR "No externals download dir set. Use -DEXTERNALS_DOWNLOAD_DIR")

endif()

IF(NOT IS_DIRECTORY ${INSTALL_ROOT})

    MESSAGE(FATAL_ERROR "No install dir set. Use -DINSTALL_ROOT")

ENDIF()

SET(TOP_INST_DIR ${INSTALL_ROOT})
SET(EXTPREFIX "${TOP_INST_DIR}")
SET(CMAKE_PREFIX_PATH "${EXTPREFIX}")

SET(CMAKE_BUILD_TYPE "RelWithDebInfo")
SET(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "Embedded")
SET(CMAKE_SYSTEM_NAME "Windows")
SET(CMAKE_C_LINK_EXECUTABLE "lld-link")
SET(CMAKE_MT "llvm-mt")

SET(GLOBAL_BUILD_TYPE RelWithDebInfo)
SET(GLOBAL_PROFILE ${GLOBAL_PROFILE}
                   -DBUILD_TESTING=false
)

SET(PATCH_COMMAND patch)

# NOTE: this list must be dependency-ordered

ADD_SUBDIRECTORY(ext_openssl)
#ADD_SUBDIRECTORY(ext_cmake)
#ADD_SUBDIRECTORY(ext_qt6)
#ADD_SUBDIRECTORY(ext_kf6)


#!/bin/bash

################################################################################
#
# Script to install Qt framework for Windows.
#
# Copyright (c) 2013-2023, Gilles Caulier, <caulier dot gilles at gmail dot com>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.
#
################################################################################

# Halt on errors
set -e

. ./common.sh
. ./config.sh

#################################################################################################
# Manage script traces to log file

mkdir -p $INSTALL_DIR/logs
exec > >(tee $INSTALL_DIR/logs/msvc-installqt6.full.log) 2>&1

#################################################################################################
# Pre-processing checks

ChecksRunAsRoot
StartScript
ChecksCPUCores
ChecksLinuxVersionAndName
ChecksGccVersion

#################################################################################################
# Create the directories

if [[ ! -d $BUILDING_DIR ]] ; then

    mkdir $BUILDING_DIR

fi

if [ ! -d $DOWNLOAD_DIR ] ; then

    mkdir $DOWNLOAD_DIR

fi

if [[ ! -d $INSTALL_DIR ]] ; then

    mkdir $INSTALL_DIR

fi

# Clean up previous openssl install

#rm -fr /usr/local/lib/libssl.a    || true
#rm -fr /usr/local/lib/libcrypto.a || true
#rm -fr /usr/local/include/openssl || true

cd $ORIG_WD/msvc-wrapper/

export BIN=$DOWNLOAD_DIR/bin/x64
. ./msvcenv-native.sh
export VERBOSE=true

MSVC_TOOLCHAIN=$ORIG_WD/cmake/conf/msvc-conf.cmake

#################################################################################################

cd $BUILDING_DIR

rm -rf $BUILDING_DIR/* || true

CMAKE_ARGS=(
    -DCMAKE_BUILD_TYPE=RelWithDebInfo
    -DCMAKE_MSVC_DEBUG_INFORMATION_FORMAT=Embedded
    -DCMAKE_SYSTEM_NAME=Windows
    -DCMAKE_TOOLCHAIN_FILE=${MSVC_TOOLCHAIN} \
    -DCMAKE_C_LINK_EXECUTABLE=$(which lld-link)
    -DCMAKE_MT=$(which llvm-mt)
)

CC="clang-cl --target=$TARGET_TRIPLE" CXX="clang-cl --target=$TARGET_TRIPLE" LD="lld-link" RC="llvm-rc" \
    cmake \
        $ORIG_WD/3rdparty \
        -DCMAKE_INSTALL_PREFIX:PATH=/$INSTALL_DIR \
        -DEXTERNALS_DOWNLOAD_DIR=$DOWNLOAD_DIR \
        -DINSTALL_ROOT=$INSTALL_DIR \
        -DKA_VERSION=$DK_KA_VERSION \
        -DKP_VERSION=$DK_KP_VERSION \
        -DKDE_VERSION=$DK_KDE_VERSION \
        -GNinja \
        -Wno-dev

#        "${CMAKE_ARGS[@]}" \

CC="clang-cl --target=$TARGET_TRIPLE" CXX="clang-cl --target=$TARGET_TRIPLE" LD="lld-link" RC="llvm-rc" \
    cmake \
        --build . \
        --config RelWithDebInfo \
        --target ext_openssl \

#        -GNinja \

#cmake --build . --config RelWithDebInfo --target ext_qt6                   -- -j$CPU_CORES

#rm -fr /usr/local/lib/libssl.a    || true
#rm -fr /usr/local/lib/libcrypto.a || true
#rm -fr /usr/local/include/openssl || true

#################################################################################################

TerminateScript

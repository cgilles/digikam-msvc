#!/bin/bash

################################################################################
#
# Script to prepare a Linux Host installation to cross-compile Qt dependencies
# for Windows target using Clang-cl and MSVC SDK.
# This script must be run as sudo
#
# Copyright (c) 2013-2023, Gilles Caulier, <caulier dot gilles at gmail dot com>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.
#
################################################################################

. ./common.sh
. ./config.sh

#################################################################################################
# Manage script traces to log file

mkdir -p $INSTALL_DIR/logs
exec > >(tee $INSTALL_DIR/logs/msvc-preparehost-ubuntu.full.log) 2>&1

#################################################################################################
# Pre-processing checks

ChecksRunAsRoot
StartScript
ChecksLinuxVersionAndName

echo -e "---------- Update Linux Ubuntu Host\n"

# for downloading package information from all configured sources.

sudo apt-get update
sudo apt-get upgrade

# benefit from a higher version of certain software, update the key

sudo apt-key adv --refresh-keys --keyserver keyserver.ubuntu.com
sudo add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"

# To fix GPP key error with some repositories
# See: https://www.skyminds.net/linux-resoudre-les-erreurs-communes-de-cle-gpg-dans-apt/

sudo apt-get update 2>&1 | \
    sed -ne 's?^.*NO_PUBKEY ??p' | \
    xargs -r -- sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys

echo -e "---------- Install New Development Packages\n"

# Install dependencies to Checkout Source Code

sudo apt-get install -y git
sudo apt-get install -y perl

optional_packages=("cmake"
                   "build-essential"
                   "ccache"
                   "python3"
                   "yasm"
                   "msitools"
                   "python3-simplejson"
                   "python3-six"
                   "ca-certificates"
                   "winbind"
                   "clang"
                   "clang-16"
                   "clang-tools-16"
                   "lld"
)

for pkg in ${optional_packages[@]}; do
    sudo apt-get install -y ${pkg}
    echo "-------------------------------------------------------------------"
done

# Switch to new compiler

update-alternatives --install /usr/bin/clang-cl clang-cl /usr/bin/clang-cl-16 16

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

cd $ORIG_WD/msvc-wrapper/

# Download and unpack MSVC

if [[ ! -d $DOWNLOAD_DIR/VC ]] ; then

    ./vsdownload.py --dest $DOWNLOAD_DIR

fi

# Clean up headers, add scripts for setting up the environments

./install.sh $DOWNLOAD_DIR

# Check if compilation works as expected with Cmake.

cd $ORIG_WD/msvc-wrapper/

export BIN=$DOWNLOAD_DIR/bin/x64
. ./msvcenv-native.sh

cd $ORIG_WD/msvc-wrapper/test

./test-cmake-clang-cl.sh

cd $ORIG_WD

#################################################################################################

TerminateScript

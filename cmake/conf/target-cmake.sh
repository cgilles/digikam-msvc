#!/usr/bin/env bash

# https://cmake.org/cmake/help/latest/manual/cmake-policies.7.html
# https://cmake.org/cmake/help/latest/variable/CMAKE_POLICY_DEFAULT_CMPNNNN.html
POLICIES=(0017,0020)

unset NO_MXE_TOOLCHAIN

if echo -- "$@" | grep -Ewq "(--build|--install|-E|--system-information)" ; then

    NO_MXE_TOOLCHAIN=1

fi

if [[ "$NO_MXE_TOOLCHAIN" == "1" ]]; then

    # see https://github.com/mxe/mxe/issues/932
    exec "@PREFIX@/@BUILD@/bin/cmake" "$@"

else

    echo "== Using MXE wrapper: @PREFIX@/bin/@TARGET@-cmake"
    echo "     - cmake version @CMAKE_VERSION@"
    echo "     - warnings for unused CMAKE_POLICY_DEFAULT variables can be ignored"
    echo "== Using MXE toolchain: @CMAKE_TOOLCHAIN_FILE@"
    echo "== Using MXE runresult: @CMAKE_RUNRESULT_FILE@"

    if ! ( echo "$@" | grep --silent "DCMAKE_BUILD_TYPE" ) ; then
        echo '== Adding "-DCMAKE_BUILD_TYPE=Release"'
        set -- "-DCMAKE_BUILD_TYPE=Release" "$@"
    fi

    exec "@PREFIX@/@BUILD@/bin/cmake" \
              -DCMAKE_TOOLCHAIN_FILE="@CMAKE_TOOLCHAIN_FILE@" \
              `eval echo -DCMAKE_POLICY_DEFAULT_CMP{$POLICIES}=NEW` \
              -C"@CMAKE_RUNRESULT_FILE@" "$@"

fi

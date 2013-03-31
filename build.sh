#!/bin/sh
ARCHOPT="arm"

if [ "X${1}" != "X" ];then
    ARCHOPT=${1}
fi

#===============================================================================
#       functions
#===============================================================================
build_for_arm()
{
    export ONYXDIR="/opt/onyx"
    export PREFIX="${ONYXDIR}/mwo"
    export PATH=/opt/onyx/arm/bin/:/opt/freescale/usr/local/gcc-4.4.4-glibc-2.11.1-multilib-1.0/arm-fsl-linux-gnueabi/bin/:${PATH}

    CLFS_TARGET=arm-linux
    export CC="${CLFS_TARGET}-gcc"
    export CXX="${CLFS_TARGET}-g++"
    export AR="${CLFS_TARGET}-ar"
    export AS="${CLFS_TARGET}-as"
    export RANLIB="${CLFS_TARGET}-ranlib"
    export LD="${CLFS_TARGET}-ld"
    export STRIP="${CLFS_TARGET}-strip"

    export PKG_CONFIG_PATH=${ONYXDIR}/mwo/lib/pkgconfig:/opt/onyx/arm/lib/pkgconfig/ 
    export PKG_CONFIG_LIBDIR=${PKG_CONFIG_PATH}

    export LIBPNG_CFLAGS="-I${ONYXDIR}/arm/include/libpng12"
    export LIBPNG_LIBS="-L${ONYXDIR}/arm/lib -lpng12"

    export FREETYPE_CFLAGS="-I${ONYXDIR}/arm/include/freetype2 -I${ONYXDIR}/arm/include"
    export FREETYPE_LIBS="-L${ONYXDIR}/arm/lib -lfreetype"

    #export TSLIB_CFLAGS="-I${DEST_DIR}/onyx/arm/include"
    #export TSLIB_LIBS="-L${DEST_DIR}/onyx/arm/lib -lts"

    export DIRECTFB_CFLAGS="-I${ONYXDIR}/mwo/include/directfb -I${ONYXDIR}/mwo/include"
    export DIRECTFB_LIBS="-L${ONYXDIR}/mwo/lib -ldirectfb -ldirect -lfusion"
    export CFLAGS="-g -I${ONYXDIR}/arm/include ${LIBPNG_CFLAGS} ${FREETYPE_CFLAGS} ${DIRECTFB_CFLAGS}"
    export LDFLAGS="-L${ONYXDIR}/arm/lib ${LIBPNG_LIBS} ${FREETYPE_LIBS} ${DIRECTFB_LIBS}"

    #export QMAKESPEC=/opt/onyx/arm/mkspecs/qws/linux-arm-g++/

    install -d build/arm
    export BUILD_DIR="build/arm"
    make -j2
}

build_for_x86()
{
    install -d build/x86
    cd build/x86 && cmake ../.. -DBUILD_FOR_X86:BOOL=ON
    make -j2
}
#===============================================================================
#       end of functions
#===============================================================================

case ${ARCHOPT} in
    "arm")
        echo "Building for ${ARCHOPT} ..."
        TARGET=arm-linux
        build_for_arm
        exit 0
        ;;
    "x86")
        echo "Building for ${ARCHOPT} ..."
        TARGET=i686-linux
        build_for_x86
        exit 0
        ;;
    *)
        echo "ARCH option ${ARCHOPT} is wrong or not supported yet."
        echo "Build aborted. Exit."
        exit 1
        ;;
esac


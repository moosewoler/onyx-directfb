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
    export CC="${TARGET}-gcc"
    export CXX="${TARGET}-g++"
    export AR="${TARGET}-ar"
    export AS="${TARGET}-as"
    export RANLIB="${TARGET}-ranlib"
    export LD="${TARGET}-ld"
    export STRIP="${TARGET}-strip"

    export PREFIX=/onyx-mwo
    export DEST_DIR=/opt
    export PATH=/opt/onyx/arm/bin/:/opt/freescale/usr/local/gcc-4.4.4-glibc-2.11.1-multilib-1.0/arm-fsl-linux-gnueabi/bin/:$PATH  

    export PKG_CONFIG_PATH=${DEST_DIR}${PREFIX}/lib/pkgconfig:/opt/onyx/arm/lib/pkgconfig/ 
    export PKG_CONFIG_LIBDIR=${PKG_CONFIG_PATH}

    export LIBPNG_CFLAGS="-I${DEST_DIR}${PREFIX}/include/libpng12"
    export FREETYPE_CFLAGS="-I${DEST_DIR}${PREFIX}/include/freetype2 -I${DEST_DIR}${PREFIX}/include"
    export DIRECTFB_CFLAGS="-I${DEST_DIR}${PREFIX}/include/directfb -I${DEST_DIR}${PREFIX}/include"
    export CFLAGS="-g -I${DEST_DIR}${PREFIX}/include ${LIBPNG_CFLAGS} ${FREETYPE_CFLAGS} ${DIRECTFB_CFLAGS}"

    export LIBPNG_LIBS="-L${DEST_DIR}${PREFIX}/lib -lpng12"
    export FREETYPE_LIBS="-L${DEST_DIR}${PREFIX}/lib -lfreetype"
    export DIRECTFB_LIBS="-L${DEST_DIR}${PREFIX}/lib -ldirectfb -ldirect -lfusion -lz"
    export LDFLAGS="-L${DEST_DIR}${PREFIX}/lib ${LIBPNG_LIBS} ${FREETYPE_LIBS} ${DIRECTFB_LIBS}"

    export QMAKESPEC=/opt/onyx/arm/mkspecs/qws/linux-arm-g++/

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


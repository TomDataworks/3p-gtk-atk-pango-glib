#!/bin/bash

# turn on verbose debugging output for parabuild logs.
set -x
# make errors fatal
set -e

stage="$(pwd)"
cd "$(dirname "$0")"
TOP="$(pwd)"

PROJECT="gtk-etc"
ATK_VERSION="1.30.0"
ATK_SOURCE_DIR="atk-$ATK_VERSION"
PIXMAN_VERSION="0.17.14"
PIXMAN_SOURCE_DIR="pixman-$PIXMAN_VERSION"
CAIRO_VERSION="1.8.10"
CAIRO_SOURCE_DIR="cairo-$CAIRO_VERSION"
PANGO_VERSION="1.28.4"
PANGO_SOURCE_DIR="pango-$PANGO_VERSION"
GTK_VERSION="2.20.1"
GTK_SOURCE_DIR="gtk+-$GTK_VERSION"

if [ -z "$AUTOBUILD" ] ; then 
    fail
fi

if [ "$OSTYPE" = "cygwin" ] ; then
    export AUTOBUILD="$(cygpath -u $AUTOBUILD)"
fi

# load autbuild provided shell functions and variables
set +x
eval "$("$AUTOBUILD" source_environment)"
eval "$AUTOBUILD install"
set -x


setup_packages()
{
   # sadly pkgconfig doesn't actually understand prefix=${PREBUILD_DIR}
   find "$1" -type f  -name '*.pc' \
       -exec perl -pi -e "\$bar='$stage/packages';s/\\$\{PREBUILD_DIR\}/\$bar/" {} \;
   rm -f "$1"/../*.la
}

build_linux()
{
         LIB_LINK_DIR="$stage/packages/lib/release"
         MAKE_OPTIONS="-j 4"

         export LD_RUN_PATH="$LIB_LINK_DIR:$LD_RUN_PATH"
         export LD_LIBRARY_PATH="$LIB_LINK_DIR:$LD_LIBRARY_PATH"
         export LDFLAGS="-m$1 -L$LIB_LINK_DIR"
         export CFLAGS="-O3 -m$1 -msse2 -mfpmath=sse -pipe -ftree-vectorize"
         export CXXFLAGS=$CFLAGS
         export PKG_CONFIG_PATH="$stage/packages/lib/release/pkgconfig"

         setup_packages $PKG_CONFIG_PATH

         # we don't want to rebuild gtk each time one of these is updated
         # so kill the shared versions 
         rm -f "$stage"/packages/lib/release/libxml2.so*
         rm -f "$stage"/packages/lib/release/libz.so*

         pushd "$TOP/$ATK_SOURCE_DIR"
         ./configure --prefix="\${PREBUILD_DIR}"    \
                     --libdir="\${prefix}/lib/release" \
                     --includedir="\${prefix}/include" \
                     --disable-rpath

         make $MAKE_OPTIONS
         make install DESTDIR="$stage"
         make install DESTDIR="$stage/packages"
         make distclean
         setup_packages $PKG_CONFIG_PATH
         popd

         pushd "$TOP/$PIXMAN_SOURCE_DIR"
         ./configure --prefix="\${PREBUILD_DIR}"    \
                     --libdir="\${prefix}/lib/release" \
                     --includedir="\${prefix}/include" \
                     --disable-rpath \
                     --disable-gtk

         make $MAKE_OPTIONS
         make install DESTDIR="$stage"
         make install DESTDIR="$stage/packages"
         make distclean
         setup_packages $PKG_CONFIG_PATH
         popd

         pushd "$TOP/$CAIRO_SOURCE_DIR"
         ./configure --prefix="\${PREBUILD_DIR}"    \
                     --libdir="\${prefix}/lib/release" \
                     --includedir="\${prefix}/include" \
                     --enable-png=yes  \
                     --enable-ft=yes   \
                     --enable-fc=yes   \
                     --enable-ps=yes   \
                     --enable-pdf=yes  \
                     --enable-svg=yes  \
                     --enable-xml=no   \
                     --disable-rpath \
                     --enable-pthread=yes

         make $MAKE_OPTIONS
         make install DESTDIR="$stage"
         make install DESTDIR="$stage/packages"
         make distclean
         setup_packages $PKG_CONFIG_PATH
         popd

         pushd "$TOP/$PANGO_SOURCE_DIR"
         ./configure --prefix="\${PREBUILD_DIR}"    \
                     --libdir="\${prefix}/lib/release" \
                     --includedir="\${prefix}/include" \
                     --disable-rpath \
                     --with-x

         make $MAKE_OPTIONS
         make install DESTDIR="$stage"
         make install DESTDIR="$stage/packages"
         make distclean
         setup_packages $PKG_CONFIG_PATH
         popd

         pushd "$TOP/$GTK_SOURCE_DIR"
         ./configure --prefix="\${PREBUILD_DIR}"    \
                     --libdir="\${prefix}/lib/release" \
                     --includedir="\${prefix}/include" \
                     --disable-rpath \
                     --enable-explicit-deps=no \
                     --disable-papi     \
                     --disable-cups     \
                     --disable-glibtest \
                     --enable-gtk-doc-html=no \
                     --without-libjpeg  \
                     --without-libtiff  \
                     --with-x

        make $MAKE_OPTIONS
        make install DESTDIR="$stage"
        make distclean
        popd

        cp -f "$stage"/lib/release/gtk-2.0/include/gdkconfig.h "$stage"/include/gtk-2.0/gdkconfig.h

        # ceterum censeo gtk is a pain to build (see above),
        # a major reason for crashes and malfunctions (see any viewers bugtracker),
        # a quite heavy dependency for just opening windows and handling the clipboard,
        # and can't do anything Qt wouldn't do at least equally well.
}

case "$AUTOBUILD_PLATFORM" in
     "linux")
       build_linux 32
     ;;
     "linux64")
       build_linux 64
    ;;
    *)
        echo "platform not supported"
        exit -1
    ;;
esac


mkdir -p "$stage/LICENSES"

LICENSE_FILE="$stage/LICENSES/gtk-etc.txt"


echo "----------------------------" >> $LICENSE_FILE
echo "$ATK_SOURCE_DIR License:" >> $LICENSE_FILE
echo "----------------------------" >> $LICENSE_FILE
cat "$TOP/$ATK_SOURCE_DIR/COPYING" >> $LICENSE_FILE

echo "----------------------------" >> $LICENSE_FILE
echo "$PIXMAN_SOURCE_DIR License:" >> $LICENSE_FILE
echo "----------------------------" >> $LICENSE_FILE
cat "$TOP/$PIXMAN_SOURCE_DIR/COPYING" >> $LICENSE_FILE

echo "----------------------------" >> $LICENSE_FILE
echo "$CAIRO_SOURCE_DIR License:" >> $LICENSE_FILE
echo "----------------------------" >> $LICENSE_FILE
cat "$TOP/$CAIRO_SOURCE_DIR/COPYING" >> $LICENSE_FILE

echo "----------------------------" >> $LICENSE_FILE
echo "$PANGO_SOURCE_DIR License:" >> $LICENSE_FILE
echo "----------------------------" >> $LICENSE_FILE
cat "$TOP/$PANGO_SOURCE_DIR/COPYING" >> $LICENSE_FILE

echo "----------------------------" >> $LICENSE_FILE
echo "$GTK_SOURCE_DIR License:" >> $LICENSE_FILE
echo "----------------------------" >> $LICENSE_FILE
cat "$TOP/$GTK_SOURCE_DIR/COPYING" >> $LICENSE_FILE

README_DIR="$stage/autobuild-bits"
README_FILE="$README_DIR/README-Version-3p-$PROJECT"
mkdir -p $README_DIR
cat $TOP/.hg/hgrc|grep default |sed  -e "s/default = ssh:\/\/hg@/https:\/\//" > $README_FILE
echo "Commit $(hg id -i)" >> $README_FILE

pass


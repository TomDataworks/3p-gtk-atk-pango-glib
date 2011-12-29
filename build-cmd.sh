#!/bin/bash

# turn on verbose debugging output for parabuild logs.
set -x
# make errors fatal
set -e

TOP="$(dirname "$0")"
GLIB_VERSION="2.24.2"
GLIB_SOURCE_DIR="glib-$GLIB_VERSION"
FONTCONFIG_VERSION="2.8.0"
FONTCONFIG_SOURCE_DIR="fontconfig-$FONTCONFIG_VERSION"
FREETYPE_VERSION="2.3.11"
FREETYPE_SOURCE_DIR="freetype-$FREETYPE_VERSION"
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
set -x

stage="$(pwd)"
case "$AUTOBUILD_PLATFORM" in
#      "linux")
# 
#      ;;
     "linux64")
         LIB_LINK_DIR="$stage/lib"
         MAKE_OPTIONS="-j 4"

         export LD_RUN_PATH="$LIB_LINK_DIR:$LD_RUN_PATH"
         export LD_LIBRARY_PATH="$LIB_LINK_DIR:$LD_LIBRARY_PATH"
         export LDFLAGS="-m64 -L$LIB_LINK_DIR"
         export CFLAGS="-O3 -m64 -msse2 -mfpmath=sse -pipe -ftree-vectorize"
         export CXXFLAGS=$CFLAGS
         export  PKG_CONFIG_PATH="$stage/lib/pkgconfig/"



         pushd "$TOP/$GLIB_SOURCE_DIR"
             ./configure --prefix="$stage"    \
                         --disable-selinux    \
                         --with-libiconv=no   \
                         --with-threads=posix \
                         --with-pcre=internal
             make $MAKE_OPTIONS
             make install
         popd
         cp -f lib/glib-2.0/include/glibconfig.h include/glib-2.0/glibconfig.h

         pushd "$TOP/$FONTCONFIG_SOURCE_DIR"
             ./configure --prefix="$stage"
             make $MAKE_OPTIONS
             make install
         popd

         pushd "$TOP/$FREETYPE_SOURCE_DIR"
             ./configure --prefix="$stage"
             make $MAKE_OPTIONS
             make install
         popd

         pushd "$TOP/$ATK_SOURCE_DIR"
             ./configure --prefix="$stage" 
             make $MAKE_OPTIONS
             make install
         popd

         pushd "$TOP/$PIXMAN_SOURCE_DIR"
             ./configure --prefix="$stage" \
                         --disable-gtk
             make $MAKE_OPTIONS
             make install
         popd

         export pixman_CFLAGS="-I$stage/include/pixman-1"
         export FREETYPE_CFLAGS="-I$stage/include/freetype2"
         export FONTCONFIG_CFLAGS="-I$stage/include/fontconfig"
         pushd "$TOP/$CAIRO_SOURCE_DIR"
             ./configure --prefix="$stage" \
                         --enable-png=yes  \
                         --enable-ft=yes   \
                         --enable-fc=yes   \
                         --enable-ps=yes   \
                         --enable-pdf=yes  \
                         --enable-svg=yes  \
                         --enable-xml=no   \
                         --enable-pthread=yes
             make $MAKE_OPTIONS
             make install
         popd

         export CAIRO_CFLAGS="-I$stage/include/cairo"
         export GLIB_CFLAGS="-I$stage/include/glib-2.0"
         pushd "$TOP/$PANGO_SOURCE_DIR"
             ./configure --prefix="$stage" \
                         --with-x
             make $MAKE_OPTIONS
             make install
         popd

         pushd "$TOP/$GTK_SOURCE_DIR"
             ./configure --prefix="$stage"  \
                         --disable-papi     \
                         --disable-cups     \
                         --disable-glibtest \
                         --without-libjpeg  \
                         --without-libtiff  \
                         --with-x
             make $MAKE_OPTIONS
             make install
        popd
        cp -f lib/gtk-2.0/include/gdkconfig.h include/gtk-2.0/gdkconfig.h

        mv lib release
        mkdir -p lib
        mv release lib
    ;;
    *)
        echo "platform not supported"
        exit -1
    ;;
esac


mkdir -p "$stage/LICENSES"

LICENSE_FILE="$stage/LICENSES/gtk-etc.txt"

echo "----------------------------" > $LICENSE_FILE
echo "$GLIB_SOURCE_DIR License:" >> $LICENSE_FILE
echo "----------------------------" >> $LICENSE_FILE
cat "$TOP/$GLIB_SOURCE_DIR/COPYING" >> $LICENSE_FILE

echo "----------------------------" >> $LICENSE_FILE
echo "$FONTCONFIG_SOURCE_DIR License:" >> $LICENSE_FILE
echo "----------------------------" >> $LICENSE_FILE
cat "$TOP/$FONTCONFIG_SOURCE_DIR/COPYING" >> $LICENSE_FILE

echo "----------------------------" >> $LICENSE_FILE
echo "$FREETYPE_SOURCE_DIR License:" >> $LICENSE_FILE
echo "----------------------------" >> $LICENSE_FILE
cat "$TOP/$FREETYPE_SOURCE_DIR/docs/FTL.TXT" >> $LICENSE_FILE

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

pass


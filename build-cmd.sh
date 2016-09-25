#!/bin/bash

# turn on verbose debugging output for parabuild logs.
set -x
# make errors fatal
set -e

stage="$(pwd)"
cd "$(dirname "$0")"
TOP="$(pwd)"

COLLECTION_VERSION="0.0.3"
PROJECT="gtk-atk-pango-glib"
GLIB_VERSION="2.48.0"
GLIB_SOURCE_DIR="glib-$GLIB_VERSION"
ATK_VERSION="2.18.0"
ATK_SOURCE_DIR="atk-$ATK_VERSION"
PIXMAN_VERSION="0.32.8"
PIXMAN_SOURCE_DIR="pixman-$PIXMAN_VERSION"
CAIRO_VERSION="1.14.6"
CAIRO_SOURCE_DIR="cairo-$CAIRO_VERSION"
HARFBUZZ_VERSION="1.0.1"
HARFBUZZ_SOURCE_DIR="harfbuzz-$HARFBUZZ_VERSION"
PANGO_VERSION="1.38.1"
PANGO_SOURCE_DIR="pango-$PANGO_VERSION"
GDK_PIXBUF_VERSION="2.32.2"
GDK_PIXBUF_SOURCE_DIR="gdk-pixbuf-$GDK_PIXBUF_VERSION"
GTK_VERSION="2.24.30"
GTK_SOURCE_DIR="gtk+-$GTK_VERSION"


if [ -z "$AUTOBUILD" ] ; then 
    fail
fi

if [ "$OSTYPE" = "cygwin" ] ; then
    export AUTOBUILD="$(cygpath -u $AUTOBUILD)"
fi

echo "${COLLECTION_VERSION}" > "${stage}/VERSION.txt"

# load autbuild provided shell functions and variables
set +x
eval "$("$AUTOBUILD" source_environment)"
eval "$AUTOBUILD install"
set -x


build_linux()
{
         LIB_LINK_DIR="$stage/packages/lib/release"
	 JOBS=`cat /proc/cpuinfo | grep processor | wc -l`
         HARDENED="-fstack-protector-strong -D_FORTIFY_SOURCE=2"
         MAKE_OPTIONS="-j$JOBS"

         export LD_RUN_PATH="$LIB_LINK_DIR:$LD_RUN_PATH"
         export LD_LIBRARY_PATH="$LIB_LINK_DIR:$LD_LIBRARY_PATH"
         export LDFLAGS="-m$1 -L$LIB_LINK_DIR"
         export CFLAGS="-O3 -m$1 $HARDENED -I$stage/packages/include -I$stage/packages/include/libpng16"
         export CXXFLAGS="$CFLAGS -std=c++11"
         export PKG_CONFIG_PATH="$stage/packages/lib/release/pkgconfig"

         # we don't want to rebuild gtk each time one of these is updated
         # so kill the shared versions 
         rm -f "$stage"/packages/lib/release/libxml2.so*
         rm -f "$stage"/packages/lib/release/libz.so*

         fix_pkgconfig_prefix "$stage/packages"
         rm -f $stage/packages/lib/release/*.la

         pushd "$TOP/$GLIB_SOURCE_DIR"
         ./configure --prefix="\${AUTOBUILD_PACKAGES_DIR}"    \
                     --libdir="\${prefix}/lib/release" \
                     --includedir="\${prefix}/include" \
                     --disable-selinux    \
                     --with-libiconv=no   \
                     --with-threads=posix \
                     --with-pcre=internal
 
         make $MAKE_OPTIONS
         make install DESTDIR="$stage"
         make install DESTDIR="$stage/packages"
 
         cp -f $stage/lib/release/glib-2.0/include/glibconfig.h $stage/include/glib-2.0/glibconfig.h
 
         make distclean
         fix_pkgconfig_prefix "$stage/packages"
         rm -f $stage/packages/lib/release/*.la
         popd
 
         pushd "$TOP/$ATK_SOURCE_DIR"
         ./configure --prefix="\${AUTOBUILD_PACKAGES_DIR}"    \
                     --libdir="\${prefix}/lib/release" \
                     --includedir="\${prefix}/include" \
                     --disable-rpath
 
         make $MAKE_OPTIONS
         make install DESTDIR="$stage"
         make install DESTDIR="$stage/packages"
         make distclean
         fix_pkgconfig_prefix "$stage/packages"
         rm -f $stage/packages/lib/release/*.la
         popd
 
         pushd "$TOP/$PIXMAN_SOURCE_DIR"
         ./configure --prefix="\${AUTOBUILD_PACKAGES_DIR}"    \
                     --libdir="\${prefix}/lib/release" \
                     --includedir="\${prefix}/include" \
                     --disable-rpath \
                     --disable-gtk
 
         make $MAKE_OPTIONS
         make install DESTDIR="$stage"
         make install DESTDIR="$stage/packages"
         make distclean
         fix_pkgconfig_prefix "$stage/packages"
         rm -f $stage/packages/lib/release/*.la
         popd
 
         pushd "$TOP/$CAIRO_SOURCE_DIR"
         ./configure --prefix="\${AUTOBUILD_PACKAGES_DIR}"    \
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
         fix_pkgconfig_prefix "$stage/packages"
         rm -f $stage/packages/lib/release/*.la
         popd

         pushd "$TOP/$HARFBUZZ_SOURCE_DIR"
         ./configure --prefix="\${AUTOBUILD_PACKAGES_DIR}" \
                     --libdir="\${prefix}/lib/release" \
                     --includedir="\${prefix}/include" \
                     --enable-gtk-doc-html=no

         make $MAKE_OPTIONS
         make install DESTDIR="$stage"
         make install DESTDIR="$stage/packages"
         make distclean

         cp $TOP/extras/*.pc $stage/lib/release/pkgconfig/
         cp $TOP/extras/*.pc $stage/packages/lib/release/pkgconfig/

         fix_pkgconfig_prefix "$stage/packages"
         rm -f $stage/packages/lib/release/*.la
         popd

         pushd "$TOP/$PANGO_SOURCE_DIR"
         ./configure --prefix="\${AUTOBUILD_PACKAGES_DIR}"    \
                     --libdir="\${prefix}/lib/release" \
                     --includedir="\${prefix}/include" \
                     --disable-rpath \
                     --with-x

         make $MAKE_OPTIONS
         make install DESTDIR="$stage"
         make install DESTDIR="$stage/packages"
         make distclean
         fix_pkgconfig_prefix "$stage/packages"
         rm -f $stage/packages/lib/release/*.la
         popd

         pushd "$TOP/$GDK_PIXBUF_SOURCE_DIR"
         ./configure --prefix="\${AUTOBUILD_PACKAGES_DIR}"    \
                     --libdir="\${prefix}/lib/release" \
                     --includedir="\${prefix}/include" \
                     --enable-gtk-doc-html=no \
                     --with-libpng   \
                     --without-libjpeg  \
                     --without-libtiff  \
                     --with-x11 \
                     --disable-rpath

         make $MAKE_OPTIONS
         make install DESTDIR="$stage"
         make install DESTDIR="$stage/packages"
         make distclean
         fix_pkgconfig_prefix "$stage/packages"
         rm -f $stage/packages/lib/release/*.la
         popd

         export GDK_PIXBUF_MODULE_FILE="$stage/packages/lib/release/gdk-pixbuf-2.0/2.10.0/loaders.cache"
         export GDK_PIXBUF_MODULEDIR="$stage/packages/lib/release/gdk-pixbuf-2.0/2.10.0/loaders"
         PATH="$stage/packages/bin:$PATH" gdk-pixbuf-query-loaders > $stage/packages/lib/release/gdk-pixbuf-2.0/2.10.0/loaders.cache

         pushd "$TOP/$GTK_SOURCE_DIR"
         PATH="$stage/packages/bin:$PATH" \
         ./configure --prefix="\${AUTOBUILD_PACKAGES_DIR}"    \
                     --libdir="\${prefix}/lib/release" \
                     --includedir="\${prefix}/include" \
                     --enable-explicit-deps=no \
                     --disable-papi     \
                     --disable-cups     \
                     --disable-glibtest \
                     --enable-gtk-doc-html=no \
                     --with-x

        make $MAKE_OPTIONS
        make install DESTDIR="$stage"
        make distclean
        popd

        cp -f "$stage"/lib/release/gtk-2.0/include/gdkconfig.h "$stage"/include/gtk-2.0/gdkconfig.h
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

LICENSE_FILE="$stage/LICENSES/gtk-atk-pango-glib.txt"

echo "----------------------------" >> $LICENSE_FILE
echo "$GLIB_SOURCE_DIR License:" >> $LICENSE_FILE
echo "----------------------------" >> $LICENSE_FILE
cat "$TOP/$GLIB_SOURCE_DIR/COPYING" >> $LICENSE_FILE

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
echo "$HARFBUZZ_SOURCE_DIR License:" >> $LICENSE_FILE
echo "----------------------------" >> $LICENSE_FILE
cat "$TOP/$HARFBUZZ_SOURCE_DIR/COPYING" >> $LICENSE_FILE

echo "----------------------------" >> $LICENSE_FILE
echo "$PANGO_SOURCE_DIR License:" >> $LICENSE_FILE
echo "----------------------------" >> $LICENSE_FILE
cat "$TOP/$PANGO_SOURCE_DIR/COPYING" >> $LICENSE_FILE

echo "----------------------------" >> $LICENSE_FILE
echo "$GDK_PIXBUF_SOURCE_DIR License:" >> $LICENSE_FILE
echo "----------------------------" >> $LICENSE_FILE
cat "$TOP/$GDK_PIXBUF_SOURCE_DIR/COPYING" >> $LICENSE_FILE

echo "----------------------------" >> $LICENSE_FILE
echo "$GTK_SOURCE_DIR License:" >> $LICENSE_FILE
echo "----------------------------" >> $LICENSE_FILE
cat "$TOP/$GTK_SOURCE_DIR/COPYING" >> $LICENSE_FILE

pass


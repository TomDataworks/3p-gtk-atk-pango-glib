#!/bin/bash

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
FFI_VERSION="3.2.1"
FFI_SOURCE_DIR="libffi-$FFI_VERSION"

TOP="$(dirname "$0")"
pushd $TOP
echo "checking for all source dirs"

if [ -d "$FFI_SOURCE_DIR" ]; then
   echo "$FFI_SOURCE_DIR is present"
else
   echo "$FFI_SOURCE_DIR not present, downloading"
   wget ftp://sourceware.org/pub/libffi/libffi-$FFI_VERSION.tar.gz
   tar -xvf libffi-$FFI_VERSION.tar.gz
fi

if [ -d "$GLIB_SOURCE_DIR" ]; then
   echo "$GLIB_SOURCE_DIR is present"
else
   echo "$GLIB_SOURCE_DIR not present, downloading"
   wget http://ftp.acc.umu.se/pub/GNOME/sources/glib/2.48/glib-$GLIB_VERSION.tar.xz
   tar -xvf glib-$GLIB_VERSION.tar.xz
fi

if [ -d "$ATK_SOURCE_DIR" ]; then
   echo "$ATK_SOURCE_DIR is present"
else
   echo "$ATK_SOURCE_DIR not present, downloading"
   wget http://ftp.gnome.org/pub/GNOME/sources/atk/2.18/atk-$ATK_VERSION.tar.xz
   tar -xvf atk-$ATK_VERSION.tar.xz
fi

if [ -d "$PIXMAN_SOURCE_DIR" ]; then
   echo "$PIXMAN_SOURCE_DIR is present"
else
   echo "$PIXMAN_SOURCE_DIR not present, downloading"
   wget --no-check-certificate http://cairographics.org/releases/pixman-$PIXMAN_VERSION.tar.gz
   tar -xvf pixman-$PIXMAN_VERSION.tar.gz
fi

if [ -d "$CAIRO_SOURCE_DIR" ]; then
   echo "$CAIRO_SOURCE_DIR is present"
else
   echo "$CAIRO_SOURCE_DIR not present, downloading"
   wget --no-check-certificate http://cairographics.org/releases/cairo-$CAIRO_VERSION.tar.xz
   tar -xvf cairo-$CAIRO_VERSION.tar.xz
fi

if [ -d "$HARFBUZZ_SOURCE_DIR" ]; then
   echo "$HARFBUZZ_SOURCE_DIR is present"
else
   echo "$HARFBUZZ_SOURCE_DIR not present, downloading"
   wget --no-check-certificate http://www.freedesktop.org/software/harfbuzz/release/harfbuzz-$HARFBUZZ_VERSION.tar.bz2
   tar -xvf harfbuzz-$HARFBUZZ_VERSION.tar.bz2
fi

if [ -d "$PANGO_SOURCE_DIR" ]; then
   echo "$PANGO_SOURCE_DIR is present"
else
   echo "$PANGO_SOURCE_DIR not present, downloading"
   wget http://ftp.gnome.org/pub/gnome/sources/pango/1.38/pango-$PANGO_VERSION.tar.xz
   tar -xvf pango-$PANGO_VERSION.tar.xz
fi

if [ -d "$GDK_PIXBUF_SOURCE_DIR" ]; then
   echo "$GDK_PIXBUF_SOURCE_DIR is present"
else
   echo "$GDK_PIXBUF_SOURCE_DIR not present, downloading"
   wget http://ftp.gnome.org/pub/gnome/sources/gdk-pixbuf/2.32/gdk-pixbuf-$GDK_PIXBUF_VERSION.tar.xz
   tar -xvf gdk-pixbuf-$GDK_PIXBUF_VERSION.tar.xz
fi

if [ -d "$GTK_SOURCE_DIR" ]; then
   echo "$GTK_SOURCE_DIR is present"
else
   echo "$GTK_SOURCE_DIR not present, downloading"
   wget http://ftp.gnome.org/pub/gnome/sources/gtk+/2.24/gtk+-$GTK_VERSION.tar.xz
   tar -xvf gtk+-$GTK_VERSION.tar.xz
fi

# if [ -d "$" ]; then
#    echo "$ is present"
# else
#    echo "$ not present, downloading"
#    wget 
#    tar -xzf 
# fi
popd

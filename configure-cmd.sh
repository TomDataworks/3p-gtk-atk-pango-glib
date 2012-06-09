#!/bin/bash

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

TOP="$(dirname "$0")"
pushd $TOP
echo "checking for all source dirs"


if [ -d "$ATK_SOURCE_DIR" ]; then
   echo "$ATK_SOURCE_DIR is present"
else
   echo "$ATK_SOURCE_DIR not present, downloading"
   wget http://ftp.gnome.org/pub/GNOME/sources/atk/1.30/atk-1.30.0.tar.gz
   tar -xzf atk-1.30.0.tar.gz
fi

if [ -d "$PIXMAN_SOURCE_DIR" ]; then
   echo "$PIXMAN_SOURCE_DIR is present"
else
   echo "$PIXMAN_SOURCE_DIR not present, downloading"
   wget http://cairographics.org/snapshots/pixman-0.17.14.tar.gz
   tar -xzf pixman-0.17.14.tar.gz
fi

if [ -d "$CAIRO_SOURCE_DIR" ]; then
   echo "$CAIRO_SOURCE_DIR is present"
else
   echo "$CAIRO_SOURCE_DIR not present, downloading"
   wget http://cairographics.org/releases/cairo-1.8.10.tar.gz
   tar -xzf cairo-1.8.10.tar.gz
fi

if [ -d "$PANGO_SOURCE_DIR" ]; then
   echo "$PANGO_SOURCE_DIR is present"
else
   echo "$PANGO_SOURCE_DIR not present, downloading"
   wget http://ftp.gnome.org/pub/gnome/sources/pango/1.28/pango-1.28.4.tar.gz
   tar -xzf pango-1.28.4.tar.gz
fi

if [ -d "$GTK_SOURCE_DIR" ]; then
   echo "$GTK_SOURCE_DIR is present"
else
   echo "$GTK_SOURCE_DIR not present, downloading"
   wget http://ftp.gnome.org/pub/gnome/sources/gtk+/2.20/gtk+-2.20.1.tar.gz
   tar -xzf gtk+-2.20.1.tar.gz
fi

# if [ -d "$" ]; then
#    echo "$ is present"
# else
#    echo "$ not present, downloading"
#    wget 
#    tar -xzf 
# fi
popd
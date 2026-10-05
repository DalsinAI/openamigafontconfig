#!/bin/sh
# openamigafontconfig: Fontconfig, built for AmigaOS 3.x (68020 + FPU) with the
# os32-gcc16 compiler (bebbo's amiga-gcc, GCC 16.2, libnix, libpthread).
# MIT, Copyright (c) 2026 Dalsin Limited. The library keeps its own licence.
#
#   OS32_GCC16   compiler root holding prefix/ and compat/
#                (default ~/AmigaChrome/stoves/os32-gcc16)
#   PREFIX       where include/ and lib/ go (default ./out)
#   TARBALLS     folder holding the upstream tarballs listed in SOURCES
#                (default ./tarballs); the script checks their SHA-256
#   JOBS         parallel jobs for CMake/make builds (default 2)
#
# usage: ./build.sh
set -eu
HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
S=${OS32_GCC16:-"$HOME/AmigaChrome/stoves/os32-gcc16"}
P=$S/prefix
OUT=${PREFIX:-"$HERE/out"}
TARBALLS=${TARBALLS:-"$HERE/tarballs"}
JOBS=${JOBS:-2}
WORK="$HERE/work"
CC="$P/bin/m68k-amigaos-gcc"
CXX="$P/bin/m68k-amigaos-g++"
AR="$P/bin/m68k-amigaos-ar"
CPU="-m68020 -m68881 -mcrt=nix20"
CFLAGS="-O2 $CPU -D_DEFAULT_SOURCE=1 -D_POSIX_TIMERS=1 -D_POSIX_REALTIME_SIGNALS=1 -fno-common"
mkdir -p "$OUT/include" "$OUT/lib" "$WORK"

# unpack NAME TARBALL SHA256: check the tarball and unpack it into $WORK
unpack() {
    t="$TARBALLS/$2"
    [ -f "$t" ] || { echo "missing $t (see SOURCES)"; exit 2; }
    echo "$3  $t" | sha256sum -c - >/dev/null || { echo "SHA-256 mismatch: $t"; exit 2; }
    rm -rf "$WORK/$1"; mkdir -p "$WORK/$1"
    case "$2" in
        *.zip) (cd "$WORK/$1" && unzip -q "$t") ;;
        *) tar xf "$t" -C "$WORK/$1" ;;
    esac
}

# archive NAME FILE...: compile into $OUT/lib/libNAME.a ($XFLAGS added)
archive() {
    name=$1; shift
    obj="$WORK/obj-$name"
    rm -rf "$obj"; mkdir -p "$obj"
    for f in "$@"; do
        o="$obj/$(echo "$f" | tr '/' '_' | sed 's/\.[a-z]*$//').o"
        case "$f" in
            *.cc|*.cpp) $CXX $CFLAGS ${XFLAGS:-} -c "$f" -o "$o" ;;
            *) $CC $CFLAGS ${XFLAGS:-} -c "$f" -o "$o" ;;
        esac
    done
    rm -f "$OUT/lib/lib$name.a"
    $AR rcs "$OUT/lib/lib$name.a" "$obj"/*.o
    echo "lib$name.a: $(wc -c < "$OUT/lib/lib$name.a") bytes"
}

DEPS=${DEPS_PREFIX:?set DEPS_PREFIX to a prefix with FreeType, libpng, zlib and Expat}
unpack fontconfig fontconfig-2.18.3.tar.xz 4f7b554a38cdf78c033f666c8871f3749e14a094f65a07f630c91ed0b43d35e3
cd "$WORK/fontconfig/fontconfig-2.18.3"
patch -p1 < "$HERE/patches/fontconfig-2.18.3-amiga-paths.patch"
patch -p1 < "$HERE/patches/fontconfig-2.18.3-amiga-cache.patch"
mkdir -p build && cd build
PATH=$P/bin:$PATH ac_cv_va_copy=C99 CC=m68k-amigaos-gcc AR=m68k-amigaos-ar RANLIB=m68k-amigaos-ranlib \
    CFLAGS="$CFLAGS" CPPFLAGS="-I$DEPS/include" LDFLAGS="-L$DEPS/lib" \
    FREETYPE_CFLAGS="-I$DEPS/include/freetype2" FREETYPE_LIBS="-L$DEPS/lib -lfreetype -lpng -lz" PKG_CONFIG=/bin/false \
    ../configure --host=m68k-amigaos --build=x86_64-pc-linux-gnu --enable-static --disable-shared --disable-docs \
    --disable-nls --disable-cache-build --disable-rpath --with-arch=m68k --with-expat-includes="$DEPS/include" \
    --with-expat-lib="$DEPS/lib" --with-default-fonts=PROGDIR:Fonts --with-cache-dir=T:fontconfig \
    --with-baseconfigdir=PROGDIR:fontconfig --with-configdir=PROGDIR:fontconfig/conf.d \
    --with-templatedir=PROGDIR:fontconfig/conf.avail --with-xmldir=PROGDIR:fontconfig --prefix="$OUT"
# libnix has these functions but its headers do not declare them.
sed -i -e 's/^#define HAVE_GETPROGNAME 1/\/* no getprogname *\//' -e 's/^#define HAVE_VASPRINTF 1/\/* no vasprintf *\//' \
    -e 's/^#define HAVE_MKOSTEMP 1/\/* no mkostemp *\//' config.h
printf '#define HAVE_VSNPRINTF 1\n' >> config.h
for d in fontconfig fc-case fc-lang fc-const fc-genericfamily; do PATH=$P/bin:$PATH make -C $d; done
# pthread.h first: libpthread's cancellation macros (read(), close()...) must
# not be defined, or they break FreeType's stream->read() in ftglue.c.
PATH=$P/bin:$PATH make -j"$JOBS" -C src CFLAGS="$CFLAGS -include pthread.h"
cp src/.libs/libfontconfig.a "$OUT/lib/"
mkdir -p "$OUT/include/fontconfig"
cp fontconfig/fontconfig.h ../fontconfig/fcfreetype.h ../fontconfig/fcprivate.h "$OUT/include/fontconfig/"

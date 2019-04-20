#!/bin/bash
set -e
srcdir="$PWD"
wasisdk="/home/zhuowei/wasi-sdk"

# build ICU on the host first
if [ ! -e icu_host ]
then
	rm -rf icu_host || true
	tar xf icu4c-64_2-src.tgz
	mv icu icu_host
	patch -p0 <disable-obj-code.patch
	cd icu_host/source
	./configure
	make -j4
	cd ../..
fi

rm -rf icu icu_out || true
tar xf icu4c-64_2-src.tgz
# build the cross one
patch -p0 <patch-double-conversion.diff
cd icu/source
cp config/mh-linux config/mh-unknown
# note: I don't know if the AR and RANLIB is required - but I've had Ubuntu's ar and ranlib produce .a files that wasm-ld won't read.
./configure \
	--host=wasm32-unknown-none --enable-static --with-cross-build="$srcdir/icu_host/source" \
	--disable-shared \
	--disable-tools --disable-tests --disable-samples --disable-extras \
	--prefix="$srcdir/icu_out" \
	--with-data-packaging=files \
	CC="$wasisdk/bin/clang" CXX="$wasisdk/bin/clang++" AR="$srcdir/wrap-ar" \
	CFLAGS="-fuse-ld=$srcdir/fakeld" CXXFLAGS="-fno-exceptions" RANLIB="touch"
make -j4
make install

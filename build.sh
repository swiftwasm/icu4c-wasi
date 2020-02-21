#!/bin/bash
set -e
srcdir="$PWD"
wasisdk=${WASI_SDK:-"/home/zhuowei/wasi-sdk"}

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
patch -p0 < patch-double-conversion.diff
patch -p0 < build_data_with_cross_tools.patch
cd icu/source
cp config/mh-linux config/mh-unknown
autoconf

./configure \
	--host=wasm32-unknown-none \
	--with-cross-build="$srcdir/icu_host/source" \
	--enable-static --disable-shared \
	--disable-tools --disable-tests \
	--disable-samples --disable-extras \
	--prefix="$srcdir/icu_out" \
	--with-data-packaging=static \
	CC="$wasisdk/bin/clang" CXX="$wasisdk/bin/clang++" \
	AR="$wasisdk/bin/llvm-ar" RANLIB="$wasisdk/bin/llvm-ranlib" \
	CFLAGS="--sysroot $wasisdk/share/wasi-sysroot" \
	CXXFLAGS="-fno-exceptions --sysroot $wasisdk/share/wasi-sysroot"
make -j4
make install

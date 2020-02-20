#!/bin/bash
set -e
# install llvm
sudo apt-get install llvm -y

# install the Wasi SDK
wget -O dist-wasi-sdk.tgz.zip "https://github.com/swiftwasm/wasi-sdk/releases/download/0.2.0-swiftwasm/dist-ubuntu-latest.tgz.zip"
unzip dist-wasi-sdk.tgz.zip -d .
WASI_SDK_TAR_PATH=$(find . -type f -name "wasi-sdk-*")
WASI_SDK_FULL_NAME=$(basename $WASI_SDK_TAR_PATH -linux.tar.gz)
tar xfz $WASI_SDK_TAR_PATH
mv $WASI_SDK_FULL_NAME ./wasi-sdk

# Link wasm32-wasi-unknown to wasm32-wasi because clang finds crt1.o from sysroot
# with os and environment name `getMultiarchTriple`.
ln -s wasm32-wasi wasi-sdk/share/wasi-sysroot/lib/wasm32-wasi-unknown

# build it
./get_source.sh
WASI_SDK=$PWD/wasi-sdk ./build.sh
# package it
tar cJf icu4c-wasi.tar.xz icu_out

#!/bin/bash
set -xe

mkdir -p ci

# install the Wasi SDK
wget -O ci/dist-wasi-sdk.tgz.zip "https://github.com/swiftwasm/wasi-sdk/releases/download/0.2.0-swiftwasm/dist-ubuntu-latest.tgz.zip"
unzip ci/dist-wasi-sdk.tgz.zip -d ci
WASI_SDK_TAR_PATH=$(find ci -type f -name "wasi-sdk-*")
WASI_SDK_FULL_NAME=$(basename $WASI_SDK_TAR_PATH -linux.tar.gz)
tar xfz $WASI_SDK_TAR_PATH -C ci
mv ci/$WASI_SDK_FULL_NAME ./ci/wasi-sdk

# Link wasm32-wasi-unknown to wasm32-wasi because clang finds crt1.o from sysroot
# with os and environment name `getMultiarchTriple`.
ln -s wasm32-wasi ci/wasi-sdk/share/wasi-sysroot/lib/wasm32-wasi-unknown

# package it
WASI_SDK_PATH=$PWD/ci/wasi-sdk make icu4c-wasi.tar.xz

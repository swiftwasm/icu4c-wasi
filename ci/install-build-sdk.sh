#!/bin/bash
set -xe

: ${BUILD_DIR:?"BUILD_DIR is missing"}

mkdir -p $BUILD_DIR/ci

# install the Wasi SDK
wget -O $BUILD_DIR/ci/dist-wasi-sdk.tgz.zip "https://github.com/swiftwasm/wasi-sdk/releases/download/0.2.0-swiftwasm/dist-ubuntu-latest.tgz.zip"
unzip $BUILD_DIR/ci/dist-wasi-sdk.tgz.zip -d $BUILD_DIR/ci
WASI_SDK_TAR_PATH=$(find $BUILD_DIR/ci -type f -name "wasi-sdk-*")
WASI_SDK_FULL_NAME=$(basename $WASI_SDK_TAR_PATH -linux.tar.gz)
tar xfz $WASI_SDK_TAR_PATH -C $BUILD_DIR/ci
mv $BUILD_DIR/ci/$WASI_SDK_FULL_NAME $BUILD_DIR/ci/wasi-sdk

# Link wasm32-wasi-unknown to wasm32-wasi because clang finds crt1.o from sysroot
# with os and environment name `getMultiarchTriple`.
ln -s wasm32-wasi $BUILD_DIR/ci/wasi-sdk/share/wasi-sysroot/lib/wasm32-wasi-unknown

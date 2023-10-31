#!/bin/bash
set -xe

: ${BUILD_DIR:?"BUILD_DIR is missing"}

mkdir -p $BUILD_DIR/ci/wasi-sdk

curl -L -o $BUILD_DIR/ci/dist-wasi-sdk.tar.gz "https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-20/wasi-sdk-20.0-linux.tar.gz"
tar -xzf $BUILD_DIR/ci/dist-wasi-sdk.tar.gz --strip-components=1 -C $BUILD_DIR/ci/wasi-sdk

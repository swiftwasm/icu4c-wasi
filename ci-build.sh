#!/bin/bash
set -e
# install the Wasi SDK
wget -O wasisdk.deb "https://github.com/swiftwasm/wasi-sdk/releases/download/20190421.6/wasi-sdk_3.19gefb17cb478f9.m_amd64.deb"
sudo dpkg -i wasisdk.deb
# build it
./get_source.sh
WASI_SDK=/opt/wasi-sdk ./build.sh
# package it
tar cJf icu4c-wasi.tar.xz icu_out
# copy it
cp icu4c-wasi.tar.xz "$BUILD_ARTIFACTSTAGINGDIRECTORY/"


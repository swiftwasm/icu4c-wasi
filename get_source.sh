#!/bin/bash
set -e
rm icu4c-64_2-src.tgz || true
wget https://github.com/unicode-org/icu/releases/download/release-64-2/icu4c-64_2-src.tgz

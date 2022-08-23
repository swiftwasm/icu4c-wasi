BUILD := build
ICU_DATA_FILTER_FILE := $(CURDIR)/data-filters/swift-minimal.json

$(BUILD)/icu4c-src.tgz:
	mkdir -p $(@D)
	curl -L -o $@ https://github.com/unicode-org/icu/releases/download/release-64-2/icu4c-64_2-src.tgz

$(BUILD)/icu4c-data.tgz:
	mkdir -p $(D)
	curl -L -o $@ https://github.com/unicode-org/icu/releases/download/release-64-2/icu4c-64_2-data.tgz

$(BUILD)/icu4c-src/host: $(BUILD)/icu4c-src.tgz
	mkdir -p $@
	tar xf $(BUILD)/icu4c-src.tgz -C $@ --strip-components=1
	patch -d $@ -p1 < patches/disable-obj-code.patch

$(BUILD)/icu4c-src/cross: $(BUILD)/icu4c-src.tgz
	mkdir -p $@
	tar xf $(BUILD)/icu4c-src.tgz -C $@ --strip-components=1
	patch -d $@ -p1 < patches/patch-double-conversion.diff
	patch -d $@ -p1 < patches/build_data_with_cross_tools.patch
	cp $@/source/config/mh-linux $@/source/config/mh-unknown
	cd $@/source && autoconf

$(BUILD)/icu4c-out/host/BUILT: $(BUILD)/icu4c-src/host
	mkdir -p $(@D)
	cd $(@D) && ../../icu4c-src/host/source/configure
	cd $(@D) && $(MAKE)
	touch $@

$(BUILD)/icu4c-out/cross/BUILT: $(BUILD)/icu4c-src/cross $(BUILD)/icu4c-out/host/BUILT
ifndef WASI_SDK_PATH
	$(error WASI_SDK_PATH is required variable)
endif
	mkdir -p $(@D)
	cd $(@D) && ../../icu4c-src/cross/source/configure \
	  --host=wasm32-unknown-none \
	  --with-cross-build="$(CURDIR)/$(BUILD)/icu4c-out/host" \
	  --enable-static --disable-shared \
	  --disable-tools --disable-tests \
	  --disable-samples --disable-extras \
	  --with-data-packaging=static \
	  CC="$(WASI_SDK_PATH)/bin/clang" CXX="$(WASI_SDK_PATH)/bin/clang++" \
	  AR="$(WASI_SDK_PATH)/bin/llvm-ar" RANLIB="$(WASI_SDK_PATH)/bin/llvm-ranlib" \
	  CFLAGS="--sysroot $(WASI_SDK_PATH)/share/wasi-sysroot" \
	  CXXFLAGS="-fno-exceptions --sysroot $(WASI_SDK_PATH)/share/wasi-sysroot" \
	  ICU_DATA_FILTER_FILE=$(ICU_DATA_FILTER_FILE)
	$(MAKE) -C $(@D)
	$(MAKE) -C $(@D) install DESTDIR=$(CURDIR)/$(BUILD)/icu4c-out/cross/install/icu
	touch $@

icu4c-wasi.tar.xz: $(BUILD)/icu4c-out/cross/BUILT
	tar cJf icu4c-wasi.tar.xz $(BUILD)/icu4c-out/cross/install/icu

$(BUILD)/SwiftPackage: $(BUILD)/icu4c-out/cross/BUILT
	cp -R SwiftPackage $(BUILD)
	mkdir -p $@/build
	cp -R $(BUILD)/icu4c-out/cross/install/icu/usr/local/lib $@/build

$(BUILD)/ci:
	BUILD_DIR=$(BUILD) ./ci/install-build-sdk.sh

.PHONY: ci-setup
ci-setup: $(BUILD)/ci

.PHONY: ci
ci: ci-setup
	$(MAKE) icu4c-wasi.tar.xz WASI_SDK_PATH=$(BUILD)/ci/wasi-sdk

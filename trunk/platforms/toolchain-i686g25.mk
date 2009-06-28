TARGET_ARCH=i686
TARGET_OS=linux
LIBC_STYLE=glibc

LIBSTDC++_VERSION=6.0.9
LIBNSL_VERSION=2.5

GNU_TARGET_NAME = i686-unknown-linux-gnu

TARGET_CC_PROBE := $(shell test -x "/opt/bin/ipkg" \
&& test -x "/opt/bin/$(GNU_TARGET_NAME)-gcc" \
&& echo yes)
#STAGING_CPPFLAGS+= -DPATH_MAX=4096 -DLINE_MAX=2048 -DMB_LEN_MAX=16

BINUTILS_VERSION := 2.19.1
BINUTILS_IPK_VERSION := 1

ifeq (yes, $(TARGET_CC_PROBE))

HOSTCC = $(TARGET_CC)
GNU_HOST_NAME = $(GNU_TARGET_NAME)
TARGET_CROSS = /opt/bin/
TARGET_LIBDIR = /opt/lib
TARGET_INCDIR = /opt/include
TARGET_LDFLAGS = -L/opt/lib
TARGET_CUSTOM_FLAGS= -O2 -pipe
TARGET_CFLAGS= -I/opt/include $(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

toolchain:

else

CROSSTOO-NG_VERSION := 1.4.1

HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
TARGET_CROSS_TOP = $(BASE_DIR)/toolchain/$(GNU_TARGET_NAME)
TARGET_CROSS = $(TARGET_CROSS_TOP)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/sys-root/lib
TARGET_USRLIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/sys-root/usr/lib
TARGET_INCDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/sys-root/usr/include
TARGET_LDFLAGS =
TARGET_CUSTOM_FLAGS= -O2
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

TOOLCHAIN_BUILD_DIR=$(BASE_DIR)/toolchain/build

$(TOOLCHAIN_BUILD_DIR)/.configured:
	$(MAKE) crosstool-ng-host-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	cp $(SOURCE_DIR)/toolchain/i686g25/ct-ng.defconfig $(@D)/.config
	sed -i \
		-e '/^CT_LOCAL_TARBALLS_DIR/s|=.*|="$(DL_DIR)"|' \
		-e '/^CT_PREFIX_DIR/s|=.*|="$(BASE_DIR)/toolchain/$${CT_TARGET}"|' \
		$(@D)/.config
	$(HOST_STAGING_PREFIX)/bin/ct-ng -C $(@D) oldconfig
#	$(HOST_STAGING_PREFIX)/bin/ct-ng -C $(@D) menuconfig
	touch $@

$(TOOLCHAIN_BUILD_DIR)/.built: $(TOOLCHAIN_BUILD_DIR)/.configured
	rm -f $@
	$(HOST_STAGING_PREFIX)/bin/ct-ng -C $(@D) build
	touch $@

toolchain: $(TOOLCHAIN_BUILD_DIR)/.built

endif

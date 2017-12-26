# This toolchain is gcc 7.2.0 on uClibc-ng 1.0.27

GNU_TARGET_NAME = arm-linux
EXACT_TARGET_NAME = arm-buildroot-linux-uclibcgnueabi

UCLIBC_VERSION=1.0.27

DEFAULT_TARGET_PREFIX=/opt
TARGET_PREFIX ?= /opt

LIBC_STYLE=uclibc
TARGET_ARCH=arm
TARGET_OS=linux-uclibc

LIBSTDC++_VERSION=6.0.24
LIBGO_VERSION=11.0.0

LIBC-DEV_IPK_VERSION=1

GETTEXT_NLS=enable
#NO_BUILTIN_MATH=true
NO_LIBNSL=true
IPV6=yes

CROSS_CONFIGURATION_GCC_VERSION=7.2.0
CROSS_CONFIGURATION_UCLIBC_VERSION=$(UCLIBC_VERSION)

NATIVE_GCC_VERSION=7.2.0
GCC_SOURCE=gcc-$(NATIVE_GCC_VERSION).tar.xz
GCC_UNZIP=xzcat

HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
CROSS_CONFIGURATION_GCC=gcc-$(CROSS_CONFIGURATION_GCC_VERSION)
CROSS_CONFIGURATION_UCLIBC=uclibc-$(CROSS_CONFIGURATION_UCLIBC_VERSION)
CROSS_CONFIGURATION=$(CROSS_CONFIGURATION_GCC)-$(CROSS_CONFIGURATION_UCLIBC)
TARGET_CROSS_BUILD_DIR = $(BASE_DIR)/toolchain/buildroot-2017.08
TARGET_CROSS_TOP = $(TARGET_CROSS_BUILD_DIR)/output/host
TARGET_CROSS = $(TARGET_CROSS_TOP)/bin/arm-buildroot-linux-uclibcgnueabi-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/arm-buildroot-linux-uclibcgnueabi/sysroot/usr/lib
TARGET_INCDIR = $(TARGET_CROSS_TOP)/arm-buildroot-linux-uclibcgnueabi/sysroot/usr/include

#	to make feed firmware-independent, we make
#	all packages dependent on uclibc-opt by hacking ipkg-build from ipkg-utils,
#	and add following ld flag to hardcode $(TARGET_PREFIX)/lib/ld-uClibc.so.1
#	into executables instead of firmware's /lib/ld-uClibc.so.1
TARGET_LDFLAGS = -Wl,--dynamic-linker=$(TARGET_PREFIX)/lib/ld-uClibc.so.1

TARGET_CUSTOM_FLAGS= -pipe
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

TOOLCHAIN_SITE=http://buildroot.uclibc.org/downloads
TOOLCHAIN_SOURCE=buildroot-2017.08.tar.bz2

UCLIBC-OPT_VERSION = $(UCLIBC_VERSION)
UCLIBC-OPT_IPK_VERSION = 2
UCLIBC-OPT_LIBS_SOURCE_DIR = $(TARGET_CROSS_TOP)/arm-buildroot-linux-uclibcgnueabi/sysroot/lib

BUILDROOT-ARMv5EABI-NG_SOURCE_DIR=$(SOURCE_DIR)/buildroot-armv5eabi-ng

BUILDROOT-ARMv5EABI-NG_PATCHES=\
$(BUILDROOT-ARMv5EABI-NG_SOURCE_DIR)/uclibc-ng-config.patch \
$(BUILDROOT-ARMv5EABI-NG_SOURCE_DIR)/toolchain-gccgo.patch \
$(BUILDROOT-ARMv5EABI-NG_SOURCE_DIR)/uclibc-ng-bump.patch \

BUILDROOT-ARMv5EABI-NG_UCLIBC-NG_PATCHES=\
$(wildcard $(BUILDROOT-ARMv5EABI-NG_SOURCE_DIR)/uclibc-ng-patches/*.patch)

BUILDROOT-ARMv5EABI-NG_GCC_PATCHES=\
$(wildcard $(BUILDROOT-ARMv5EABI-NG_SOURCE_DIR)/gcc-patches/$(CROSS_CONFIGURATION_GCC_VERSION)/*.patch)

toolchain: $(TARGET_CROSS_TOP)/.built

$(DL_DIR)/$(TOOLCHAIN_SOURCE):
	$(WGET) -P $(@D) $(TOOLCHAIN_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(TARGET_CROSS_TOP)/.configured: $(DL_DIR)/$(TOOLCHAIN_SOURCE) \
		$(BUILDROOT-ARMv5EABI-NG_SOURCE_DIR)/config \
		$(BUILDROOT-ARMv5EABI-NG_PATCHES) \
		$(BUILDROOT-ARMv5EABI-NG_UCLIBC-NG_PATCHES) \
		$(BUILDROOT-ARMv5EABI-NG_GCC_PATCHES) \
		#$(OPTWARE_TOP)/platforms/toolchain-$(OPTWARE_TARGET).mk
	rm -rf $(TARGET_CROSS_TOP) $(TARGET_CROSS_BUILD_DIR)
	mkdir -p $(@D)
	tar -xjvf $(DL_DIR)/$(TOOLCHAIN_SOURCE) -C $(BASE_DIR)/toolchain
	if test -n "$(BUILDROOT-ARMv5EABI-NG_PATCHES)" ; \
		then cat $(BUILDROOT-ARMv5EABI-NG_PATCHES) | \
		$(PATCH) -bd $(TARGET_CROSS_BUILD_DIR) -p1 ; \
	fi
ifneq ($(BUILDROOT-ARMv5EABI-NG_UCLIBC-NG_PATCHES), )
	$(INSTALL) -m 644 $(BUILDROOT-ARMv5EABI-NG_UCLIBC-NG_PATCHES) $(TARGET_CROSS_BUILD_DIR)/package/uclibc
endif
ifneq ($(BUILDROOT-ARMv5EABI-NG_GCC_PATCHES), )
	$(INSTALL) -m 644 $(BUILDROOT-ARMv5EABI-NG_GCC_PATCHES) \
		$(TARGET_CROSS_BUILD_DIR)/package/gcc/$(CROSS_CONFIGURATION_GCC_VERSION)
endif
	cd $(TARGET_CROSS_BUILD_DIR)/package/uclibc; \
		rm -f 0001-fix-issues-with-gdb-8.0.patch 0002-microblaze-handle-R_MICROBLAZE_NONE-for-ld.so-bootst.patch
	(echo "DO_XSI_MATH=y"; echo "COMPAT_ATEXIT=y"; echo "UCLIBC_SV4_DEPRECATED=y") >> \
				$(TARGET_CROSS_BUILD_DIR)/package/uclibc/uClibc-ng.config
	sed 's|^BR2_DL_DIR=.*|BR2_DL_DIR="$(DL_DIR)"|' $(BUILDROOT-ARMv5EABI-NG_SOURCE_DIR)/config > $(TARGET_CROSS_BUILD_DIR)/.config
	touch $@

$(TARGET_CROSS_TOP)/.built: $(TARGET_CROSS_TOP)/.configured
	rm -f $@
	$(MAKE) -C $(TARGET_CROSS_BUILD_DIR)
	ln -sf arm-buildroot-linux-uclibcgnueabi-gccgo $(TARGET_CROSS_TOP)/bin/gccgo
#	cp -f $(UCLIBC-OPT_LIBS_SOURCE_DIR)/libnsl-$(UCLIBC_VERSION).so $(TARGET_LIBDIR)/ # shared libnsl removed from uClibc-ng
	cp -f $(TARGET_CROSS_TOP)/lib/gcc/arm-buildroot-linux-uclibcgnueabi/7.2.0/*.a $(UCLIBC-OPT_LIBS_SOURCE_DIR)/
	touch $@

GCC_TARGET_NAME := arm-buildroot-linux-uclibcgnueabi

GCC_CPPFLAGS := -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -mfloat-abi=soft

GCC_EXTRA_CONF_ENV := ac_cv_lbl_unaligned_fail=yes ac_cv_func_mmap_fixed_mapped=yes ac_cv_func_memcmp_working=yes ac_cv_have_decl_malloc=yes gl_cv_func_malloc_0_nonnull=yes ac_cv_func_malloc_0_nonnull=yes ac_cv_func_calloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes lt_cv_sys_lib_search_path_spec="" ac_cv_c_bigendian=no

NATIVE_GCC_EXTRA_CONFIG_ARGS=--with-gxx-include-dir=$(TARGET_PREFIX)/include/c++/7.2.0 --disable-__cxa_atexit --with-gnu-ld --disable-libssp --disable-libsanitizer --enable-tls --disable-libmudflap --enable-threads --without-isl --without-cloog --with-float=soft --disable-decimal-float --with-abi=aapcs-linux --with-cpu=arm926ej-s --with-mode=arm --enable-shared --disable-libgomp --with-gmp=$(STAGING_PREFIX) --with-mpfr=$(STAGING_PREFIX) --with-mpc=$(STAGING_PREFIX) --with-default-libstdcxx-abi=gcc4-compatible --with-system-zlib

NATIVE_GCC_ADDITIONAL_DEPS=zlib

NATIVE_GCC_ADDITIONAL_STAGE=zlib-stage

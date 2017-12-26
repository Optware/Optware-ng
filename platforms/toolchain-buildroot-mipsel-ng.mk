# This toolchain is gcc 7.2.0 on uClibc-ng 1.0.27

GNU_TARGET_NAME = mipsel-linux
EXACT_TARGET_NAME = mipsel-buildroot-linux-uclibc

UCLIBC_VERSION=1.0.27

DEFAULT_TARGET_PREFIX=/opt
TARGET_PREFIX ?= /opt

LIBC_STYLE=uclibc
TARGET_ARCH=mipsel
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
TARGET_CROSS = $(TARGET_CROSS_TOP)/bin/mipsel-buildroot-linux-uclibc-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/mipsel-buildroot-linux-uclibc/sysroot/usr/lib
TARGET_INCDIR = $(TARGET_CROSS_TOP)/mipsel-buildroot-linux-uclibc/sysroot/usr/include

#	to make feed firmware-independent, we make
#	all packages dependent on uclibc-opt by hacking ipkg-build from ipkg-utils,
#	and add following ld flag to hardcode $(TARGET_PREFIX)/lib/ld-uClibc.so.1
#	into executables instead of firmware's /lib/ld-uClibc.so.1
TARGET_LDFLAGS = -Wl,--dynamic-linker=$(TARGET_PREFIX)/lib/ld-uClibc.so.1

TARGET_CUSTOM_FLAGS= -pipe
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

TOOLCHAIN_SITE=http://buildroot.uclibc.org/downloads
TOOLCHAIN_SOURCE=buildroot-2017.08.tar.bz2

TOOLCHAIN_KERNEL_GIT=https://github.com/wl500g/wl500g.git
TOOLCHAIN_KERNEL_VERSION=2.6.22.19-wl500g-20160709
TOOLCHAIN_KERNEL_HASH=4164297511fb63af279cdade148f340f7947eedd
TOOLCHAIN_KERNEL_SOURCE=linux-$(TOOLCHAIN_KERNEL_VERSION).tar.xz

UCLIBC-OPT_VERSION = $(UCLIBC_VERSION)
UCLIBC-OPT_IPK_VERSION = 2
UCLIBC-OPT_LIBS_SOURCE_DIR = $(TARGET_CROSS_TOP)/mipsel-buildroot-linux-uclibc/sysroot/lib

BUILDROOT-MIPSEL-NG_SOURCE_DIR=$(SOURCE_DIR)/buildroot-mipsel-ng

BUILDROOT-MIPSEL-NG_PATCHES=\
$(BUILDROOT-MIPSEL-NG_SOURCE_DIR)/uclibc-ng-config.patch \
$(BUILDROOT-MIPSEL-NG_SOURCE_DIR)/toolchain-gccgo.patch \
$(BUILDROOT-MIPSEL-NG_SOURCE_DIR)/uclibc-ng-bump.patch \

BUILDROOT-MIPSEL-NG_UCLIBC-NG_PATCHES=\
$(wildcard $(BUILDROOT-MIPSEL-NG_SOURCE_DIR)/uclibc-ng-patches/*.patch)

BUILDROOT-MIPSEL-NG_GCC_PATCHES=\
$(wildcard $(BUILDROOT-MIPSEL-NG_SOURCE_DIR)/gcc-patches/$(CROSS_CONFIGURATION_GCC_VERSION)/*.patch)

toolchain: $(TARGET_CROSS_TOP)/.built

toolchain-configure: $(TARGET_CROSS_TOP)/.configured

$(DL_DIR)/$(TOOLCHAIN_SOURCE):
	$(WGET) -P $(@D) $(TOOLCHAIN_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(DL_DIR)/$(TOOLCHAIN_KERNEL_SOURCE):
	(cd $(BUILD_DIR) ; \
		rm -rf linux-$(TOOLCHAIN_KERNEL_VERSION) && \
		git clone $(TOOLCHAIN_KERNEL_GIT) linux-$(TOOLCHAIN_KERNEL_VERSION) && \
		(cd linux-$(TOOLCHAIN_KERNEL_VERSION) && \
		git checkout $(TOOLCHAIN_KERNEL_HASH) && \
		git submodule update && \
		cd linux && \
		touch linux-2.6.22.19/include/linux/utsrelease.h && \
		tar -cJf $@ linux-2.6.22.19) && \
		rm -rf linux-$(TOOLCHAIN_KERNEL_VERSION) ; \
	)

$(TARGET_CROSS_TOP)/.configured: $(DL_DIR)/$(TOOLCHAIN_SOURCE) \
		$(DL_DIR)/$(TOOLCHAIN_KERNEL_SOURCE) \
		$(BUILDROOT-MIPSEL-NG_SOURCE_DIR)/config \
		$(BUILDROOT-MIPSEL-NG_PATCHES) \
		$(BUILDROOT-MIPSEL-NG_UCLIBC-NG_PATCHES) \
		$(BUILDROOT-MIPSEL-NG_GCC_PATCHES) \
		#$(OPTWARE_TOP)/platforms/toolchain-$(OPTWARE_TARGET).mk
	rm -rf $(TARGET_CROSS_TOP) $(TARGET_CROSS_BUILD_DIR)
	mkdir -p $(@D)
	tar -xjvf $(DL_DIR)/$(TOOLCHAIN_SOURCE) -C $(BASE_DIR)/toolchain
	if test -n "$(BUILDROOT-MIPSEL-NG_PATCHES)" ; \
		then cat $(BUILDROOT-MIPSEL-NG_PATCHES) | \
		$(PATCH) -bd $(TARGET_CROSS_BUILD_DIR) -p1 ; \
	fi
#	cd $(TARGET_CROSS_BUILD_DIR)/package/uclibc; \
		rm -f 0001-include-netdb.h-Do-not-define-IDN-related-flags.patch 0002-mips-fix-build-if-threads-are-disabled.patch
ifneq ($(BUILDROOT-MIPSEL-NG_UCLIBC-NG_PATCHES), )
	$(INSTALL) -m 644 $(BUILDROOT-MIPSEL-NG_UCLIBC-NG_PATCHES) $(TARGET_CROSS_BUILD_DIR)/package/uclibc
endif
ifneq ($(BUILDROOT-MIPSEL-NG_GCC_PATCHES), )
	$(INSTALL) -m 644 $(BUILDROOT-MIPSEL-NG_GCC_PATCHES) \
		$(TARGET_CROSS_BUILD_DIR)/package/gcc/$(CROSS_CONFIGURATION_GCC_VERSION)
endif
	cd $(TARGET_CROSS_BUILD_DIR)/package/uclibc; \
		rm -f 0001-fix-issues-with-gdb-8.0.patch 0002-microblaze-handle-R_MICROBLAZE_NONE-for-ld.so-bootst.patch
	(echo "DO_XSI_MATH=y"; echo "COMPAT_ATEXIT=y"; echo "# UCLIBC_USE_MIPS_PREFETCH is not set") >> $(TARGET_CROSS_BUILD_DIR)/package/uclibc/uClibc-ng.config
	(echo "DO_XSI_MATH=y"; echo "COMPAT_ATEXIT=y"; echo "UCLIBC_SV4_DEPRECATED=y"; \
		echo "# UCLIBC_USE_MIPS_PREFETCH is not set") >> $(TARGET_CROSS_BUILD_DIR)/package/uclibc/uClibc-ng.config
	sed -e 's|^BR2_DL_DIR=.*|BR2_DL_DIR="$(DL_DIR)"|' -e 's|@KERNEL_VERSION@|$(TOOLCHAIN_KERNEL_VERSION)|' \
		$(BUILDROOT-MIPSEL-NG_SOURCE_DIR)/config > $(TARGET_CROSS_BUILD_DIR)/.config
	touch $@

$(TARGET_CROSS_TOP)/.built: $(TARGET_CROSS_TOP)/.configured
	rm -f $@
	$(MAKE) -C $(TARGET_CROSS_BUILD_DIR)
	ln -sf mipsel-buildroot-linux-uclibc-gccgo $(TARGET_CROSS_TOP)/bin/gccgo
#	cp -f $(UCLIBC-OPT_LIBS_SOURCE_DIR)/libnsl-$(UCLIBC_VERSION).so $(TARGET_LIBDIR)/ # shared libnsl removed from uClibc-ng
	cp -f $(TARGET_CROSS_TOP)/lib/gcc/mipsel-buildroot-linux-uclibc/7.2.0/*.a $(UCLIBC-OPT_LIBS_SOURCE_DIR)/
	touch $@

GCC_TARGET_NAME := mipsel-buildroot-linux-uclibc

GCC_CPPFLAGS := -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64

GCC_EXTRA_CONF_ENV := ac_cv_lbl_unaligned_fail=yes ac_cv_func_mmap_fixed_mapped=yes ac_cv_func_memcmp_working=yes ac_cv_have_decl_malloc=yes gl_cv_func_malloc_0_nonnull=yes ac_cv_func_malloc_0_nonnull=yes ac_cv_func_calloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes lt_cv_sys_lib_search_path_spec="" ac_cv_c_bigendian=no

NATIVE_GCC_EXTRA_CONFIG_ARGS=--with-gxx-include-dir=$(TARGET_PREFIX)/include/c++/7.2.0 --disable-__cxa_atexit --with-gnu-ld --disable-libssp --enable-target-optspace --disable-libsanitizer --enable-tls --disable-libmudflap --enable-threads --without-isl --without-cloog --with-float=soft --disable-decimal-float --with-arch=mips32r2 --with-abi=32 --enable-shared --disable-libgomp --with-gmp=$(STAGING_PREFIX) --with-mpfr=$(STAGING_PREFIX) --with-mpc=$(STAGING_PREFIX) --with-default-libstdcxx-abi=gcc4-compatible --with-system-zlib

NATIVE_GCC_ADDITIONAL_DEPS=zlib

NATIVE_GCC_ADDITIONAL_STAGE=zlib-stage

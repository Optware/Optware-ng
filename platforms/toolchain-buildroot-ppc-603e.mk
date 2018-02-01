# This toolchain is gcc 6.4.0 on glibc 2.25

GNU_TARGET_NAME = powerpc-603e-linux
EXACT_TARGET_NAME = powerpc-buildroot-linux-gnu

DEFAULT_TARGET_PREFIX=/opt
TARGET_PREFIX ?= /opt

LIBC_STYLE=glibc
TARGET_ARCH=powerpc
TARGET_OS=linux

LIBSTDC++_VERSION=6.0.22
LIBGO_VERSION=9.0.0

LIBC-DEV_IPK_VERSION=3

GETTEXT_NLS=enable
#NO_BUILTIN_MATH=true
IPV6=yes

CROSS_CONFIGURATION_GCC_VERSION=6.4.0
CROSS_CONFIGURATION_GLIBC_VERSION=2.25

NATIVE_GCC_VERSION=6.4.0
GCC_SOURCE=gcc-$(NATIVE_GCC_VERSION).tar.xz
GCC_UNZIP=xzcat

HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
CROSS_CONFIGURATION_GCC=gcc-$(CROSS_CONFIGURATION_GCC_VERSION)
CROSS_CONFIGURATION_GLIBC=glibc-$(CROSS_CONFIGURATION_GLIBC_VERSION)
CROSS_CONFIGURATION=$(CROSS_CONFIGURATION_GCC)-$(CROSS_CONFIGURATION_GLIBC)
TARGET_CROSS_BUILD_DIR = $(BASE_DIR)/toolchain/buildroot-2017.08
TARGET_CROSS_TOP = $(TARGET_CROSS_BUILD_DIR)/output/host
TARGET_CROSS = $(TARGET_CROSS_TOP)/bin/powerpc-buildroot-linux-gnu-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/powerpc-buildroot-linux-gnu/sysroot/usr/lib
TARGET_INCDIR = $(TARGET_CROSS_TOP)/powerpc-buildroot-linux-gnu/sysroot/usr/include

#	to make feed firmware-independent, we make
#	all packages dependent on glibc-opt by hacking ipkg-build from ipkg-utils,
#	and add following ld flag to hardcode $(TARGET_PREFIX)/lib/ld.so.1
#	into executables
TARGET_LDFLAGS = -Wl,--dynamic-linker=$(TARGET_PREFIX)/lib/ld.so.1

TARGET_CUSTOM_FLAGS= -pipe -fno-var-tracking-assignments
# for -fno-var-tracking-assignments see:
# https://gcc.gnu.org/bugzilla/show_bug.cgi?id=65779
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

TOOLCHAIN_SITE=http://buildroot.uclibc.org/downloads
TOOLCHAIN_SOURCE=buildroot-2017.08.tar.bz2

GLIBC-OPT_VERSION = 2.23
GLIBC-OPT_IPK_VERSION = 1
GLIBC-OPT_LIBS_SOURCE_DIR = $(TARGET_CROSS_TOP)/powerpc-buildroot-linux-gnu/sysroot/usr/lib
LIBNSL_SO_DIR = $(TARGET_CROSS_TOP)/powerpc-buildroot-linux-gnu/sysroot/usr/lib

LIBNSL_VERSION = 2.23
LIBNSL_IPK_VERSION = 1

BUILDROOT-PPC_603E_SOURCE_DIR=$(SOURCE_DIR)/buildroot-ppc-603e

BUILDROOT-PPC_603E_PATCHES=\
$(BUILDROOT-PPC_603E_SOURCE_DIR)/glibc-prefix.patch \
$(BUILDROOT-PPC_603E_SOURCE_DIR)/glibc-enable-kernel.patch \
$(BUILDROOT-PPC_603E_SOURCE_DIR)/glibc-version.patch \
$(BUILDROOT-PPC_603E_SOURCE_DIR)/old-headers.patch \
$(BUILDROOT-PPC_603E_SOURCE_DIR)/toolchain-gccgo.patch \

BUILDROOT-PPC_603E_GCC_PATCHES=\
$(wildcard $(BUILDROOT-PPC_603E_SOURCE_DIR)/gcc-patches/$(CROSS_CONFIGURATION_GCC_VERSION)/*.patch)

BUILDROOT-PPC_603E_GLIBC_PATCHES=\
$(wildcard $(BUILDROOT-PPC_603E_SOURCE_DIR)/glibc-patches/*.patch)

toolchain: $(TARGET_CROSS_TOP)/.built

$(DL_DIR)/$(TOOLCHAIN_SOURCE):
	$(WGET) -P $(@D) $(TOOLCHAIN_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(TARGET_CROSS_TOP)/.configured: $(DL_DIR)/$(TOOLCHAIN_SOURCE) \
				$(BUILDROOT-PPC_603E_SOURCE_DIR)/config \
				$(BUILDROOT-PPC_603E_PATCHES) \
				$(BUILDROOT-PPC_603E_GCC_PATCHES) \
				$(BUILDROOT-PPC_603E_GLIBC_PATCHES) \
				#$(OPTWARE_TOP)/platforms/toolchain-$(OPTWARE_TARGET).mk
	rm -rf $(TARGET_CROSS_TOP) $(TARGET_CROSS_BUILD_DIR)
	mkdir -p $(@D)
	tar -xjvf $(DL_DIR)/$(TOOLCHAIN_SOURCE) -C $(BASE_DIR)/toolchain
	if test -n "$(BUILDROOT-PPC_603E_PATCHES)" ; \
		then cat $(BUILDROOT-PPC_603E_PATCHES) | \
		$(PATCH) -bd $(TARGET_CROSS_BUILD_DIR) -p1 ; \
	fi
ifneq ($(BUILDROOT-PPC_603E_GCC_PATCHES), )
	$(INSTALL) -m 644 $(BUILDROOT-PPC_603E_GCC_PATCHES) \
		$(TARGET_CROSS_BUILD_DIR)/package/gcc/$(CROSS_CONFIGURATION_GCC_VERSION)
endif
	rm -f $(TARGET_CROSS_BUILD_DIR)/package/gcc/6.4.0/941-mips-Add-support-for-mips-r6-musl.patch
	rm -f $(TARGET_CROSS_BUILD_DIR)/package/glibc/0006-sh4-trap.patch
ifneq ($(BUILDROOT-PPC_603E_GLIBC_PATCHES), )
	$(INSTALL) -m 644 $(BUILDROOT-PPC_603E_GLIBC_PATCHES) \
		$(TARGET_CROSS_BUILD_DIR)/package/glibc
endif
	sed 's|^BR2_DL_DIR=.*|BR2_DL_DIR="$(DL_DIR)"|' $(BUILDROOT-PPC_603E_SOURCE_DIR)/config > $(TARGET_CROSS_BUILD_DIR)/.config
	touch $@

$(TARGET_CROSS_TOP)/.built: $(TARGET_CROSS_TOP)/.configured
	rm -f $@
	$(MAKE) -C $(TARGET_CROSS_BUILD_DIR)
	ln -sf powerpc-buildroot-linux-gnu-gccgo $(TARGET_CROSS_TOP)/bin/gccgo
	install -m 644 $(BUILDROOT-PPC_603E_SOURCE_DIR)/videodev.h $(TARGET_CROSS_TOP)/powerpc-buildroot-linux-gnu/sysroot/usr/include/linux
	cp -af  $(TARGET_CROSS_TOP)/powerpc-buildroot-linux-gnu/sysroot/lib/* \
		$(TARGET_CROSS_TOP)/lib/gcc/powerpc-buildroot-linux-gnu/6.4.0/*.a $(GLIBC-OPT_LIBS_SOURCE_DIR)/
	touch $@

GCC_TARGET_NAME := powerpc-buildroot-linux-gnu

GCC_CPPFLAGS := -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64

GCC_EXTRA_CONF_ENV := ac_cv_lbl_unaligned_fail=yes ac_cv_func_mmap_fixed_mapped=yes ac_cv_func_memcmp_working=yes ac_cv_have_decl_malloc=yes gl_cv_func_malloc_0_nonnull=yes ac_cv_func_malloc_0_nonnull=yes ac_cv_func_calloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes lt_cv_sys_lib_search_path_spec="" ac_cv_c_bigendian=yes

NATIVE_GCC_EXTRA_CONFIG_ARGS=--with-gxx-include-dir=$(TARGET_PREFIX)/include/c++/6.4.0 --disable-__cxa_atexit --with-gnu-ld --disable-libssp --disable-libquadmath --enable-tls --disable-libmudflap --enable-threads --without-isl --without-cloog --disable-decimal-float --with-cpu=603e --enable-shared --disable-libgomp --with-gmp=$(STAGING_PREFIX) --with-mpfr=$(STAGING_PREFIX) --with-mpc=$(STAGING_PREFIX) --with-default-libstdcxx-abi=gcc4-compatible --with-system-zlib

NATIVE_GCC_ADDITIONAL_DEPS=zlib

NATIVE_GCC_ADDITIONAL_STAGE=zlib-stage

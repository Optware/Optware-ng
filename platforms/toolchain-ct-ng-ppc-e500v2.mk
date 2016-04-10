# This toolchain is gcc 5.3.0 on glibc 2.23

GNU_TARGET_NAME = powerpc-linux-gnuspe
EXACT_TARGET_NAME = powerpc-e500v2-linux-gnuspe

DEFAULT_TARGET_PREFIX=/opt
TARGET_PREFIX ?= /opt

LIBC_STYLE=glibc
TARGET_ARCH=powerpc
TARGET_OS=linux

LIBSTDC++_VERSION=6.0.21

LIBC-DEV_IPK_VERSION=1

GETTEXT_NLS=enable
#NO_BUILTIN_MATH=true
IPV6=yes

CROSS_CONFIGURATION_GCC_VERSION=5.3.0
CROSS_CONFIGURATION_GLIBC_VERSION=2.23

ifeq ($(HOST_MACHINE),ppc)

HOSTCC = $(TARGET_CC)
GNU_HOST_NAME = $(GNU_TARGET_NAME)
TARGET_CROSS = $(TARGET_PREFIX)/bin/
TARGET_LIBDIR = $(TARGET_PREFIX)/lib
TARGET_INCDIR = $(TARGET_PREFIX)/include
TARGET_LDFLAGS =
TARGET_CUSTOM_FLAGS=
TARGET_CFLAGS= $(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

toolchain:

else

HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
CROSS_CONFIGURATION_GCC=gcc-$(CROSS_CONFIGURATION_GCC_VERSION)
CROSS_CONFIGURATION_GLIBC=glibc-$(CROSS_CONFIGURATION_GLIBC_VERSION)
CROSS_CONFIGURATION=$(CROSS_CONFIGURATION_GCC)-$(CROSS_CONFIGURATION_GLIBC)
TARGET_CROSS_BUILD_DIR = $(BASE_DIR)/toolchain/crosstool-ng-$(TOOLCHAIN_VERSION)
TARGET_CROSS_TOP = $(BASE_DIR)/toolchain/ct-ng-powerpc-linux-3.2.66-glibc-5.3.0
TARGET_CROSS = $(TARGET_CROSS_TOP)/bin/powerpc-e500v2-linux-gnuspe-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/powerpc-e500v2-linux-gnuspe/sysroot/usr/lib
TARGET_INCDIR = $(TARGET_CROSS_TOP)/powerpc-e500v2-linux-gnuspe/sysroot/usr/include

#	to make feed firmware-independent, we make
#	all packages dependent on glibc-opt by hacking ipkg-build from ipkg-utils,
#	and add following ld flag to hardcode $(TARGET_PREFIX)/lib/ld.so.1
#	into executables
TARGET_LDFLAGS = -Wl,--dynamic-linker=$(TARGET_PREFIX)/lib/ld.so.1

TARGET_CUSTOM_FLAGS= -pipe -mfloat-gprs=double -Wa,-me500x2
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

TOOLCHAIN_GIT=https://github.com/crosstool-ng/crosstool-ng.git
TOOLCHAIN_GIT_DATE=20160326
TOOLCHAIN_VERSION=git$(TOOLCHAIN_GIT_DATE)
TOOLCHAIN_TREEISH=`git rev-list --max-count=1 --until=2016-03-26 HEAD`
TOOLCHAIN_SOURCE=crosstool-ng-$(TOOLCHAIN_VERSION).tar.bz2

LIBSTDC++_TARGET_LIBDIR = $(TARGET_CROSS_TOP)/powerpc-e500v2-linux-gnuspe/sysroot/lib

GLIBC-OPT_VERSION = 2.23
GLIBC-OPT_IPK_VERSION = 1
GLIBC-OPT_LIBS_SOURCE_DIR = $(TARGET_CROSS_TOP)/powerpc-e500v2-linux-gnuspe/sysroot/lib
LIBNSL_SO_DIR = $(TARGET_CROSS_TOP)/powerpc-e500v2-linux-gnuspe/sysroot/lib

LIBNSL_VERSION = 2.23
LIBNSL_IPK_VERSION = 1

CT-NG-PPC_E500v2_SOURCE_DIR=$(SOURCE_DIR)/ct-ng-ppc-e500v2

CT-NG-PPC_E500v2_PATCHES=\
$(CT-NG-PPC_E500v2_SOURCE_DIR)/linux-3.2.patch \

toolchain: $(TARGET_CROSS_BUILD_DIR)/.built

$(DL_DIR)/$(TOOLCHAIN_SOURCE):
	mkdir -p $(BUILD_DIR)
	(cd $(BUILD_DIR) ; \
		rm -rf crosstool-ng-$(TOOLCHAIN_VERSION) && \
		git clone $(TOOLCHAIN_GIT) crosstool-ng-$(TOOLCHAIN_VERSION) && \
		(cd crosstool-ng-$(TOOLCHAIN_VERSION) && \
		git checkout $(TOOLCHAIN_TREEISH) && \
		$(PATCH) -p1 < $(CT-NG-PPC_E500v2_SOURCE_DIR)/no-help2man.patch && \
		$(AUTORECONF1.14) -vif && \
		rm -rf .git) && \
		tar -cjvf $@ crosstool-ng-$(TOOLCHAIN_VERSION) && \
		rm -rf crosstool-ng-$(TOOLCHAIN_VERSION) ; \
	)

$(TARGET_CROSS_BUILD_DIR)/.configured: $(DL_DIR)/$(TOOLCHAIN_SOURCE) \
				$(CT-NG-PPC_E500v2_SOURCE_DIR)/glibc-patches/*.patch \
				$(CT-NG-PPC_E500v2_PATCHES) \
				#$(OPTWARE_TOP)/platforms/toolchain-$(OPTWARE_TARGET).mk
	$(MAKE) libtool-host
	rm -rf $(@D) $(TARGET_CROSS_TOP)
	tar -xjvf $(DL_DIR)/$(TOOLCHAIN_SOURCE) -C $(BASE_DIR)/toolchain
	if test -n "$(CT-NG-PPC_E500v2_PATCHES)" ; \
		then cat $(CT-NG-PPC_E500v2_PATCHES) | \
		$(PATCH) -d $(TARGET_CROSS_BUILD_DIR) -p1 ; \
	fi
	mkdir -p $(@D)/patches/glibc/2.23
	$(INSTALL) -m 644 $(CT-NG-PPC_E500v2_SOURCE_DIR)/glibc-patches/* $(@D)/patches/glibc/2.23
	cd $(@D); \
		LIBTOOL=$(HOST_STAGING_PREFIX)/bin/libtool \
		LIBTOOLIZE=$(HOST_STAGING_PREFIX)/bin/libtoolize \
		./configure --enable-local
	$(MAKE) -C $(@D) MAKELEVEL=0
	sed -e 's|^CT_PREFIX_DIR=.*|CT_PREFIX_DIR="$(TARGET_CROSS_TOP)"|' $(CT-NG-PPC_E500v2_SOURCE_DIR)/config > $(TARGET_CROSS_BUILD_DIR)/.config
	mkdir -p $(@D)/.build
	ln -s $(DL_DIR) $(@D)/.build/tarballs
	cd $(@D); ./ct-ng +libc_check_config
	touch $@

$(TARGET_CROSS_BUILD_DIR)/.built: $(TARGET_CROSS_BUILD_DIR)/.configured
	rm -f $@
	cd $(@D); ./ct-ng build
	chmod -R +w $(TARGET_CROSS_TOP)
	install -m 644 $(CT-NG-PPC_E500v2_SOURCE_DIR)/videodev.h $(TARGET_CROSS_TOP)/powerpc-e500v2-linux-gnuspe/sysroot/usr/include/linux
	cp -af $(TARGET_CROSS_TOP)/lib/gcc/powerpc-e500v2-linux-gnuspe/5.3.0/*.a $(GLIBC-OPT_LIBS_SOURCE_DIR)/
	cp -af $(TARGET_CROSS_TOP)/powerpc-e500v2-linux-gnuspe/sysroot/lib/libstdc++*.a $(TARGET_CROSS_TOP)/powerpc-e500v2-linux-gnuspe/sysroot/usr/lib/
	touch $@

GLIBC-OPT_LIBS := ld libc libm libdl librt libanl libutil libcrypt libnss_db libresolv libnss_dns libnss_nis libpthread libnss_files libnss_compat libnss_hesiod libnss_nisplus libBrokenLocale

GCC_TARGET_NAME := powerpc-e500v2-linux-gnuspe

GCC_CPPFLAGS := -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64

GCC_EXTRA_CONF_ENV := ac_cv_lbl_unaligned_fail=yes ac_cv_func_mmap_fixed_mapped=yes ac_cv_func_memcmp_working=yes ac_cv_have_decl_malloc=yes gl_cv_func_malloc_0_nonnull=yes ac_cv_func_malloc_0_nonnull=yes ac_cv_func_calloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes lt_cv_sys_lib_search_path_spec="" ac_cv_c_bigendian=yes

NATIVE_GCC_EXTRA_CONFIG_ARGS=--with-gxx-include-dir=$(TARGET_PREFIX)/include/c++/5.3.0 --disable-__cxa_atexit --with-gnu-ld --disable-libssp --disable-libquadmath --enable-tls --disable-libmudflap --enable-threads --without-isl --without-cloog --disable-decimal-float --with-cpu=8548 --with-float=soft --enable-shared --disable-libgomp --with-gmp=$(STAGING_PREFIX) --with-mpfr=$(STAGING_PREFIX) --with-mpc=$(STAGING_PREFIX) --with-default-libstdcxx-abi=gcc4-compatible --with-system-zlib --enable-lto --enable-long-long --enable-e500_double --enable-e500_double

NATIVE_BINUTILS_CONFIG_ARGS=--enable-spe=yes --enable-e500x2 --with-e500x2

NATIVE_GCC_ADDITIONAL_DEPS=zlib

NATIVE_GCC_ADDITIONAL_STAGE=zlib-stage

endif

# This toolchain is gcc 4.5.3 on uClibc 0.9.32.1

GNU_TARGET_NAME = arm-linux
EXACT_TARGET_NAME = arm-brcm-linux-uclibcgnueabi

LIBC_STYLE=uclibc
TARGET_ARCH=arm
TARGET_OS=linux-uclibc

LIBSTDC++_VERSION=6.0.14

GETTEXT_NLS=enable
#NO_BUILTIN_MATH=true
IPV6=yes

CROSS_CONFIGURATION_GCC_VERSION=4.5.3
CROSS_CONFIGURATION_UCLIBC_VERSION=0.9.32.1

NATIVE_GCC_EXTRA_CONFIG_ARGS=--with-system-libunwind

ifeq ($(HOST_MACHINE), $(filter armv5tel armv5tejl, $(HOST_MACHINE)))

HOSTCC = $(TARGET_CC)
GNU_HOST_NAME = $(GNU_TARGET_NAME)
TARGET_CROSS = /opt/bin/
TARGET_LIBDIR = /opt/lib
TARGET_INCDIR = /opt/include
TARGET_LDFLAGS =
TARGET_CUSTOM_FLAGS=
TARGET_CFLAGS= $(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

toolchain:

else

HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
CROSS_CONFIGURATION_GCC=gcc-$(CROSS_CONFIGURATION_GCC_VERSION)
CROSS_CONFIGURATION_UCLIBC=uclibc-$(CROSS_CONFIGURATION_UCLIBC_VERSION)
CROSS_CONFIGURATION=$(CROSS_CONFIGURATION_GCC)-$(CROSS_CONFIGURATION_UCLIBC)
TARGET_CROSS_BUILD_DIR = $(BASE_DIR)/toolchain/buildroot-2012.02
TARGET_CROSS_TOP = $(BASE_DIR)/toolchain/hndtools-arm-linux-2.6.36-uclibc-4.5.3
TARGET_CROSS = $(TARGET_CROSS_TOP)/bin/arm-brcm-linux-uclibcgnueabi-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/arm-brcm-linux-uclibcgnueabi/sysroot/usr/lib
TARGET_INCDIR = $(TARGET_CROSS_TOP)/arm-brcm-linux-uclibcgnueabi/sysroot/usr/include

#	to make feed firmware-independent, we make
#	all packages dependent on uclibc-opt by hacking ipkg-build from ipkg-utils,
#	and add following ld flag to hardcode /opt/lib/ld-uClibc.so.0
#	into executables instead of firmware's /lib/ld-uClibc.so.0
TARGET_LDFLAGS = -Wl,--dynamic-linker=/opt/lib/ld-uClibc.so.0

TARGET_CUSTOM_FLAGS= -pipe
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

TOOLCHAIN_SITE=http://dl.lazyzhu.com/file/Toolchain/crosstool-NG
TOOLCHAIN_BINARY=hndtools-arm-linux-2.6.36-uclibc-4.5.3.tar.bz2

UCLIBC-OPT_VERSION = 0.9.32.1
UCLIBC-OPT_IPK_VERSION = 2
UCLIBC-OPT_LIBS_SOURCE_DIR = $(TARGET_CROSS_TOP)/arm-brcm-linux-uclibcgnueabi/sysroot/lib

SHIBBY-TOMATO-ARM_SOURCE_DIR=$(SOURCE_DIR)/shibby-tomato-arm

#toolchain: $(TARGET_CROSS_TOP)/.unpacked
toolchain: $(TARGET_CROSS_TOP)/.built

$(DL_DIR)/$(TOOLCHAIN_BINARY):
	$(WGET) -P $(@D) $(TOOLCHAIN_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(TARGET_CROSS_TOP)/.configured: $(DL_DIR)/$(TOOLCHAIN_BINARY) #$(OPTWARE_TOP)/platforms/toolchain-$(OPTWARE_TARGET).mk
	rm -rf $(TARGET_CROSS_TOP) $(TARGET_CROSS_BUILD_DIR)
	mkdir -p $(TARGET_CROSS_TOP)
	tar -xjvOf $(DL_DIR)/$(TOOLCHAIN_BINARY) hndtools-arm-linux-2.6.36-uclibc-4.5.3/src/buildroot-2012.02.tar.bz2 | tar -xjvf - -C $(BASE_DIR)/toolchain
	sed 's|^BR2_STAGING_DIR=.*|BR2_STAGING_DIR="$(TARGET_CROSS_TOP)"|' $(TARGET_CROSS_BUILD_DIR)/dl_save/defconfig-arm-uclibc > $(TARGET_CROSS_BUILD_DIR)/.config
	cp -f $(SHIBBY-TOMATO-ARM_SOURCE_DIR)/uClibc-0.9.32.1-*.patch $(TARGET_CROSS_BUILD_DIR)/toolchain/uClibc/
	cp -f $(SHIBBY-TOMATO-ARM_SOURCE_DIR)/m4-1.4.16-002-gets.patch $(TARGET_CROSS_BUILD_DIR)/package/m4/
	cp -f $(SHIBBY-TOMATO-ARM_SOURCE_DIR)/gcc-4.5.3-no-building-info.patch $(TARGET_CROSS_BUILD_DIR)/toolchain/gcc/4.5.3/
	touch $@

$(TARGET_CROSS_TOP)/.built: $(TARGET_CROSS_TOP)/.configured
	rm -f $@
	$(MAKE) -C $(TARGET_CROSS_BUILD_DIR)
	rm -f $(UCLIBC-OPT_LIBS_SOURCE_DIR)/libgcc_s.so
	ln -s libgcc_s.so.1 $(UCLIBC-OPT_LIBS_SOURCE_DIR)/libgcc_s.so
	-for app in `cd $(TARGET_CROSS_TOP)/bin; ls arm-brcm-linux-uclibcgnueabi-*` ; do \
		cd $(TARGET_CROSS_TOP)/bin; ln -s $$app `echo $$app|sed -e 's/arm-brcm-linux-uclibcgnueabi-/arm-linux-uclibc-/'` ; \
		ln -s $$app `echo $$app|sed -e 's/arm-brcm-linux-uclibcgnueabi-/arm-linux-/'` ; done
	cp -f $(UCLIBC-OPT_LIBS_SOURCE_DIR)/libnsl-0.9.32.1.so $(TARGET_LIBDIR)/
	touch $@

$(TARGET_CROSS_TOP)/.unpacked: $(DL_DIR)/$(TOOLCHAIN_BINARY) # $(OPTWARE_TOP)/platforms/toolchain-$(OPTWARE_TARGET).mk
	rm -rf $(TARGET_CROSS_TOP)
	mkdir -p $(BASE_DIR)/toolchain
	tar -xjvf $(DL_DIR)/$(TOOLCHAIN_BINARY) -C $(BASE_DIR)/toolchain
	rm -f $(UCLIBC-OPT_LIBS_SOURCE_DIR)/libgcc_s.so
	ln -s libgcc_s.so.1 $(UCLIBC-OPT_LIBS_SOURCE_DIR)/libgcc_s.so
	-for app in `cd $(TARGET_CROSS_TOP)/bin; ls arm-brcm-linux-uclibcgnueabi-*` ; do \
		cd $(TARGET_CROSS_TOP)/bin; ln -s $$app `echo $$app|sed -e 's/arm-brcm-linux-uclibcgnueabi-/arm-linux-uclibc-/'` ; \
		ln -s $$app `echo $$app|sed -e 's/arm-brcm-linux-uclibcgnueabi-/arm-linux-/'` ; done
	cp -f $(UCLIBC-OPT_LIBS_SOURCE_DIR)/libnsl-0.9.32.1.so $(TARGET_LIBDIR)/
	touch $@

GCC_TARGET_NAME := arm-brcm-linux-uclibcgnueabi

GCC_CPPFLAGS := -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -mfloat-abi=soft

GCC_EXTRA_CONF_ENV := ac_cv_lbl_unaligned_fail=yes ac_cv_func_mmap_fixed_mapped=yes ac_cv_func_memcmp_working=yes ac_cv_have_decl_malloc=yes gl_cv_func_malloc_0_nonnull=yes ac_cv_func_malloc_0_nonnull=yes ac_cv_func_calloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes lt_cv_sys_lib_search_path_spec="" ac_cv_c_bigendian=no

NATIVE_GCC_EXTRA_CONFIG_ARGS=--with-gxx-include-dir=/opt/include/c++/4.5.3 --disable-__cxa_atexit --enable-target-optspace --disable-libgomp --with-gnu-ld --disable-libssp --disable-tls --enable-shared --enable-threads --disable-decimal-float --with-float=soft --with-abi=aapcs-linux --with-arch=armv7-a --with-tune=cortex-a9

endif

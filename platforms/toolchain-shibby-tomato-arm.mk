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
TARGET_CROSS_TOP = $(BASE_DIR)/toolchain/hndtools-arm-linux-2.6.36-uclibc-4.5.3
TARGET_CROSS = $(TARGET_CROSS_TOP)/bin/arm-brcm-linux-uclibcgnueabi-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/arm-brcm-linux-uclibcgnueabi/sysroot/usr/lib
TARGET_INCDIR = $(TARGET_CROSS_TOP)/arm-brcm-linux-uclibcgnueabi/sysroot/usr/include
TARGET_LDFLAGS =
TARGET_CUSTOM_FLAGS= -pipe
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

#TOOLCHAIN_SITE=https://bitbucket.org/pl_shibby/tomato-arm/get
#TOOLCHAIN_BINARY=shibby-tomato-arm.git20140205.zip
TOOLCHAIN_SITE=http://dl.lazyzhu.com/file/Toolchain/crosstool-NG
TOOLCHAIN_BINARY=hndtools-arm-linux-2.6.36-uclibc-4.5.3.tar.bz2

UCLIBC-OPT_VERSION = 0.9.32.1
UCLIBC-OPT_IPK_VERSION = 1
UCLIBC-OPT_LIBS_SOURCE_DIR = $(TARGET_CROSS_TOP)/arm-brcm-linux-uclibcgnueabi/sysroot/lib

toolchain: $(TARGET_CROSS_TOP)/.unpacked

$(DL_DIR)/$(TOOLCHAIN_BINARY):
#	$(WGET) -O $@ $(TOOLCHAIN_SITE)/4e7f635c8c54.zip || \
#	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
	$(WGET) -P $(@D) $(TOOLCHAIN_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(TARGET_CROSS_TOP)/.unpacked: $(DL_DIR)/$(TOOLCHAIN_BINARY) # $(OPTWARE_TOP)/platforms/toolchain-$(OPTWARE_TARGET).mk
	rm -rf $(TARGET_CROSS_TOP)
	mkdir -p $(BASE_DIR)/toolchain
#	unzip $(DL_DIR)/$(TOOLCHAIN_BINARY) 'pl_shibby-tomato-arm-4e7f635c8c54/release/src-rt-6.x.4708/toolchains/*' -d $(BASE_DIR)/toolchain
#	mv -f $(BASE_DIR)/toolchain/pl_shibby-tomato-arm-4e7f635c8c54/release/src-rt-6.x.4708/toolchains/hndtools-arm-linux-2.6.36-uclibc-4.5.3 $(BASE_DIR)/toolchain/
#	rm -rf $(BASE_DIR)/toolchain/pl_shibby-tomato-arm-4e7f635c8c54
	tar -xjvf $(DL_DIR)/$(TOOLCHAIN_BINARY) -C $(BASE_DIR)/toolchain
	rm -f $(UCLIBC-OPT_LIBS_SOURCE_DIR)/libgcc_s.so
	ln -s libgcc_s.so.1 $(UCLIBC-OPT_LIBS_SOURCE_DIR)/libgcc_s.so
#	### since toolchain's uclibc is missing getifaddrs and freeifaddrs implementations, we should remove the header with respective declarations,
#	### otherwise it can be picked up by packages, e.g., sane-backends, leading to 'undefined reference' linking errors
#	mv $(TARGET_CROSS_TOP)/arm-brcm-linux-uclibcgnueabi/sysroot/usr/include/ifaddrs.h $(TARGET_CROSS_TOP)/arm-brcm-linux-uclibcgnueabi/sysroot/usr/include/ifaddrs.h_
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

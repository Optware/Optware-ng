LIBC_STYLE=uclibc
TARGET_ARCH=arm
TARGET_OS=linux-uclibc

LIBSTDC++_VERSION=6.0.2

GETTEXT_NLS=enable
NO_BUILTIN_MATH=true
IPV6=no

HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME=$(TARGET_ARCH)-linux

CROSS_CONFIGURATION_GCC_VERSION=3.4.2
CROSS_CONFIGURATION_UCLIBC_VERSION=0.9.28
BUILDROOT_GCC=$(CROSS_CONFIGURATION_GCC_VERSION)
UCLIBC-OPT_VERSION=$(CROSS_CONFIGURATION_UCLIBC_VERSION)

WDBE_SOURCE_DIR=$(SOURCE_DIR)/wdbe

ifeq ($(HOST_MACHINE),armv5tejl)

HOSTCC = $(TARGET_CC)
GNU_HOST_NAME = $(HOST_MACHINE)-linux-gnu
GNU_TARGET_NAME=$(TARGET_ARCH)-linux
TARGET_CROSS=/opt/bin/
TARGET_LIBDIR=/opt/lib
TARGET_INCDIR=/opt/include
TARGET_LDFLAGS = -L/opt/lib
TARGET_CUSTOM_FLAGS=
TARGET_CFLAGS=-I/opt/include $(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain:

else

CROSS_CONFIGURATION_GCC=gcc-$(CROSS_CONFIGURATION_GCC_VERSION)
CROSS_CONFIGURATION_UCLIBC=uclibc-$(CROSS_CONFIGURATION_UCLIBC_VERSION)
CROSS_CONFIGURATION=$(CROSS_CONFIGURATION_GCC)-$(CROSS_CONFIGURATION_UCLIBC)
TARGET_CROSS_TOP = $(shell cd $(BASE_DIR); pwd)/toolchain/wdbe-buildroot/build_arm_nofpu/staging_dir
TARGET_CROSS = $(TARGET_CROSS_TOP)/bin/$(TARGET_ARCH)-$(TARGET_OS)-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/lib
TARGET_INCDIR = $(TARGET_CROSS_TOP)/include
TARGET_LDFLAGS = 
TARGET_CUSTOM_FLAGS= -pipe 
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

TOOLCHAIN_SITE=http://support.wdc.com/download/mybook
TOOLCHAIN_SOURCE=WD-World-NAS-v02.00.18-GPL.tar.bz2

UCLIBC-OPT_VERSION = 0.9.28
UCLIBC-OPT_IPK_VERSION = 1
UCLIBC-OPT_LIBS_SOURCE_DIR = $(TARGET_CROSS_TOP)/lib

NATIVE_GCC_VERSION=3.4.6
NATIVE_GCC_EXTRA_CONFIG_ARGS=--with-float=soft --enable-threads --disable-__cxa_atexit --enable-target-optspace --with-gnu-ld
LIBC-DEV_CRT_DIR=/opt/lib/gcc/arm-linux-uclibc/$(NATIVE_GCC_VERSION)

toolchain: $(TARGET_CROSS)gcc

$(DL_DIR)/$(TOOLCHAIN_SOURCE):
	$(WGET) -P $(@D) $(TOOLCHAIN_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(BASE_DIR)/toolchain/.unpacked: $(DL_DIR)/$(TOOLCHAIN_SOURCE) # $(OPTWARE_TOP)/platforms/toolchain-$(OPTWARE_TARGET).mk
	rm -rf $@ $(TARGET_CROSS_TOP)
	mkdir -p $(@D)
	tar -xvj -C $(@D) -f $< WD_v2.0_RC18/gpl-buildroot-archives.tar
	tar -xv -C $(@D) -f $(@D)/WD_v2.0_RC18/gpl-buildroot-archives.tar
	rm -rf $(@D)/WD_v2.0_RC18
	mv $(@D)/buildroot-archives/buildroot-20060823.tar.bz2 $(@D)
	mv -u $(@D)/buildroot-archives/* $(DL_DIR)
	rm -rf $(@D)/buildroot-archives
	tar -xvj -C $(@D) -f $(@D)/buildroot-20060823.tar.bz2
	mv $(@D)/buildroot $(@D)/wdbe-buildroot
	rm -f $(@D)/buildroot-20060823.tar.bz2
	cp -f $(WDBE_SOURCE_DIR)/.defconfig $(@D)/wdbe-buildroot
	sed -i -e "s~Apply appropriate binutils patches.~Apply appropriate binutils patches.\n	cat $(WDBE_SOURCE_DIR)/binutils_bfd_ar_spacepad.patch | patch -d toolchain_build_arm_nofpu/binutils-2.16.1 -p0~" $(@D)/wdbe-buildroot/toolchain/binutils/binutils.mk
	echo "ARCH_HAS_MMU=y" >> $(@D)/wdbe-buildroot/toolchain/uClibc/uClibc.config
	echo "HAS_FPU=n" >> $(@D)/wdbe-buildroot/toolchain/uClibc/uClibc.config
	echo "BUILD_UCLIBC_LDSO=y" >> $(@D)/wdbe-buildroot/toolchain/uClibc/uClibc.config
	echo "DL_FINI_CRT_COMPAT=n" >> $(@D)/wdbe-buildroot/toolchain/uClibc/uClibc.config
	echo "LDSO_RUNPATH=y" >> $(@D)/wdbe-buildroot/toolchain/uClibc/uClibc.config
	touch $@

$(TARGET_CROSS)gcc: $(BASE_DIR)/toolchain/.unpacked # $(OPTWARE_TOP)/platforms/toolchain-gumstix1151.mk
	mkdir -p tmp
	$(MAKE) -C toolchain/wdbe-buildroot defconfig
	$(MAKE) -C toolchain/wdbe-buildroot DL_DIR=$(DL_DIR)
	rm -rf tmp
endif

LIBC_STYLE=uclibc
TARGET_ARCH=arm
TARGET_OS=linux-uclibc

LIBSTDC++_VERSION=6.0.3

GETTEXT_NLS=enable
NO_BUILTIN_MATH=true
IPV6=no

HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME=$(TARGET_ARCH)-linux

CROSS_CONFIGURATION_GCC_VERSION=3.4.5
CROSS_CONFIGURATION_UCLIBC_VERSION=0.9.28
BUILDROOT_GCC=$(CROSS_CONFIGURATION_GCC_VERSION)
UCLIBC-OPT_VERSION=$(CROSS_CONFIGURATION_UCLIBC_VERSION)

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
TARGET_CROSS_TOP = $(shell cd $(BASE_DIR); pwd)/toolchain/gumstix-buildroot/build_arm_nofpu/staging_dir
TARGET_CROSS = $(TARGET_CROSS_TOP)/bin/$(TARGET_ARCH)-$(TARGET_OS)-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/lib
TARGET_INCDIR = $(TARGET_CROSS_TOP)/include
TARGET_LDFLAGS = 
TARGET_CUSTOM_FLAGS= -pipe 
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

NATIVE_GCC_VERSION=3.4.6
NATIVE_GCC_EXTRA_CONFIG_ARGS=--with-float=soft
LIBC-DEV_CRT_DIR=/opt/lib/gcc/arm-linux-uclibc/$(NATIVE_GCC_VERSION)

toolchain: $(TARGET_CROSS)gcc

$(TARGET_CROSS)gcc: # $(OPTWARE_TOP)/platforms/toolchain-gumstix1151.mk
	cd toolchain; \
	rm -rf gumstix-buildroot; \
	svn co -r1151 --username root --password root http://svn.gumstix.com/gumstix-buildroot/trunk gumstix-buildroot
	cp $(SOURCE_DIR)/toolchain/gumstix1151/102-configure.patch \
		toolchain/gumstix-buildroot/toolchain/binutils/2.17
	$(MAKE) -C toolchain/gumstix-buildroot defconfig DL_DIR=$(DL_DIR)
	sed -i.orig \
	    -e '/BR2_INSTALL_LIBSTDCPP/s/^.*/BR2_INSTALL_LIBSTDCPP=y/' \
	    toolchain/gumstix-buildroot/.config
	sed -i.orig \
	    -e '/UCLIBC_HAS_FULL_RPC/d' \
	    -e '/UCLIBC_HAS_RPC/s/^.*/UCLIBC_HAS_RPC=y/' \
	    -e '/UCLIBC_HAS_RPC/aUCLIBC_HAS_FULL_RPC=y' \
	    toolchain/gumstix-buildroot/toolchain/uClibc/uClibc.config \
	    toolchain/gumstix-buildroot/target/device/Gumstix/basix-connex/uClibc.config
	$(MAKE) -C toolchain/gumstix-buildroot DL_DIR=$(DL_DIR)
endif

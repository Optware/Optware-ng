TARGET_ARCH=armeb
TARGET_OS=linux
LIBC_STYLE=glibc

LIBSTDC++_VERSION=6.0.9
LIBNSL_VERSION=2.6.1

CROSS_CONFIGURATION_GCC_VERSION=4.2.4
CROSS_CONFIGURATION_GLIBC_VERSION=2.6.1
CROSS_CONFIGURATION_GCC=gcc-$(CROSS_CONFIGURATION_GCC_VERSION)
CROSS_CONFIGURATION_GLIBC=glibc-$(CROSS_CONFIGURATION_GLIBC_VERSION)
CROSS_CONFIGURATION = $(CROSS_CONFIGURATION_GCC)-$(CROSS_CONFIGURATION_GLIBC)

#STAGING_CPPFLAGS+= -DPATH_MAX=4096 -DLINE_MAX=2048 -DMB_LEN_MAX=16

GNU_TARGET_NAME = armeb-linux-gnueabi

UPD-ALT_PREFIX = /opt

ifeq ($(HOST_MACHINE),armv5teb)
HOSTCC = $(TARGET_CC)
GNU_HOST_NAME = armeb-linux
TARGET_CROSS = /usr/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = /usr/lib
TARGET_INCDIR = /usr/include
TARGET_LDFLAGS =
TARGET_CUSTOM_FLAGS=
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain:
else
HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
TARGET_CROSS_TOOLCHAIN_LOCATION=slugos/tmp/cross/armv5teb
#TARGET_CROSS_TOOLCHAIN_LOCATION=releases/slugos-5.1-beta/nslu2be.tmp/cross
TARGET_CROSS_TOP = $(shell cd $(BASE_DIR)/../..; pwd)/$(TARGET_CROSS_TOOLCHAIN_LOCATION)
TARGET_CROSS = $(TARGET_CROSS_TOP)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/lib
TARGET_INCDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/include
TARGET_LDFLAGS = 
TARGET_CUSTOM_FLAGS= -pipe 
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain:
endif

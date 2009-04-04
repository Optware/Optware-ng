# This toolchain is gcc 4.2.3 on glibc 2.5

TARGET_ARCH=arm
TARGET_OS=linux
LIBC_STYLE=glibc

LIBSTDC++_VERSION=6.0.9
LIBNSL_VERSION=2.5

BINUTILS_VERSION = 2.19.1
BINUTILS_IPK_VERSION = 1

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
GNU_TARGET_NAME = arm-none-linux-gnueabi
TARGET_CROSS_TOP = $(BASE_DIR)/toolchain/arm-2008q1
TARGET_CROSS = $(TARGET_CROSS_TOP)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/libc/lib
TARGET_USRLIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/libc/usr/lib
TARGET_INCDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/libc/usr/include
TARGET_LDFLAGS =
TARGET_CUSTOM_FLAGS= -pipe
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

TOOLCHAIN_SITE=http://www.codesourcery.com/public/gnu_toolchain/arm-none-linux-gnueabi
TOOLCHAIN_BINARY=arm-2008q1-126-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2
TOOLCHAIN_SOURCE=arm-2008q1-126-arm-none-linux-gnueabi.src.tar.bz2

toolchain: $(TARGET_CROSS_TOP)/.unpacked

$(DL_DIR)/$(TOOLCHAIN_BINARY):
	$(WGET) -P $(@D) $(TOOLCHAIN_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(DL_DIR)/$(TOOLCHAIN_SOURCE):
	$(WGET) -P $(@D) $(TOOLCHAIN_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(TARGET_CROSS_TOP)/.unpacked: $(DL_DIR)/$(TOOLCHAIN_BINARY) # $(OPTWARE_TOP)/platforms/toolchain-$(OPTWARE_TARGET).mk
	rm -rf $(TARGET_CROSS_TOP)
	mkdir -p $(BASE_DIR)/toolchain
	tar -xj -C $(BASE_DIR)/toolchain -f $(DL_DIR)/$(TOOLCHAIN_BINARY)
	touch $@

# following three are for building native gcc using cross toolchain
GCC_SOURCE=gcc-2008q1-126.tar.bz2
GCC_DIR=gcc-4.2
GCC_PATCHES=nothing

GCC_IPK_VERSION = 1

$(DL_DIR)/$(GCC_SOURCE): $(DL_DIR)/$(TOOLCHAIN_SOURCE)
	tar -C $(@D) -xjf $(@D)/$(TOOLCHAIN_SOURCE) arm-2008q1-126-arm-none-linux-gnueabi/$(@F)
	mv $(@D)/arm-2008q1-126-arm-none-linux-gnueabi/$(@F) $@
	rmdir $(@D)/arm-2008q1-126-arm-none-linux-gnueabi
	touch $@

NATIVE_GCC_EXTRA_CONFIG_ARGS=--enable-threads --disable-libmudflap --disable-libssp --disable-libgomp --disable-libstdcxx-pch --enable-shared --enable-symvers=gnu --enable-__cxa_atexit

endif

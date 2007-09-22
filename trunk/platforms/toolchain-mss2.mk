TARGET_ARCH=armeb
TARGET_OS=linux
LIBC_STYLE=glibc

HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME = arm-none-linux-gnueabi
TARGET_CROSS_TOP = $(BASE_DIR)/toolchain/$(GNU_TARGET_NAME)/gcc-2005q3-glibc-2.3.6
TARGET_CROSS = $(TARGET_CROSS_TOP)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/lib
TARGET_USRLIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/libc/usr/lib
TARGET_INCDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/libc/usr/include
TARGET_LDFLAGS =
TARGET_CUSTOM_FLAGS= -pipe
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

TOOLCHAIN_URL="http://www.codesourcery.com/gnu_toolchains/arm/releases/download?version=2005q3-2&pkg_prefix=arm&target=arm-none-linux-gnueabi&host=i686-pc-linux-gnu"
TOOLCHAIN_SOURCE=arm-2005q3-2-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2

toolchain: $(TARGET_CROSS_TOP)/.unpacked

$(DL_DIR)/$(TOOLCHAIN_SOURCE):
	$(WGET) -P $(DL_DIR) $(TOOLCHAIN_URL) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(TOOLCHAIN_SOURCE)

$(TARGET_CROSS_TOP)/.unpacked: $(DL_DIR)/$(TOOLCHAIN_SOURCE) $(OPTWARE_TOP)/platforms/toolchain-gumstix1151.mk
	rm -rf $(TARGET_CROSS_TOP)
	mkdir -p $(TARGET_CROSS_TOP)
	tar -xj -C $(TARGET_CROSS_TOP) -f $(DL_DIR)/$(TOOLCHAIN_SOURCE)
	touch $@

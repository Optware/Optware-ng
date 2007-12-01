# This toolchain is gcc 4.1.1 on glibc 2.3.6

TARGET_ARCH=arm
TARGET_OS=linux
LIBC_STYLE=glibc

LIBSTDC++_VERSION=6.0.9
LIBNSL_VERSION=2.3.6

HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME = arm-none-linux-gnueabi
#TARGET_CROSS_TOP = $(BASE_DIR)/toolchain/$(GNU_TARGET_NAME)/gcc-2007q3-glibc-2.3.6
TARGET_CROSS_TOP = $(BASE_DIR)/toolchain/arm-2007q3
TARGET_CROSS = $(TARGET_CROSS_TOP)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/lib
TARGET_USRLIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/libc/usr/lib
TARGET_INCDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/libc/usr/include
TARGET_LDFLAGS =
TARGET_CUSTOM_FLAGS= -pipe
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

TOOLCHAIN_SITE=http://www.codesourcery.com/public/gnu_toolchain/arm-none-linux-gnueabi
TOOLCHAIN_BINARY=arm-2007q3-51-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2
TOOLCHAIN_SOURCE=arm-2007q3-51-arm-none-linux-gnueabi.src.tar.bz2

toolchain: $(TARGET_CROSS_TOP)/.unpacked

$(DL_DIR)/$(TOOLCHAIN_BINARY):
	$(WGET) -P $(DL_DIR) $(TOOLCHAIN_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

$(DL_DIR)/$(TOOLCHAIN_SOURCE):
	$(WGET) -P $(DL_DIR) $(TOOLCHAIN_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

$(TARGET_CROSS_TOP)/.unpacked: $(DL_DIR)/$(TOOLCHAIN_BINARY) # $(OPTWARE_TOP)/platforms/toolchain-$(OPTWARE_TARGET).mk
	rm -rf $(TARGET_CROSS_TOP)
	mkdir -p $(BASE_DIR)/toolchain
	tar -xj -C $(BASE_DIR)/toolchain -f $(DL_DIR)/$(TOOLCHAIN_BINARY)
	touch $@

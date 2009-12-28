TARGET_ARCH=armeb
TARGET_OS=linux
LIBC_STYLE=glibc

LIBSTDC++_VERSION=6.0.3
LIBNSL_VERSION=2.3.6

HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME = armeb-none-linux-gnueabi
TARGET_CROSS_TOP = $(BASE_DIR)/toolchain/$(GNU_TARGET_NAME)/gcc-2005q3-glibc-2.3.5
TARGET_CROSS = $(TARGET_CROSS_TOP)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/sys-root/lib
TARGET_USRLIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/sys-root/usr/lib
TARGET_INCDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/sys-root/usr/include
TARGET_LDFLAGS = 
TARGET_CUSTOM_FLAGS= -pipe
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

UPD-ALT_PREFIX = /usr


TOOLCHAIN_SITE = http://ftp.osuosl.org/pub/nslu2/sources
TOOLCHAIN_SOURCE = arm-eabi-lebe.tar.bz2
TOOLCHAIN_SOURCE2 = arm-linux-tools-20031127.tar.gz


toolchain: $(BASE_DIR)/toolchain/.unpacked

$(DL_DIR)/$(TOOLCHAIN_SOURCE):
	$(WGET) -P $(DL_DIR) $(TOOLCHAIN_SITE)/$(@F)

$(DL_DIR)/$(TOOLCHAIN_SOURCE2):
	$(WGET) -P $(DL_DIR) $(TOOLCHAIN_SITE)/$(@F)

toolchain-download: $(DL_DIR)/$(TOOLCHAIN_SOURCE) $(DL_DIR)/$(TOOLCHAIN_SOURCE2)

$(BASE_DIR)/toolchain/.unpacked: $(DL_DIR)/$(TOOLCHAIN_SOURCE) $(DL_DIR)/$(TOOLCHAIN_SOURCE2) \
$(OPTWARE_TOP)/platforms/toolchain-fsg3v4.mk
	rm -rf $(TARGET_CROSS_TOP)
	mkdir -p $(TARGET_CROSS_TOP)
	tar -xj -C $(TARGET_CROSS_TOP) -f $(DL_DIR)/$(TOOLCHAIN_SOURCE)
	mkdir -p $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/include
	tar -xz -C $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/include/ \
	    -f $(DL_DIR)/$(TOOLCHAIN_SOURCE2) usr/local/arm-linux/sys-include
	mv $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/include/usr/local/arm-linux/sys-include/* \
	   $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/include/
	rm -rf $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/include/usr
	rm -rf $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/include/net/route.h
	touch $@

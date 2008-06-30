TARGET_ARCH=arm
TARGET_OS=linux
LIBC_STYLE=glibc

LIBSTDC++_VERSION=6.0.3
LIBNSL_VERSION=2.3.2

GNU_TARGET_NAME = arm-marvell-linux-gnu

STAGING_CPPFLAGS+= -DPATH_MAX=4096 -DLINE_MAX=2048 -DMB_LEN_MAX=16

ifeq (armv5tejl, $(HOST_MACHINE))

HOSTCC = $(TARGET_CC)
GNU_HOST_NAME = $(GNU_TARGET_NAME)
TARGET_CROSS = /opt/bin/
TARGET_LIBDIR = /opt/lib
TARGET_INCDIR = /opt/include
TARGET_LDFLAGS = -L/opt/lib
TARGET_CUSTOM_FLAGS= -O2 -pipe
TARGET_CFLAGS= -I/opt/include $(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

toolchain:

else

HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
TARGET_CROSS_TOP = $(BASE_DIR)/toolchain/gcc-3.4.3-glibc-2.3.2
TARGET_CROSS = $(TARGET_CROSS_TOP)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/lib
TARGET_USRLIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/lib
TARGET_INCDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/include
TARGET_LDFLAGS =
TARGET_CUSTOM_FLAGS= -O2 -pipe
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

TOOLCHAIN_BINARY_SITE=http://download.synology.com/toolchain
TOOLCHAIN_BINARY=gcc343_glibc232_88f5281.tbz

TOOLCHAIN_KERNEL_SITE=ftp://ftp.kernel.org/pub/linux/kernel/v2.6
TOOLCHAIN_KERNEL_VERSION=2.6.15
TOOLCHAIN_KERNEL_SOURCE=linux-$(TOOLCHAIN_KERNEL_VERSION).tar.bz2

toolchain: $(TARGET_CROSS_TOP)/.unpacked

$(DL_DIR)/$(TOOLCHAIN_BINARY):
	$(WGET) -P $(@D) $(TOOLCHAIN_BINARY_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(DL_DIR)/$(TOOLCHAIN_KERNEL_SOURCE):
	$(WGET) -P $(@D) $(TOOLCHAIN_KERNEL_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(BASE_DIR)/toolchain/linux-$(TOOLCHAIN_KERNEL_VERSION)/include/linux/version.h: $(DL_DIR)/$(TOOLCHAIN_KERNEL_SOURCE)
	tar -xj -C $(BASE_DIR)/toolchain -f $(DL_DIR)/$(TOOLCHAIN_KERNEL_SOURCE)
	$(MAKE) -C $(BASE_DIR)/toolchain/linux-$(TOOLCHAIN_KERNEL_VERSION) include/linux/version.h

$(TARGET_CROSS_TOP)/.unpacked: \
$(BASE_DIR)/toolchain/linux-$(TOOLCHAIN_KERNEL_VERSION)/include/linux/version.h \
$(DL_DIR)/$(TOOLCHAIN_BINARY) \
# $(OPTWARE_TOP)/platforms/toolchain-$(OPTWARE_TARGET).mk
	rm -rf $(@D)
	mkdir -p $(@D)
	tar -xj -C $(BASE_DIR)/toolchain -f $(DL_DIR)/$(TOOLCHAIN_BINARY)
	mv $(BASE_DIR)/toolchain/usr/local/$(GNU_TARGET_NAME)/* $(@D)
	rm -rf $(BASE_DIR)/toolchain/usr
	ln -s $(BASE_DIR)/toolchain/linux-$(TOOLCHAIN_KERNEL_VERSION)/include/linux $(TARGET_INCDIR)/
	ln -s $(BASE_DIR)/toolchain/linux-$(TOOLCHAIN_KERNEL_VERSION)/include/asm-arm $(TARGET_INCDIR)/asm
	ln -s $(BASE_DIR)/toolchain/linux-$(TOOLCHAIN_KERNEL_VERSION)/include/asm-generic $(TARGET_INCDIR)/
	cp $(OPTWARE_TOP)/sources/toolchain-$(OPTWARE_TARGET)/autoconf.h $(BASE_DIR)/toolchain/linux-$(TOOLCHAIN_KERNEL_VERSION)/include/linux/
	touch $@

endif

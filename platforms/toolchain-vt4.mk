TARGET_ARCH=arm
TARGET_OS=linux
LIBC_STYLE=glibc

# LIBSTDC++_VERSION=6.0.3
LIBNSL_VERSION=2.3.5

HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME = arm-linux
TARGET_NAME = arm_920t_le
TARGET_CROSS_TOP = $(BASE_DIR)/toolchain/$(TARGET_NAME)
TARGET_CROSS  = $(TARGET_CROSS_TOP)/920t_le/bin/$(TARGET_NAME)-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/920t_le/lib/gcc/${GNU_TARGET_NAME}/3.4.4/
TARGET_INCDIR = $(TARGET_CROSS_TOP)/920t_le/lib/gcc/$(GNU_TARGET_NAME)/3.4.4/include
TARGET_LDFLAGS = -L$(TARGET_LIBDIR) -Wl,-rpath-link,$(TARGET_LIBDIR)
TARGET_CUSTOM_FLAGS= -pipe -I$(TARGET_INCDIR)
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

UPD-ALT_PREFIX = /usr


TOOLCHAIN_BINARY_URL="http://sources.nslu2-linux.org/sources/arm-920t_le.tar.bz2"
TOOLCHAIN_BINARY=arm-920t_le.tar.bz2

TOOLCHAIN_KERNEL_SITE=ftp://ftp.kernel.org/pub/linux/kernel/v2.6
TOOLCHAIN_KERNEL_VERSION=2.6.15
TOOLCHAIN_KERNEL_SOURCE=linux-$(TOOLCHAIN_KERNEL_VERSION).tar.bz2

toolchain: $(TARGET_CROSS_TOP)/.unpacked

$(DL_DIR)/$(TOOLCHAIN_BINARY):
	$(WGET) -P $(DL_DIR) $(TOOLCHAIN_BINARY_URL)

$(DL_DIR)/$(TOOLCHAIN_KERNEL_SOURCE):
	$(WGET) -P $(DL_DIR) $(TOOLCHAIN_KERNEL_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

$(BASE_DIR)/toolchain/linux-$(TOOLCHAIN_KERNEL_VERSION)/include/linux/version.h: $(DL_DIR)/$(TOOLCHAIN_KERNEL_SOURCE)
	tar -xj -C $(BASE_DIR)/toolchain -f $(DL_DIR)/$(TOOLCHAIN_KERNEL_SOURCE)
	cp $(OPTWARE_TOP)/sources/toolchain-$(OPTWARE_TARGET)/autoconf.h $(BASE_DIR)/toolchain/linux-$(TOOLCHAIN_KERNEL_VERSION)/include/linux/
	$(MAKE) -C $(BASE_DIR)/toolchain/linux-$(TOOLCHAIN_KERNEL_VERSION) include/linux/version.h

$(TARGET_CROSS_TOP)/.unpacked: \
$(BASE_DIR)/toolchain/linux-$(TOOLCHAIN_KERNEL_VERSION)/include/linux/version.h \
$(DL_DIR)/$(TOOLCHAIN_BINARY) \
$(OPTWARE_TOP)/platforms/toolchain-$(OPTWARE_TARGET).mk
	rm -rf $(@D)
	mkdir -p $(@D)
	tar -xj -C $(@D) -f $(DL_DIR)/$(TOOLCHAIN_BINARY)
	install -d $(STAGING_LIB_DIR)
	# delete old libs in toolchain
	rm -rf $(TARGET_CROSS_TOP)/920t_le/lib/gcc/$(GNU_TARGET_NAME)/3.4.4/libcrypto*
	rm -rf $(TARGET_CROSS_TOP)/920t_le/lib/gcc/$(GNU_TARGET_NAME)/3.4.4/libjpeg*
	rm -rf $(TARGET_CROSS_TOP)/920t_le/lib/gcc/$(GNU_TARGET_NAME)/3.4.4/libncurses*
	rm -rf $(TARGET_CROSS_TOP)/920t_le/lib/gcc/$(GNU_TARGET_NAME)/3.4.4/libpng*
	rm -rf $(TARGET_CROSS_TOP)/920t_le/lib/gcc/$(GNU_TARGET_NAME)/3.4.4/libtorrent*
	rm -rf $(TARGET_CROSS_TOP)/920t_le/lib/gcc/$(GNU_TARGET_NAME)/3.4.4/libz*
	rm -rf $(TARGET_CROSS_TOP)/920t_le/lib/gcc/$(GNU_TARGET_NAME)/3.4.4/libuuid*
	rm -rf $(TARGET_CROSS_TOP)/920t_le/lib/gcc/$(GNU_TARGET_NAME)/3.4.4/libssl*
	rm -rf $(TARGET_CROSS_TOP)/920t_le/lib/gcc/$(GNU_TARGET_NAME)/3.4.4/libcurl*
	rm -rf $(TARGET_CROSS_TOP)/920t_le/lib/gcc/$(GNU_TARGET_NAME)/3.4.4/libid3tag*
	#cp -fpd $(TARGET_CROSS_TOP)/920t_le/lib/gcc/$(GNU_TARGET_NAME)/3.4.4/libdl*so* $(STAGING_LIB_DIR)/
	ln -sf $(BASE_DIR)/toolchain/linux-$(TOOLCHAIN_KERNEL_VERSION)/include/linux $(TARGET_INCDIR)/
	ln -sf $(BASE_DIR)/toolchain/linux-$(TOOLCHAIN_KERNEL_VERSION)/include/asm-arm $(TARGET_INCDIR)/asm
	ln -sf $(BASE_DIR)/toolchain/linux-$(TOOLCHAIN_KERNEL_VERSION)/include/asm-generic $(TARGET_INCDIR)/
	cd $(TARGET_CROSS_TOP)/920t_le/bin && sh $(OPTWARE_TOP)/sources/toolchain-$(OPTWARE_TARGET)/symlink-back.sh
	touch $@

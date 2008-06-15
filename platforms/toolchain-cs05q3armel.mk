TARGET_ARCH=arm
TARGET_OS=linux
LIBC_STYLE=glibc

LIBSTDC++_VERSION=6.0.3
LIBNSL_VERSION=2.3.6

HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME = arm-none-linux-gnueabi
TARGET_CROSS_TOP = $(BASE_DIR)/toolchain/$(GNU_TARGET_NAME)/gcc-2005q3-glibc-2.3.6
TARGET_CROSS = $(TARGET_CROSS_TOP)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/lib
TARGET_USRLIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/libc/usr/lib
TARGET_LIBC_LIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/libc/lib
TARGET_INCDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/libc/usr/include
TARGET_LDFLAGS =
TARGET_CUSTOM_FLAGS= -pipe
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

TOOLCHAIN_BINARY_URL="http://www.codesourcery.com/gnu_toolchains/arm/releases/download?version=2005q3-2&pkg_prefix=arm&target=arm-none-linux-gnueabi&host=i686-pc-linux-gnu"
TOOLCHAIN_BINARY=arm-2005q3-2-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2
TOOLCHAIN_SOURCE_SITE=http://www.codesourcery.com/public/gnu_toolchain/arm-none-linux-gnueabi
TOOLCHAIN_SOURCE=arm-2005q3-2-arm-none-linux-gnueabi.src.tar.bz2

toolchain: $(TARGET_CROSS_TOP)/.010patched

$(DL_DIR)/$(TOOLCHAIN_BINARY):
	$(WGET) -P $(DL_DIR) $(TOOLCHAIN_BINARY_URL) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

$(DL_DIR)/$(TOOLCHAIN_SOURCE):
	$(WGET) -P $(DL_DIR) $(TOOLCHAIN_SOURCE_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

$(TARGET_CROSS_TOP)/.unpacked: $(DL_DIR)/$(TOOLCHAIN_BINARY) # $(OPTWARE_TOP)/platforms/toolchain-$(OPTWARE_TARGET).mk
	rm -rf $(TARGET_CROSS_TOP)
	mkdir -p $(TARGET_CROSS_TOP)
	tar -xj -C $(TARGET_CROSS_TOP) -f $(DL_DIR)/$(TOOLCHAIN_BINARY)
	touch $@


$(TARGET_CROSS_TOP)/.010patched: $(TARGET_CROSS_TOP)/.unpacked
	rm -f $@
	patch -d $(TARGET_INCDIR) -p0 < $(SOURCE_DIR)/toolchain-cs05q3armel/kernel_ulong_t.patch
	touch $@

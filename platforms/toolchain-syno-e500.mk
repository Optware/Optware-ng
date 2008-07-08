TARGET_ARCH=powerpc
TARGET_OS=linux
LIBC_STYLE=glibc

LIBSTDC++_VERSION=6.0.3
LIBNSL_VERSION=2.3.4

GNU_TARGET_NAME = powerpc-linux-gnuspe

ifeq (ppc, $(HOST_MACHINE))

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
TARGET_CROSS_TOP = $(BASE_DIR)/toolchain/gcc-3.4.3-glibc-2.3.4
TARGET_CROSS = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/lib
TARGET_USRLIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/lib
TARGET_INCDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/include
TARGET_LDFLAGS =
TARGET_CUSTOM_FLAGS= -O2 -pipe
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

NATIVE_GCC_VERSION=3.4.6

TOOLCHAIN_BINARY_SITE=http://download.synology.com/toolchain
TOOLCHAIN_BINARY=gcc343_glibc234_854x.tar.gz

toolchain: $(TARGET_CROSS_TOP)/.unpacked

$(DL_DIR)/$(TOOLCHAIN_BINARY):
	$(WGET) -P $(@D) $(TOOLCHAIN_BINARY_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(TARGET_CROSS_TOP)/.unpacked: \
$(DL_DIR)/$(TOOLCHAIN_BINARY) \
$(OPTWARE_TOP)/platforms/toolchain-$(OPTWARE_TARGET).mk
	rm -rf $(@D)
	mkdir -p $(@D)
	tar -xz -C $(@D) -f $(DL_DIR)/$(TOOLCHAIN_BINARY)
	cd $(TARGET_INCDIR); \
	rm -rf ext2fs et mtd security; \
	rm -rf `find . -newer stdio.h -a ! -newer pam_client.h`
	touch $@

endif

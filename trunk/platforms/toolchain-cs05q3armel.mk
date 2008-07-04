TARGET_ARCH=arm
TARGET_OS=linux
LIBC_STYLE=glibc

LIBSTDC++_VERSION=6.0.3
LIBNSL_VERSION=2.3.6

GNU_TARGET_NAME = arm-none-linux-gnueabi

ifeq ($(HOST_MACHINE), $(filter armv5tejl, $(HOST_MACHINE)))

HOSTCC = $(TARGET_CC)
GNU_HOST_NAME = $(GNU_TARGET_NAME)
TARGET_CROSS = /opt/bin/
TARGET_LIBDIR = /opt/lib
TARGET_INCDIR = /opt/include
TARGET_LDFLAGS = -L/opt/lib
TARGET_CUSTOM_FLAGS=
TARGET_CFLAGS=-I/opt/include $(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

toolchain:

else

HOSTCC = gcc
  ifneq (Darwin, $(HOST_OS))
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
TARGET_CROSS_TOP = $(BASE_DIR)/toolchain/$(GNU_TARGET_NAME)/gcc-2005q3-glibc-2.3.6
  else
GNU_HOST_NAME = i386-apple-darwin
TARGET_CROSS_TOP = /opt/local
  endif

TARGET_CROSS = $(TARGET_CROSS_TOP)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/lib
TARGET_USRLIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/libc/usr/lib
TARGET_LIBC_LIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/libc/lib
TARGET_INCDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/libc/usr/include
TARGET_LDFLAGS =
TARGET_CUSTOM_FLAGS= -pipe
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

  ifneq (Darwin, $(HOST_OS))

TOOLCHAIN_SITE=http://www.codesourcery.com/public/gnu_toolchain/arm-none-linux-gnueabi
TOOLCHAIN_BINARY=arm-2005q3-2-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2
TOOLCHAIN_SOURCE=arm-2005q3-2-arm-none-linux-gnueabi.src.tar.bz2

# following three are for building native gcc using cross toolchain
GCC_SOURCE=gcc-2005q3-2.tar.bz2
GCC_DIR=gcc-2005q3
GCC_PATCHES=nothing

toolchain: $(TARGET_CROSS_TOP)/.010patched

$(DL_DIR)/$(TOOLCHAIN_BINARY):
	$(WGET) -P $(@D) $(TOOLCHAIN_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(DL_DIR)/$(TOOLCHAIN_SOURCE):
	$(WGET) -P $(@D) $(TOOLCHAIN_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(DL_DIR)/$(GCC_SOURCE): $(DL_DIR)/$(TOOLCHAIN_SOURCE)
	tar -C $(@D) -xjf $(@D)/$(TOOLCHAIN_SOURCE) arm-2005q3-2-arm-none-linux-gnueabi/$(@F)
	mv $(@D)/arm-2005q3-2-arm-none-linux-gnueabi/$(@F) $@
	rmdir $(@D)/arm-2005q3-2-arm-none-linux-gnueabi
	touch $@

$(TARGET_CROSS_TOP)/.unpacked: $(DL_DIR)/$(TOOLCHAIN_BINARY) # $(OPTWARE_TOP)/platforms/toolchain-$(OPTWARE_TARGET).mk
	rm -rf $(TARGET_CROSS_TOP)
	mkdir -p $(TARGET_CROSS_TOP)
	tar -xj -C $(TARGET_CROSS_TOP) -f $(DL_DIR)/$(TOOLCHAIN_BINARY)
	touch $@

$(TARGET_CROSS_TOP)/.010patched: $(TARGET_CROSS_TOP)/.unpacked
	rm -f $@
	patch -d $(TARGET_INCDIR) -p0 < $(SOURCE_DIR)/toolchain-cs05q3armel/kernel_ulong_t.patch
	touch $@

  else		# Mac OS X
toolchain:

  endif

endif

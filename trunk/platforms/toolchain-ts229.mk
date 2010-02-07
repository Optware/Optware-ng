TARGET_ARCH=powerpc
TARGET_OS=linux
LIBC_STYLE=glibc

LIBSTDC++_VERSION=6.0.9
LIBNSL_VERSION=2.6

GNU_TARGET_NAME = ppc-linux

ifeq ($(HOST_MACHINE), $(filter ppc, $(HOST_MACHINE)))

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

GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
TARGET_CROSS_TOP = $(BASE_DIR)/toolchain/eldk

TARGET_CROSS = $(TARGET_CROSS_TOP)/usr/bin/ppc_4xxFP-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/ppc_4xxFP/lib
TARGET_USRLIBDIR = $(TARGET_CROSS_TOP)/ppc_4xxFP/usr/lib
TARGET_LIBC_LIBDIR = $(TARGET_CROSS_TOP)/ppc_4xxFP/lib
TARGET_INCDIR = $(TARGET_CROSS_TOP)/ppc_4xxFP/usr/include
TARGET_LDFLAGS =
TARGET_CUSTOM_FLAGS= -pipe
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

LIBC-DEV_LIBC_SO_DIR := $(TARGET_LIBDIR)
LIBC-DEV_CRT_DIR := /opt/ppc-linux/lib
GCC_BUILD_EXTRA_ENV := CROSS_COMPILE=ppc_4xxFP-

TOOLCHAIN_SITE=$(SOURCES_NLO_SITE)
TOOLCHAIN_BINARY=qnap-ppc_4xxFP-toolchain.tar.bz2
#TOOLCHAIN_SOURCE=gnu-csl-arm-2005Q1B-arm-none-linux-gnueabi.src.tar.bz2

# following three are for building native gcc using cross toolchain
# GCC_SOURCE=gcc-2005q3-2.tar.bz2
# GCC_DIR=gcc-2005q3
# GCC_PATCHES=nothing

toolchain: $(TARGET_CROSS_TOP)/.unpacked

$(DL_DIR)/$(TOOLCHAIN_BINARY):
	$(WGET) -P $(@D) $(TOOLCHAIN_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#$(DL_DIR)/$(TOOLCHAIN_SOURCE):
#	$(WGET) -P $(@D) $(TOOLCHAIN_SITE)/$(@F) || \
#	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#$(DL_DIR)/$(GCC_SOURCE): $(DL_DIR)/$(TOOLCHAIN_SOURCE)
#	tar -C $(@D) -xjf $(@D)/$(TOOLCHAIN_SOURCE) arm-2005q3-2-arm-none-linux-gnueabi/$(@F)
#	mv $(@D)/arm-2005q3-2-arm-none-linux-gnueabi/$(@F) $@
#	rmdir $(@D)/arm-2005q3-2-arm-none-linux-gnueabi
#	touch $@

$(TARGET_CROSS_TOP)/.unpacked: $(DL_DIR)/$(TOOLCHAIN_BINARY) # $(OPTWARE_TOP)/platforms/toolchain-$(OPTWARE_TARGET).mk
	rm -rf $(@D)
	mkdir -p $(@D)
	tar -xj -C $(@D)/.. -f $(DL_DIR)/$(TOOLCHAIN_BINARY)
	touch $@

#$(TARGET_CROSS_TOP)/.010patched: $(TARGET_CROSS_TOP)/.unpacked
#	rm -f $@
#	patch -d $(TARGET_INCDIR) -p0 < $(SOURCE_DIR)/toolchain-cs05q3armel/kernel_ulong_t.patch
#	touch $@

endif

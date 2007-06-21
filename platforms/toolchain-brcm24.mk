# This toolchain builds Optware packages for Broadcom routers with OpenWRT
# Kamikaze firmware using OpenWRT buildroot SDK 7.06
#
# LOCALE_SUPPORT is not available
# some math functions (eg. C99) are missing
#
# Visit http://www.nslu2-linux.org/wiki/FAQ/Optware-brcm24Build
# for more info
#


LIBC_STYLE=uclibc
TARGET_ARCH=mipsel
TARGET_OS=linux-uclibc

# TODO BUILDROOT_CUSTOM_HEADERS = $(HEADERS_OLEG)

HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME=$(TARGET_ARCH)-linux

CROSS_CONFIGURATION_GCC_VERSION=3.4.6
CROSS_CONFIGURATION_UCLIBC_VERSION=0.9.28
BUILDROOT_GCC=$(CROSS_CONFIGURATION_GCC_VERSION)
UCLIBC-OPT_VERSION=$(CROSS_CONFIGURATION_UCLIBC_VERSION)

ifeq ($(HOST_MACHINE),mips)
HOSTCC = $(TARGET_CC)
GNU_HOST_NAME = $(HOST_MACHINE)-linux-gnu
GNU_TARGET_NAME=$(TARGET_ARCH)-linux 
TARGET_CROSS=/opt/bin/
TARGET_LIBDIR=/opt/lib
TARGET_LDFLAGS = -L/opt/lib -luclibcnotimpl
TARGET_CUSTOM_FLAGS=
TARGET_CFLAGS=-I/opt/include $(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain:
else
CROSS_CONFIGURATION_GCC=gcc-$(CROSS_CONFIGURATION_GCC_VERSION)
CROSS_CONFIGURATION_UCLIBC=uclibc-$(CROSS_CONFIGURATION_UCLIBC_VERSION)
CROSS_CONFIGURATION=$(CROSS_CONFIGURATION_GCC)-$(CROSS_CONFIGURATION_UCLIBC)
TARGET_CROSS = $(TOOL_BUILD_DIR)/$(TARGET_ARCH)-$(TARGET_OS)/$(CROSS_CONFIGURATION)/bin/$(TARGET_ARCH)-$(TARGET_OS)-
TARGET_LIBDIR = $(TOOL_BUILD_DIR)/$(TARGET_ARCH)-$(TARGET_OS)/$(CROSS_CONFIGURATION)/lib
TARGET_LDFLAGS = -luclibcnotimpl
TARGET_CUSTOM_FLAGS= -Os -pipe -mips32 -mtune=mips32 -funit-at-a-time
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain: brcm24-toolchain
endif

TARGET_GXX=$(TOOL_BUILD_DIR)/$(TARGET_ARCH)-$(TARGET_OS)/$(CROSS_CONFIGURATION)/nowrap/$(TARGET_ARCH)-$(TARGET_OS)-g++


#
# While it is rather simple to create toolchain with OpenWER buildroot system,
# it is not provided for i686 but rather for x86_64 architecture
# That's why SDK is provided by alternate source
#
BRCM24_SDK=OpenWrt-SDK-brcm-2.4-for-Linux-i686
BRCM24_SOURCE=$(BRCM24_SDK).tar.bz2
BRCM24_SITE=http://www.wlan-sat.com/boleo/optware
#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BRCM24_SOURCE):
	$(WGET) -P $(DL_DIR) $(BRCM24_SITE)/$(BRCM24_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(BRCM24_SOURCE)


$(TOOL_BUILD_DIR)/$(TARGET_ARCH)-$(TARGET_OS)/$(CROSS_CONFIGURATION)/.staged: $(DL_DIR)/$(BRCM24_SOURCE)
	rm -rf $(TOOL_BUILD_DIR)/$(TARGET_ARCH)-$(TARGET_OS)/$(CROSS_CONFIGURATION)
	rm -rf $(TOOL_BUILD_DIR)/$(TARGET_ARCH)-$(TARGET_OS)/$(BRCM24_SDK)
	install -d  $(TOOL_BUILD_DIR)/$(TARGET_ARCH)-$(TARGET_OS)
	tar -xvj -C $(TOOL_BUILD_DIR)/$(TARGET_ARCH)-$(TARGET_OS) -f $(DL_DIR)/$(BRCM24_SOURCE)
	ln -s $(TOOL_BUILD_DIR)/$(TARGET_ARCH)-$(TARGET_OS)/$(BRCM24_SDK)/staging_dir_$(TARGET_ARCH) \
		$(TOOL_BUILD_DIR)/$(TARGET_ARCH)-$(TARGET_OS)/$(CROSS_CONFIGURATION)
	touch $(TOOL_BUILD_DIR)/$(TARGET_ARCH)-$(TARGET_OS)/$(CROSS_CONFIGURATION)/.staged

brcm24-toolchain: directories $(TOOL_BUILD_DIR)/$(TARGET_ARCH)-$(TARGET_OS)/$(CROSS_CONFIGURATION)/.staged uclibcnotimpl-toolchain libuclibc++-toolchain
brcm24-source:  $(DL_DIR)/$(BRCM24_SOURCE)

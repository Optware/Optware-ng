# This toolchain builds Optware packages for Broadcom routers with OpenWRT
# Kamikaze firmware using OpenWRT buildroot SDK for Linux 2.6
#
# uClibc/config/mipsel shows that
# UCLIBC_HAS_FLOATS=y
# UCLIBC_HAS_FPU=y
# DO_C99_MATH=y
# UCLIBC_HAS_LOCALE is not set
# so there is no need to define NO_BUILTIN_MATH=true
#
# Toolchain C++ in wrapped against uClibc++ library while for some difficult C++ programs
# still uses non wrapped TARGET_GXX for which complete stdlibc++ is required
#
# Visit http://www.nslu2-linux.org/wiki/Optware/OpenWRT-brcm47xxBuild
# for more info
#

# We provide two toolchains: stable | unstable
OPENWRT-BRCM47XX_DISTRIBUTION ?= stable

ifeq ($(OPENWRT-BRCM47XX_DISTRIBUTION), stable)
OPENWRT-BRCM47XX_CODENAME=backfire
OPENWRT-BRCM47XX_REVISION=20728
OPENWRT-BRCM47XX_VERSION=10.03
else
OPENWRT-BRCM47XX_CODENAME=trunk
OPENWRT-BRCM47XX_REVISION=22390
OPENWRT-BRCM47XX_VERSION=10.03
endif

LIBC_STYLE=uclibc
TARGET_ARCH=mipsel
TARGET_OS=linux-uclibc

GETTEXT_NLS=enable

HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME=$(TARGET_ARCH)-openwrt-linux


CROSS_CONFIGURATION_GCC_VERSION=4.3.3
CROSS_CONFIGURATION_UCLIBC_VERSION=0.9.30.1
LIBSTDC++_VERSION=6.0.8
LIBNSL_VERSION=0.9.30.1
NATIVE_GCC_VERSION=4.3.3

LIBC-DEV_CRT_DIR=/opt/lib/gcc/$(TARGET_ARCH)-$(TARGET_OS)/$(NATIVE_GCC_VERSION)

ifeq ($(HOST_MACHINE),mips)
HOSTCC = $(TARGET_CC)
GNU_HOST_NAME = $(HOST_MACHINE)-linux-gnu
GNU_TARGET_NAME=$(TARGET_ARCH)-linux 
TARGET_CROSS=/opt/bin/
TARGET_LIBDIR=/opt/lib
TARGET_INCDIR=/opt/include
TARGET_LDFLAGS = -L/opt/lib
TARGET_CUSTOM_FLAGS=
TARGET_CFLAGS=-I/opt/include $(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain:
else
CROSS_CONFIGURATION_GCC=gcc-$(CROSS_CONFIGURATION_GCC_VERSION)
CROSS_CONFIGURATION_UCLIBC=uclibc-$(CROSS_CONFIGURATION_UCLIBC_VERSION)
CROSS_CONFIGURATION=$(CROSS_CONFIGURATION_GCC)-$(CROSS_CONFIGURATION_UCLIBC)
TARGET_CROSS_TOP = $(TOOL_BUILD_DIR)/$(TARGET_ARCH)-$(TARGET_OS)/$(CROSS_CONFIGURATION)
TARGET_CROSS = $(TARGET_CROSS_TOP)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/lib
TARGET_INCDIR = $(TARGET_CROSS_TOP)/include
TARGET_LDFLAGS =
#FLAGS -mips32 -mtune=mips32 conflicts with amule, asterisk, apcupsd, ... 
TARGET_CUSTOM_FLAGS= -O2 -pipe -fPIC
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain: openwrt-brcm47xx-toolchain
endif


TARGET_GXX = $(TARGET_CROSS_TOP)/nowrap/$(GNU_TARGET_NAME)-g++


#
# We build toolchain (SDK) from Subversion repository
#
OPENWRT-BRCM47XX_SOURCE=openwrt-$(OPENWRT-BRCM47XX_CODENAME)-r$(OPENWRT-BRCM47XX_REVISION)_source.tar.bz2
OPENWRT-BRCM47XX_SITE=http://downloads.openwrt.org/$(OPENWRT-BRCM47XX_CODENAME)/$(OPENWRT-BRCM47XX_VERSION)
OPENWRT-BRCM47XX_DIR=openwrt-$(OPENWRT-BRCM47XX_CODENAME)-r$(OPENWRT-BRCM47XX_REVISION)

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the NSLU2 site using wget.

ifeq ($(OPENWRT-BRCM47XX_DISTRIBUTION), stable)
$(DL_DIR)/$(OPENWRT-BRCM47XX_SOURCE):
	( svn co -r $(OPENWRT-BRCM47XX_REVISION) svn://svn.openwrt.org/openwrt/branches/backfire \
		$(TOOL_BUILD_DIR)/$(OPENWRT-BRCM47XX_DIR) \
		&& cd $(TOOL_BUILD_DIR) && tar cvjf $@ $(OPENWRT-BRCM47XX_DIR) \
		&& rm -rf $(TOOL_BUILD_DIR)/$(OPENWRT-BRCM47XX_DIR) \
	) \
	|| $(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(OPENWRT-BRCM47XX_SOURCE)
else
$(DL_DIR)/$(OPENWRT-BRCM47XX_SOURCE):
	svn co -r $(OPENWRT-BRCM47XX_REVISION) svn://svn.openwrt.org/openwrt/trunk \
		$(TOOL_BUILD_DIR)/$(OPENWRT-BRCM47XX_DIR)
	tar -C $(TOOL_BUILD_DIR) -cvjf $@ $(OPENWRT-BRCM47XX_DIR)
	rm -rf $(TOOL_BUILD_DIR)/$(OPENWRT-BRCM47XX_DIR)
endif

OPENWRT-BRCM47XX_TOOL_DIR=$(TOOL_BUILD_DIR)/$(TARGET_ARCH)-$(TARGET_OS)
OPENWRT-BRCM47XX_BUILD_DIR=$(OPENWRT-BRCM47XX_TOOL_DIR)/$(OPENWRT-BRCM47XX_DIR)
OPENWRT-BRCM47XX_CONFIG=$(OPENWRT-BRCM47XX_BUILD_DIR)/.config

#
# Configure for toochain
# For building firmware from trunk additional packages should be selected
# with make menuconfig && make 
#
$(OPENWRT-BRCM47XX_BUILD_DIR)/.configured : $(DL_DIR)/$(OPENWRT-BRCM47XX_SOURCE) 
	rm -rf $(OPENWRT-BRCM47XX_BUILD_DIR)
	rm -rf $(OPENWRT-BRCM47XX_BUILD_DIR)/$(CROSS_CONFIGURATION)
	install -d $(OPENWRT-BRCM47XX_TOOL_DIR)
	bzcat $(DL_DIR)/$(OPENWRT-BRCM47XX_SOURCE) | tar -C $(OPENWRT-BRCM47XX_TOOL_DIR) -xvf -
#	sed -i -e 's/-openwrt-linux/-linux/g' $(OPENWRT-BRCM47XX_BUILD_DIR)/rules.mk
ifeq ($(OPENWRT-BRCM47XX_DISTRIBUTION), stable)
	wget -P $(OPENWRT-BRCM47XX_BUILD_DIR) $(OPENWRT-BRCM47XX_SITE)/brcm47xx/OpenWrt.config
	cp $(OPENWRT-BRCM47XX_BUILD_DIR)/OpenWrt.config $(OPENWRT-BRCM47XX_CONFIG)
	sed  -i -e 's/# CONFIG_MAKE_TOOLCHAIN is not set/CONFIG_MAKE_TOOLCHAIN=y/' \
		-e 's/# CONFIG_SDK is not set/CONFIG_SDK=y/' \
		$(OPENWRT-BRCM47XX_CONFIG)
	$(MAKE) -C $(OPENWRT-BRCM47XX_BUILD_DIR) oldconfig
else
	echo 'CONFIG_TARGET_brcm47xx=y'        		> $(OPENWRT-BRCM47XX_CONFIG)
	echo 'CONFIG_TARGET_BOARD="brcm47xx"' 		>> $(OPENWRT-BRCM47XX_CONFIG)
	echo 'CONFIG_SDK=y'                   		>> $(OPENWRT-BRCM47XX_CONFIG)
	echo 'CONFIG_MAKE_TOOLCHAIN=y'			>> $(OPENWRT-BRCM47XX_CONFIG)
	echo 'CONFIG_PACKAGE_libpthread=m'		>> $(OPENWRT-BRCM47XX_CONFIG)
	echo 'CONFIG_PACKAGE_librt=m'			>> $(OPENWRT-BRCM47XX_CONFIG)
	echo 'CONFIG_PACKAGE_libstdcpp=m'		>> $(OPENWRT-BRCM47XX_CONFIG)
	echo '# CONFIG_PACKAGE_ebtables is not set' 	>> $(OPENWRT-BRCM47XX_CONFIG)
	echo '# CONFIG_PACKAGE_ebtables-utils is not set' >> $(OPENWRT-BRCM47XX_CONFIG)
	echo '# CONFIG_PACKAGE_kmod-ebtables is not set' >> $(OPENWRT-BRCM47XX_CONFIG)
	echo '# CONFIG_PACKAGE_enlightenment is not set' >> $(OPENWRT-BRCM47XX_CONFIG)
	echo '# CONFIG_PACKAGE_etk is not set' 		>> $(OPENWRT-BRCM47XX_CONFIG)
	echo '# CONFIG_PACKAGE_python-etk is not set' 	>> $(OPENWRT-BRCM47XX_CONFIG)
	echo 'CONFIG_PACKAGE_luci-admin-full=y' 	>> $(OPENWRT-BRCM47XX_CONFIG)
	echo 'CONFIG_PACKAGE_luci-admin-mini=y' 	>> $(OPENWRT-BRCM47XX_CONFIG)
	$(MAKE) -C $(OPENWRT-BRCM47XX_BUILD_DIR) defconfig
endif
	touch $@

#
# This builds the actual SDK and .trx firmware
#
$(OPENWRT-BRCM47XX_BUILD_DIR)/.built: $(OPENWRT-BRCM47XX_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(OPENWRT-BRCM47XX_BUILD_DIR) tools/install toolchain/install
	$(MAKE) -C $(OPENWRT-BRCM47XX_BUILD_DIR) V=99
	touch $@


$(TARGET_CROSS_TOP)/.staged: $(OPENWRT-BRCM47XX_BUILD_DIR)/.built
	rm -rf $(TARGET_CROSS_TOP)
	ln -s $(OPENWRT-BRCM47XX_BUILD_DIR)/staging_dir/toolchain-$(TARGET_ARCH)_gcc-$(CROSS_CONFIGURATION_GCC_VERSION)+cs_uClibc-$(CROSS_CONFIGURATION_UCLIBC_VERSION)/usr $(TARGET_CROSS_TOP)
	touch $@

# This is the main toolchain target
openwrt-brcm47xx-toolchain: directories $(TARGET_CROSS_TOP)/.staged libuclibc++-toolchain


#
# These are the SDK build convenience target.
#
openwrt-brcm47xx-source: $(DL_DIR)/$(OPENWRT-BRCM47XX_SOURCE)
openwrt-brcm47xx-unpack: $(OPENWRT-BRCM47XX_BUILD_DIR)/.configured
openwrt-brcm47xx-sdk: $(OPENWRT-BRCM47XX_BUILD_DIR)/.built
openwrt-brcm47xx-stage: $(TARGET_CROSS_TOP)/.staged

openwrt-brcm47xx-dirclean:
	rm -rf $(OPENWRT-BRCM47XX_BUILD_DIR) $(TARGET_CROSS_TOP)

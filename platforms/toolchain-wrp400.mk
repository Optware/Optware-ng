TARGET_ARCH=arm
TARGET_OS=linux
LIBC_STYLE=uclibc

GNU_TARGET_NAME = arm-linux-uclibc

#LIBSTDC++_VERSION=6.0.3
LIBNSL_VERSION=0.9.28

GETTEXT_NLS=enable

GPL_SOURCE_VERSION=1.00.06
GPL_SOURCE_SITE=ftp://ftp.linksys.com/opensourcecode/wrp400/$(GPL_SOURCE_VERSION)
GPL_SOURCE_DIR=wrp400_$(GPL_SOURCE_VERSION)_us_source
GPL_SOURCE_TARBALL=wrp400_$(GPL_SOURCE_VERSION)_us.tgz

$(DL_DIR)/$(GPL_SOURCE_TARBALL):
	$(WGET) -P $(@D) $(GPL_SOURCE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

ifeq (arm, $(HOST_MACHINE))

toolchain:

else

HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu

TARGET_CROSS_TOP = $(BASE_DIR)/toolchain/$(GPL_SOURCE_DIR)/Result/buildroot/build_arm/opt/usr
TARGET_CROSS = $(TARGET_CROSS_TOP)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/lib
TARGET_USRLIBDIR = $(TARGET_CROSS_TOP)/lib
TARGET_INCDIR = $(TARGET_CROSS_TOP)/include
TARGET_LDFLAGS =
TARGET_OPTIMIZATION= -O2
TARGET_CUSTOM_FLAGS= -pipe
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

.PHONY: toolchain

toolchain: $(TARGET_CROSS)-gcc

$(TARGET_CROSS)-gcc: $(DL_DIR)/$(GPL_SOURCE_TARBALL)
	rm -rf $(BASE_DIR)/toolchain/$(GPL_SOURCE_DIR)
	tar -xOzvf $(DL_DIR)/$(GPL_SOURCE_TARBALL) \
	    wrp400_$(GPL_SOURCE_VERSION)_us_0701_1827/$(GPL_SOURCE_DIR).tgz \
	    | tar -C $(BASE_DIR)/toolchain -xzvf -
	sed -i -e '/make -C buildroot/s|$$| DL_DIR=$(DL_DIR)|' $(BASE_DIR)/toolchain/$(GPL_SOURCE_DIR)/Result/Makefile
	cd $(BASE_DIR)/toolchain/$(GPL_SOURCE_DIR) && script -c 'make -C Result toolchain'

endif

# TODO:
#	* patch toolchain_build_arm/binutils-2.17/configure.in to use makeinfo 4.11
#		http://gcc.gnu.org/ml/gcc-patches/2007-09/msg01271.html
#	* BR2_INSTALL_LIBSTDCPP=y in buildroot/.config to enable C++
#	* LD_RUNPATH in uclibc/.config to enable rpath
#	* UCLIBC_HAS_RPC=y and UCLIBC_HAS_FULL_RPC=y in uclibc/.config

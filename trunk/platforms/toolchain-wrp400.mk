TARGET_ARCH=arm
TARGET_OS=linux
LIBC_STYLE=uclibc

GNU_TARGET_NAME = arm-linux-uclibc

LIBSTDC++_VERSION=6.0.3
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

$(BASE_DIR)/toolchain/$(GPL_SOURCE_DIR)/.built: $(DL_DIR)/$(GPL_SOURCE_TARBALL)
	rm -rf $(@D)
	tar -xOzvf $(DL_DIR)/$(GPL_SOURCE_TARBALL) \
	    wrp400_$(GPL_SOURCE_VERSION)_us_0701_1827/$(GPL_SOURCE_DIR).tgz \
	    | tar -C $(BASE_DIR)/toolchain -xzvf -
	cp $(SOURCE_DIR)/toolchain/wrp400/buildroot-defconfig $(@D)/toolchain_misc/_config
	sed -i -e '/make -C buildroot/s|$$| DL_DIR=$(DL_DIR)|' $(@D)/Result/Makefile
	$(MAKE) -C $(@D)/Result .toolchain
	cp $(SOURCE_DIR)/toolchain/wrp400/302-c99-snprintf.patch \
		$(@D)/Result/buildroot/toolchain/gcc/3.4.6/
	sed -i -e '/LDSO_RUNPATH/s|.*|LDSO_RUNPATH=y|' \
		$(@D)/Result/buildroot/toolchain/uClibc/uClibc-0.9.28.config
	$(MAKE) -C $(@D)/Result toolchain
	touch $@

toolchain: $(BASE_DIR)/toolchain/$(GPL_SOURCE_DIR)/.built

endif

# TODO:
#	* patch toolchain_build_arm/binutils-2.17/configure.in to use makeinfo 4.11
#		http://gcc.gnu.org/ml/gcc-patches/2007-09/msg01271.html

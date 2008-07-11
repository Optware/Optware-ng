TARGET_ARCH=arm
TARGET_OS=linux
LIBC_STYLE=uclibc

#LIBSTDC++_VERSION=6.0.3
LIBNSL_VERSION=0.9.28

GNU_TARGET_NAME = arm-linux-uclibc

GPL_SOURCE_VERSION=1.00.06
GPL_SOURCE_SITE=ftp://ftp.linksys.com/opensourcecode/wrp400/$(GPL_SOURCE_VERSION)
GPL_SOURCE_DIR=wrp400_$(GPL_SOURCE_VERSION)_us
GPL_SOURCE_SOURCE=$(GPL_SOURCE_DIR).tgz

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

toolchain:

endif

# TODO:
#	* automate download and make toolchain
#	* patch toolchain_build_arm/binutils-2.17/configure.in to use makeinfo 4.11
#		http://gcc.gnu.org/ml/gcc-patches/2007-09/msg01271.html
#	* BR2_INSTALL_LIBSTDCPP=y in buildroot/.config to enable C++
#	* LD_RUNPATH in uclibc/.config to enable rpath

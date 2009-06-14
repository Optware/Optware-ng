TARGET_ARCH=arm
TARGET_OS=linux
LIBC_STYLE=glibc

LIBSTDC++_VERSION=6.0.3
LIBNSL_VERSION=2.3.2

GNU_TARGET_NAME = arm-marvell-linux-gnu

STAGING_CPPFLAGS+= -DPATH_MAX=4096 -DLINE_MAX=2048 -DMB_LEN_MAX=16

ifeq (armv5tejl, $(HOST_MACHINE))

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
TARGET_CROSS_TOP = $(BASE_DIR)/toolchain/gcc-3.4.3-glibc-2.3.2
TARGET_CROSS = $(TARGET_CROSS_TOP)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/lib
TARGET_USRLIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/lib
TARGET_INCDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/include
TARGET_LDFLAGS =
TARGET_CUSTOM_FLAGS= -O2 -pipe
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)


toolchain: toolchain/.configured

toolchain/.configured: ../syno-x07/toolchain/gcc-3.4.3-glibc-2.3.2/.unpacked
	rm -rf toolchain
	ln -s ../syno-x07/toolchain .
	touch $@

../syno-x07/toolchain/gcc-3.4.3-glibc-2.3.2/.unpacked:
	$(MAKE) -C .. syno-x07-target
	$(MAKE) -C ../syno-x07 toolchain

endif

TARGET_ARCH=arm
TARGET_OS=linux
LIBC_STYLE=glibc

LIBSTDC++_VERSION=6.0.9
LIBNSL_VERSION=2.5

HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME = arm-none-linux-gnueabi

TARGET_CROSS_TOP = $(BASE_DIR)/toolchain/arm-2008q1
TARGET_CROSS = $(TARGET_CROSS_TOP)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/libc/lib
TARGET_USRLIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/libc/usr/lib
TARGET_INCDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/libc/usr/include
TARGET_LDFLAGS =
TARGET_CUSTOM_FLAGS= -pipe
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)


toolchain: toolchain/$(GNU_COMBO)/.unpacked

toolchain/$(GNU_COMBO)/.unpacked: ../cs08q1armel/toolchain/arm-2008q1/.unpacked
	rm -rf toolchain
	ln -s ../cs08q1armel/toolchain .

../cs08q1armel/toolchain/arm-2008q1/.unpacked:
	$(MAKE) -C .. cs08q1armel-target
	$(MAKE) -C ../cs08q1armel toolchain

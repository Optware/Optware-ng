TARGET_ARCH=arm
TARGET_OS=linux
LIBC_STYLE=glibc

HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME = arm-none-linux-gnueabi
GNU_COMBO=$(GNU_TARGET_NAME)/gcc-2005q3-glibc-2.3.6
TARGET_CROSS_TOP = $(BASE_DIR)/toolchain/$(GNU_COMBO)
TARGET_CROSS = $(TARGET_CROSS_TOP)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/lib
TARGET_USRLIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/libc/usr/lib
TARGET_INCDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/libc/usr/include
TARGET_LDFLAGS =
TARGET_CUSTOM_FLAGS= -pipe
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

toolchain: toolchain/$(GNU_COMBO)/.unpacked

toolchain/$(GNU_COMBO)/.unpacked: ../cs05q3armel/toolchain/$(GNU_COMBO)/.unpacked
	rm -rf toolchain
	ln -s ../cs05q3armel/toolchain .

../cs05q3armel/toolchain/$(GNU_COMBO)/.unpacked:
	$(MAKE) -C .. cs05q3armel-target
	$(MAKE) -C ../cs05q3armel toolchain

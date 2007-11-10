# This toolchain can build binaries for Debian arm etch 4.0

TARGET_ARCH=arm
TARGET_OS=linux
LIBC_STYLE=glibc

HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME = arm-linux
TARGET_CROSS_TOP = $(BASE_DIR)/toolchain/scratchbox/compilers/arm-linux-gcc3.4.cs-glibc2.3
TARGET_CROSS = $(TARGET_CROSS_TOP)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/lib
TARGET_USRLIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/libc/usr/lib
TARGET_INCDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/libc/usr/include
TARGET_LDFLAGS =
TARGET_CUSTOM_FLAGS= -pipe
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

TOOLCHAIN_APOPHIS_SITE=http://scratchbox.org/download/files/sbox-releases/branches/apophis
TOOLCHAIN_BIN_SITE=$(TOOLCHAIN_APOPHIS_SITE)/r3/tarball
TOOLCHAIN_BIN=scratchbox-toolchain-arm-gcc3.4-glibc2.3-1.0.2-i386.tar.gz
TOOLCHAIN_LIB_SITE=$(TOOLCHAIN_APOPHIS_SITE)/r4/tarball
TOOLCHAIN_LIB=scratchbox-libs-1.0.8-i386.tar.gz

toolchain: $(BASE_DIR)/toolchain/.unpacked

$(DL_DIR)/$(TOOLCHAIN_BIN):
	$(WGET) -P $(DL_DIR) $(TOOLCHAIN_BIN_SITE)/$(@F)

$(DL_DIR)/$(TOOLCHAIN_LIB):
	$(WGET) -P $(DL_DIR) $(TOOLCHAIN_LIB_SITE)/$(@F)

toolchain-download: $(DL_DIR)/$(TOOLCHAIN_BIN) $(DL_DIR)/$(TOOLCHAIN_LIB)

$(BASE_DIR)/toolchain/.unpacked: $(DL_DIR)/$(TOOLCHAIN_BIN) $(DL_DIR)/$(TOOLCHAIN_LIB) # $(OPTWARE_TOP)/platforms/toolchain-$(OPTWARE_TARGET).mk
	rm -f $@
	rm -rf $(BASE_DIR)/toolchain/scratchbox
	mkdir -p $(BASE_DIR)/toolchain/scratchbox
	tar -xz -C $(BASE_DIR)/toolchain -f $(DL_DIR)/$(TOOLCHAIN_BIN)
	@echo "###"; echo "### Manually do the following:"
	@echo "sudo tar -xz -C / -f $(DL_DIR)/$(TOOLCHAIN_LIB)"
	@echo touch $@

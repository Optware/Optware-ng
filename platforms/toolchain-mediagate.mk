# Toolchain for Mediagate players should be installed as root with
# make toolchain
# sh downloads/arm-elf-tools-20030314.sh
# http://mediagate.pbwiki.com/
# Building toolchain from sources does not work at the moment.

TARGET_ARCH=arm
TARGET_OS=linux
LIBC_STYLE=uclibc

# LIBSTDC++_VERSION=5.0.3
# LIBNSL_VERSION=2.2.5

HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME = arm-elf
CROSS_CONFIGURATION = arm-elf
TARGET_CROSS = /usr/local/bin/${CROSS_CONFIGURATION}-
TARGET_LIBDIR = /usr/local/$(CROSS_CONFIGURATION)/lib
TARGET_INCDIR = /usr/local/$(CROSS_CONFIGURATION)/include
TARGET_LDFLAGS = -Wl,-elf2flt
TARGET_CUSTOM_FLAGS= -pipe -I${TARGET_INCDIR}
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

TOOLCHAIN_MEDIAGATE_SITE=\
	http://www.uclinux.org/pub/uClinux/arm-elf-tools

TOOLCHAIN_MEDIAGATE_BIN=arm-elf-tools-20030314.sh

$(DL_DIR)/$(TOOLCHAIN_MEDIAGATE):
	$(WGET) -P $(DL_DIR) $(TOOLCHAIN_MEDIAGATE_SITE)/$(TOOLCHAIN_MEDIAGATE_BIN) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(TOOLCHAIN_MEDIAGATE_BIN)


TOOLCHAIN_MEDIAGATE_SRC=$(TOOL_BUILD_DIR)/mediagate-src

TOOLCHAIN_MEDIAGATE_FILES = \
build-uclinux-tools.sh        \
binutils-2.10.tar.bz2         \
binutils-2.10-full.patch      \
gcc-2.95.3.tar.bz2            \
gcc-2.95.3-full.patch         \
gcc-2.95.3-arm-pic.patch      \
gcc-2.95.3-arm-pic.patch2     \
gcc-2.95.3-arm-mlib.patch     \
gcc-2.95.3-sigset.patch       \
gcc-2.95.3-m68k-zext.patch    \
genromfs-0.5.1.tar.gz         \
STLport-4.5.3.tar.gz          \
STLport-4.5.3.patch           \
uClibc-20030314.tar.gz        \
uClibc-0.9.19.patch.gz        \
elf2flt-20030314.tar.gz

TOOLCHAIN_MEDIAGATE_SRC_UCLINUX=\
	$(addprefix $(TOOLCHAIN_MEDIAGATE_SITE)/tools-20030314/, \
	$(TOOLCHAIN_MEDIAGATE_FILES))


$(TOOLCHAIN_MEDIAGATE_SRC):
	install -d $@

$(TOOLCHAIN_MEDIAGATE_SRC)/.downloaded: $(TOOLCHAIN_MEDIAGATE_SRC)
	$(WGET) -P $(TOOLCHAIN_MEDIAGATE_SRC) $(TOOLCHAIN_MEDIAGATE_SRC_UCLINUX)
	svn co https://mg35tools.svn.sourceforge.net/svnroot/mg35tools/firmware/uClinux-2.4 \
		$(TOOLCHAIN_MEDIAGATE_SRC)/linux-2.4.x
	touch $@

$(TOOLCHAIN_MEDIAGATE_SRC)/.configured: $(TOOLCHAIN_MEDIAGATE_SRC)/.downloaded
	cd $(TOOLCHAIN_MEDIAGATE_SRC) ; \
	tar xvzf uClibc-20030314.tar.gz ; \
	tar xvzf elf2flt-20030314.tar.gz

$(TOOLCHAIN_MEDIAGATE_SRC)/.build: $(TOOLCHAIN_MEDIAGATE_SRC)/.configured
	cd $(TOOLCHAIN_MEDIAGATE_SRC);\
	PATH=$PATH:$(TOOL_BUILD_DIR)/mg/bin \
	PREFIX=$(TOOL_BUILD_DIR)/mg \
	sh build-uclinux-tools.sh

toolchain-src: $(TOOLCHAIN_MEDIAGATE_SRC)/.build

toolchain: $(DL_DIR)/$(TOOLCHAIN_MEDIAGATE)

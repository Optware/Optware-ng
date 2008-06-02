# Toolchain for Mediagate players http://mediagate.pbwiki.com/
# Toochain description:
# http://ipodlinux.org/Toolchain#For_applications_.283.4.3_toolchain.29
# Building toolchain from sources does not work at the moment.
# http://ipodlinux.org/Building_Toolchain
# Shared libraries not supported!

TARGET_ARCH=arm
TARGET_OS=linux
LIBC_STYLE=uclibc

HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME = arm-elf
CROSS_CONFIGURATION = arm-uclinux-elf
TARGET_CROSS = /usr/local/arm-uclinux-tools2/bin/${CROSS_CONFIGURATION}-
TARGET_LIBDIR = /usr/local/arm-uclinux-tools2/$(CROSS_CONFIGURATION)/lib
TARGET_INCDIR = /usr/local/arm-uclinux-tools2/$(CROSS_CONFIGURATION)/include
TARGET_LDFLAGS = -Wl,-elf2flt
TARGET_CUSTOM_FLAGS= -pipe -I${TARGET_INCDIR}
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

TOOLCHAIN_MEDIAGATE_SRC=$(TOOL_BUILD_DIR)/mediagate-src

TOOLCHAIN_MEDIAGATE_BIN_FILES = \
	arm-uclinux-elf-tools-base-gcc3.4.3-20050722.sh \
	arm-uclinux-elf-tools-c++-gcc3.4.3-20050722.sh \
	arm-uclinux-elf-tools-gdb-20050722.sh

TOOLCHAIN_MEDIAGATE_DL=$(addprefix $(DL_DIR)/,$(TOOLCHAIN_MEDIAGATE_BIN_FILES))

TOOLCHAIN_MEDIAGATE_DL_SRC=\
	$(addprefix http://www.so2.sys-techs.com/ipod/toolchain/linux-x86/,\
	$(TOOLCHAIN_MEDIAGATE_BIN_FILES))

TOOLCHAIN_MEDIAGATE_DL_NLO=\
	$(addprefix $(SOURCES_NLO_SITE)/,\
	$(TOOLCHAIN_MEDIAGATE_BIN_FILES))


$(TOOLCHAIN_MEDIAGATE_DL):
	$(WGET) -P $(DL_DIR) $(TOOLCHAIN_MEDIAGATE_DL_SRC) || \
	$(WGET) -P $(DL_DIR) $(TOOLCHAIN_MEDIAGATE_DL_NLO)

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


TOOLCHAIN_MEDIAGATE_SITE=\
	http://www.uclinux.org/pub/uClinux/arm-elf-tools

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

$(TARGET_CROSS)gcc:
	@echo "###############"; echo "### Manually do the following:"
	@echo "sudo make toolchain-install"
	@echo "If you get the error like: 'tail: cannot open +43' for reading..."
	@echo "change line 42 in .sh script to:"
	@echo '        tail -n+$${SKIP} $${SCRIPT} | gunzip | tar xvf -'
	@echo "To remove toolchain: sudo rm -rf /usr/local/arm-uclinux-tools2"

toolchain: $(TOOLCHAIN_MEDIAGATE_DL) $(TARGET_CROSS)gcc

toolchain-install:
	$(foreach script, $(TOOLCHAIN_MEDIAGATE_DL), /bin/sh $(script); )
	mv $(TARGET_STRIP) $(TARGET_STRIP).orig
	echo "#!/bin/sh" > $(TARGET_STRIP)
	echo "$(TARGET_STRIP).orig $$@ || exit 0" >> $(TARGET_STRIP)
	chmod 755 $(TARGET_STRIP)

toolchain-remove:
	rm -rf /usr/local/arm-uclinux-tools2

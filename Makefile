# Makefle for unslung packages
#
# Copyright (C) 2004 by Rod Whitby
# Copyright (C) 2004 by Oleg I. Vdovikin <oleg@cs.msu.su>
# Copyright (C) 2001-2004 Erik Andersen <andersen@codepoet.org>
# Copyright (C) 2002 by Tim Riker <Tim@Rikers.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#

TARGETS:= slugtool slingbox

PACKAGES:= dropbear busybox zlib portmap nfs-server inetutils # gdbm

WGET=wget --passive-ftp

# You must install the crosstool Linux Tool Chain.  See:
# http://groups.yahoo.com/group/nslu2-linux/message/422
# and do exactly what it says there (i.e. do not use rc34).

TARGET_OPTIMIZATION= #-Os
TARGET_DEBUGGING= #-g
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING)

HOSTCC:=gcc
BASE_DIR=$(shell pwd)
SOURCE_DIR=$(BASE_DIR)/sources
DL_DIR=$(BASE_DIR)/downloads
FIRMWARE_DIR=$(BASE_DIR)/firmware
BUILD_DIR=$(BASE_DIR)/builds
TARGET_DIR=$(BUILD_DIR)/root
STAGING_DIR=$(BASE_DIR)/staging
TOOL_BUILD_DIR=$(BASE_DIR)/toolchain
TARGET_PATH=$(STAGING_DIR)/bin:/bin:/sbin:/usr/bin:/usr/sbin
PACKAGE_DIR=$(BASE_DIR)/packages

#GNU_TARGET_NAME=arm-linux
GNU_TARGET_NAME=armv5b-softfloat-linux
GNU_SHORT_TARGET_NAME=arm-linux
TARGET_CROSS=$(GNU_TARGET_NAME)-
TARGET_CC=$(TARGET_CROSS)gcc
TARGET_LD=$(TARGET_CROSS)ld
TARGET_AR=$(TARGET_CROSS)ar
TARGET_RANLIB=$(TARGET_CROSS)ranlib
STRIP=$(TARGET_CROSS)strip --remove-section=.comment --remove-section=.note

HOST_ARCH:=$(shell $(HOSTCC) -dumpmachine | sed -e s'/-.*//' \
	-e 's/sparc.*/sparc/' \
	-e 's/arm.*/arm/g' \
	-e 's/m68k.*/m68k/' \
	-e 's/ppc/powerpc/g' \
	-e 's/v850.*/v850/g' \
	-e 's/sh[234]/sh/' \
	-e 's/mips-.*/mips/' \
	-e 's/mipsel-.*/mipsel/' \
	-e 's/cris.*/cris/' \
	-e 's/i[3-9]86/i386/' \
	)
GNU_HOST_NAME:=$(HOST_ARCH)-pc-linux-gnu
TARGET_CONFIGURE_OPTS= \
		AR=$(TARGET_CROSS)ar \
		AS=$(TARGET_CROSS)as \
		LD="$(TARGET_CROSS)ld" \
		NM=$(TARGET_CROSS)nm \
		CC="$(TARGET_CROSS)gcc" \
		GCC="$(TARGET_CROSS)gcc" \
		CXX="$(TARGET_CROSS)g++" \
		RANLIB=$(TARGET_CROSS)ranlib

all: world packages

unslung: $(TARGETS)
	cd firmware ; $(MAKE) umount clean unslung

TARGETS_CLEAN:=$(patsubst %,%-clean,$(TARGETS))
TARGETS_SOURCE:=$(patsubst %,%-source,$(TARGETS))
TARGETS_DIRCLEAN:=$(patsubst %,%-dirclean,$(TARGETS))
TARGETS_INSTALL:=$(patsubst %,%-install,$(TARGETS))

$(TARGETS) : directories
$(TARGETS_INSTALL) : directories

PACKAGES_CLEAN:=$(patsubst %,%-clean,$(PACKAGES))
PACKAGES_SOURCE:=$(patsubst %,%-source,$(PACKAGES))
PACKAGES_DIRCLEAN:=$(patsubst %,%-dirclean,$(PACKAGES))
PACKAGES_UPKG:=$(patsubst %,%-upkg,$(PACKAGES))
PACKAGES_IPKG:=$(patsubst %,%-ipk,$(PACKAGES))

$(PACKAGES) : directories

$(PACKAGES_IPK) : directories ipkg-utils

$(PACKAGE_DIR)/Packages: ipkg-utils $(PACKAGES_IPKG)
	-@mkdir -p $(PACKAGE_DIR)
	{ \
		cd $(PACKAGE_DIR); \
		cp $(BUILD_DIR)/*.ipk .; \
		$(IPKG_MAKE_INDEX) . > Packages; \
	}
	@echo "ALL DONE."

packages: $(PACKAGE_DIR)/Packages

upload:
	scp packages/* nslu.sf.net:/home/groups/n/ns/nslu/htdocs/ipkg

world:  $(DL_DIR) $(BUILD_DIR) $(TARGET_DIR) $(STAGING_DIR) \
	$(TOOL_INSTALL_DIR) $(PACKAGE_DIR) $(TARGETS_INSTALL)
	@echo "ALL DONE."

.PHONY: all world clean dirclean distclean directories source unslung packages \
	$(TARGETS) $(TARGETS_SOURCE) $(TARGETS_CLEAN) $(TARGETS_DIRCLEAN) \
	$(PACKAGES) $(PACKAGES_SOURCE) $(TARGETS_CLEAN) $(TARGETS_DIRCLEAN) \
	$(PACKAGES_IPKG)

include make/*.mk

directories: $(DL_DIR) $(BUILD_DIR) $(TARGET_DIR) $(STAGING_DIR) \
		$(TOOL_BUILD_DIR) $(PACKAGE_DIR)

$(DL_DIR):
	mkdir $(DL_DIR)

$(BUILD_DIR):
	mkdir $(BUILD_DIR)

$(TARGET_DIR):
	mkdir $(TARGET_DIR)
	mkdir $(TARGET_DIR)/lib
	mkdir $(TARGET_DIR)/include

$(STAGING_DIR):
	mkdir $(STAGING_DIR)
	mkdir $(STAGING_DIR)/lib
	mkdir $(STAGING_DIR)/include

$(TOOL_BUILD_DIR):
	mkdir $(TOOL_BUILD_DIR)

$(PACKAGE_DIR):
	mkdir $(PACKAGE_DIR)

source: $(TARGETS_SOURCE) $(PACKAGES_SOURCE)

clean: $(TARGETS_CLEAN) $(PACKAGES_CLEAN)
	cd firmware ; $(MAKE) umount clean
	find . -name '*~' -print | xargs /bin/rm -f
	find . -name '.*~' -print | xargs /bin/rm -f
	find . -name '.#*' -print | xargs /bin/rm -f

distclean: clean
	rm -rf $(BUILD_DIR) $(TARGET_DIR) $(STAGING_DIR) $(TOOL_BUILD_DIR) $(PACKAGE_DIR)

# Makefle for unslung packages
#
# Copyright (C) 2004 by Rod Whitby
# Copyright (C) 2004 by Oleg I. Vdovikin <oleg@cs.msu.su>
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

PACKAGES:= dropbear busybox

WGET=wget --passive-ftp

# You must install the ARM/XScale Linux Tool Chain from:
# http://ftp.snapgear.org/pub/snapgear/tools/arm-linux/arm-linux-tools-20031127.tar.gz

TARGET_OPTIMIZATION= #-Os
TARGET_DEBUGGING= #-g
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING)

HOSTCC:=gcc
BASE_DIR=$(shell pwd)
SOURCE_DIR=$(BASE_DIR)/sources
DL_DIR=$(BASE_DIR)/downloads
FIRMWARE_DIR=$(BASE_DIR)/firmware
BUILD_DIR=$(BASE_DIR)/builds
TARGET_DIR=$(BUILD_DIR)/armeb
PACKAGE_DIR=$(BASE_DIR)/packages

#GNU_TARGET_NAME=arm-linux
GNU_TARGET_NAME=armv5b-softfloat-linux
TARGET_CROSS=$(GNU_TARGET_NAME)-
TARGET_CC=$(TARGET_CROSS)gcc
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
		LD="$(TARGET_CROSS)ld -EB" \
		NM=$(TARGET_CROSS)nm \
		CC="$(TARGET_CROSS)gcc -mbig-endian" \
		GCC="$(TARGET_CROSS)gcc -mbig-endian" \
		CXX="$(TARGET_CROSS)g++ -mbig-endian" \
		RANLIB=$(TARGET_CROSS)ranlib

all: world

unslung: $(TARGETS)
	cd firmware ; $(MAKE) clean unslung

TARGETS_CLEAN:=$(patsubst %,%-clean,$(TARGETS))
TARGETS_SOURCE:=$(patsubst %,%-source,$(TARGETS))
TARGETS_DIRCLEAN:=$(patsubst %,%-dirclean,$(TARGETS))
TARGETS_INSTALL:=$(patsubst %,%-install,$(TARGETS))

PACKAGES_UPKG:=$(patsubst %,%-upkg,$(PACKAGES))

world:  $(DL_DIR) $(BUILD_DIR) $(TARGET_DIR) $(PACKAGE_DIR) \
	$(TARGETS_INSTALL) $(PACKAGES_UPKG)
	@echo "ALL DONE."

.PHONY: all world clean dirclean distclean source slugtool unslung $(TARGETS) \
	$(TARGETS_CLEAN) $(TARGETS_DIRCLEAN) $(TARGETS_SOURCE) \
	$(PACKAGES_UPKG)

include make/*.mk

$(DL_DIR):
	mkdir $(DL_DIR)

$(BUILD_DIR):
	mkdir $(BUILD_DIR)

$(TARGET_DIR):
	mkdir $(TARGET_DIR)

$(PACKAGE_DIR):
	mkdir $(PACKAGE_DIR)

source: $(TARGETS_SOURCE)

distclean: clean
	rm -rf $(BUILD_DIR) $(TARGET_DIR) $(PACKAGE_DIR)
	find . -name '*~' -print | xargs /bin/rm -f

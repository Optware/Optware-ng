# Makefile for unslung packages
#
# Copyright (C) 2004 by Rod Whitby <unslung@gmail.com>
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

PACKAGES:= dropbear busybox miau zlib termcap bash iptables atftp \
	   tinyproxy dnsmasq openssl openssh ntpclient libusb \
	   \
	   sudo rsync rdate grep jove \
	   portmap nfs-server flex inetutils \
	   gdbm libid3tag mt-daapd unfs3 bison cvs \
	   ncurses ircd-hybrid procps \
	   tcpwrappers libevent vdr-mediamvp \
	   wget bzip2 dhcp nano nethack ccxstream \
	   mdadm scponly strace libtool libdb libcurl libbt

PACKAGES_TO_BE_TESTED:= 

PACKAGES_THAT_NEED_TO_BE_FIXED_TO_MATCH_TEMPLATE:= \
	   e2fsprogs dump glib gkrellm

WGET=wget --passive-ftp

# You must install the crosstool Linux Tool Chain.  See:
# http://www.nslu2-linux.org/wiki/HowTo/CompileCrossTool

TARGET_OPTIMIZATION= #-Os
TARGET_DEBUGGING= #-g
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING)

CC=
LD=
AR=
RANLIB=
HOSTCC:=gcc
BASE_DIR=$(shell pwd)
SOURCE_DIR=$(BASE_DIR)/sources
DL_DIR=$(BASE_DIR)/downloads
FIRMWARE_DIR=$(BASE_DIR)/firmware
BUILD_DIR=$(BASE_DIR)/builds
STAGING_DIR=$(BASE_DIR)/staging
STAGING_PREFIX=$(STAGING_DIR)/opt
TOOL_BUILD_DIR=$(BASE_DIR)/toolchain
TARGET_PATH=$(STAGING_PREFIX)/bin:$(STAGING_DIR)/bin:/bin:/sbin:/usr/bin:/usr/sbin
PACKAGE_DIR=$(BASE_DIR)/packages

#GNU_TARGET_NAME=arm-linux
GNU_TARGET_NAME=armv5b-softfloat-linux
GNU_SHORT_TARGET_NAME=arm-linux
TARGET_CROSS=$(GNU_TARGET_NAME)-
TARGET_CC=$(TARGET_CROSS)gcc
TARGET_LD=$(TARGET_CROSS)ld
TARGET_AR=$(TARGET_CROSS)ar
TARGET_RANLIB=$(TARGET_CROSS)ranlib

STAGING_INCLUDE_DIR=$(STAGING_PREFIX)/include
STAGING_LIB_DIR=$(STAGING_PREFIX)/lib

STAGING_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)
STAGING_LDFLAGS=-L$(STAGING_LIB_DIR)

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
		LD=$(TARGET_CROSS)ld \
		NM=$(TARGET_CROSS)nm \
		CC=$(TARGET_CROSS)gcc \
		GCC=$(TARGET_CROSS)gcc \
		CXX=$(TARGET_CROSS)g++ \
		RANLIB=$(TARGET_CROSS)ranlib

all: directories packages

unslung: directories $(TARGETS)
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
	rsync -avr packages/*.ipk ipkg.nslu2-linux.org:/home/nslu2-linux/public_html/feeds/unslung/unstable/
	rsync -avr packages/ ipkg.nslu2-linux.org:/home/nslu2-linux/public_html/feeds/unslung/unstable/

.PHONY: all clean dirclean distclean directories source unslung packages \
	$(TARGETS) $(TARGETS_SOURCE) $(TARGETS_CLEAN) $(TARGETS_DIRCLEAN) \
	$(PACKAGES) $(PACKAGES_SOURCE) $(TARGETS_CLEAN) $(TARGETS_DIRCLEAN) \
	$(PACKAGES_IPKG)

include make/*.mk

directories: $(DL_DIR) $(BUILD_DIR) $(STAGING_DIR) $(STAGING_PREFIX) \
		$(STAGING_LIB_DIR) $(STAGING_INCLUDE_DIR) $(TOOL_BUILD_DIR) $(PACKAGE_DIR)

$(DL_DIR):
	mkdir $(DL_DIR)

$(BUILD_DIR):
	mkdir $(BUILD_DIR)

$(STAGING_DIR):
	mkdir $(STAGING_DIR)

$(STAGING_PREFIX):
	mkdir $(STAGING_PREFIX)

$(STAGING_LIB_DIR):
	mkdir $(STAGING_LIB_DIR)

$(STAGING_INCLUDE_DIR):
	mkdir $(STAGING_INCLUDE_DIR)

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

distclean:
	rm -rf $(BUILD_DIR) $(STAGING_DIR) $(TOOL_BUILD_DIR) $(PACKAGE_DIR)

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

NATIVE_AND_CROSS_PACKAGES = \
	bash \
	bzip2 \
	ccxstream cpio \
	distcc dnsmasq dropbear \
	gdbm \
	inetutils iptables \
	libid3tag libtool lsof \
	make miau \
	ntpclient \
	portmap puppy \
	rsync \
	strace sudo \
	tcpwrappers \
	termcap \
	vsftpd \
	zlib \

CROSS_ONLY_PACKAGES = \
	atftp \
	bind busybox \
	coreutils cvs \
	dhcp \
	findutils flex freeradius \
	gawk grep \
	ircd-hybrid \
	jove \
	libbt libcurl libdb libevent libjpeg libpcap libpng \
	m4 mc mdadm mt-daapd \
	nano ncurses nfs-server ntp \
	openssl openssh \
	popt procps \
	rdate \
	screen svn \
	tar \
	unfs3 \
	vdr-mediamvp \
	wget \

UNCATEGORISED_PACKAGES = \
	diffutils libtiff less nfs-utils \
	logrotate appweb imagemagick \
	nail stunnel patch \

PACKAGES = \
	$(CROSS_ONLY_PACKAGES) $(NATIVE_AND_CROSS_PACKAGES) $(UNCATEGORISED_PACKAGES)

PACKAGES_TO_BE_TESTED =

PACKAGES_THAT_NEED_TO_BE_FIXED_TO_MATCH_TEMPLATE = \
	   e2fsprogs dump glib gkrellm

PACKAGES_THAT_NEED_TO_BE_FIXED = perl file nethack scponly tcpdump nload nmap bison

PACKAGES_FOR_DEVELOPERS = crosstool-native

NATIVE_ONLY_PACKAGES =

# Common tools which may need overriding
CVS=cvs
SUDO=sudo
WGET=wget --passive-ftp

# Directory location definitions
BASE_DIR=$(shell pwd)
SOURCE_DIR=$(BASE_DIR)/sources
DL_DIR=$(BASE_DIR)/downloads
BUILD_DIR=$(BASE_DIR)/builds
STAGING_DIR=$(BASE_DIR)/staging
STAGING_PREFIX=$(STAGING_DIR)/opt
TOOL_BUILD_DIR=$(BASE_DIR)/toolchain
PACKAGE_DIR=$(BASE_DIR)/packages

TARGET_OPTIMIZATION= #-Os
TARGET_DEBUGGING= #-g
TARGET_CUSTOM_FLAGS= -pipe 
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

HOSTCC:=gcc

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
GNU_TARGET_NAME=armv5b-softfloat-linux
GNU_SHORT_TARGET_NAME=arm-linux

CROSS_CONFIGURATION=gcc-3.3.4-glibc-2.2.5

TARGET_CROSS=$(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/bin/$(GNU_TARGET_NAME)-
TARGET_CXX=$(TARGET_CROSS)g++
TARGET_CC=$(TARGET_CROSS)gcc
TARGET_LD=$(TARGET_CROSS)ld
TARGET_AR=$(TARGET_CROSS)ar
TARGET_AS=$(TARGET_CROSS)as
TARGET_NM=$(TARGET_CROSS)nm
TARGET_RANLIB=$(TARGET_CROSS)ranlib
TARGET_STRIP=$(TARGET_CROSS)strip
TARGET_CONFIGURE_OPTS= \
	AR=$(TARGET_AR) \
	AS=$(TARGET_AS) \
	LD=$(TARGET_LD) \
	NM=$(TARGET_NM) \
	CC=$(TARGET_CC) \
	GCC=$(TARGET_CC) \
	CXX=$(TARGET_CXX) \
	RANLIB=$(TARGET_RANLIB) \
	STRIP=$(TARGET_STRIP)
TARGET_PATH=$(STAGING_PREFIX)/bin:$(STAGING_DIR)/bin:/opt/bin:/opt/sbin:/bin:/sbin:/usr/bin:/usr/sbin

STRIP_COMMAND=$(TARGET_STRIP) --remove-section=.comment --remove-section=.note --strip-unneeded

STAGING_INCLUDE_DIR=$(STAGING_PREFIX)/include
STAGING_LIB_DIR=$(STAGING_PREFIX)/lib

STAGING_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)
STAGING_LDFLAGS=-L$(STAGING_LIB_DIR) -Wl,-rpath,/opt/lib

# Clear these variables to remove assumptions
AR=
AS=
LD=
NM=
CC=
GCC=
CXX=
RANLIB=
STRIP=

all: directories crosstool packages

PACKAGES_CLEAN:=$(patsubst %,%-clean,$(PACKAGES))
PACKAGES_SOURCE:=$(patsubst %,%-source,$(PACKAGES))
PACKAGES_DIRCLEAN:=$(patsubst %,%-dirclean,$(PACKAGES))
PACKAGES_STAGE:=$(patsubst %,%-stage,$(PACKAGES))
PACKAGES_IPKG:=$(patsubst %,%-ipk,$(PACKAGES))

$(PACKAGES) : directories crosstool
$(PACKAGES_STAGE) : directories crosstool
$(PACKAGES_IPKG) : directories crosstool ipkg-utils

$(PACKAGE_DIR)/Packages: $(PACKAGES_IPKG)
	rm -f $(PACKAGE_DIR)/*
	mkdir -p $(PACKAGE_DIR)
	{ \
		cd $(PACKAGE_DIR); \
		cp $(BUILD_DIR)/*.ipk .; \
		$(IPKG_MAKE_INDEX) . > Packages; \
		gzip -c Packages > Packages.gz; \
	}
	@echo "ALL DONE."

packages: $(PACKAGE_DIR)/Packages

upload:
	rsync -avr packages/*.ipk ipkg.nslu2-linux.org:/home/nslu2-linux/public_html/feeds/unslung/unstable/
	rsync -avr packages/ ipkg.nslu2-linux.org:/home/nslu2-linux/public_html/feeds/unslung/unstable/

.PHONY: all clean dirclean distclean directories packages \
	$(PACKAGES) $(PACKAGES_SOURCE) $(PACKAGES_DIRCLEAN) \
	$(PACKAGES_STAGE) $(PACKAGES_IPKG)

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
	find . -name '*~' -print | xargs /bin/rm -f
	find . -name '.*~' -print | xargs /bin/rm -f
	find . -name '.#*' -print | xargs /bin/rm -f

distclean:
	rm -rf $(BUILD_DIR) $(STAGING_DIR) $(PACKAGE_DIR)

toolclean:
	rm -rf $(TOOL_BUILD_DIR)

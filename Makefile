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
	adns atftp \
	bash bzip2 \
	ccxstream coreutils cpio cvs \
	diffutils distcc dnsmasq dropbear \
	elinks expat \
	fetchmail file findutils flex \
	gawk gdbm grep gzip \
	imagemagick inetutils iptables \
	jove \
	less libcurl libdb libevent libid3tag libjpeg \
	libpng libstdc++ libtiff libtool lsof \
	m4 make mc miau mtr \
	nano ncurses ntp ntpclient \
	openssl openssh \
	patch portmap procps puppy \
	rsync \
	screen strace sudo \
	tar tcpwrappers termcap \
	unslung-feeds \
	vdr-mediamvp vsftpd \
	wget-ssl \
	zlib \

CROSS_ONLY_PACKAGES = \
	appweb autoconf automake \
	bind busybox \
	dhcp \
	freeradius \
	gift gift-ares gift-fasttrack gift-gnutella gift-openft \
	glib groff \
	ircd-hybrid \
	libbt libogg libvorbis libpcap logrotate \
	mdadm mt-daapd \
	nail nfs-server nfs-utils \
	popt proftpd \
	rdate \
	stunnel svn \
	unfs3 \
	xinetd

# bison cross-compiles, but can't build flex.  native-compiled bison is fine.
# emacs and xemacs needs to run themselves to dump an image, so they probably will never cross-compile.
# perl's Configure is not cross-compile "friendly"
NATIVE_ONLY_PACKAGES = \
	bison \
	emacs \
	xemacs \
	perl

PACKAGES = \
	$(NATIVE_AND_CROSS_PACKAGES) $(CROSS_ONLY_PACKAGES)

NATIVE_PACKAGES = \
	$(NATIVE_AND_CROSS_PACKAGES) $(NATIVE_ONLY_PACKAGES)

PACKAGES_TO_BE_TESTED = 

PACKAGES_THAT_NEED_TO_BE_FIXED_TO_MATCH_TEMPLATE = \
	   e2fsprogs dump gkrellm

PACKAGES_THAT_NEED_TO_BE_FIXED = nethack scponly tcpdump nload nmap bzflag

PACKAGES_FOR_DEVELOPERS = crosstool-native


all: directories toolchain packages

native:
	$(MAKE) PACKAGES="$(NATIVE_PACKAGES)" all

native-upload:
	mkdir -p native
	rsync -avr nslu2:/src/unslung/packages/ native/
	( cd native ; $(IPKG_MAKE_INDEX) . > Packages; gzip -c Packages > Packages.gz )
	rsync -avr native/*.ipk ipkg.nslu2-linux.org:/home/nslu2-linux/public_html/feeds/unslung/native/
	rsync -avr native/ ipkg.nslu2-linux.org:/home/nslu2-linux/public_html/feeds/unslung/native/

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

TARGET_OPTIMIZATION= #-mtune=xscale -march=armv4 -Wa,-mcpu=xscale
TARGET_DEBUGGING= #-g
TARGET_CUSTOM_FLAGS= -pipe 

HOST_MACHINE:=$(shell uname -m | sed \
	-e 's/i[3-9]86/i386/' \
	)

ifeq ($(HOST_MACHINE),armv5b)
HOSTCC = $(TARGET_CC)
GNU_HOST_NAME = armv5b-softfloat-linux
GNU_TARGET_NAME = armv5b-softfloat-linux
CROSS_CONFIGURATION = gcc-3.3.5-glibc-2.2.5
TARGET_CROSS = /opt/armeb/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = /opt/armeb/$(GNU_TARGET_NAME)/lib
TARGET_LDFLAGS = -L/opt/lib
TARGET_CFLAGS=-I/opt/include $(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain:
else
HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME = armv5b-softfloat-linux
CROSS_CONFIGURATION = gcc-3.3.5-glibc-2.2.5
TARGET_CROSS = $(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = $(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/$(GNU_TARGET_NAME)/lib
TARGET_LDFLAGS = 
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain: crosstool
endif

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

STAGING_CPPFLAGS=$(TARGET_CFLAGS) -I$(STAGING_INCLUDE_DIR)
STAGING_LDFLAGS=$(TARGET_LDFLAGS) -L$(STAGING_LIB_DIR) -Wl,-rpath,/opt/lib

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

PACKAGES_CLEAN:=$(patsubst %,%-clean,$(PACKAGES))
PACKAGES_SOURCE:=$(patsubst %,%-source,$(PACKAGES))
PACKAGES_DIRCLEAN:=$(patsubst %,%-dirclean,$(PACKAGES))
PACKAGES_STAGE:=$(patsubst %,%-stage,$(PACKAGES))
PACKAGES_IPKG:=$(patsubst %,%-ipk,$(PACKAGES))

$(PACKAGES) : directories toolchain
$(PACKAGES_STAGE) : directories toolchain
$(PACKAGES_IPKG) : directories toolchain ipkg-utils

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
ifeq ($(HOST_MACHINE),armv5b)
	rsync -avr packages/*.ipk ipkg.nslu2-linux.org:/home/nslu2-linux/public_html/feeds/unslung/native/
	rsync -avr packages/ ipkg.nslu2-linux.org:/home/nslu2-linux/public_html/feeds/unslung/native/
else
	rsync -avr packages/*.ipk ipkg.nslu2-linux.org:/home/nslu2-linux/public_html/feeds/unslung/cross/
	rsync -avr packages/ ipkg.nslu2-linux.org:/home/nslu2-linux/public_html/feeds/unslung/cross/
endif

.PHONY: all clean dirclean distclean directories packages source toolchain \
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

source: $(PACKAGES_SOURCE)

clean: $(TARGETS_CLEAN) $(PACKAGES_CLEAN)
	find . -name '*~' -print | xargs /bin/rm -f
	find . -name '.*~' -print | xargs /bin/rm -f
	find . -name '.#*' -print | xargs /bin/rm -f

dirclean: $(PACKAGES_DIRCLEAN)

distclean:
	rm -rf $(BUILD_DIR) $(STAGING_DIR) $(PACKAGE_DIR)

toolclean:
	rm -rf $(TOOL_BUILD_DIR)

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
	adns atftp automake \
	bash bind bzip2 \
	ccxstream coreutils cpio ctorrent cups cvs cyrus-sasl \
	dhcp diffutils distcc dnsmasq dropbear \
	ed elinks expat \
	fetchmail file findutils flex \
	gawk gdbm grep groff gzip \
	imagemagick inetutils iptables ircd-hybrid \
	jamvm jikes joe jove \
	less libbt libcurl libdb libevent libiconv libid3tag \
	libjpeg libnsl libpng libstdc++ libtiff libtool libxml2 lsof \
	m4 make man man-pages mc mdadm miau mtr mutt \
	nail nano ncftp ncurses nload nmap ntp ntpclient \
	openssh openssl \
	patch portmap procps puppy \
	rsync \
	screen sed strace stunnel sudo \
	tar tcpwrappers termcap torrent \
	unfs3 unslung-feeds \
	vdr-mediamvp vsftpd \
	wakelan wget-ssl which \
	xinetd \
	zlib \

# Add new packages here - make sure you have tested both native compilation and cross compilation.
# When they have been tested, they will be promoted and uploaded.
NATIVE_AND_CROSS_PACKAGES_READY_FOR_TESTING = \
	gdb \

# appweb ships with x86 binaries which it requires during configure phase
# busybox has PATH_MAX define issue on native
# bzflag actually builds native, but it takes 11 hours
# classpath requires a java compiler
# metalog may compile native - don't have working native build support (bob_tm)
# pkgconfig fails native during configure
CROSS_ONLY_PACKAGES = \
	appweb \
	busybox \
	bzflag \
	classpath \
	gettext \
	metalog \
	pkgconfig \

# Add new cross-only packages here, and state why they don't compile native.
CROSS_ONLY_PACKAGES_READY_FOR_TESTING = \


# autoconf compiles in a path to m4, and also wants to run it at that path.
# bison cross-compiles, but can't build flex.  native-compiled bison is fine.
# emacs and xemacs needs to run themselves to dump an image, so they probably will never cross-compile.
# lynx's makefile runs executables it has built.
# openldap probably will build cross - may just need some configure work
# perl's Configure is not cross-compile "friendly"
# squid probably will build cross - may just need some configure work
# samba probably will build cross - may just need some configure work
NATIVE_ONLY_PACKAGES = \
	autoconf \
	bison \
	emacs \
	xemacs \
	lynx \
	openldap \
	perl \
	squid \
	samba

# Add new native-only packages here, and state why they don't cross compile.
NATIVE_ONLY_PACKAGES_READY_FOR_TESTING = \


UNSORTED_PACKAGES = \
	freeradius \
	gift giftcurs gift-ares gift-fasttrack gift-gnutella gift-openft gift-opennap glib \
	libogg libvorbis libpcap logrotate \
	mt-daapd \
	nfs-server nfs-utils \
	pcre popt \
	rdate \
	svn 

DEVELOPER_PACKAGES = crosstool-native

PACKAGES_THAT_NEED_TO_BE_FIXED = proftpd nethack scponly tcpdump e2fsprogs dump gkrellm	clamav 

CROSS_PACKAGES  = $(NATIVE_AND_CROSS_PACKAGES) $(CROSS_ONLY_PACKAGES) $(UNSORTED_PACKAGES) $(DEVELOPER_PACKAGES)

# We prefer cross-compilation to native compilation ...
# NATIVE_PACKAGES = $(NATIVE_AND_CROSS_PACKAGES) $(NATIVE_ONLY_PACKAGES)
NATIVE_PACKAGES = $(NATIVE_ONLY_PACKAGES)

HOST_MACHINE:=$(shell uname -m | sed \
	-e 's/i[3-9]86/i386/' \
	)

ifeq ($(HOST_MACHINE),armv5b)
PACKAGES = $(NATIVE_PACKAGES)
else
PACKAGES = $(CROSS_PACKAGES)
endif

all: directories toolchain packages

testing:
ifeq ($(HOST_MACHINE),armv5b)
	$(MAKE) PACKAGES="$(NATIVE_AND_CROSS_PACKAGES_READY_FOR_TESTING) $(NATIVE_ONLY_PACKAGES_READY_FOR_TESTING)" all
else
	$(MAKE) PACKAGES="$(NATIVE_AND_CROSS_PACKAGES_READY_FOR_TESTING) $(CROSS_ONLY_PACKAGES_READY_FOR_TESTING)" all
endif

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

ifeq ($(HOST_MACHINE),armv5b)
HOSTCC = $(TARGET_CC)
GNU_HOST_NAME = armv5b-softfloat-linux
GNU_TARGET_NAME = armv5b-softfloat-linux
CROSS_CONFIGURATION = gcc-3.3.5-glibc-2.2.5
TARGET_CROSS = /opt/armeb/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = /opt/armeb/$(GNU_TARGET_NAME)/lib
TARGET_LDFLAGS = -L/opt/lib
TARGET_CUSTOM_FLAGS=
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
TARGET_CUSTOM_FLAGS= -pipe 
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
	rsync -avr --delete $(BUILD_DIR)/*.ipk $(PACKAGE_DIR)/
	{ \
		cd $(PACKAGE_DIR); \
		$(IPKG_MAKE_INDEX) . > Packages; \
		gzip -c Packages > Packages.gz; \
	}
	@echo "ALL DONE."

packages: $(PACKAGE_DIR)/Packages

upload:
ifeq ($(HOST_MACHINE),armv5b)
	ssh builds.nslu2-linux.org mkdir -p /home/unslung/packages/native/
	rsync -avr --delete packages/ builds.nslu2-linux.org:/home/unslung/packages/native/
	ssh builds.nslu2-linux.org "cd /home/unslung/packages/native ; /home/unslung/packages/staging/bin/ipkg-make-index . > Packages; gzip -c Packages > Packages.gz"
	ssh builds.nslu2-linux.org rsync -vrlt /home/unslung/packages/native/*.ipk unslung@ipkg.nslu2-linux.org:/home/groups/n/ns/nslu/htdocs/feeds/unslung/native/
	ssh builds.nslu2-linux.org rsync -vrlt /home/unslung/packages/native/ unslung@ipkg.nslu2-linux.org:/home/groups/n/ns/nslu/htdocs/feeds/unslung/native/
else
	rsync -vrlt packages/*.ipk unslung@ipkg.nslu2-linux.org:/home/groups/n/ns/nslu/htdocs/feeds/unslung/cross/
	rsync -vrlt packages/ unslung@ipkg.nslu2-linux.org:/home/groups/n/ns/nslu/htdocs/feeds/unslung/cross/
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

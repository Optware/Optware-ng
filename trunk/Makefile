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

CROSS_PACKAGES = \
	adns atftp appweb apache apr apr-util atk automake \
	bash bind busybox bzflag bzip2 \
	ccxstream classpath coreutils cpio ctorrent cups cvs cyrus-sasl \
	dhcp diffutils distcc dnsmasq dropbear \
	e2fsprogs ed elinks expat \
	fetchmail ffmpeg file findutils fixesext fontconfig flac flex freetype \
	gawk gconv-modules gdb gdbm gettext ghostscript \
	gift giftcurs gift-ares gift-fasttrack gift-gnutella gift-openft gift-opennap \
	glib grep groff gtk gzip \
	hdparm \
	ice imagemagick inetutils iptables ircd-hybrid \
	jamvm jikes joe jove \
	lame less libbt libcurl libdb libdvdread libevent libgd libiconv libid3tag \
	libjpeg libnsl libogg libpcap libpng libstdc++ libtiff libtool libvorbis libxml2 libxslt \
	logrotate lsof \
	m4 make man man-pages mc mdadm metalog miau mt-daapd mtr mutt \
	nail nano ncftp ncurses nfs-server nfs-utils nload nmap ntp ntpclient \
	openssh openssl \
	pango parted patch pcre php pkgconfig popt portmap procps proftpd puppy \
	rdate recordext renderext rsync \
	screen sed sm strace stunnel sudo svn \
	tar tcpdump tcpwrappers termcap torrent transcode ttf-bitstream-vera \
	unfs3 unslung-feeds \
	vdr-mediamvp vsftpd vte \
	wakelan wget-ssl which \
	x11 xau xauth xaw xchat xcursor xdmcp xdpyinfo xext xextensions xfixes xft xinetd xmu \
	xpm xproto xrender xt xtrans xtst xvid \
	zlib \
	crosstool-native

# Add new packages here - make sure you have tested cross compilation.
# When they have been tested, they will be promoted and uploaded.
CROSS_PACKAGES_READY_FOR_TESTING = \

CROSS_PACKAGES_THAT_NEED_TO_BE_FIXED = \

# autoconf compiles in a path to m4, and also wants to run it at that path.
# bison cross-compiles, but can't build flex.  native-compiled bison is fine.
# cyrus-imapd fails with "impossible constraint in `asm'" when cross-compiled
# emacs and xemacs needs to run themselves to dump an image, so they probably will never cross-compile.
# lynx's makefile runs executables it has built.
# openldap runs its own binaries at compile-time and expects them to have same byte-order as target
# perl's Configure is not cross-compile "friendly"
# perl modules depend on perl
# squid probably will build cross - may just need some configure work
# samba probably will build cross - may just need some configure work
NATIVE_PACKAGES = \
	autoconf \
	bison \
	cyrus-imapd \
	emacs \
	xemacs \
	lynx \
	openldap \
	perl perl-db-file perl-dbi perl-digest-hmac perl-digest-sha1 perl-html-parser perl-html-tagset \
	perl-mime-base64 perl-net-dns perl-net-ident perl-storable perl-time-hires \
	postfix \
	squid \
	samba \
        xmail \

# Add new native-only packages here, and state why they don't cross compile.
NATIVE_PACKAGES_READY_FOR_TESTING = \

# vim won't compile: "vim.h:40: error: parse error before ':' token"
# perl-spamassassin can't be downloaded: 404 not found
PACKAGES_THAT_NEED_TO_BE_FIXED = \
        vim \
	perl-spamassassin \
	nethack scponly dump gkrellm clamav freeradius


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
	$(MAKE) PACKAGES="$(NATIVE_PACKAGES_READY_FOR_TESTING)" all
else
	$(MAKE) PACKAGES="$(CROSS_PACKAGES_READY_FOR_TESTING)" all
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
	ssh nudi.nslu2-linux.org mkdir -p /home/unslung/packages/native/
	rsync -avr --delete packages/ nudi.nslu2-linux.org:/home/unslung/packages/native/
	ssh nudi.nslu2-linux.org "cd /home/unslung/packages/native ; /home/unslung/packages/staging/bin/ipkg-make-index . > Packages; gzip -c Packages > Packages.gz"
	ssh nudi.nslu2-linux.org rsync -vrlt /home/unslung/packages/native/*.ipk unslung@ipkg.nslu2-linux.org:/home/groups/n/ns/nslu/htdocs/feeds/unslung/native/
	ssh nudi.nslu2-linux.org rsync -vrlt /home/unslung/packages/native/ unslung@ipkg.nslu2-linux.org:/home/groups/n/ns/nslu/htdocs/feeds/unslung/native/
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

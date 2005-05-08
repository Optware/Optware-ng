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

# Options are "nslu2", and "wl500g"
UNSLUNG_TARGET=nslu2

CROSS_PACKAGES = \
	abook adduser adns alac-decoder \
	atftp appweb apache apr apr-util atk audiofile automake \
	bash bc bind bitchx busybox byrequest bzflag bzip2 \
	ccxstream classpath cogito coreutils cpio \
	cron ctorrent cups ctags cvs cyrus-sasl \
	dhcp dict diffutils distcc dokuwiki dnsmasq dropbear \
	e2fsprogs eaccelerator ed eggdrop elinks esmtp esound expat \
	fetchmail ffmpeg file findutils fixesext flac flex \
	fontconfig freetype ftpd-topfield \
	gawk gconv-modules getmail gdb gdbm gettext ghostscript \
	gift giftcurs gift-ares gift-fasttrack gift-gnutella gift-openft gift-opennap \
	glib grep groff gtk gzip \
	hdparm hnb \
	ice imagemagick inetutils iptables ircd-hybrid ivorbis-tools \
	jabber jamvm jikes joe jove \
	lame less \
	libbt libcurl libdb libdvb libdvdread libesmtp libevent \
	libgc libgd libid3tag \
	libjpeg libnsl libogg libol libosip2 \
	libpcap libpng libstdc++ libtiff libtool libtopfield libusb \
	libvorbis libvorbisidec libxml2 libxslt logrotate lsof lua lynx lzo \
	m4 make man man-pages mc mdadm mediawiki metalog miau \
	mod-fastcgi mod-python \
	minicom mktemp mt-daapd mtr mutt mysql \
	nail nano ncftp ncurses nfs-server nfs-utils nload nmap ntp ntpclient \
	nylon \
	openssh openssl openvpn \
	pango parted patch pcre \
	php php-apache php-thttpd phpmyadmin \
	pkgconfig popt portmap postgresql \
	procmail procps proftpd puppy python \
	py-sqlite py-bittorrent pt-moin py-mxbase py-mysql py-psycopg \
	quagga \
	rdate readline recordext renderext rsync \
	samba screen sed ser siproxy sm snownews \
	sqlite sqlite2 strace stunnel streamripper sudo svn syslog-ng \
	tar tcl tcpdump tcpwrappers termcap textutils tin torrent transcode \
	ttf-bitstream-vera \
	unfs3 units unslung-feeds \
	vdr-mediamvp vsftpd vte vorbis-tools \
	w3cam wakelan wget-ssl which webalizer \
	x11 xau xauth xaw xchat xcursor xdmcp xdpyinfo xext xextensions xfixes xft xinetd xmu \
	xpm xproto xrender xt xterm xtrans xtst xvid \
	zlib \
	unslung-devel \
	crosstool-native

# Add new packages here - make sure you have tested cross compilation.
# When they have been tested, they will be promoted and uploaded.

CROSS_PACKAGES_READY_FOR_TESTING = \
	py-cherrypy \

# asterisk may just need configure work
# autoconf compiles in a path to m4, and also wants to run it at that path.
# bison cross-compiles, but can't build flex.  native-compiled bison is fine.
# bogofilter's configure wants to run some small executables
# cyrus-imapd fails with "impossible constraint in `asm'" when cross-compiled
# emacs and xemacs needs to run themselves to dump an image, so they probably will never cross-compile.
# openldap runs its own binaries at compile-time and expects them to have same byte-order as target
# perl's Configure is not cross-compile "friendly"
# perl modules depend on perl
# rsnapshot depends on perl
# squid probably will build cross - may just need some configure work
# stow depends on perl
# vim probably just needs configure work
NATIVE_PACKAGES = \
	asterisk \
	autoconf \
	bison \
	bogofilter \
	clamav \
	cyrus-imapd \
	emacs \
	xemacs \
	hugs \
	openldap \
	mzscheme \
	perl perl-db-file perl-dbi perl-digest-hmac perl-digest-sha1 \
	perl-appconfig perl-cgi-application \
	perl-html-parser perl-html-tagset perl-html-template \
	perl-mime-base64 perl-net-dns perl-net-ident \
	perl-spamassassin perl-storable perl-time-hires \
	perl-template-toolkit \
	perl-term-readkey \
	postfix \
	rsnapshot ruby \
	squid \
	stow \
	vim \
	w3m \
        xmail \

# Add new native-only packages here, and state why they don't cross compile.
NATIVE_PACKAGES_READY_FOR_TESTING = \

# libao - has runtime trouble
PACKAGES_THAT_NEED_TO_BE_FIXED = \
	libao \
	nethack scponly dump gkrellm freeradius

PACKAGES_OBSOLETED = libiconv git

WL500G_PACKAGES = \
	adduser adns appweb atftp audiofile autoconf automake \
	bash bc bitchx busybox bzip2 \
	ccxstream chillispot classpath cogito coreutils cpio cron ctags cyrus-sasl \
	diffutils distcc dnsmasq dokuwiki  \
	e2fsprogs eggdrop esmtp expat \
	fetchmail file findutils fixesext flex \
	freeradius freetype ftpd-topfield fontconfig \
	gconv-modules gdb gdbm gift gift-ares gift-fasttrack gift-gnutella gift-openft gift-openap grep gzip \
	hdparm \
	inetutils \
	joe \
	lame less libcurl libdb libevent libesmtp libgd libid3tag libjpeg libmad libogg libol \
	libnsl libosip2 libpng libtool libtopfield libusb libvorbis libxml2 libxslt \
	logrotate lua lynx lzo \
	m4 madplay make man man-pages mc miau microperl minicom mktemp mt-daapd \
	nano ncftp ncurses ntpclient nylon \
	openssl openvpn \
	patch php php-thttpd pkgconfig popt portmap procps proftpd puppy py-moin \
	quagga \
	rdate readline recordext renderext rsync \
	samba siproxd sqlite strace stunnel syslog-ng \
	tar tcl tcpdump tcpwrappers termcap textutils thttpd  \
	unfs3 units \
	vorbis-tools vsftpd \
	w3cam wakelan wget-ssl which \
	xau xdmcp xextensions xinetd xproto xtrans xvid \
	zlib

WL500G_PACKAGES_THAT_NEED_FIXING = \
	bind \
	groff \
	postgresql python \
	syslog-ng \
	torrent ttf-bitstream-vera \
	xmail 

WL500G_PACKAGES_READY_FOR_TESTING =  \
	mod-fastcgi

WL500G_PACKAGES_JUST_REQUIRING_CONTROL_GENERATION = \
	dhcp dropbear \
	ed ffmpeg flac \
	ghostscript \
	iptables ircd-hybrid \
	jove \
	libdvdread \
	vdr-mediamvp

HOST_MACHINE:=$(shell uname -m | sed \
	-e 's/i[3-9]86/i386/' \
	)

ifeq ($(UNSLUNG_TARGET),nslu2)
ifeq ($(HOST_MACHINE),armv5b)
PACKAGES = $(NATIVE_PACKAGES)
else
PACKAGES = $(CROSS_PACKAGES)
endif
TARGET_ARCH=armeb
TARGET_OS=linux
endif

ifeq ($(UNSLUNG_TARGET),wl500g)
PACKAGES = $(WL500G_PACKAGES)
TARGET_ARCH=mipsel
TARGET_OS=linux-uclibc
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
BASE_DIR:=$(shell pwd)
SOURCE_DIR=$(BASE_DIR)/sources
DL_DIR=$(BASE_DIR)/downloads
BUILD_DIR=$(BASE_DIR)/builds
STAGING_DIR=$(BASE_DIR)/staging
STAGING_PREFIX=$(STAGING_DIR)/opt
TOOL_BUILD_DIR=$(BASE_DIR)/toolchain
PACKAGE_DIR=$(BASE_DIR)/packages
export TMPDIR=$(BASE_DIR)/tmp

TARGET_OPTIMIZATION=-O2 #-mtune=xscale -march=armv4 -Wa,-mcpu=xscale
TARGET_DEBUGGING= #-g

ifeq ($(UNSLUNG_TARGET),nslu2)
ifeq ($(HOST_MACHINE),armv5b)
HOSTCC = $(TARGET_CC)
GNU_HOST_NAME = armv5b-softfloat-linux
GNU_TARGET_NAME = armv5b-softfloat-linux
CROSS_CONFIGURATION = gcc-3.3.5-glibc-2.2.5
TARGET_CROSS = /opt/$(TARGET_ARCH)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = /opt/$(TARGET_ARCH)/$(GNU_TARGET_NAME)/lib
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
endif

ifeq ($(UNSLUNG_TARGET),wl500g)
HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME = mipsel-linux
CROSS_CONFIGURATION = hndtools-mipsel-uclibc
TARGET_CROSS = /opt/brcm/$(CROSS_CONFIGURATION)/bin/mipsel-uclibc-
TARGET_LIBDIR = /opt/brcm/$(CROSS_CONFIGURATION)/lib
TARGET_LDFLAGS = 
TARGET_CUSTOM_FLAGS= -pipe 
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain:
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
STAGING_LDFLAGS=$(TARGET_LDFLAGS) -L$(STAGING_LIB_DIR) -Wl,-rpath,/opt/lib -Wl,-rpath-link,$(STAGING_LIB_DIR)

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
ifeq ($(UNSLUNG_TARGET),nslu2)
ifeq ($(HOST_MACHINE),armv5b)
	ssh nudi.nslu2-linux.org mkdir -p /home/unslung/packages/native/
	rsync -avr --delete packages/ nudi.nslu2-linux.org:/home/unslung/packages/native/
	ssh nudi.nslu2-linux.org "cd /home/unslung/packages/native ; /home/unslung/packages/staging/bin/ipkg-make-index . > Packages; gzip -c Packages > Packages.gz"
	ssh nudi.nslu2-linux.org rsync -vrlt /home/unslung/packages/native/*.ipk unslung@ipkg.nslu2-linux.org:/home/groups/n/ns/nslu/htdocs/feeds/unslung/native/
	ssh nudi.nslu2-linux.org rsync -vrlt /home/unslung/packages/native/ unslung@ipkg.nslu2-linux.org:/home/groups/n/ns/nslu/htdocs/feeds/unslung/native/
else
	rsync -vrlt packages/*.ipk unslung@ipkg.nslu2-linux.org:/home/groups/n/ns/nslu/htdocs/feeds/unslung/cross/
	rsync -vrl packages/ unslung@ipkg.nslu2-linux.org:/home/groups/n/ns/nslu/htdocs/feeds/unslung/cross/
endif
else
	rsync -vrlt packages/*.ipk unslung@ipkg.nslu2-linux.org:/home/groups/n/ns/nslu/htdocs/feeds/unslung/wl500g
	rsync -vrl packages/      unslung@ipkg.nslu2-linux.org:/home/groups/n/ns/nslu/htdocs/feeds/unslung/wl500g
endif

.PHONY: all clean dirclean distclean directories packages source toolchain \
	$(PACKAGES) $(PACKAGES_SOURCE) $(PACKAGES_DIRCLEAN) \
	$(PACKAGES_STAGE) $(PACKAGES_IPKG) \
	query-%

query-%:
	@echo $($(*))

include make/*.mk

directories: $(DL_DIR) $(BUILD_DIR) $(STAGING_DIR) $(STAGING_PREFIX) \
	$(STAGING_LIB_DIR) $(STAGING_INCLUDE_DIR) $(TOOL_BUILD_DIR) \
	$(PACKAGE_DIR) $(TMPDIR)

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

$(TMPDIR):
	mkdir $(TMPDIR)

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

# Makefile for Optware packages
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

# Options are "nslu2", "wl500g", "ds101" and "ds101g"
OPTWARE_TARGET ?= nslu2

CROSS_PACKAGES = \
	abook adduser adns alac-decoder appweb \
	atftp apache apr apr-util atk audiofile automake \
	asterisk-sounds \
	bash bc bind bitchx busybox byrequest bzflag bzip2 \
	bluez-libs bluez-utils bluez-hcidump \
	ccxstream cherokee chrpath classpath clips cogito coreutils cpio \
	cron ctorrent cups ctags cvs cyrus-sasl \
	dev-pts dhcp dict diffutils distcc dokuwiki dovecot \
	dnsmasq dropbear \
	e2fsprogs e2tools eaccelerator ed eggdrop elinks esmtp erlang esound expat \
	fetchmail ffmpeg ficy file findutils fixesext flac flex \
	fontconfig freeradius freetds freetype ftpd-topfield \
	gawk gconv-modules getmail gdb gdbm gdchart gettext ghostscript \
	gift giftcurs gift-ares gift-fasttrack gift-gnutella gift-openft gift-opennap \
	git-core glib gnupg gnutls grep groff gtk gzip \
	hdparm hexcurse hnb hpijs \
	ice imagemagick imap inetutils \
	iperf ipkg-web iptables ircd-hybrid ivorbis-tools \
	jabber jamvm jikes joe jove \
	lame ldconfig less \
	libart libbt libcurl libdb libdvb libdvdread libesmtp libevent \
	libgc libgcrypt libgd libghttp libgpg-error libid3tag \
	libjpeg libmad libnsl libogg libol libosip2 \
	libpcap libpng libstdc++ libtasn1 libtiff libtool libtopfield libusb \
	libvorbis libvorbisidec libxml2 libxslt logrotate lsof lua lynx lzo \
	m4 make man man-pages mc mdadm mediawiki metalog miau monotone \
	mod-fastcgi mod-python \
	minicom mktemp mt-daapd mtr mutt mysql \
	nail nano ncftp ncurses neon net-snmp net-tools netio nfs-server nfs-utils \
	nget nload nmap noip ntop ntp ntpclient nylon \
	opencdk openssh openssl openvpn oww \
	pango patch pcre \
	php php-apache php-thttpd phpmyadmin \
	pkgconfig popt portmap postgresql \
	procmail procps proftpd psutils puppy python \
	py-bluez py-cheetah py-cherrypy py-clips \
	py-gdchart2 py-gd py-pil py-mssql \
	py-sqlite py-bittorrent py-moin py-mx-base py-mysql py-psycopg py-xml \
	py-roundup py-serial py-simpy py-soappy \
	quagga  \
	rcs rdate readline recordext renderext rrdtool rsync \
	samba sane-backends screen sdl sed ser siproxd sm snownews \
	sqlite sqsh sqlite2 strace stunnel streamripper sudo svn syslog-ng \
	sysstat \
	tar taged tcl tcpdump tcpwrappers termcap textutils tftp-hda \
	tin torrent transcode tsocks \
	ttf-bitstream-vera \
	ufsd unfs3 units unrar unslung-feeds unzip usbutils \
	vblade vdr-mediamvp vim vsftpd vte vorbis-tools \
	w3cam wakelan webalizer wget-ssl whois which wizd \
	x11 xau xauth xaw xchat xcursor xdmcp xdpyinfo xext xextensions xfixes xft xinetd xmu \
	xpdf xpm xproto xrender xt xterm xtrans xtst xvid \
	zlib \
	unslung-devel \
	crosstool-native

# Add new packages here - make sure you have tested cross compilation.
# When they have been tested, they will be promoted and uploaded.
CROSS_PACKAGES_READY_FOR_TESTING = \

# asterisk may just need configure and HOSTCC work
# autoconf compiles in a path to m4, and also wants to run it at that path.
# bison cross-compiles, but can't build flex.  native-compiled bison is fine.
# bogofilter's configure wants to run some small executables
# cyrus-imapd fails with "impossible constraint in `asm'" when cross-compiled
# emacs and xemacs needs to run themselves to dump an image, so they probably will never cross-compile.
# ocaml does not use gnu configure, cross build may work by some more tweaking, build native first
# openldap runs its own binaries at compile-time and expects them to have same byte-order as target
# perl's Configure is not cross-compile "friendly"
# perl modules depend on perl
# rsnapshot depends on perl
# squid probably will build cross - may just need some configure work
# stow depends on perl
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
	mzscheme \
        ocaml \
	openldap \
	perl perl-db-file perl-dbi perl-digest-hmac perl-digest-sha1 \
	perl-date-manip \
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
	w3m \
        xmail \

# Add new native-only packages here, and state why they don't cross compile.
NATIVE_PACKAGES_READY_FOR_TESTING = \

# dump: is broken in several ways. It is using the host's e2fsprogs
# includes.  It is also misconfigured: --includedir and --libdir as
# arguments to configure affect installation directories, not where
# things get searched for.  I think it would be best to rewrite this
# .mk from scratch, following template.mk.
# 
# bitlbee: "Could not find a suitable SSL library". Assumes
# cross-build host has gnutls installed?
#
# libao - has runtime trouble
# parted - does not work on the slug, even when compiled natively
# qemu fails while building gas
PACKAGES_THAT_NEED_TO_BE_FIXED = \
	dump \
	bitlbee \
	libao \
	madplay nethack scponly gkrellm \
	parted \
	qemu qemu-libc-i386 

# libiconv - has been made obsolete by gconv-modules
# git - ?
# thttpd - has been made obsolete by php-thttpd
# Metalog - has been made obsolete by syslog-ng
PACKAGES_OBSOLETED = libiconv git thttpd metalog

WL500G_PACKAGES = \
	adduser adns antinat atftp audiofile autoconf automake \
	bash bc bind bitchx bluez-libs bluez-utils bluez-hcidump busybox bzip2 \
	ccxstream chillispot classpath clips cogito coreutils cpio cron ctags cups cyrus-sasl \
	dhcp diffutils distcc dnsmasq dokuwiki  dropbear \
	e2fsprogs e2tools ed eggdrop esmtp expat \
	fetchmail ffmpeg file findutils fixesext flac flex \
	freeradius freetype ftpd-topfield fontconfig \
	gconv-modules gdb gdbm gdchart gift gift-ares gift-fasttrack gift-gnutella gift-openft gift-opennap \
	ghostscript grep gzip \
	hdparm hexcurse \
	inetutils ircd-hybrid \
	joe jove \
	lame less libart libcurl libbt libdb libdvdread libevent libesmtp libgcrypt libgd libghttp libgpg-error \
	libgcrypt libid3tag libjpeg libmad libogg libol \
	libnsl libosip2 libpng libtasn1 libtool libtopfield libusb libvorbis libxml2 libxslt \
	logrotate lua lynx lzo \
	m4 madplay make man man-pages mc miau microperl minicom mktemp mt-daapd \
	nano ncftp ncurses netio neon net-snmp net-tools noip ntpclient nylon \
	openssl openvpn oww \
	patch php php-thttpd pkgconfig popt poptop portmap postgresql procps proftpd psutils puppy py-moin python \
	quagga \
	rdate readline recordext renderext rrdtool rsync \
	sane-backends screen sed siproxd sqlite strace stunnel syslog-ng sysstat \
	taged tar tcl tcpdump tcpwrappers termcap textutils tftp-hpa thttpd  torrent tsocks \
	unfs3 units unzip usbutils \
	vblade vdr-mediamvp vorbis-tools vsftpd \
	w3cam wakelan which whois wiley-feeds wizd wpa-supplicant \
	xau xdmcp xextensions xinetd xproto xtrans xvid \
	zlib

WL500G_PACKAGES_THAT_NEED_FIXING = \
	groff \
	iptables \
	ttf-bitstream-vera \
	xmail 

WL500G_PACKAGES_READY_FOR_TESTING =  \
	dovecot unrar appweb git-core cogito

# Packages that work on both the ds101 and ds101g+
DS101_COMMON_PACKAGES = \
	bash whois

# Packages that only work for ds101
DS101_SPECIFIC_PACKAGES = \
	openssh

# Packages that only work for ds101g+
DS101G_SPECIFIC_PACKAGES = \
	bc bzip2 coreutils cpio cron dhcp diffutils dnsmasq dropbear fetchmail \
	findutils grep gnupg hdparm inetutils lame less lynx libdb libnsl \
	libpcap libstdc++ lzo minicom mktemp ncftp ncurses openssl openvpn \
	patch procps rsync screen sed tcpdump tar termcap vim wget-ssl which \
	zlib

DS101G_PACKAGES_THAT_NEED_FIXING = \
	ldconfig mc 

HOST_MACHINE:=$(shell uname -m | sed \
	-e 's/i[3-9]86/i386/' \
	)

ifeq ($(OPTWARE_TARGET),nslu2)
ifeq ($(HOST_MACHINE),armv5b)
PACKAGES = $(NATIVE_PACKAGES)
PACKAGES_READY_FOR_TESTING = $(NATIVE_PACKAGES_READY_FOR_TESTING)
# when native building on unslung, it's important to have a working awk 
# in the path ahead of busybox's broken one.
PATH=/opt/bin:/usr/bin:/bin
else
PACKAGES = $(CROSS_PACKAGES)
PACKAGES_READY_FOR_TESTING = $(CROSS_PACKAGES_READY_FOR_TESTING)
endif
TARGET_ARCH=armeb
TARGET_OS=linux
endif

ifeq ($(OPTWARE_TARGET),wl500g)
PACKAGES = $(WL500G_PACKAGES)
PACKAGES_READY_FOR_TESTING = $(WL500G_PACKAGES_READY_FOR_TESTING)
TARGET_ARCH=mipsel
TARGET_OS=linux-uclibc
endif

ifeq ($(OPTWARE_TARGET),ds101)
DS101_PACKAGES=$(DS101_COMMON_PACKAGES) $(DS101_SPECIFIC_PACKAGES)
PACKAGES = $(DS101_PACKAGES)
PACKAGES_READY_FOR_TESTING = $(DS101_PACKAGES_READY_FOR_TESTING)
TARGET_ARCH=armeb
TARGET_OS=linux
endif

ifeq ($(OPTWARE_TARGET),ds101g)
DS101G_PACKAGES=$(DS101_COMMON_PACKAGES) $(DS101G_SPECIFIC_PACKAGES)
PACKAGES = $(DS101G_PACKAGES)
PACKAGES_READY_FOR_TESTING = $(DS101G_PACKAGES_READY_FOR_TESTING)
TARGET_ARCH=powerpc
TARGET_OS=linux
endif

all: directories toolchain packages

testing:
	$(MAKE) PACKAGES="$(PACKAGES_READY_FOR_TESTING)" all
	$(PERL) -w scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) --objdump-path=$(TARGET_CROSS)objdump --base-dir=$(BASE_DIR) $(patsubst %,$(BUILD_DIR)/%*.ipk,$(PACKAGES_READY_FOR_TESTING))

# Common tools which may need overriding
CVS=cvs
SUDO=sudo
WGET=wget --passive-ftp
PERL=perl

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

ifeq ($(OPTWARE_TARGET),nslu2)
CROSS_CONFIGURATION_GCC_VERSION=3.3.5
CROSS_CONFIGURATION_GLIBC_VERSION=2.2.5
CROSS_CONFIGURATION_GCC=gcc-$(CROSS_CONFIGURATION_GCC_VERSION)
CROSS_CONFIGURATION_GLIBC=glibc-$(CROSS_CONFIGURATION_GLIBC_VERSION)
CROSS_CONFIGURATION = $(CROSS_CONFIGURATION_GCC)-$(CROSS_CONFIGURATION_GLIBC)
ifeq ($(HOST_MACHINE),armv5b)
HOSTCC = $(TARGET_CC)
GNU_HOST_NAME = armv5b-softfloat-linux
GNU_TARGET_NAME = armv5b-softfloat-linux
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
TARGET_CROSS = $(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = $(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/$(GNU_TARGET_NAME)/lib
TARGET_LDFLAGS = 
TARGET_CUSTOM_FLAGS= -pipe 
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain: crosstool
endif
endif

ifeq ($(OPTWARE_TARGET),wl500g)
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

ifeq ($(OPTWARE_TARGET),ds101)
CROSS_CONFIGURATION_GCC_VERSION=3.3.5
CROSS_CONFIGURATION_GLIBC_VERSION=2.2.5
CROSS_CONFIGURATION_GCC=gcc-$(CROSS_CONFIGURATION_GCC_VERSION)
CROSS_CONFIGURATION_GLIBC=glibc-$(CROSS_CONFIGURATION_GLIBC_VERSION)
CROSS_CONFIGURATION = $(CROSS_CONFIGURATION_GCC)-$(CROSS_CONFIGURATION_GLIBC)
HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME = armv5b-softfloat-linux
TARGET_CROSS = $(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = $(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/$(GNU_TARGET_NAME)/lib
TARGET_LDFLAGS =
TARGET_CUSTOM_FLAGS= -pipe
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain: crosstool
endif

ifeq ($(OPTWARE_TARGET),ds101g)
CROSS_CONFIGURATION_GCC_VERSION=3.3.4
CROSS_CONFIGURATION_GLIBC_VERSION=2.3.3
CROSS_CONFIGURATION_GCC=gcc-$(CROSS_CONFIGURATION_GCC_VERSION)
CROSS_CONFIGURATION_GLIBC=glibc-$(CROSS_CONFIGURATION_GLIBC_VERSION)
CROSS_CONFIGURATION = $(CROSS_CONFIGURATION_GCC)-$(CROSS_CONFIGURATION_GLIBC)
HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME = powerpc-603e-linux
TARGET_CROSS = $(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = $(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/$(GNU_TARGET_NAME)/lib
TARGET_LDFLAGS =
TARGET_CUSTOM_FLAGS= -pipe
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain: crosstool
endif


TARGET_CXX=$(TARGET_CROSS)g++
TARGET_CC=$(TARGET_CROSS)gcc
TARGET_CPP="$(TARGET_CC) -E"
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
	CPP=$(TARGET_CPP) \
	GCC=$(TARGET_CC) \
	CXX=$(TARGET_CXX) \
	RANLIB=$(TARGET_RANLIB) \
	STRIP=$(TARGET_STRIP)
TARGET_PATH=$(STAGING_PREFIX)/bin:$(STAGING_DIR)/bin:/opt/bin:/opt/sbin:/bin:/sbin:/usr/bin:/usr/sbin

STRIP_COMMAND=$(TARGET_STRIP) --remove-section=.comment --remove-section=.note --strip-unneeded

PATCH_LIBTOOL=sed -i \
	-e 's|^sys_lib_search_path_spec=.*|sys_lib_search_path_spec="$(TARGET_LIBDIR) $(STAGING_LIB_DIR)"|' \
	-e 's|^sys_lib_dlsearch_path_spec=.*|sys_lib_dlsearch_path_spec=""|'

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
LD_LIBRARY_PATH=

PACKAGES_CLEAN:=$(patsubst %,%-clean,$(PACKAGES))
PACKAGES_SOURCE:=$(patsubst %,%-source,$(PACKAGES))
PACKAGES_DIRCLEAN:=$(patsubst %,%-dirclean,$(PACKAGES))
PACKAGES_STAGE:=$(patsubst %,%-stage,$(PACKAGES))
PACKAGES_IPKG:=$(patsubst %,%-ipk,$(PACKAGES))

$(PACKAGES) : directories toolchain
$(PACKAGES_STAGE) %-stage : directories toolchain
$(PACKAGES_IPKG) %-ipk : directories toolchain ipkg-utils

.PHONY: index
index: $(PACKAGE_DIR)/Packages

$(PACKAGE_DIR)/Packages: $(BUILD_DIR)/*.ipk
	rsync -avr --delete $(BUILD_DIR)/*.ipk $(PACKAGE_DIR)/
	{ \
		cd $(PACKAGE_DIR); \
		$(IPKG_MAKE_INDEX) . > Packages; \
		gzip -c Packages > Packages.gz; \
	}
	@echo "ALL DONE."

packages: $(PACKAGES_IPKG)
	$(MAKE) index

upload:
ifeq ($(OPTWARE_TARGET),nslu2)
ifeq ($(HOST_MACHINE),armv5b)
	ssh nudi.nslu2-linux.org mkdir -p /home/unslung/packages/native/
	rsync -avr --delete packages/ nudi.nslu2-linux.org:/home/unslung/packages/native/
	ssh nudi.nslu2-linux.org "cd /home/unslung/packages/native ; /home/unslung/packages/staging/bin/ipkg-make-index . > Packages; gzip -c Packages > Packages.gz"
	ssh nudi.nslu2-linux.org rsync -vrlt --progress /home/unslung/packages/native/*.ipk unslung@ipkg.nslu2-linux.org:/home/groups/n/ns/nslu/htdocs/feeds/unslung/native/
	ssh nudi.nslu2-linux.org rsync -vrlt --progress /home/unslung/packages/native/ unslung@ipkg.nslu2-linux.org:/home/groups/n/ns/nslu/htdocs/feeds/unslung/native/
endif
endif

.PHONY: all clean dirclean distclean directories packages source toolchain \
	autoclean \
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

check-packages:
	@$(PERL) -w scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) --objdump-path=$(TARGET_CROSS)objdump --base-dir=$(BASE_DIR) $(filter-out $(BUILD_DIR)/crosstool-native-%,$(wildcard $(BUILD_DIR)/*.ipk))

autoclean:
	$(PERL) -w scripts/optware-autoclean.pl -v -C $(BASE_DIR)

clean: $(TARGETS_CLEAN) $(PACKAGES_CLEAN)
	find . -name '*~' -print | xargs /bin/rm -f
	find . -name '.*~' -print | xargs /bin/rm -f
	find . -name '.#*' -print | xargs /bin/rm -f

dirclean: $(PACKAGES_DIRCLEAN)

distclean:
	rm -rf $(BUILD_DIR) $(STAGING_DIR) $(PACKAGE_DIR) nslu2 wl500g

toolclean:
	rm -rf $(TOOL_BUILD_DIR)

make/%.mk:
	PKG_UP=$$(echo $* | tr [a-z\-] [A-Z_]);			\
	sed -e "s/<foo>/$*/g" -e "s/<FOO>/$${PKG_UP}/g"		\
		 -e '6,11d' make/template.mk > $@

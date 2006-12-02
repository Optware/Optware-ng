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

# Options are "nslu2", "wl500g", "ddwrt", "oleg", "ds101", "ds101j", 
#  "ds101g", "mss", "nas100d", "fsg3", "ts72xx" and "ts101"
OPTWARE_TARGET ?= nslu2

HOST_MACHINE:=$(shell uname -m | sed -e 's/i[3-9]86/i386/' )

# Add new packages here - make sure you have tested cross compilation.
# When they have been tested, they will be promoted and uploaded.
#
CROSS_PACKAGES_READY_FOR_TESTING = \


# Add new native-only packages here
# When they have been tested, they will be promoted and uploaded.
#
NATIVE_PACKAGES_READY_FOR_TESTING = \

# dump: is broken in several ways. It is using the host's e2fsprogs
# includes.  It is also misconfigured: --includedir and --libdir as
# arguments to configure affect installation directories, not where
# things get searched for.  I think it would be best to rewrite this
# .mk from scratch, following template.mk.
# 
# lftp - segfault even with native build, upstream bug?
# libao - has runtime trouble
# parted - does not work on the slug, even when compiled natively
# lumikki - does not install to /opt
# doxygen - host binary, not stripped
# perl-dbd-mysql: Can't exec "mysql_config": No such file or directory at Makefile.PL line 76.
# bpalogin - for some reason it can't find 'sed' on the build machine
PACKAGES_THAT_NEED_TO_BE_FIXED = dump libao nethack scponly gkrellm parted lumikki mini_httpd \
	doxygen \
	lftp \
	libextractor \
	perl-dbd-mysql \
	asterisk-sounds \
	bpalogin

PERL_PACKAGES = \
	perl \
	perl-algorithm-diff \
	perl-appconfig \
	perl-berkeleydb \
	perl-archive-tar perl-archive-zip \
	perl-business-isbn-data perl-business-isbn \
	perl-cgi-application \
	perl-class-accessor perl-class-data-inheritable perl-class-dbi perl-class-trigger \
	perl-clone \
	perl-compress-zlib \
	perl-convert-binhex perl-convert-tnef perl-convert-uulib \
	perl-date-manip \
	perl-db-file perl-dbd-sqlite perl-dbi perl-dbix-contextualfetch \
	perl-digest-hmac perl-digest-perl-md5 perl-digest-sha1 perl-digest-sha \
	perl-extutils-cbuilder perl-extutils-parsexs \
	perl-gd perl-gd-barcode \
	perl-html-parser perl-html-tagset perl-html-template \
	perl-ima-dbi \
	perl-io-multiplex perl-io-socket-ssl perl-io-string perl-io-stringy perl-io-zlib \
	perl-libwww \
	perl-mail-spf-query perl-mailtools \
	perl-mime-tools \
	perl-module-build perl-module-signature \
	perl-net-cidr-lite perl-net-dns perl-net-ident perl-net-server perl-net-ssleay \
	perl-par-dist \
	perl-pod-readme \
	perl-storable \
	perl-sys-hostname-long \
	perl-template-toolkit \
	perl-term-readkey \
	perl-text-diff \
	perl-time-hires \
	perl-unicode-map perl-unicode-string \
	perl-universal-moniker \
	perl-unix-syslog \
	perl-uri \
	perl-version \
	perl-wakeonlan \
	perl-xml-parser \
	amavisd-new \
	spamassassin \
	stow \

PYTHON_PACKAGES = \
	getmail ipython mailman mod-python pyrex \
	py-4suite py-amara py-apsw \
	py-bazaar-ng py-bittorrent py-bluez py-celementtree py-cheetah py-cherrypy py-cherrytemplate \
	py-clips py-codeville py-configobj py-constraint py-crypto py-curl py-django py-docutils \
	py-elementtree py-flup py-formencode py-gdchart2 py-gd py-genshi py-kid py-lxml py-nose \
	py-mercurial py-moin py-mssql py-mx-base py-mysql py-myghty \
	py-paste py-pastedeploy py-pastescript py-pastewebkit py-pexpect py-pil py-ply py-protocols \
	py-pgsql py-psycopg py-psycopg2 py-pygresql py-pyro py-quixote \
	py-rdiff-backup py-reportlab py-routes py-roundup py-ruledispatch \
	py-scgi py-selector py-serial py-setuptools py-simplejson py-simpy py-soappy \
	py-sqlalchemy py-sqlite py-sqlobject \
	py-tailor py-tgfastdata py-turbocheetah py-turbogears py-turbojson py-turbokid \
	py-urwid py-usb py-wsgiref py-yaml py-xml py-zope-interface \
	py-twisted py-axiom py-epsilon py-mantissa py-nevow \

ERLANG_PACKAGES = \
	erlang erl-escript erl-yaws \

COMMON_CROSS_PACKAGES = \
	abook adduser adns alac-decoder amule antinat appweb \
	apache apr apr-util arc asterisk \
	atftp atk audiofile autoconf automake \
	bash bc bind bip bison bitchx bitlbee bogofilter \
	bsdmainutils busybox byrequest bzflag bzip2 \
	bluez-libs bluez-utils bluez-hcidump \
	cabextract catdoc ccxstream chillispot coreutils cpio cron cdargs \
	cherokee chrpath classpath clamav clearsilver \
	clips cogito connect cscope ctags ctcs ctorrent cups cvs \
	cyrus-imapd cyrus-sasl \
	dash dcraw denyhosts dev-pts dict digitemp distcc dhcp diffutils dnsmasq dokuwiki \
	dovecot dropbear dspam dtach \
	e2fsprogs e2tools eaccelerator ed ecl elinks enhanced-ctorrent esmtp esniper \
	$(ERLANG_PACKAGES) \
	esound eggdrop expat extract-xiso \
	fcgi fetchmail file findutils fish flex flip ftpd-topfield ffmpeg ficy fixesext flac \
	fontconfig freeradius freetds freetype freeze ftpcopy \
	gambit-c gawk gconv-modules gettext gdchart ghostscript gdb gdbm grep groff gzip \
	gift giftcurs gift-ares gift-fasttrack gift-gnutella gift-openft gift-opennap \
	git-core glib gnupg gnuplot gnutls gtk \
	gphoto2 libgphoto2 \
	hdparm hexcurse heyu hnb hpijs \
	ice id3lib indent iozone imagemagick imap inetutils iperf ipkg-web iptables \
	ircd-hybrid irssi ivorbis-tools \
	jabberd jamvm jikes jove joe \
	knock \
	lame ldconfig less lha \
	libart libbt libcurl libdb libdvb libdvdread libesmtp libevent libexif libftdi \
	libgc libgcrypt libgd libghttp libgmp libgpg-error libid3tag libidn \
	libjpeg liblcms libmad libmemcache libnsl \
	libol libogg libosip2 libpcap libpng libpth \
	librsync libsigc++ libstdc++ libtasn1 libtiff libtool libtorrent \
	libupnp libusb libvorbis libvorbisidec libxml2 libxslt lighttpd logrotate lrzsz lsof lua lynx lzo \
	m4 make mc miau minicom mktemp modutils monit motion mt-daapd mysql \
	madplay man man-pages mdadm mediawiki memcached metalog microperl mod-fastcgi \
	monotone mp3blaster mpack mpage mrtg mtools mtr multitail mutt \
	nagios-plugins nail nano nbench-byte neon net-snmp ncftp ncurses ncursesw noip \
	netcat net-tools netio nfs-server nfs-utils \
	nget nmap nload nrpe ntfsprogs ntop ntp ntpclient nvi nylon nzbget \
	opencdk openldap openssh openssl openvpn optware-devel oww \
	palantir pango patch pcre pen php php-apache php-fcgi php-thttpd phpmyadmin pkgconfig \
	popt poptop portmap postgresql postfix pound privoxy procmail procps proftpd psutils puppy pwgen \
	python python24 python25 $(PYTHON_PACKAGES) \
	qemu qemu-libc-i386 quagga quickie quilt \
	rc rcs rdate readline recode recordext renderext rlfe rrdtool \
	rsync rtorrent ruby rubygems \
	sablevm samba sane-backends scons sdl sendmail ser setserial \
	setpwc simh siproxd sm snownews \
	screen sdparm sed smartmontools socat sqlite sqlite2 \
	sqsh squeak squid strace stunnel streamripper sudo swi-prolog svn \
	syslog-ng sysstat \
	taged tcl tcpwrappers tethereal tftp-hpa \
	tar tcpdump tcsh termcap textutils thttpd \
	tin tinyscheme tnef tor torrent transcode transmission tsocks \
	ttf-bitstream-vera \
	ufsd unarj unfs3 units unrar \
	unzip usbutils ushare \
	vblade vdr-mediamvp vim vorbis-tools vsftpd vte \
	w3cam w3m wakelan webalizer wget wget-ssl \
	which whois wizd wpa-supplicant wput wxbase \
	x11 xau xauth xaw xchat xcursor xdmcp xdpyinfo xext xextensions xfixes xft xinetd \
	xmail xmu xpdf xpm xproto xrender xt xterm xtrans xtst xvid \
	zip zlib zoo zsh \

# cdrtools makes no provision in the build for cross-compilation.  It
#   *always* uses shell calls to uname to determine the target arch.
# emacs and xemacs needs to run themselves to dump an image, so they probably will never cross-compile.
# nginx does not use gnu configure, cross build may work by alot more tweaking, build native first
# ocaml does not use gnu configure, cross build may work by some more tweaking, build native first
# rsnapshot depends on perl
COMMON_NATIVE_PACKAGES = \
	cdrtools \
	emacs \
	xemacs \
	hugs \
	mzscheme \
        nginx \
        ocaml \
	rsnapshot \
	unison \

# libiconv - has been made obsolete by gconv-modules
# git - has been made obsolete by git-core
# Metalog - has been made obsolete by syslog-ng
PACKAGES_OBSOLETED = libiconv git metalog perl-spamassassin perl-mime-base64 jabber \

# Packages that *only* work for nslu2 - do not just put new packages here.
NSLU2_SPECIFIC_PACKAGES = upslug2 unslung-feeds unslung-devel crosstool-native \

# Packages that do not work for nslu2.
NSLU2_BROKEN_PACKAGES = \

# Packages that *only* work for wl500g - do not just put new packages here.
WL500G_SPECIFIC_PACKAGES = wiley-feeds libuclibc++ 

# Packages that do not work for wl500g.
WL500G_BROKEN_PACKAGES = \
	 amule asterisk atk bitlbee bsdmainutils bzflag dcraw dict dnsmasq \
	 ecl elinks \
	$(ERLANG_PACKAGES) \
	 fcgi ficy fish freetds gambit-c gawk \
	 giftcurs git-core glib gnupg gphoto2 libgphoto2 gtk hnb ice \
	 id3lib iperf iptables irssi jabberd jamvm jikes \
	 ldconfig lftp libdvb libftdi liblcms libtorrent lsof \
	 mc mdadm mod-fastcgi mod-python monotone mtr mutt \
	 ncursesw nfs-server nfs-utils nget ntfsprogs ntp nvi \
	 nylon openldap pango postfix py-mssql \
	 qemu qemu-libc-i386 quickie rtorrent \
	 sablevm sdl ser sm snownews sqsh swi-prolog \
	 tcsh tethereal transcode unrar vte w3m wget wget-ssl wxbase x11 \
	 xauth xaw xchat xcursor xdpyinfo xext xfixes \
	 xft xmu xpm xrender xt xterm xtst zsh \

# Packages that do not work for uclibc
UCLIBC_BROKEN_PACKAGES = \
	 amule bitlbee bsdmainutils bzflag elinks \
	$(ERLANG_PACKAGES) \
	 fcgi ficy fish gambit-c \
	 gphoto2 libgphoto2 \
	 gtk ice id3lib iperf iptables jabberd \
	 jamvm ldconfig libdvb libtorrent monotone \
	 mtr net-tools nfs-server nfs-utils nget \
	 pango procps \
	 qemu qemu-libc-i386 quickie rtorrent sdl ser sm \
	 snownews transcode vte wxbase xauth xaw xchat xcursor xfixes xft \
	 xmu xrender xt xterm

# Packages that *only* work for uclibc - do not just put new packages here.
UCLIBC_SPECIFIC_PACKAGES = $(WL500G_SPECIFIC_PACKAGES) buildroot uclibc ipkg

# Packages that *only* work for mss - do not just put new packages here.
MSS_SPECIFIC_PACKAGES = 

# Packages that do not work for mss.
MSS_BROKEN_PACKAGES = \
	amule apache apr-util asterisk \
	bitlbee \
	clamav \
	elinks \
	$(ERLANG_PACKAGES) \
	gambit-c gawk \
	jamvm \
	ldconfig lsof \
	mod-fastcgi mod-python monotone \
	ntp \
	php-apache py-lxml \
	qemu qemu-libc-i386 quickie \
	sablevm svn \
	transcode \
	tethereal \
	wxbase \

# Packages that *only* work for ds101 - do not just put new packages here.
DS101_SPECIFIC_PACKAGES = ds101-bootstrap

# Packages that do not work for ds101.
# gnuplot - matrix.c:337: In function `lu_decomp': internal compiler error: Segmentation fault
# tnef - malloc.c:30: error: conflicting types for 'malloc'
DS101_BROKEN_PACKAGES = \
	adns amule apache appweb apr-util \
	atftp bash bitchx bpalogin bzflag \
	ctcs ctorrent dspam eaccelerator \
	enhanced-ctorrent freeradius gnuplot hexcurse \
	imagemagick \
	ldconfig lftp libstdc++ lighttpd \
	mc mod-fastcgi mod-python monotone motion mysql \
	net-tools nmap nzbget \
	php php-apache \
	py-mysql \
	qemu qemu-libc-i386 \
	svn \
	tnef tcpwrappers tethereal textutils \
	transcode unrar

# Packages that *only* work for ds101j - do not just put new packages here.
DS101J_SPECIFIC_PACKAGES = bip

# Packages that do not work for ds101j.
DS101J_BROKEN_PACKAGES = \
	apache apr-util \
	ctcs \
	cyrus-sasl \
	enhanced-ctorrent \
	glib \
	imagemagick irssi \
	mod-fastcgi mod-python monotone \
	php-apache \
	qemu qemu-libc-i386 \
	svn \
	atk bitlbee ctrlproxy giftcurs gkrellm irssi pango \

# Packages that *only* work for ds101g+ - do not just put new packages here.
DS101G_SPECIFIC_PACKAGES = \
	ipkg \
	ds101g-kernel-modules \
	ds101-bootstrap \
	py-ctypes \

# Packages that do not work for ds101g+.
DS101G_BROKEN_PACKAGES = \
	$(COMMON_NATIVE_PACKAGES) \
	bitlbee \
	eaccelerator \
	freeradius \
	ldconfig \
	mod-python ntop ntp \
	qemu qemu-libc-i386 \
	ser \

# Packages that *only* work for nas100d - do not just put new packages here.
NAS100D_SPECIFIC_PACKAGES = ipkg

# Packages that do not work for nas100d.
NAS100D_BROKEN_PACKAGES = 

# Packages that *only* work for fsg3 - do not just put new packages here.
FSG3_SPECIFIC_PACKAGES = \
	fsg3-kernel-modules \
	fsg3-bootstrap \
	crosstool-native \
	optware-devel

# Packages that do not work for fsg3.
FSG3_BROKEN_PACKAGES = \
	$(COMMON_NATIVE_PACKAGES) \
	qemu qemu-libc-i386 \
	transcode

# Packages that *only* work for ts72xx - do not just put new packages here.
TS72XX_SPECIFIC_PACKAGES = 

# Packages that do not work for ts72xx.
TS72XX_BROKEN_PACKAGES = \
	appweb asterisk asterisk-sounds \
	bitlbee classpath clearsilver dict dspam \
	eaccelerator ecl \
	$(ERLANG_PACKAGES) \
	freeradius \
	ldconfig lighttpd \
	motion mysql nfs-server nrpe \
	php php-apache py-mysql py-soappy \
	qemu qemu-libc-i386 quagga rtorrent \
	sablevm tethereal transcode w3m xvid \

ifeq ($(OPTWARE_TARGET),nslu2)
ifeq ($(HOST_MACHINE),armv5b)
PACKAGES = $(COMMON_NATIVE_PACKAGES)
PACKAGES_READY_FOR_TESTING = $(NATIVE_PACKAGES_READY_FOR_TESTING)
# when native building on unslung, it's important to have a working awk 
# in the path ahead of busybox's broken one.
PATH=/opt/bin:/usr/bin:/bin
else
PACKAGES = $(filter-out $(NSLU2_NATIVE_PACKAGES) $(NSLU2_BROKEN_PACKAGES), $(COMMON_CROSS_PACKAGES) $(PERL_PACKAGES) $(NSLU2_SPECIFIC_PACKAGES))
PACKAGES_READY_FOR_TESTING = $(CROSS_PACKAGES_READY_FOR_TESTING)
endif
TARGET_ARCH=armeb
TARGET_OS=linux
endif

ifeq ($(OPTWARE_TARGET),wl500g)
PACKAGES = $(filter-out $(WL500G_BROKEN_PACKAGES), $(COMMON_CROSS_PACKAGES) $(WL500G_SPECIFIC_PACKAGES))
PACKAGES_READY_FOR_TESTING = $(CROSS_PACKAGES_READY_FOR_TESTING)
TARGET_ARCH=mipsel
TARGET_OS=linux-uclibc
endif

ifeq ($(OPTWARE_TARGET),mss)
PACKAGES = $(filter-out $(MSS_BROKEN_PACKAGES), $(COMMON_CROSS_PACKAGES) $(MSS_SPECIFIC_PACKAGES))
PACKAGES_READY_FOR_TESTING = $(CROSS_PACKAGES_READY_FOR_TESTING)
TARGET_ARCH=mipsel
TARGET_OS=linux
endif

ifeq ($(OPTWARE_TARGET),ts101)
PACKAGES = $(filter-out $(TS101_BROKEN_PACKAGES), $(COMMON_CROSS_PACKAGES) $(TS101_SPECIFIC_PACKAGES))
PACKAGES_READY_FOR_TESTING = $(CROSS_PACKAGES_READY_FOR_TESTING)
TARGET_ARCH=powerpc
TARGET_OS=linux-uclibc
endif

ifeq ($(OPTWARE_TARGET),ds101)
PACKAGES = $(filter-out $(DS101_BROKEN_PACKAGES), $(COMMON_CROSS_PACKAGES) $(DS101_SPECIFIC_PACKAGES))
PACKAGES_READY_FOR_TESTING = $(CROSS_PACKAGES_READY_FOR_TESTING)
TARGET_ARCH=armeb
TARGET_OS=linux
endif

ifeq ($(OPTWARE_TARGET),ds101j)
PACKAGES = $(filter-out $(DS101J_BROKEN_PACKAGES), $(COMMON_CROSS_PACKAGES) $(DS101J_SPECIFIC_PACKAGES))
PACKAGES_READY_FOR_TESTING = $(CROSS_PACKAGES_READY_FOR_TESTING)
TARGET_ARCH=armeb
TARGET_OS=linux
endif

ifeq ($(OPTWARE_TARGET),ds101g)
ifeq ($(HOST_MACHINE),ppc)
PACKAGES = $(filter-out $(DS101G_BROKEN_PACKAGES), $(COMMON_NATIVE_PACKAGES))
PACKAGES_READY_FOR_TESTING = $(NATIVE_PACKAGES_READY_FOR_TESTING)
else
PACKAGES = $(filter-out $(DS101G_BROKEN_PACKAGES), $(COMMON_CROSS_PACKAGES) $(PERL_PACKAGES) $(DS101G_SPECIFIC_PACKAGES))
PACKAGES_READY_FOR_TESTING = $(CROSS_PACKAGES_READY_FOR_TESTING)
endif
TARGET_ARCH=powerpc
TARGET_OS=linux
endif

ifeq ($(OPTWARE_TARGET),nas100d)
PACKAGES = $(filter-out $(NAS100D_BROKEN_PACKAGES), $(COMMON_CROSS_PACKAGES) $(NAS100D_SPECIFIC_PACKAGES))
PACKAGES_READY_FOR_TESTING = $(CROSS_PACKAGES_READY_FOR_TESTING)
TARGET_ARCH=armeb
TARGET_OS=linux
endif

ifeq ($(OPTWARE_TARGET),fsg3)
ifeq ($(HOST_MACHINE),armv5b)
PACKAGES = $(filter-out $(FSG3_BROKEN_PACKAGES), $(COMMON_NATIVE_PACKAGES))
PACKAGES_READY_FOR_TESTING = $(NATIVE_PACKAGES_READY_FOR_TESTING)
else
PACKAGES = $(filter-out $(FSG3_BROKEN_PACKAGES), $(COMMON_CROSS_PACKAGES) $(PERL_PACKAGES) $(FSG3_SPECIFIC_PACKAGES))
PACKAGES_READY_FOR_TESTING = $(CROSS_PACKAGES_READY_FOR_TESTING)
endif
TARGET_ARCH=armeb
TARGET_OS=linux
endif

ifeq ($(OPTWARE_TARGET),ts72xx)
PACKAGES = $(filter-out $(TS72XX_BROKEN_PACKAGES), $(COMMON_CROSS_PACKAGES) $(TS72XX_SPECIFIC_PACKAGES))
PACKAGES_READY_FOR_TESTING = $(CROSS_PACKAGES_READY_FOR_TESTING)
TARGET_ARCH=arm
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

# The hostname or IP number of our local dl.sf.net mirror
SOURCEFORGE_MIRROR=easynews.dl.sf.net

# Directory location definitions
BASE_DIR:=$(shell pwd)
SOURCE_DIR=$(BASE_DIR)/sources
DL_DIR=$(BASE_DIR)/downloads

BUILD_DIR=$(BASE_DIR)/builds
STAGING_DIR=$(BASE_DIR)/staging
STAGING_PREFIX=$(STAGING_DIR)/opt

TOOL_BUILD_DIR=$(BASE_DIR)/toolchain
PACKAGE_DIR=$(BASE_DIR)/packages

HOST_BUILD_DIR=$(BASE_DIR)/host/builds
HOST_STAGING_DIR=$(BASE_DIR)/host/staging
HOST_STAGING_PREFIX=$(HOST_STAGING_DIR)/opt

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
LIBC_STYLE=uclibc
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

ifeq ($(OPTWARE_TARGET), oleg)
LIBC_STYLE=uclibc
TARGET_ARCH=mipsel
BUILDROOT_CUSTOM_HEADERS = $(HEADERS_OLEG)
endif

ifeq ($(OPTWARE_TARGET), ddwrt)
LIBC_STYLE=uclibc
TARGET_ARCH=mipsel
BUILDROOT_CUSTOM_HEADERS = $(HEADERS_DDWRT)
endif

ifeq ($(OPTWARE_TARGET), ts101)
LIBC_STYLE=uclibc
TARGET_ARCH=powerpc-603e
BUILDROOT_CUSTOM_HEADERS = $(HEADERS_TS101)
endif

ifeq ($(LIBC_STYLE), uclibc)
ifneq ($(OPTWARE_TARGET), wl500g)
PACKAGES = $(filter-out $(UCLIBC_BROKEN_PACKAGES), $(COMMON_CROSS_PACKAGES) $(UCLIBC_SPECIFIC_PACKAGES))
PACKAGES_READY_FOR_TESTING = $(CROSS_PACKAGES_READY_FOR_TESTING)
TARGET_OS=linux-uclibc
HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME=$(TARGET_ARCH)-linux
CROSS_CONFIGURATION_GCC_VERSION=3.4.6
ifeq ($(OPTWARE_TARGET), ts101)
CROSS_CONFIGURATION_UCLIBC_VERSION=0.9.27
else
CROSS_CONFIGURATION_UCLIBC_VERSION=0.9.28
endif
BUILDROOT_GCC=$(CROSS_CONFIGURATION_GCC_VERSION)
UCLIBC_VERSION=$(CROSS_CONFIGURATION_UCLIBC_VERSION)
CROSS_CONFIGURATION_GCC=gcc-$(CROSS_CONFIGURATION_GCC_VERSION)
CROSS_CONFIGURATION_UCLIBC=uclibc-$(CROSS_CONFIGURATION_UCLIBC_VERSION)
CROSS_CONFIGURATION=$(CROSS_CONFIGURATION_GCC)-$(CROSS_CONFIGURATION_UCLIBC)
TARGET_CROSS = $(TOOL_BUILD_DIR)/$(TARGET_ARCH)-$(TARGET_OS)/$(CROSS_CONFIGURATION)/bin/$(TARGET_ARCH)-$(TARGET_OS)-
TARGET_LIBDIR = $(TOOL_BUILD_DIR)/$(TARGET_ARCH)-$(TARGET_OS)/$(CROSS_CONFIGURATION)/lib
TARGET_LDFLAGS = 
TARGET_CUSTOM_FLAGS= -pipe 
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain: buildroot-toolchain libuclibc++-toolchain
endif
else
LIBC_STYLE=glibc
endif

ifeq ($(OPTWARE_TARGET),mss)
HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME = mipsel-linux
CROSS_CONFIGURATION = hndtools-mipsel-linux
TARGET_CROSS = /opt/brcm/$(CROSS_CONFIGURATION)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = /opt/brcm/$(CROSS_CONFIGURATION)/$(GNU_TARGET_NAME)/lib
TARGET_LDFLAGS = 
TARGET_CUSTOM_FLAGS= -pipe 
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain:
endif

ifeq ($(OPTWARE_TARGET),ds101)
CROSS_CONFIGURATION_GCC_VERSION=3.3.4
CROSS_CONFIGURATION_GLIBC_VERSION=2.3.3
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

ifeq ($(OPTWARE_TARGET),ds101j)
CROSS_CONFIGURATION_GCC_VERSION=3.3.4
CROSS_CONFIGURATION_GLIBC_VERSION=2.3.3
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
ifeq ($(HOST_MACHINE),ppc)
HOSTCC = $(TARGET_CC)
GNU_HOST_NAME = powerpc-603e-linux
GNU_TARGET_NAME = powerpc-603e-linux
TARGET_CROSS = /opt/$(TARGET_ARCH)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = /opt/$(TARGET_ARCH)/$(GNU_TARGET_NAME)/lib
TARGET_LDFLAGS = -L/opt/lib
TARGET_CUSTOM_FLAGS=
TARGET_CFLAGS=-I/opt/include $(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain:
else
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
endif

ifeq ($(OPTWARE_TARGET),nas100d)
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

ifeq ($(OPTWARE_TARGET),fsg3)
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

ifeq ($(OPTWARE_TARGET),ts72xx)
CROSS_CONFIGURATION_GCC_VERSION=3.3.4
CROSS_CONFIGURATION_GLIBC_VERSION=2.3.2
CROSS_CONFIGURATION_GCC=gcc-$(CROSS_CONFIGURATION_GCC_VERSION)
CROSS_CONFIGURATION_GLIBC=glibc-$(CROSS_CONFIGURATION_GLIBC_VERSION)
CROSS_CONFIGURATION = $(CROSS_CONFIGURATION_GCC)-$(CROSS_CONFIGURATION_GLIBC)
HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME = arm-linux
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
	-e 's|^sys_lib_search_path_spec=.*"$$|sys_lib_search_path_spec="$(TARGET_LIBDIR) $(STAGING_LIB_DIR)"|' \
	-e 's|^sys_lib_dlsearch_path_spec=.*"$$|sys_lib_dlsearch_path_spec=""|' \
	-e 's|^hardcode_libdir_flag_spec=.*"$$|hardcode_libdir_flag_spec=""|' \

STAGING_INCLUDE_DIR=$(STAGING_PREFIX)/include
STAGING_LIB_DIR=$(STAGING_PREFIX)/lib

STAGING_CPPFLAGS=$(TARGET_CFLAGS) -I$(STAGING_INCLUDE_DIR)
STAGING_LDFLAGS=$(TARGET_LDFLAGS) -L$(STAGING_LIB_DIR) -Wl,-rpath,/opt/lib -Wl,-rpath-link,$(STAGING_LIB_DIR)

HOST_STAGING_INCLUDE_DIR=$(HOST_STAGING_PREFIX)/include
HOST_STAGING_LIB_DIR=$(HOST_STAGING_PREFIX)/lib

HOST_STAGING_CPPFLAGS=-I$(HOST_STAGING_INCLUDE_DIR)
HOST_STAGING_LDFLAGS=-L$(HOST_STAGING_LIB_DIR) -Wl,-rpath,/opt/lib -Wl,-rpath-link,$(HOST_STAGING_LIB_DIR)

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
	if ls $(BUILD_DIR)/*_$(TARGET_ARCH).xsh > /dev/null 2>&1; then \
		rsync -avr --delete $(BUILD_DIR)/*_$(TARGET_ARCH).{ipk,xsh} $(PACKAGE_DIR)/ ; \
	else \
		rsync -avr --delete $(BUILD_DIR)/*_$(TARGET_ARCH).ipk $(PACKAGE_DIR)/ ; \
	fi
	{ \
		cd $(PACKAGE_DIR); \
		$(IPKG_MAKE_INDEX) . > Packages; \
		gzip -c Packages > Packages.gz; \
	}
	@echo "ALL DONE."

packages: $(PACKAGES_IPKG)
	$(MAKE) index

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
	rm -rf $(BUILD_DIR) $(STAGING_DIR) $(PACKAGE_DIR) nslu2 wl500g mss nas100d ds101 ds101j ds101g fsg3 ts72xx

toolclean:
	rm -rf $(TOOL_BUILD_DIR)

host/.configured:
	[ -d $(HOST_BUILD_DIR) ] || ( \
		if [ "$(OPTWARE_TARGET)" = $(shell basename $(BASE_DIR)) ]; \
			then mkdir -p ../host; ln -s ../host .; \
			else mkdir -p host; \
		fi; \
		mkdir -p $(HOST_BUILD_DIR) $(HOST_STAGING_PREFIX); \
	)
	touch host/.configured

make/%.mk:
	PKG_UP=$$(echo $* | tr [a-z\-] [A-Z_]);			\
	sed -e "s/<foo>/$*/g" -e "s/<FOO>/$${PKG_UP}/g"		\
		 -e '6,11d' make/template.mk > $@

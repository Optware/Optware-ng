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

# one of `ls platforms/toolchain-*.mk | sed 's|^platforms/toolchain-\(.*\)\.mk$$|\1|'`
OPTWARE_TARGET ?= nslu2


# Add new packages here - make sure you have tested cross compilation.
# When they have been tested, they will be promoted and uploaded.
#
CROSS_PACKAGES_READY_FOR_TESTING = \

# Add new native-only packages here
# When they have been tested, they will be promoted and uploaded.
#
NATIVE_PACKAGES_READY_FOR_TESTING = \

# iozone - fileop_linux-arm.o: No such file or directory
# parted - does not work on the slug, even when compiled natively
# lumikki - does not install to /opt
# doxygen - host binary, not stripped
# bpalogin - for some reason it can't find 'sed' on the build machine
PACKAGES_THAT_NEED_TO_BE_FIXED = gkrellm parted lumikki \
	doxygen \
	iozone \
	bpalogin \

PERL_PACKAGES = \
	perl \
	perl-algorithm-diff \
	perl-appconfig perl-assp \
	perl-archive-tar perl-archive-zip \
	perl-berkeleydb \
	perl-bit-vector \
	perl-bsd-resource \
	perl-business-isbn-data perl-business-isbn \
	perl-carp-clan \
	perl-cgi-application \
	perl-class-accessor perl-class-data-inheritable perl-class-dbi perl-class-trigger \
	perl-clone \
	perl-compress-zlib \
	perl-convert-binhex perl-convert-tnef perl-convert-uulib \
	perl-crypt-openssl-random perl-crypt-openssl-rsa perl-crypt-ssleay \
	perl-danga-socket \
	perl-date-calc perl-date-manip \
	perl-db-file \
	perl-dbd-mysql perl-dbd-sqlite perl-dbi \
	perl-dbix-contextualfetch \
	perl-devel-caller perl-devel-lexalias \
	perl-device-serialport \
	perl-digest-hmac perl-digest-perl-md5 perl-digest-sha1 perl-digest-sha \
	perl-extutils-cbuilder perl-extutils-parsexs \
	perl-file-next perl-file-rename \
	perl-gd perl-gd-barcode \
	perl-html-parser perl-html-tagset perl-html-template perl-hottproxy \
	perl-ima-dbi \
	perl-io-multiplex perl-io-socket-ssl perl-io-string perl-io-stringy perl-io-zlib \
	perl-ip-country \
	perl-lexical-persistence \
	perl-libnet perl-libwww \
	perl-mail-spf-query perl-mailtools \
	perl-mime-tools \
	perl-module-build perl-module-refresh perl-module-signature \
	perl-net-cidr-lite perl-net-dns perl-net-ident perl-net-server perl-net-ssleay \
	perl-padwalker \
	perl-par-dist \
	perl-pod-readme \
	perl-scgi \
	perl-storable \
	perl-sys-hostname-long \
	perl-sys-syscall \
	perl-template-toolkit \
	perl-term-readkey perl-term-readline-gnu \
	perl-text-diff \
	perl-time-hires \
	perl-unicode-map perl-unicode-string \
	perl-universal-moniker \
	perl-unix-syslog \
	perl-uri \
	perl-version \
	perl-wakeonlan \
	perl-xml-parser \
	perl-yaml \
	ack \
	amavisd-new \
	colordiff \
	cowsay \
	ddclient \
	ipcalc \
	perlbal \
	perlconsole \
	postgrey \
	rsnapshot \
	slimserver spamassassin \
	stow \

PYTHON_PACKAGES = \
	cherokee-pyscgi \
	dstat \
	getmail \
	hellanzb \
	hplip \
	ipython \
	mailman \
	mod-python mod-wsgi \
	putmail \
	pyrex \
	sabnzbd \
	scons \
	py-4suite py-amara py-apsw \
	py-bazaar-ng py-beaker py-bittorrent py-bluez py-buildutils \
	py-celementtree py-cheetah py-cherrypy py-cherrytemplate py-cjson \
	py-clips py-codeville py-configobj py-constraint py-crypto py-curl \
	py-decorator py-decoratortools py-django py-docutils py-duplicity \
	py-elementtree py-flup py-formencode \
	py-gdchart2 py-gd py-genshi py-gnosis-utils \
	py-hgsvn py-kid py-lxml \
	py-mako py-markdown py-mercurial \
	py-moin py-mssql py-mx-base py-mysql \
	py-myghty py-myghtyutils \
	py-nose \
	py-openssl \
	py-paste py-pastedeploy py-pastescript py-pastewebkit \
	py-pexpect py-pil py-ply py-protocols \
	py-pgsql py-psycopg py-psycopg2 py-pygresql \
	py-pudge py-pylons py-pyro py-quixote \
	py-rdiff-backup py-reportlab py-routes py-roundup py-ruledispatch \
	py-scgi py-selector py-serial py-setuptools \
	py-silvercity py-simplejson py-simpy py-soappy \
	py-sqlalchemy py-sqlite py-sqlobject \
	py-tailor py-tgfastdata py-trac \
	py-turbocheetah py-turbogears py-turbojson py-turbokid \
	py-urwid py-usb py-weatherget py-webpy py-wsgiref py-webhelpers \
	py-xml py-yaml py-yenc py-zope-interface \
	py-twisted py-axiom py-epsilon py-mantissa py-nevow \

ERLANG_PACKAGES = \
	erlang erl-yaws \

# removed asterisk-chan-capi, doesn't build because of asterisk-stage problems
ASTERISK_PACKAGES = \
	asterisk asterisk-sounds \
	asterisk14 \
	asterisk14-chan-capi \
	asterisk14-core-sounds-en-alaw \
	asterisk14-core-sounds-en-g729 \
	asterisk14-core-sounds-en-gsm \
	asterisk14-core-sounds-en-ulaw \
	asterisk14-extra-sounds-en-alaw \
	asterisk14-extra-sounds-en-g729 \
	asterisk14-extra-sounds-en-gsm \
	asterisk14-extra-sounds-en-ulaw \
	asterisk14-moh-freeplay-alaw \
	asterisk14-moh-freeplay-g729 \
	asterisk14-moh-freeplay-gsm \
	asterisk14-moh-freeplay-ulaw \
	asterisk14-gui \
	asterisk16 \
	asterisk16-addons \

PACKAGES_REQUIRE_LINUX26 = \
	inotail \
	lm-sensors \
	module-init-tools \
	sysfsutils \
	varnish \

PACKAGES_ONLY_WORK_ON_LINUX24 = \
	modutils \
	spindown \

# libao - has runtime trouble?
COMMON_CROSS_PACKAGES = \
	9base \
	abook adduser adns alac-decoder amule analog antinat \
	apcupsd appweb \
	apache apr apr-util \
	arc aria2 arping arpwatch aspell \
	$(ASTERISK_PACKAGES) \
	at atftp atk atop audiofile autoconf automake autossh avahi \
	bash bc bftpd bind bip bison bitchx bitlbee bogofilter \
	bridge-utils \
	bsdgames bsdmainutils \
	btpd busybox byrequest bzflag bzip2 \
	bluez-libs bluez-utils bluez-hcidump \
	bluez2-libs bluez2-utils \
	cabextract cairo calc calcurse castget \
	catdoc ccollect ccxstream cdargs cdrtools \
	cherokee chicken chillispot chrpath cksfv \
	classpath clamav clearsilver clips clutch cmdftp \
	cogito confuse connect coreutils corkscrew cpio cron \
	cscope ctags ctcs ctorrent ctrlproxy \
	cups cups-pdf cvs \
	cyrus-imapd cyrus-sasl \
	dansguardian dash davtools dbus dcraw denyhosts dev-pts dfu-util \
	dialog dict digitemp dircproxy distcc dhcp diffstat diffutils \
	dmsetup dnsmasq dnstracer dokuwiki dosfstools dovecot \
	dropbear drraw dspam dtach dump \
	e2fsprogs e2tools eaccelerator ed ecl electric-fence elinks \
	emacs22 endian enhanced-ctorrent esmtp esniper \
	$(ERLANG_PACKAGES) \
	esound eggdrop eventlog expat extract-xiso ez-ipupdate \
	faad2 fann fcgi fconfig fetchmail ffmpeg \
	ficy file finch findutils firedrill-httptunnel \
	fis fish fixesext flac flex flip \
	fontconfig freecell freeradius freetds freetype freeze \
	ftpcopy ftpd-topfield fuppes \
	gambit-c gawk gcal gconv-modules gdb gdbm gdchart \
	geoip gettext \
	ggrab ghostscript git glib gnet gnokii \
	gnu-httptunnel gnu-smalltalk gnugo gnupg gnuplot gnutls \
	gpsd \
	grep groff gsasl gsnmp gtmess gtk gutenprint gzip  \
	gphoto2 libgphoto2 \
	gift giftcurs gift-ares gift-fasttrack gift-gnutella \
	gift-openft gift-opennap \
	haproxy haserl hd2u hdparm hello hexcurse heyu \
	hiawatha hnb hpijs hping htop httping \
	ice icecast id3lib iftop ii iksemel imagemagick imap \
	inadyn indent inetutils ipac-ng \
	iperf ipkg-web iptables iptraf iputils-arping \
	ircd-hybrid irssi ivorbis-tools \
	jabberd jamvm jed jikes jove joe \
	keychain kismet kissdx knock \
	lame launchtool lcd4linux ldconfig leafnode less lftp lha \
	liba52 libao libart libbt libcapi20 libcdio libcurl \
	libdaemon libdb libdlna \
	libdvb libdvbpsi libdvdnav libdvdread \
	libesmtp libevent libexif libextractor libftdi \
	libgc libgcrypt libgd libghttp libgmp libgpg-error \
	libid3tag libidn libijs \
	libjpeg liblcms libmad libmemcache libmpcdec libmpeg2 libmrss libmtp \
	libnetfilter-queue libnfnetlink libnsl libnxml \
	libol libogg libosip2 libopensync libpar2 libpcap libpng libpth librsync \
	libshout libsigc++ libsoup libsndfile libstdc++ \
	libtasn1 libtiff libtool libtorrent \
	libupnp libusb libvncserver libvorbis libvorbisidec libxml2 libxslt \
	lighttpd lirc linksys-tftp littlesmalltalk \
	logrotate lookat loudmouth lrzsz lsof ltrace \
	lua luarocks \
	lynx lzo \
	m4 madplay make man man-pages mc mcabber md5deep mdadm \
	mediatomb mediawiki memcached metalog memtester \
	mg miau microcom microperl mimms \
	minicom mini-sendmail minihttpd miscfiles \
	mktemp mlocate moblock moc modutils monit most motion \
	mod-fastcgi moe monotone mp3blaster mpack mpage \
	mpc mpd mpdscribble \
	mpg123 mpop mrtg msmtp \
	msort msynctool mt-daapd mtools \
	mtr multitail mutt mxml \
	mysql mysql-connector-odbc \
	nagg nagios-plugins nail nano nanoblogger nbench-byte \
	ncdu ncftp ncmpc ncurses ncursesw nd ne nemesis \
	neon net-snmp net-tools netatalk netcat nethack netio \
	newsbeuter newt \
	nfs-server nfs-utils \
	nget nginx ngrep nickle ninvaders nmap nload noip nrpe \
	ntfsprogs ntop ntp ntpclient nttcp nut nvi nylon nzbget \
	ocaml oleo open2300 \
	openobex obexftp \
	opencdk openldap openser openssh openssl openvpn \
	optware-devel ossp-js oww \
	pal p7zip palantir pango par2cmdline patch patchutils \
	pcapsipdump pciutils pcre pen perltgd \
	phoneme-advanced \
	php php-apache php-fcgi php-thttpd phpmyadmin \
	picocom picolisp pkgconfig player polipo \
	popt poptop portmap postgresql postfix pound ppp privoxy procmail \
	procps proftpd proxytunnel psmisc psutils puppy pure-ftpd pv pwgen \
	python python24 python25 $(PYTHON_PACKAGES) \
	qemacs qemu qemu-libc-i386 quagga quickie quilt \
	radiusclient-ng rc rcs rdate readline re2c recode recordext \
	redir renderext rhtvision rlfe rlwrap rrdcollect rrdtool \
	rssh rsstail rsync rtorrent rtpproxy ruby rubygems \
	sablevm samba samba2 sane-backends \
	scli scponly screen scsi-idle sdl sdparm \
	sed sendmail ser ser2net setserial setpwc sg3-utils \
	sharutils simh sipcalc siproxd slang slrn slsc \
	sm smartmontools snort snownews \
	socat softflowd spandsp speex spindown sqlite sqlite2 \
	sqsh squeak squid srelay ssam sslwrap strace stunnel streamripper \
	stupid-ftpd sudo surfraw swi-prolog svn syslog-ng sysstat syx \
	taged taglib tar tcl tcpwrappers tftp-hpa \
	tcpdump tcpflow tcsh termcap texinfo textutils thttpd \
	tig tin tinyscheme tmsnc tnef tnftp tnftpd toppyweb tor torrent \
	transcode transmission tre tree trickle \
	tshark tsocks ttf-bitstream-vera tz tzwatch \
	ucl uemacs ufsd unarj unfs3 units unixodbc unrar unrtf \
	unzip up-imapproxy updatedd upslug2 \
	upx usbutils ushare utf8proc util-linux util-linux-ng \
	vblade vdr-mediamvp vim vitetris vlc \
	vnstat vorbis-tools vpnc vsftpd vte vtun \
	w3cam w3m wakelan webalizer weechat wget \
	which whois wizd wpa-supplicant wput wxbase \
	xmlrpc-c \
	x11 xau xauth xaw xchat xcursor xdmcp xdpyinfo xext \
	xextensions xfixes xft xinetd \
	xmu xpdf xpm xproto xrender xt xterm xtrans xtst \
	x264 xmail xvid \
	yafc yawk yougrabber \
	zile zip zlib zoo zsh \

# emacs and xemacs needs to run themselves to dump an image, so they probably will never cross-compile.
# ocaml does not use gnu configure, cross build may work by some more tweaking, build native first
# pure-ftpd too many AC_RUN_IF_ELSE
COMMON_NATIVE_PACKAGES = \
	emacs \
	xemacs \
	hugs \
	mldonkey \
	mzscheme \
        ocaml \
        pure-ftpd \
	unison \

# libiconv - has been made obsolete by gconv-modules
# Metalog - has been made obsolete by syslog-ng
PACKAGES_OBSOLETED = erl-escript libiconv metalog \
	perl-spamassassin perl-mime-base64 jabber tzcode \

##############

HOST_MACHINE:=$(shell uname -m | sed -e 's/i[3-9]86/i386/' )
HOST_OS:=$(shell uname)

# Directory location definitions

OPTWARE_TOP=$(shell if ! grep -q ^OPTWARE_TOP= ./Makefile; then cd ..; fi; pwd)
BASE_DIR:=$(shell pwd)

SOURCE_DIR=$(BASE_DIR)/sources
DL_DIR=$(BASE_DIR)/downloads
TOOL_BUILD_DIR=$(BASE_DIR)/toolchain
PACKAGE_DIR=$(BASE_DIR)/packages

BUILD_DIR=$(BASE_DIR)/builds
STAGING_DIR=$(BASE_DIR)/staging

STAGING_PREFIX=$(STAGING_DIR)/opt
STAGING_INCLUDE_DIR=$(STAGING_PREFIX)/include
STAGING_LIB_DIR=$(STAGING_PREFIX)/lib
STAGING_CPPFLAGS=$(TARGET_CFLAGS) -I$(STAGING_INCLUDE_DIR)
STAGING_LDFLAGS=$(TARGET_LDFLAGS) -L$(STAGING_LIB_DIR) -Wl,-rpath,/opt/lib -Wl,-rpath-link,$(STAGING_LIB_DIR)

HOST_BUILD_DIR=$(BASE_DIR)/host/builds
HOST_STAGING_DIR=$(BASE_DIR)/host/staging

HOST_STAGING_PREFIX=$(HOST_STAGING_DIR)/opt
HOST_STAGING_INCLUDE_DIR=$(HOST_STAGING_PREFIX)/include
HOST_STAGING_LIB_DIR=$(HOST_STAGING_PREFIX)/lib
HOST_STAGING_CPPFLAGS=-I$(HOST_STAGING_INCLUDE_DIR)
HOST_STAGING_LDFLAGS=-L$(HOST_STAGING_LIB_DIR) -Wl,-rpath,/opt/lib -Wl,-rpath-link,$(HOST_STAGING_LIB_DIR)

export TMPDIR=$(BASE_DIR)/tmp

##############

all: directories toolchain packages

TARGET_OPTIMIZATION=-O2 #-mtune=xscale -march=armv4 -Wa,-mcpu=xscale
TARGET_DEBUGGING= #-g

include $(OPTWARE_TOP)/platforms/toolchain-$(OPTWARE_TARGET).mk
ifndef TARGET_USRLIBDIR
TARGET_USRLIBDIR = $(TARGET_LIBDIR)
endif

ifeq (darwin,$(TARGET_OS))
SHLIB_EXT=dylib
SO=
DYLIB=.dylib
else	# default linux
SHLIB_EXT=so
SO=.so
DYLIB=
endif

ifeq ($(LIBC_STYLE), uclibc)
include $(OPTWARE_TOP)/platforms/packages-uclibc.mk
else
LIBC_STYLE=glibc
endif

include $(OPTWARE_TOP)/platforms/packages-$(OPTWARE_TARGET).mk

ifeq ($(HOSTCC), $(TARGET_CC))
PACKAGES ?= $(COMMON_NATIVE_PACKAGES)
PACKAGES_READY_FOR_TESTING = $(NATIVE_PACKAGES_READY_FOR_TESTING)
else
PACKAGES ?= $(filter-out $(NATIVE_PACKAGES) $(BROKEN_PACKAGES), $(COMMON_CROSS_PACKAGES) $(SPECIFIC_PACKAGES))
PACKAGES_READY_FOR_TESTING = $(CROSS_PACKAGES_READY_FOR_TESTING)
endif

ifneq (, $(filter ipkg-opt $(OPTWARE_TARGET)-bootstrap $(OPTWARE_TARGET)-optware-bootstrap, $(PACKAGES)))
UPD-ALT_PREFIX ?= /opt
endif

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
SOURCES_NLO_SITE=http://sources.nslu2-linux.org/sources

TARGET_CXX=$(TARGET_CROSS)g++
TARGET_CC=$(TARGET_CROSS)gcc
TARGET_CPP="$(TARGET_CC) -E"
TARGET_LD=$(TARGET_CROSS)ld
TARGET_AR=$(TARGET_CROSS)ar
TARGET_AS=$(TARGET_CROSS)as
TARGET_NM=$(TARGET_CROSS)nm
TARGET_RANLIB=$(TARGET_CROSS)ranlib
TARGET_STRIP?=$(TARGET_CROSS)strip
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

STRIP_COMMAND ?= $(TARGET_STRIP) --remove-section=.comment --remove-section=.note --strip-unneeded

PATCH_LIBTOOL=sed -i \
	-e 's|^sys_lib_search_path_spec=.*"$$|sys_lib_search_path_spec="$(TARGET_LIBDIR) $(STAGING_LIB_DIR)"|' \
	-e 's|^sys_lib_dlsearch_path_spec=.*"$$|sys_lib_dlsearch_path_spec=""|' \
	-e 's|^hardcode_libdir_flag_spec=.*"$$|hardcode_libdir_flag_spec=""|' \
	-e 's|nmedit |$(TARGET_CROSS)nmedit |' \

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

ifeq ($(PACKAGE_DIR),$(BASE_DIR)/packages)
    ifeq (,$(findstring -bootstrap,$(SPECIFIC_PACKAGES)))
$(PACKAGE_DIR)/Packages: $(BUILD_DIR)/*.ipk
    else
$(PACKAGE_DIR)/Packages: $(BUILD_DIR)/*.ipk $(BUILD_DIR)/*.xsh
    endif
	if ls $(BUILD_DIR)/*_$(TARGET_ARCH).xsh > /dev/null 2>&1; then \
		rm -f $(@D)/*_$(TARGET_ARCH).xsh ; \
		cp -fal $(BUILD_DIR)/*_$(TARGET_ARCH).xsh $(@D)/ ; \
	fi
	rm -f $(@D)/*_$(TARGET_ARCH).ipk
	cp -fal $(BUILD_DIR)/*_$(TARGET_ARCH).ipk $(@D)/
else
$(PACKAGE_DIR)/Packages:
endif
	{ \
		cd $(PACKAGE_DIR); \
		$(IPKG_MAKE_INDEX) . > Packages; \
		gzip -c Packages > Packages.gz; \
	}
	@echo "ALL DONE."

packages: $(PACKAGES_IPKG)
	$(MAKE) index

.PHONY: all clean dirclean distclean directories packages source toolchain \
	buildroot-toolchain libuclibc++-toolchain \
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
	cd $(OPTWARE_TOP)
	rm -rf $(BUILD_DIR) $(STAGING_DIR) $(PACKAGE_DIR)
	rm -rf host
	rm -rf `ls platforms/toolchain-*.mk | sed 's|^platforms/toolchain-\(.*\)\.mk$$|\1|'`

toolclean:
	rm -rf $(TOOL_BUILD_DIR)

%-savespace:
	scripts/clean-workdir.sh $*

host/.configured:
	[ -d $(HOST_BUILD_DIR) ] || ( \
		if [ "$(OPTWARE_TARGET)" = $(shell basename $(BASE_DIR)) ]; \
			then mkdir -p ../host; ln -s ../host .; \
			else mkdir -p host; \
		fi; \
		mkdir -p $(HOST_BUILD_DIR) $(HOST_STAGING_PREFIX); \
	)
	[ -e $@ ] || touch $@

%-target %/.configured:
	[ -e ${DL_DIR} ] || mkdir -p ${DL_DIR}
	[ -e $*/Makefile ] || ( \
		mkdir -p $* ; \
		echo "OPTWARE_TARGET=$*" > $*/Makefile ; \
		echo "include ../Makefile" >> $*/Makefile ; \
		ln -s ../downloads $*/downloads ; \
		ln -s ../make $*/make ; \
		ln -s ../scripts $*/scripts ; \
		ln -s ../sources $*/sources ; \
	)
	touch $*/.configured


make/%.mk:
	PKG_UP=$$(echo $* | tr [a-z\-] [A-Z_]);			\
	sed -e "s/<foo>/$*/g" -e "s/<FOO>/$${PKG_UP}/g"		\
		 -e '6,11d' make/template.mk > $@

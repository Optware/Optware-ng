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

#PACKAGES_BROKEN_ON_64BIT_HOST = \
apcupsd appweb atop 9base alsa-oss appweb \
bitlbee boost bridge-utils bsdgames bzflag \
centerim cyrus-imapd dansguardian delegate dialog \
eaccelerator libol elinks gift-opennap netatalk \
taglib libopensync newsbeuter newt ettercap-ng lighttpd \
nfs-server transcode esound ices0 nfs-utils \
littlesmalltalk nget fcgi nload ffmpeg uemacs fish \
loudmouth nrpe uncia freeze madplay iptraf ntop \
ffmpeg ushare fuppes mc irssi util-linux-ng mdadm vlc \
ivorbis-tools jabberd rrdcollect gambit-c obexftp \
vorbis-tools rrdtool jove git launchtool gnu-smalltalk \
ldconfig libao gloox libcdio libdlna libdvb gift-ares \
opendchub wakelan \
ossp-js mediatomb memcached minidlna mkvtoolnix \
phoneme-advanced motion picoLisp motor pkgconfig moe \
player mpd mrtg msynctool mt-daapd mt-daapd-svn mtr \
rssh rtorrent qemu rxtx sablevm qemu-libc-i386 quickie \
samba2 sandbox scrobby sm sox srecord swi-prolog \
ack avn colordiff ipcalc perlbal perlconsole \
subvertpy slimserver squeezecenter SpamAssassin py-pyro \

# Add new packages here - make sure you have tested cross compilation.
# When they have been tested, they will be promoted and uploaded.
#
CROSS_PACKAGES_READY_FOR_TESTING = qt-embedded \
	py-btpd-webui \
	cryptsetup \
	unbound \
	ldns \
	dnssec-trigger \
	collectd \

# Add new native-only packages here
# When they have been tested, they will be promoted and uploaded.
#
NATIVE_PACKAGES_READY_FOR_TESTING = cmake \

# iozone - fileop_linux-arm.o: No such file or directory
# parted - does not work on the slug, even when compiled natively
# lumikki - does not install to $(TARGET_PREFIX)
# doxygen - host binary, not stripped
# bpalogin - for some reason it can't find 'sed' on the build machine
# clinkcc - ../../src/cybergarage/xml/XML.cpp:151: error: invalid conversion from 'const char**' to 'char**'
# clinkcc - fixed: http://wiki.embeddedacademy.org/index.php/Instaling_and_configurating_the_tools#Cyber_Lynk_for_C.2B.2B
# clinkcc - depends on broken xerces-c package
# btg - needs old boost and libtorrent-rasterbar
#
PACKAGES_THAT_NEED_TO_BE_FIXED = lumikki \
	doxygen \
	xchat \
	iozone \
	bpalogin \
	nemesis \
	appweb bluez-utils bluez-hcidump libextractor sandbox \
	btg \
 
# deluge is actually a python package, but it depends on perl package intltool
PERL_PACKAGES = \
	deluge deluge-develop \
	intltool \
	perl \
	perl-algorithm-diff \
	perl-appconfig perl-assp \
	perl-archive-tar perl-archive-zip \
	perl-b-keywords \
	perl-berkeleydb \
	perl-bit-vector \
	perl-bsd-resource \
	perl-business-isbn-data perl-business-isbn \
	perl-carp-clan \
	perl-cgi perl-cgi-application \
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
	perl-email-address perl-email-messageid \
	perl-email-mime-contenttype \
	perl-email-mime-encodings \
	perl-email-mime-modifier perl-email-mime \
	perl-email-simple perl-email-send \
	perl-encode-detect \
	perl-extutils-cbuilder perl-extutils-parsexs \
	perl-file-next perl-file-rename \
	perl-gd perl-gd-barcode \
	perl-html-parser perl-html-tagset perl-html-template perl-hottproxy \
	perl-http-response-encoding \
	perl-ima-dbi \
	perl-io-multiplex perl-io-socket-ssl perl-io-string perl-io-stringy perl-io-zlib \
	perl-ip-country \
	perl-json-xs \
	perl-lexical-persistence \
	perl-libnet perl-libwww perl-libxml \
	perl-mail-spf-query perl-mailtools \
	perl-mime-tools \
	perl-module-build perl-module-pluggable perl-module-refresh perl-module-signature \
	perl-net-cidr-lite perl-net-dns perl-net-ident perl-net-server perl-net-ssleay \
	perl-padwalker \
	perl-par-dist \
	perl-pod-readme perl-poe-xs-queue-array \
	perl-return-value \
	perl-scgi \
	perl-storable \
	perl-sys-hostname-long \
	perl-sys-syscall \
	perl-template-toolkit \
	perl-term-readkey perl-term-readline-gnu \
	perl-text-diff \
	perl-timedate \
	perl-unicode-map perl-unicode-string \
	perl-universal-moniker \
	perl-unix-syslog \
	perl-uri \
	perl-version \
	perl-wakeonlan \
	perl-www-mechanize \
	perl-xml-dom perl-xml-parser perl-xml-regexp \
	perl-yaml-syck \
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
	slimrat \
	slimserver squeezecenter \
	spamassassin \
	stow \

PYTHON_PACKAGES = \
	bzr bzr-rewrite bzr-svn bzrtools \
	cherokee-pyscgi \
	dstat \
	getmail \
	gitosis \
	hellanzb \
	hplip \
	iotop \
	ipython \
	mailman \
	mod-python mod-wsgi \
	pyload \
	pssh putmail \
	pygments pyrex \
	sabnzbd sabnzbdplus \
	scons \
	stgit \
	subvertpy \
	py-4suite py-amara py-apsw \
	py-asn1-modules py-asn1 py-cairo py-cffi py-characteristic py-cparser \
	py-cryptography py-enum34 py-hgdistver py-ordereddict py-service-identity py-six \
	py-beaker py-bittorrent py-bluez py-boto py-buildutils \
	py-celementtree py-chardet py-cheetah py-cherrypy py-cherrytemplate py-cjson \
	py-clips py-configobj py-constraint py-crypto py-curl \
	py-decorator py-decoratortools py-django py-docutils py-duplicity \
	py-elementtree py-feedparser py-flup py-formencode \
	py-gdchart2 py-gd py-genshi py-gnosis-utils py-gobject2 py-gtk \
	py-idna py-ipaddress \
	py-hgsubversion py-hgsvn py-jsmin py-kid py-lepl py-lxml \
	py-mako py-markdown py-mercurial \
	py-moin py-mssql py-mx-base py-mysql \
	py-myghty \
	py-nose \
	py-openssl py-paramiko \
	py-paste py-pastedeploy py-pastescript py-pastewebkit \
	py-pexpect py-pil py-ply py-protocols \
	py-pgsql py-psycopg py-psycopg2 py-pygresql \
	py-pudge py-pylons py-pyro py-quixote \
	py-rdiff-backup py-redis \
	py-reportlab py-routes py-roundup py-ruledispatch \
	py-scgi py-selector py-serial py-setuptools \
	py-silvercity py-simplejson py-simpy py-slimit py-soappy \
	py-sqlalchemy py-sqlite py-sqlobject py-statlib \
	py-tailor py-tgfastdata py-trac \
	py-turbocheetah py-turbogears py-turbojson py-turbokid \
	py-urwid py-usb py-weatherget py-webpy py-wsgiref py-webhelpers \
	py-xdg py-xml py-yaml py-yenc py-zope-interface \
	py-twisted py-axiom py-epsilon py-mantissa py-nevow \

ERLANG_PACKAGES = \
	erlang erl-yaws erl-ejabberd \

# removed asterisk-chan-capi, doesn't build because of asterisk-stage problems
ASTERISK_PACKAGES = \
	asterisk10 \
	asterisk11 \
	asterisk13 \
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
	asterisk14-moh-opsound-alaw \
	asterisk14-moh-opsound-g729 \
	asterisk14-moh-opsound-gsm \
	asterisk14-moh-opsound-ulaw \
	asterisk-gui \
	asterisk18 \

PACKAGES_REQUIRE_LINUX26 = \
	inotail \
	lm-sensors \
	module-init-tools \
	sysfsutils \
	varnish \

PACKAGES_ONLY_WORK_ON_LINUX24 = \
	modutils \
	spindown \

BOOST_PACKAGES = \
	libtorrent-rasterbar \
	mkvtoolnix \
	player \

# libao - has runtime trouble?
COMMON_CROSS_PACKAGES = \
	9base \
	abook adduser adns aget aiccu alac-decoder \
	alsa-lib alsa-oss alsa-utils \
	amule analog antinat apcupsd \
	apache apr apr-util \
	arc aria2 arping arpwatch aspell \
	$(ASTERISK_PACKAGES) \
	at at-spi2-core atftp atk atk-bridge atop attr audiofile autoconf \
	automake automake1.4 automake1.9 automake1.10 automake1.14 autossh avahi \
	bacula bash bash-completion bc bftpd \
	bind bip bison bitchx bitlbee \
	bogofilter boost $(BOOST_PACKAGES) bridge-utils \
	bsdgames bsdmainutils \
	btpd busybox byrequest bzflag bzip2 \
	bluez-libs \
	bluez2-libs bluez2-utils \
	c-ares cabextract cadaver cairo calc calcurse castget \
	catdoc ccollect ccrypt ccxstream cdargs \
	cdrtools centerim cuetools \
	cherokee chicken chillispot chrpath cksfv \
	classpath clamav clearsilver climm clinkcc clips cmdftp \
	confuse connect coreutils corkscrew cpio cppunit cpufrequtils cron cryptcat \
	cscope ctags ctcs ctorrent ctrlproxy \
	cups cups-pdf cvs \
	cyrus-imapd cyrus-sasl \
	daemonize dansguardian dash davtools \
	dbus dbus-glib dbus-python \
	dcled dcraw delegate denyhosts dev-pts devio devmem2 dfu-util \
	dhcp dialog dict digitemp dircproxy distcc \
	diffstat diffutils discount \
	dmsetup dnsmasq dnstracer dokuwiki dos2unix dosfstools dovecot \
	dropbear dropbear-android drraw dspam dtach dump \
	e2fsprogs e2tools eaccelerator easy-rsa ed ecl electric-fence elinks \
	elementary-xfce-icon-theme \
	emacs22 endian enhanced-ctorrent enscript esmtp esniper \
	ettercap ettercap-ng \
	$(ERLANG_PACKAGES) \
	esound eggdrop eventlog exif exo expat extract-xiso ez-ipupdate \
	faad2 fann fatresize fatsort fbcat fcgi fconfig \
	fdupes fetchmail ffmpeg ffmpegthumbnailer \
	ficy file finch findutils firedrill-httptunnel \
	fis fish fixesext flac flex flip \
	fontconfig \
	fossil-scm \
	freecell freeradius freetds freetype freeze \
	fribidi ftpcopy fslint ftpd-topfield fuppes fuse fuse-exfat \
	gambit-c gawk gcal gconv-modules gdb gdbm gdchart \
	ged gedit geoip gettext gdk-pixbuf \
	ggrab ghostscript ghostscript-fonts git gkrellmd glib gnet gnokii gnome-icon-theme \
	gnome-icon-theme-symbolic \
	gnu-httptunnel gnu-smalltalk gnugo \
	gnupg1 gnupg gnuplot gnutls gpgme \
	gloox gobject-introspection golang gpsd \
	grep groff gsasl gsnmp gtmess gtypist gutenprint gzip \
	gphoto2 libgphoto2 \
	gift giftcurs gift-ares gift-fasttrack gift-gnutella \
	gift-openft gift-opennap gtk gtk2 gtksourceview gtksourceview2 gsettings-desktop-schemas \
	haproxy harfbuzz haserl hd2u hdparm hello hexcurse heyu \
	hiawatha hicolor-icon-theme hnb hping htop httping \
	ice icecast ices0 icu icu54 \
	id3lib ifstat iftop ii iksemel imagemagick imap \
	inadyn indent inetutils \
	inferno \
	ink inputproto \
	ipac-ng iperf ipkg-web iptables iptraf iputils-arping \
	ircd-hybrid irssi ivorbis-tools \
	jabberd jamvm jed jfsutils jikes jove joe \
	kamailio kbproto keychain kismet kissdx knock \
	lame launchtool lcd4linux ldconfig leafnode less lftp lha \
	liba52 libacl libao libart libassuan libatomic-ops libbt libcap \
	libcapi20 libcdio libcroco libcurl \
	libdaemon libdb libdb52 libdlna \
	libdvb libdvbpsi libdvdnav libdvdread libdrm \
	libebml libexosip2 \
	libepoxy libevent \
	libesmtp libexif libexplain libffi libftdi \
	libgc libgcrypt libgd libghttp libgmp libgpg-error libgssapi \
	libglade libhid \
	libical \
	libid3tag libidn libieee1284 libijs libinklevel libjansson libjbigkit libjpeg \
	libksba liblcms libmaa libmad libmatroska libmemcache libmicrohttpd \
	libmcrypt \
	libmms libmnl libmpc libmpcdec libmpdclient libmpeg2 libmpfr libmrss libmtp \
	libnetfilter-acct libnetfilter-conntrack libnetfilter-log libnetfilter-queue libnfnetlink libnettle libnl libnsl libnxml \
	libol libogg libosip2 libopensync libotr libpam \
	libpar2 libpcap libpeas libpng libpth librsync librsvg \
	libsamplerate libshout libsigc++ libsoup libsndfile libstdc++ \
	libtasn1 libtheora libtiff libtool libtorrent \
	libunistring libupnp libusb libusb1 libvncserver \
	libvorbis libvorbisidec libxfce4ui libxfce4util libxkbcommon libxml2 libxslt libzip \
	lighttpd lirc links2 linksys-tftp linphone littlesmalltalk llink \
	logrotate lookat loudmouth lrzsz lsof ltrace \
	lua luarocks lxappearance lxde-icon-theme \
	lynx lzo \
	m4 madplay make man man-pages mc mcabber md5deep mdadm \
	mediatomb mediawiki memcached mesalib metalog memtester \
	mg miau microcom microdc2 microperl mimms \
	minicom minidlna minidlna-rescan minihttpd miniupnpd \
	mini-sendmail mini-snmpd \
	miscfiles mktemp mktorrent mlocate moblock \
	moc modutils monit most motif motion motor mousepad \
	mod-fastcgi moe moreutils mp3blaster mp3info mpack mpage \
	mpc mpd mpdscribble \
	mpg123 mpop mrtg msmtp \
	msort msynctool mt-daapd mt-daapd-svn mtools \
	mtr multitail mussh mutt mxml \
	myrapbook \
	mysql mysql5 mysql-connector-odbc \
	nagg nagios-plugins nail nano nanoblogger nbench-byte \
	ncdu ncftp ncmpc ncurses ncursesw nd ne \
	neon net-snmp net-tools netatalk netcat nethack netio netrik \
	newsbeuter newt \
	nfs-server nfs-utils \
	nget nginx ngrep nickle ninvaders nload \
	nmap nmon noip nostromo nrpe \
	ntfs-3g ntfsprogs \
	ntop ntp ntpclient nttcp nut nvi nylon nzbget nzbget-testing \
	ocaml oleo open2300 \
	openobex obexftp \
	opendchub openjpeg openldap opensips \
	openssl openssh openvpn \
	optware-devel ossp-js oww owwlog \
	p7zip p910nd pal palantir pango parted \
	par2cmdline patch patchutils \
	pcal pcapsipdump pciutils pcre pen perltgd pinentry pixman \
	phoneme-advanced \
	php php-apache php-thttpd phpmyadmin \
	picocom picolisp pkgconfig plowshare polipo pop3proxy \
	popt poptop portmap postgresql postfix pound powertop \
	ppower ppp printproto privoxy procmail \
	procps proftpd proxytunnel psmisc psutils pthread-stubs puppy pure-ftpd pv pwgen \
	python python24 python25 python26 python27 python3 $(PYTHON_PACKAGES) \
	qemacs qemu qemu-libc-i386 qpopper quagga quickie quilt \
	radiusclient-ng rc rc5pipe rcs rdate \
	readline re2c recode recordext recordprotos \
	redir renderext renderproto rhtvision rkhunter \
	rlfe rlwrap rox-filer rrdcollect rrdtool \
	rssh rsstail rsync rtmpdump rtorrent rtpproxy ruby rubygems rxtx \
	sablevm samba samba2 samba34 samba35 samba36 sane-backends \
	scli scponly screen scrobby scsi-idle sdl sdparm \
	sed sendmail ser ser2net setserial setpwc sg3-utils shared-mime-info \
	sharutils shellinabox shntool silc-client simh sipcalc siproxd sispmctl \
	slang slrn slsc \
	sm smartmontools snort snownews \
	socat softflowd sox spandsp spawn-fcgi speex spindown splix \
	sqlite sqlite2 \
	sqsh squeak squid squid3 \
	srelay srecord srtp ssam sslwrap start-stop-daemon \
	strace strongswan stunnel streamripper \
	stupid-ftpd sudo surfraw swi-prolog svn \
	swig syslog-ng sysstat syx \
	taged taglib talloc tar tcl tcpwrappers tftp-hpa \
	tcpdump tcpflow tcsh telldus-core termcap tesseract-ocr \
	texinfo textutils thttpd thunar \
	tig tin tinyproxy tinyscheme tmsnc tmux tnef tnftp tnftpd \
	toppyweb tor torsocks torrent torrentflux transcode \
	transmission \
	transmissiond transmissiondcfp tre tree trickle \
	tshark tsocks ttf-bitstream-vera tz tzwatch \
	ucl udev udns udpxy uemacs ulogd unarj uncia unfs3 units unixodbc \
	unrar unrtf \
	unzip up-imapproxy updatedd upslug2 \
	upx usbutils ushare utelnetd utf8proc util-linux util-linux-ng \
	vblade vdr-mediamvp vim vitetris vlc \
	vnstat vorbis-tools vpnc vsftpd vte vtun \
	w3cam w3m wayland wakelan wavpack webalizer weechat werc wget \
	which whois wizd wpa-supplicant wput wxbase \
	xerces-c xmlrpc-c \
	x11 xau xauth xaw xbitmaps xcursor xdg-utils xdmcp xdpyinfo xext xdamage xshmfence \
	xextensions xfixes xfixesproto xft xi xinetd pciaccess \
	xmu xp xpdf xpm xcb-proto xcb xextproto xfconf xorg-macros xproto xrender xt xterm xtrans xtst \
	damageproto dri2proto dri3proto glproto presentproto \
	x264 xmail xupnpd xvid xz-utils \
	yafc yasm yawk yougrabber \
	zile zip zlib znc zoo zsh \

# php-fcgi ipk is now built from php.mk

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
PACKAGES_OBSOLETED = cogito erl-escript libiconv metalog monotone \
	perl-spamassassin perl-mime-base64 jabber tzcode \

##############

HOST_MACHINE:=$(shell \
if test x86_64 = `uname -m` -a 32-bit = `file /sbin/init | awk '{print $$3}'`; then echo i386 ; else uname -m; fi \
| sed -e 's/i[3-9]86/i386/' )
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

STAGING_PREFIX=$(STAGING_DIR)$(TARGET_PREFIX)
STAGING_INCLUDE_DIR=$(STAGING_PREFIX)/include
STAGING_LIB_DIR=$(STAGING_PREFIX)/lib
STAGING_CPPFLAGS=$(TARGET_CFLAGS) -I$(STAGING_INCLUDE_DIR)
STAGING_LDFLAGS=$(TARGET_LDFLAGS) -L$(STAGING_LIB_DIR) -Wl,-rpath,$(TARGET_PREFIX)/lib -Wl,-rpath-link,$(STAGING_LIB_DIR)

HOST_BUILD_DIR=$(BASE_DIR)/host/builds
HOST_STAGING_DIR=$(BASE_DIR)/host/staging

HOST_STAGING_PREFIX=$(HOST_STAGING_DIR)/opt
HOST_STAGING_INCLUDE_DIR=$(HOST_STAGING_PREFIX)/include
HOST_STAGING_LIB_DIR=$(HOST_STAGING_PREFIX)/lib
HOST_STAGING_CPPFLAGS=-I$(HOST_STAGING_INCLUDE_DIR)
HOST_STAGING_LDFLAGS=-L$(HOST_STAGING_LIB_DIR) -Wl,-rpath,$(HOST_STAGING_LIB_DIR) -Wl,-rpath-link,$(HOST_STAGING_LIB_DIR)

WHAT_TO_DO_WITH_IPK_DIR=rm -rf
# WHAT_TO_DO_WITH_IPK_DIR=: keep

export TMPDIR=$(BASE_DIR)/tmp

##############

all: directories toolchain packages

TARGET_OPTIMIZATION=-O2 #-mtune=xscale -march=armv4 -Wa,-mcpu=xscale
TARGET_DEBUGGING= #-g

include $(OPTWARE_TOP)/platforms/toolchain-$(OPTWARE_TARGET).mk

DEFAULT_TARGET_PREFIX ?= /opt

TARGET_PREFIX ?= /opt

INSTALL = TARGET_PREFIX=$(TARGET_PREFIX) sh $(BASE_DIR)/scripts/install.sh

PATCH = TARGET_PREFIX=$(TARGET_PREFIX) sh $(BASE_DIR)/scripts/patch.sh

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
PACKAGES ?= $(filter-out \
	$(NATIVE_PACKAGES) \
	$(BROKEN_PACKAGES) \
	$(if $(filter x86_64, $(HOST_MACHINE)), $(PACKAGES_BROKEN_ON_64BIT_HOST), ) \
	, $(COMMON_CROSS_PACKAGES) $(SPECIFIC_PACKAGES))
PACKAGES_READY_FOR_TESTING = $(CROSS_PACKAGES_READY_FOR_TESTING)
endif

ifneq (, $(filter ipkg-static ipkg-opt $(OPTWARE_TARGET)-bootstrap $(OPTWARE_TARGET)-optware-bootstrap, $(PACKAGES)))
UPD-ALT_PREFIX ?= $(TARGET_PREFIX)
endif

testing:
	$(MAKE) PACKAGES="$(PACKAGES_READY_FOR_TESTING)" all
	$(PERL) -w scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) --objdump-path=$(TARGET_CROSS)objdump --base-dir=$(BASE_DIR) $(patsubst %,$(BUILD_DIR)/%*.ipk,$(PACKAGES_READY_FOR_TESTING))

# Common tools which may need overriding
CVS=cvs
SUDO=sudo
WGET_BINARY=wget
WGET = wget --passive-ftp --tries=1 --no-check-certificate
PERL=perl

# Required host-tools, which will build if they missing
HOST_TOOL_GCC33 = $(MAKE) gcc-host-stage GCC_VERSION=3.3.6
HOST_TOOL_ACLOCAL = \
	$(MAKE) directories automake-host-stage autoconf-host-stage pkgconfig-host-stage m4-host-stage libtool-host-stage
HOST_TOOL_AUTOMAKE = \
	$(MAKE) directories automake-host-stage autoconf-host-stage pkgconfig-host-stage m4-host-stage libtool-host-stage
HOST_TOOL_ACLOCAL1.14 = \
	$(MAKE) directories automake1.14-host-stage autoconf-host-stage pkgconfig-host-stage m4-host-stage libtool-host-stage
HOST_TOOL_AUTOMAKE1.14 = \
	$(MAKE) directories automake1.14-host-stage autoconf-host-stage pkgconfig-host-stage m4-host-stage libtool-host-stage
HOST_TOOL_ACLOCAL1.10 = \
	$(MAKE) directories automake1.10-host-stage autoconf-host-stage pkgconfig-host-stage m4-host-stage libtool-host-stage
HOST_TOOL_AUTOMAKE1.10 = \
	$(MAKE) directories automake1.10-host-stage autoconf-host-stage pkgconfig-host-stage m4-host-stage libtool-host-stage
HOST_TOOL_ACLOCAL1.9 = \
	$(MAKE) directories automake1.9-host-stage autoconf-host-stage pkgconfig-host-stage m4-host-stage libtool-host-stage
HOST_TOOL_AUTOMAKE1.9 = \
	$(MAKE) directories automake1.9-host-stage autoconf-host-stage pkgconfig-host-stage m4-host-stage libtool-host-stage
HOST_TOOL_ACLOCAL1.4 = \
	$(MAKE) directories automake1.4-host-stage autoconf-host-stage pkgconfig-host-stage m4-host-stage libtool-host-stage
HOST_TOOL_AUTOMAKE1.4 = \
	$(MAKE) directories automake1.4-host-stage autoconf-host-stage pkgconfig-host-stage m4-host-stage libtool-host-stage

# These are aclocal wrappers used to automatically fix
# libtool versions mismatch issue that can occur with
# some software in most cases
ACLOCAL1.15_SH= TOP=$(BASE_DIR) ACLOCAL=$(HOST_STAGING_PREFIX)/bin/aclocal-1.15 \
		sh $(BASE_DIR)/scripts/aclocal.sh
ACLOCAL1.14_SH= TOP=$(BASE_DIR) ACLOCAL=$(HOST_STAGING_PREFIX)/bin/aclocal-1.14 \
		sh $(BASE_DIR)/scripts/aclocal.sh
ACLOCAL1.10_SH= TOP=$(BASE_DIR) ACLOCAL=$(HOST_STAGING_PREFIX)/bin/aclocal-1.10 \
		sh $(BASE_DIR)/scripts/aclocal.sh
ACLOCAL1.9_SH= TOP=$(BASE_DIR) ACLOCAL=$(HOST_STAGING_PREFIX)/bin/aclocal-1.9 \
		sh $(BASE_DIR)/scripts/aclocal.sh
ACLOCAL1.4_SH= TOP=$(BASE_DIR) ACLOCAL=$(HOST_STAGING_PREFIX)/bin/aclocal-1.4 \
		sh $(BASE_DIR)/scripts/aclocal.sh


# These should be called instead of `autoreconf`
AUTORECONF1.15 = (cd $(BASE_DIR) && $(HOST_TOOL_AUTOMAKE)) && \
	$(subst %,$(HOST_STAGING_PREFIX)/bin/, \
		AUTOCONF=%autoconf \
		AUTOHEADER=%autoheader \
		AUTOMAKE=%automake-1.15 \
		AUTOPOINT=%autopoint \
		LIBTOOLIZE=%libtoolize \
		M4=%m4 \
		ACLOCAL='$(ACLOCAL1.15_SH) -I $(STAGING_PREFIX)/share/aclocal' \
		%autoreconf)
AUTORECONF1.14 = (cd $(BASE_DIR) && $(HOST_TOOL_AUTOMAKE1.14)) && \
	$(subst %,$(HOST_STAGING_PREFIX)/bin/, \
		AUTOCONF=%autoconf \
		AUTOHEADER=%autoheader \
		AUTOMAKE=%automake-1.14 \
		AUTOPOINT=%autopoint \
		LIBTOOLIZE=%libtoolize \
		M4=%m4 \
		ACLOCAL='$(ACLOCAL1.14_SH) -I $(STAGING_PREFIX)/share/aclocal' \
		%autoreconf)
AUTORECONF1.10 =(cd $(BASE_DIR) && $(HOST_TOOL_AUTOMAKE1.10)) && \
	$(subst %,$(HOST_STAGING_PREFIX)/bin/, \
		AUTOCONF=%autoconf \
		AUTOHEADER=%autoheader \
		AUTOMAKE=%automake-1.10 \
		AUTOPOINT=%autopoint \
		LIBTOOLIZE=%libtoolize \
		M4=%m4 \
		ACLOCAL='$(ACLOCAL1.10_SH) -I $(STAGING_PREFIX)/share/aclocal' \
		%autoreconf)
AUTORECONF1.9 = (cd $(BASE_DIR) && $(HOST_TOOL_AUTOMAKE1.9)) && \
	$(subst %,$(HOST_STAGING_PREFIX)/bin/, \
		AUTOCONF=%autoconf \
		AUTOHEADER=%autoheader \
		AUTOMAKE=%automake-1.9 \
		AUTOPOINT=%autopoint \
		LIBTOOLIZE=%libtoolize \
		M4=%m4 \
		ACLOCAL='$(ACLOCAL1.9_SH) -I $(STAGING_PREFIX)/share/aclocal' \
		%autoreconf)
AUTORECONF1.4 = (cd $(BASE_DIR) && $(HOST_TOOL_AUTOMAKE1.4)) && \
	$(subst %,$(HOST_STAGING_PREFIX)/bin/, \
		AUTOCONF=%autoconf \
		AUTOHEADER=%autoheader \
		AUTOMAKE=%automake-1.4 \
		AUTOPOINT=%autopoint \
		LIBTOOLIZE=%libtoolize \
		M4=%m4 \
		ACLOCAL='$(ACLOCAL1.4_SH) -I $(STAGING_PREFIX)/share/aclocal' \
		%autoreconf)

host-automake-tools: directories automake1.4-host-stage automake1.9-host-stage automake1.10-host-stage automake1.14-host-stage automake-host-stage autoconf-host-stage pkgconfig-host-stage m4-host-stage libtool-host-stage


# The hostname or IP number of our local dl.sf.net mirror
SOURCEFORGE_MIRROR=downloads.sourceforge.net
#SOURCES_NLO_SITE=http://sources.nslu2-linux.org/sources
SOURCES_NLO_SITE=http://ftp.osuosl.org/pub/nslu2/sources

# FreeBSD distfiles site
FREEBSD_DISTFILES=ftp://ftp.fi.freebsd.org/pub/FreeBSD/ports/distfiles

# Perl CPAN mirror:
# use this instead of search.cpan.org, since search.cpan.org
# contains only recent versions
PERL_CPAN_SITE=ftp.auckland.ac.nz

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
TARGET_PATH=$(STAGING_PREFIX)/bin:$(STAGING_DIR)/bin:$(TARGET_PREFIX)/bin:$(TARGET_PREFIX)/sbin:/bin:/sbin:/usr/bin:/usr/sbin

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
$(PACKAGES_STAGE) : directories toolchain
%-stage : directories toolchain
$(PACKAGES_IPKG) : directories toolchain ipkg-utils
%-ipk : directories toolchain ipkg-utils

.PHONY: index
index: $(HOST_STAGING_DIR)/bin/ipk_indexer_html_sorted.sh $(PACKAGE_DIR)/Packages $(PACKAGE_DIR)/Packages.html

boost-packages:
	@$(MAKE) $(BOOST_PACKAGES)

boost-packages-ipk:
	@$(MAKE) $(patsubst %, %-ipk, $(BOOST_PACKAGES))

boost-packages-dirclean:
	@$(MAKE) $(patsubst %, %-dirclean, $(BOOST_PACKAGES))

boost-packages-check:
	@$(MAKE) $(patsubst %, %-check, $(BOOST_PACKAGES))

ifeq ($(PACKAGE_DIR),$(BASE_DIR)/packages)
    ifeq (,$(findstring -bootstrap,$(SPECIFIC_PACKAGES)))
$(PACKAGE_DIR)/Packages $(PACKAGE_DIR)/Packages.html: $(BUILD_DIR)/*.ipk
    else
$(PACKAGE_DIR)/Packages $(PACKAGE_DIR)/Packages.html: $(BUILD_DIR)/*.ipk $(BUILD_DIR)/*.xsh
    endif
	if ls $(BUILD_DIR)/*_$(TARGET_ARCH).xsh > /dev/null 2>&1; then \
		rm -f $(@D)/*_$(TARGET_ARCH).xsh ; \
		cp -fal $(BUILD_DIR)/*_$(TARGET_ARCH).xsh $(@D)/ ; \
	fi
	rm -f $(@D)/*_$(TARGET_ARCH).ipk
	cp -fal $(BUILD_DIR)/*_$(TARGET_ARCH).ipk $(@D)/
else
$(PACKAGE_DIR)/Packages $(PACKAGE_DIR)/Packages.html:
endif
	{ \
		cd $(PACKAGE_DIR); \
		$(IPKG_MAKE_INDEX) . > Packages; \
		gzip -c Packages > Packages.gz; \
		$(IPK_INDEXER_MAKE_HTML_INDEX); \
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

TARGET_CC_VER = $(shell test -x "$(TARGET_CC)" && $(TARGET_CC) -dumpversion)

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
	mkdir -p $(STAGING_PREFIX)

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

ifeq ($(DEFAULT_TARGET_PREFIX), $(TARGET_PREFIX))
DIRNAME_SUFFIX=
else
DIRNAME_SUFFIX=$(shell echo $(TARGET_PREFIX) | sed 's/[^a-zA-Z]/-/g')
endif

%-target %$(DIRNAME_SUFFIX)/.configured:
	[ -e ${DL_DIR} ] || mkdir -p ${DL_DIR}
	[ -e $*$(DIRNAME_SUFFIX)/Makefile ] || ( \
		mkdir -p $*$(DIRNAME_SUFFIX) ; \
		cd $*$(DIRNAME_SUFFIX) ; \
		echo "OPTWARE_TARGET=$*" > Makefile ; \
		echo "TARGET_PREFIX=$(TARGET_PREFIX)" >> Makefile ; \
		echo "include ../Makefile" >> Makefile ; \
		ln -s ../downloads downloads ; \
		ln -s ../make make ; \
		ln -s ../scripts scripts ; \
		ln -s ../sources sources ; \
	)
	touch $*$(DIRNAME_SUFFIX)/.configured


make/%.mk:
	PKG_UP=$$(echo $* | tr [a-z\-] [A-Z_]);			\
	sed -e "s/<foo>/$*/g" -e "s/<FOO>/$${PKG_UP}/g"		\
		 -e '6,11d' make/template.mk > $@

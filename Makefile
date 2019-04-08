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

# shell used by make: should be bash
SHELL=/bin/bash

# one of `ls platforms/toolchain-*.mk | sed 's|^platforms/toolchain-\(.*\)\.mk$$|\1|'`
OPTWARE_TARGET ?= buildroot-armeabi-ng

# Add new packages here
# When they have been tested, they will be promoted and uploaded.
#
PACKAGES_READY_FOR_TESTING = qt-embedded \
	py-btpd-webui \
	cryptsetup \
	unbound \
	ldns \
	dnssec-trigger \

# iozone - fileop_linux-arm.o: No such file or directory
# lumikki - does not install to $(TARGET_PREFIX)
# doxygen - host binary, not stripped
# bpalogin - for some reason it can't find 'sed' on the build machine
# btg - needs old boost and libtorrent-rasterbar
# clinkcc - fails to build with GCC 7:
#	../../src/cybergarage/upnp/Service.cpp: In member function ‘bool CyberLink::Service::loadSCPD(CyberIO::File*)’:
#	../../src/cybergarage/upnp/Service.cpp:349:33: error: ISO C++ forbids comparison between pointer and integer [-fpermissive]
#
PACKAGES_THAT_NEED_TO_BE_FIXED = lumikki \
	doxygen \
	xchat \
	iozone \
	bpalogin \
	nemesis \
	appweb libextractor sandbox \
	btg \
	clinkcc \
 
PERL_PACKAGES = \
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
	perl-class-accessor perl-class-data-inheritable perl-class-inspector perl-class-dbi perl-class-trigger \
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
	perl-devel-modlist \
	perl-device-serialport \
	perl-digest-hmac perl-digest-perl-md5 perl-digest-sha1 perl-digest-sha \
	perl-email-address perl-email-messageid \
	perl-email-mime-contenttype \
	perl-email-mime-encodings \
	perl-email-mime-modifier perl-email-mime \
	perl-email-simple perl-email-send \
	perl-encode-detect \
	perl-encode-locale \
	perl-extutils-cbuilder perl-extutils-parsexs \
	perl-file-next perl-file-pid perl-file-rename \
	perl-gd perl-gd-barcode \
	perl-html-form \
	perl-html-parser perl-html-tagparser perl-html-tagset perl-html-template perl-hottproxy \
	perl-http-cookies perl-http-date perl-http-message \
	perl-http-response-encoding \
	perl-ima-dbi \
	perl-io-interface perl-io-socket-multicast \
	perl-io-multiplex perl-io-socket-ssl perl-io-string perl-io-stringy perl-io-zlib \
	perl-ip-country \
	perl-json-xs \
	perl-lexical-persistence \
	perl-libnet perl-libwww \
	perl-libxml perl-libxml-libxml perl-libxml-namespacesupport perl-libxml-sax-base perl-libxml-sax perl-libxml-simple \
	perl-lwp-protocol-https \
	perl-mail-spf-query perl-mailtools \
	perl-mime-tools \
	perl-module-build perl-module-pluggable perl-module-refresh perl-module-signature perl-mozilla-ca \
	perl-net-cidr-lite perl-net-dns perl-net-http perl-net-ident perl-net-server perl-net-ssleay \
	perl-padwalker \
	perl-par-dist \
	perl-pod-readme perl-poe-xs-queue-array \
	perl-return-value \
	perl-scgi perl-soap-lite \
	perl-storable \
	perl-sys-hostname-long \
	perl-sys-syscall \
	perl-template-toolkit \
	perl-term-readkey perl-term-readline-gnu \
	perl-text-diff \
	perl-timedate \
	perl-time-hires \
	perl-unicode-map perl-unicode-string \
	perl-universal-moniker \
	perl-unix-syslog \
	perl-uri \
	perl-version \
	perl-wakeonlan \
	perl-www-mechanize \
	perl-xml-dom perl-xml-parser perl-xml-parser-lite perl-xml-regexp \
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
	deluge deluge-develop \
	dir2ogg \
	dstat \
	getmail \
	gitosis \
	hellanzb \
	hplip \
	iotop \
	ipython \
	mailman \
	mod-python mod-wsgi \
	offlineimap \
	pyload \
	pssh putmail \
	pygments pyrex \
	sabnzbd sabnzbdplus \
	scons \
	stgit \
	subvertpy \
	py-4suite py-amara py-apsw \
	py-asn1-modules py-asn1 py-cairo py-cffi py-characteristic py-cparser \
	py-cryptography py-cython py-enum34 py-hgdistver py-ordereddict py-service-identity py-six \
	py-beaker py-bittorrent py-bluez py-boto py-buildutils \
	py-celementtree py-chardet py-cheetah py-cherrypy py-cherrytemplate py-cjson \
	py-clips py-configobj py-constraint py-crypto py-cups py-curl \
	py-decorator py-decoratortools py-dispatcher py-django py-docutils py-duplicity \
	py-elementtree py-feedparser py-flup py-formencode \
	py-gdchart2 py-gd py-genshi py-geoip py-gnosis-utils py-gobject2 py-gtk \
	py-idna py-imaplib2 py-ipaddress py-jinja2 \
	py-hgsubversion py-hgsvn py-jsmin py-kid py-lepl py-lxml \
	py-mako py-markdown py-mercurial \
	py-moin py-mssql py-mutagen py-mx-base py-mysql \
	py-myghty \
	py-nose \
	py-openssl py-openzwave py-paramiko \
	py-paste py-pastedeploy py-pastescript py-pastewebkit \
	py-pexpect py-pil py-pip py-ply py-protocols \
	py-pgsql py-psycopg py-psycopg2 py-pygresql \
	py-pudge py-pylons py-pyro py-quixote \
	py-rdiff-backup py-redis py-requests py-tornado \
	py-reportlab py-routes py-roundup py-ruledispatch \
	py-scgi py-selector py-serial py-setuptools \
	py-silvercity py-simplejson py-simpy py-slimit py-soappy \
	py-sqlalchemy py-sqlite py-sqlobject py-statlib \
	py-tailor py-tgfastdata py-trac py-urllib3 \
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
	asterisk11-chan-dongle \
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

OPENJDK_PACKAGES = \
	openjdk7 openjdk8 \
	bubbleupnpserver-installer

GCCGO_PACKAGES = \
	gotty \
	shell2http \

GOLANG_PACKAGES = \
	rclone \
	syncthing \

# libao - has runtime trouble?
COMMON_PACKAGES = \
	$(PACKAGES_REQUIRE_LINUX26) \
	6relayd 9base \
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
	bluez-libs bluez-utils bluez-hcidump \
	bluez2-libs bluez2-utils bvi \
	c-ares cabextract cacerts jre-cacerts cadaver cairo calc calcurse castget \
	catdoc ccollect ccrypt ccxstream cdargs \
	cdrtools centerim cuetools \
	cherokee chicken chillispot chromaprint chrpath cksfv \
	classpath clamav clearsilver climm clips cmake cmdftp collectd \
	confuse connect coreutils corkscrew cpio cppunit cpufrequtils cron cryptcat \
	cscope csync2 ctags ctcs ctorrent ctrlproxy \
	cups cups-filters cups-pdf cvs \
	cyrus-imapd cyrus-sasl \
	daemonize dansguardian dash davtools \
	dbus dbus-glib dbus-python \
	dcled dcraw delegate denyhosts dev-pts devio devmem2 dfu-util \
	dhcp dialog dict digitemp dircproxy distcc \
	diffstat diffutils discount \
	dmsetup dnscrypt-proxy dnsmasq dnstracer dokuwiki dos2unix dosfstools dovecot \
	dropbear dropbear-android drraw dspam dtach duktape dump \
	e2fsprogs e2tools eaccelerator easy-rsa ed ecl electric-fence elinks \
	elementary-xfce-icon-theme \
	emacs22 encfs endian enhanced-ctorrent enscript esmtp esniper \
	ettercap ettercap-ng \
	$(ERLANG_PACKAGES) \
	esound eggdrop eventlog exif exo expat extract-xiso ez-ipupdate \
	faad2 fake-hwclock fann fatresize fatsort fbcat fcgi fconfig \
	fdupes fetchmail ffmpeg ffmpegthumbnailer \
	ficy file finch findutils firedrill-httptunnel \
	fis fish fixesext flac flex flip \
	fontconfig \
	fossil-scm \
	freecell freeradius freetds freetype freeze \
	fribidi ftpcopy fslint ftpd-topfield fuppes fuse fuse-exfat \
	gambit-c gawk gcal gconv-modules gdb gdbm gdchart \
	ged gedit geoip gerbera gettext gdk-pixbuf \
	ggrab ghostscript ghostscript-fonts git gkrellmd glib glib-networking gnet gnokii gnome-icon-theme \
	gnome-icon-theme-symbolic \
	gnu-httptunnel gnu-smalltalk gnugo \
	gnupg1 gnupg gnuplot gnutls gpgme \
	gloox gobject-introspection golang $(GCCGO_PACKAGES) $(GOLANG_PACKAGES) gpsd \
	grep groff gsasl gsnmp gtmess gtypist gutenprint gzip \
	gphoto2 libgphoto2 \
	gift giftcurs gift-ares gift-fasttrack gift-gnutella \
	gift-openft gift-opennap gtk gtk2 gtksourceview gtksourceview2 gsettings-desktop-schemas \
	haproxy harfbuzz haserl hd2u hdparm hello hexcurse heyu \
	hiawatha hicolor-icon-theme hnb hping htop httping \
	ice icecast ices0 icu \
	id3lib ifstat iftop ii iksemel imagemagick imap \
	inadyn indent inetutils \
	inferno \
	ink inputproto \
	ipac-ng iperf ipkg-web iptables iptraf iputils-arping \
	ircd-hybrid irssi ivorbis-tools \
	jabberd jamvm jed jfsutils jikes jove joe \
	kamailio kbproto keychain kismet kissdx knock \
	lame launchtool lcd4linux ldconfig ldd lddtree leafnode less lftp lha \
	liba52 libacl libao libart libass libassuan libatomic-ops libbt libcap \
	libcapi20 libcdio libconfig libcroco libcurl \
	libdaemon libdb libdb52 libdlna \
	libdvb libdvbpsi libdvdnav libdvdread libdrm \
	libebml libexosip2 \
	libepoxy libevent \
	libesmtp libexif libexplain libfdk-aac libffi libftdi \
	libgc libgcrypt libgd libghttp libgmp libgpg-error libgssapi \
	libglade libhid \
	libical \
	libid3tag libidn libieee1284 libijs libinklevel libjansson libjbigkit libjpeg libjson-c \
	libksba liblcms liblcms2 libmaa libmad libmatroska libmediainfo libmemcache libmemcached libmicrohttpd \
	libmcrypt libmm $(strip $(if $(filter true, $(NO_LIBNSL)), , libnsl)) \
	libmms libmnl libmpc libmpcdec libmpdclient libmpeg2 libmpfr libmrss libmtp \
	libnetfilter-acct libnetfilter-conntrack libnetfilter-log libnetfilter-queue libnfnetlink libnettle libnl libnxml \
	libol libogg libosip2 libopensync libopenzwave libopus libotr libpam \
	libpar2 libpcap libpeas libpng libpth librsync librsvg \
	libsamplerate libserf libshout libsigc++ libsoup libsndfile libsodium libsoxr libstdc++ libgo \
	libtasn1 libtheora libtiff libtirpc libtool libtorrent \
	libubox libunistring libupnp libupnp6 libusb libusb1 libuv libvncserver \
	libvorbis libvorbisidec libwebsockets libxfce4ui libxfce4util libxkbcommon libxml2 libxslt libzen libzip \
	lighttpd lirc links2 linksys-tftp linphone littlesmalltalk llink \
	logrotate lookat loudmouth lrzsz lsof ltrace \
	lua luarocks lxappearance lxde-icon-theme \
	lynx lzo \
	m4 mac madplay make man man-pages mc mcabber md5deep mdadm \
	mediainfo mediatomb mediawiki meganz-sdk megatools memcached mesalib metalog memtester \
	mg miau microcom microdc2 microperl mimms \
	minicom minidlna minidlna-rescan minihttpd miniupnpd \
	mini-sendmail mini-snmpd \
	miscfiles mktemp mktorrent mlocate moblock \
	moc modutils monit most motif motion motor mousepad \
	mod-fastcgi moe moreutils mp3blaster mp3info mpack mpage \
	mpc mpd mpdscribble \
	mpg123 mplayer mpop mrtg msmtp \
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
	nmap nmon node node010 noip nostromo nrpe \
	ntfs-3g ntfsprogs \
	ntop ntp ntpclient nttcp nut nvi nylon nzbget nzbget-testing \
	ocaml oleo open2300 $(OPENJDK_PACKAGES) \
	openobex obexftp \
	opendchub openjpeg openldap opensips \
	openssl openssh sshfs sshguard openvpn oscam \
	optware-devel ossp-js oww owwlog \
	p7zip p910nd pal palantir pango parted \
	par2cmdline patch patchutils \
	pcal pcapsipdump pciutils pcre pcsc-lite pen perltgd $(PERL_PACKAGES) pinentry pixman \
	phoneme-advanced \
	php php-apache php-geoip php-imagick php-opcache php-thttpd php-memcached phpmyadmin \
	picocom picolisp pkgconfig plowshare poco polipo pop3proxy poppler \
	popt poptop portmap postgresql postfix pound powertop \
	ppower ppp printproto privoxy procmail \
	procps proftpd proxytunnel psmisc psutils pthread-stubs puppy pure-ftpd pv pwgen \
	python python24 python25 python26 python27 python3 $(PYTHON_PACKAGES) \
	qemacs qemu qemu-libc-i386 qpdf qpopper quagga quickie quilt \
	radiusclient-ng rc rc5pipe rcs rdate \
	readline re2c recode recordext recordprotos \
	redir renderext renderproto rhtvision rkhunter \
	rlfe rlwrap rox-filer rpcbind rrdcollect rrdtool \
	rssh rsstail rsync rtmpdump rtorrent rtpproxy ruby rubygems rxtx \
	sablevm samba samba2 samba34 samba35 samba36 sane-backends \
	scli scponly screen scrobby scsi-idle sd-idle sdl sdparm \
	sed sendmail ser ser2net setserial setpwc sg3-utils shared-mime-info \
	sharutils shellinabox shntool silc-client simh sipcalc siproxd sispmctl \
	slang slrn slsc \
	sm smartmontools smstools3 snort snownews \
	socat softethervpn softflowd sox spandsp spawn-fcgi speex speexdsp spindown splix \
	sqlite sqlite2 \
	sqsh squeak squid squid3 squeezelite \
	srelay srecord srtp ssam sslh sslwrap start-stop-daemon \
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
	ucl udev udns udpxy uemacs ulogd unarj uncia unfs3 unionfs-fuse units unixodbc \
	unrar unrtf \
	unzip up-imapproxy updatedd upslug2 \
	upx usb-modeswitch usbutils ushare utelnetd utf8proc util-linux \
	vblade vdr-mediamvp vim vitetris vlc \
	vnstat vorbis-tools vorbisgain vpnc vsftpd vte vtun \
	w3cam w3m wayland wakelan wavpack webalizer weechat werc wget \
	which whois wizd wpa-supplicant wput wxbase \
	xerces-c xmlrpc-c xmlstarlet \
	x11 xau xauth xaw xbitmaps compositeproto libxcomposite xcursor xdg-utils xdmcp xdpyinfo xext xdamage xinerama xineramaproto xshmfence \
	xextensions xfixes xfixesproto xft xi xinetd pciaccess \
	xmu xp xpdf xpm xcb-proto xcb xextproto xfconf xorg-macros xproto xrender xt xterm xtrans xtst \
	damageproto dri2proto dri3proto glproto presentproto \
	x264 xmail xupnpd xvid xz-utils \
	yafc yasm yawk yougrabber \
	zile zip zlib znc zoo zsh zsync \
	glibc-opt glibc-locale binutils libc-dev gcc ipkg-static \

# php-fcgi ipk is now built from php.mk

# libiconv - has been made obsolete by gconv-modules
# Metalog - has been made obsolete by syslog-ng
PACKAGES_OBSOLETED = cogito erl-escript libiconv metalog monotone \
	perl-spamassassin perl-mime-base64 jabber tzcode \

##############

HOST_MACHINE:=$(shell \
if test x86_64 = `uname -m` -a 32-bit = `file /sbin/init | awk '{print $$3}'`; then echo i386 ; else uname -m; fi \
| sed -e 's/i[3-9]86/i386/' )
HOST_OS:=$(shell uname)

# extract number of jobs passed through the command line
MAKE_JOBS:=$(shell \
ps T | grep "^\s*$(shell echo $$PPID).*$(MAKE)" | \
sed -e 's/--jobs=/--jobs /g' -e 's/--jobs/-j/g' -e 's/[ \t][\t ]*/ /g' -e 's/-j /-j/g' -n -e 's/.* -j\([^ ]*\).*/\1/p')

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

INSTALL = TARGET_PREFIX=$(TARGET_PREFIX) $(SHELL) $(BASE_DIR)/scripts/install.sh

PATCH = TARGET_PREFIX=$(TARGET_PREFIX) $(SHELL) $(BASE_DIR)/scripts/patch.sh

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

include $(OPTWARE_TOP)/platforms/packages-$(OPTWARE_TARGET).mk

ifeq ($(LIBC_STYLE), uclibc)
include $(OPTWARE_TOP)/platforms/packages-uclibc.mk
else
LIBC_STYLE=glibc
endif

PACKAGES = $(filter-out \
	$(BROKEN_PACKAGES) \
	, $(COMMON_PACKAGES) $(SPECIFIC_PACKAGES))

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
CREATE_CHECKSUM=0
ifeq ($(CREATE_CHECKSUM), 1)
WGET = TOP=$(BASE_DIR)/scripts WGET=$(WGET_BINARY) CREATE_CHECKSUM=1 $(SHELL) $(BASE_DIR)/scripts/wget.sh --passive-ftp --tries=2 --no-check-certificate
else
WGET = TOP=$(BASE_DIR)/scripts WGET=$(WGET_BINARY) $(SHELL) $(BASE_DIR)/scripts/wget.sh --passive-ftp --tries=2 --no-check-certificate
endif
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
		$(SHELL) $(BASE_DIR)/scripts/aclocal.sh
ACLOCAL1.14_SH= TOP=$(BASE_DIR) ACLOCAL=$(HOST_STAGING_PREFIX)/bin/aclocal-1.14 \
		$(SHELL) $(BASE_DIR)/scripts/aclocal.sh
ACLOCAL1.10_SH= TOP=$(BASE_DIR) ACLOCAL=$(HOST_STAGING_PREFIX)/bin/aclocal-1.10 \
		$(SHELL) $(BASE_DIR)/scripts/aclocal.sh
ACLOCAL1.9_SH= TOP=$(BASE_DIR) ACLOCAL=$(HOST_STAGING_PREFIX)/bin/aclocal-1.9 \
		$(SHELL) $(BASE_DIR)/scripts/aclocal.sh
ACLOCAL1.4_SH= TOP=$(BASE_DIR) ACLOCAL=$(HOST_STAGING_PREFIX)/bin/aclocal-1.4 \
		$(SHELL) $(BASE_DIR)/scripts/aclocal.sh


# These should be called instead of `autoreconf`
AUTORECONF1.15 = (cd $(BASE_DIR) && $(HOST_TOOL_AUTOMAKE)) && \
	mkdir -p $(STAGING_PREFIX)/share/aclocal && \
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
	mkdir -p $(STAGING_PREFIX)/share/aclocal && \
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
	mkdir -p $(STAGING_PREFIX)/share/aclocal && \
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
	mkdir -p $(STAGING_PREFIX)/share/aclocal && \
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
	mkdir -p $(STAGING_PREFIX)/share/aclocal && \
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
#SOURCES_NLO_SITE=http://ftp.osuosl.org/pub/nslu2/sources
SOURCES_NLO_SITE=http://ipkg.nslu2-linux.org/sources

# FreeBSD distfiles site
FREEBSD_DISTFILES=ftp://ftp.fi.freebsd.org/pub/FreeBSD/ports/distfiles

# Perl CPAN mirror:
# use this instead of search.cpan.org, since search.cpan.org
# contains only recent versions
PERL_CPAN_SITE=ftp.auckland.ac.nz

TARGET_CXX=$(TARGET_CROSS)g++
TARGET_CC=$(TARGET_CROSS)gcc
TARGET_GCCGO=$(TARGET_CROSS)gccgo
TARGET_CPP="$(TARGET_CC) -E"
TARGET_LD=$(TARGET_CROSS)ld
TARGET_AR=$(TARGET_CROSS)ar
TARGET_AS=$(TARGET_CROSS)as
TARGET_NM=$(TARGET_CROSS)nm
TARGET_OBJDUMP=$(TARGET_CROSS)objdump
TARGET_RANLIB=$(TARGET_CROSS)ranlib
TARGET_READELF=$(TARGET_CROSS)readelf
TARGET_STRIP?=$(TARGET_CROSS)strip

TARGET_CONFIGURE_OPTS= \
	AR=$(TARGET_AR) \
	AS=$(TARGET_AS) \
	LD=$(TARGET_LD) \
	NM=$(TARGET_NM) \
	OBJDUMP=$(TARGET_OBJDUMP) \
	CC=$(TARGET_CC) \
	CPP=$(TARGET_CPP) \
	GCC=$(TARGET_CC) \
	CXX=$(TARGET_CXX) \
	RANLIB=$(TARGET_RANLIB) \
	STRIP=$(TARGET_STRIP) \
	PKG_CONFIG=$(OPTWARE_TOP)/scripts/pkg-config.sh

CMAKE_CONFIGURE_OPTS= \
	-DCMAKE_VERBOSE_MAKEFILE=TRUE \
	-DCMAKE_SYSTEM_NAME=Linux \
	-DCMAKE_SYSTEM_VERSION=1 \
	-DCMAKE_CROSSCOMPILING=1 \
	-DCMAKE_SYSTEM_PROCESSOR=$(TARGET_ARCH) \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_FLAGS_RELEASE="-DNDEBUG" \
	-DCMAKE_CXX_FLAGS_RELEASE="-DNDEBUG" \
	-DCMAKE_C_COMPILER="$(TARGET_CC)" \
	-DCMAKE_C_COMPILER_ARG1="" \
	-DCMAKE_CXX_COMPILER="$(TARGET_CXX)" \
	-DCMAKE_CXX_COMPILER_ARG1="" \
	-DCMAKE_ASM_COMPILER="$(TARGET_CC)" \
	-DCMAKE_ASM_COMPILER_ARG1="" \
	-DCMAKE_AR=$(TARGET_AR) \
	-DCMAKE_NM=$(TARGET_NM) \
	-DCMAKE_RANLIB=$(TARGET_RUNLIB) \
	-DPKG_CONFIG_EXECUTABLE=$(OPTWARE_TOP)/scripts/pkg-config.sh \
	-DCMAKE_FIND_ROOT_PATH="$(STAGING_PREFIX);$(TARGET_CROSS_TOP)" \
	-DCMAKE_LIBRARY_PATH=$(STAGING_LIB_DIR) \
	-DCMAKE_INCLUDE_PATH=$(STAGING_INCLUDE_DIR) \
	-DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
	-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
	-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
	-DCMAKE_STRIP=: \
	-DCMAKE_INSTALL_PREFIX=$(TARGET_PREFIX) \
	-DDL_LIBRARY=$(STAGING_DIR) \
	-DCMAKE_PREFIX_PATH=$(STAGING_DIR) \
	-DCMAKE_SKIP_RPATH=TRUE

TARGET_GOARCH=$(strip \
$(if $(filter buildroot-armeabi-ng buildroot-armeabihf buildroot-armv5eabi-ng buildroot-armv5eabi-ng-legacy, $(OPTWARE_TARGET)), arm, \
$(if $(filter buildroot-i686, $(OPTWARE_TARGET)), 386, \
$(if $(filter buildroot-mipsel-ng, $(OPTWARE_TARGET)), mipsle, \
$(if $(filter buildroot-ppc-603e ct-ng-ppc-e500v2, $(OPTWARE_TARGET)), ppc, \
$(if $(filter buildroot-x86_64, $(OPTWARE_TARGET)), amd64, \
$(TARGET_ARCH)))))))

CROSS_GCCGO_GOROOT ?= $(TARGET_CROSS_TOP)/$(EXACT_TARGET_NAME)

TARGET_GCCGO_GO_ENV= \
	GCCGO=$(TARGET_GCCGO) \
	GOROOT=$(CROSS_GCCGO_GOROOT) \
	GOARCH=$(TARGET_GOARCH) \
	CC=$(TARGET_CC) \
	CXX=$(TARGET_CXX)

TARGET_PATH=$(STAGING_PREFIX)/bin:$(STAGING_DIR)/bin:$(TARGET_PREFIX)/bin:$(TARGET_PREFIX)/sbin:/bin:/sbin:/usr/bin:/usr/sbin

STRIP_COMMAND ?= $(TARGET_STRIP) --remove-section=.comment --remove-section=.note --strip-unneeded

PATCH_LIBTOOL=$(SHELL) $(OPTWARE_TOP)/scripts/patch_libtool.sh -i \
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

boost-packages: $(BOOST_PACKAGES)

boost-packages-ipk: $(patsubst %, %-ipk, $(BOOST_PACKAGES))

boost-packages-dirclean: $(patsubst %, %-dirclean, $(BOOST_PACKAGES))

boost-packages-check: $(patsubst %, %-check, $(BOOST_PACKAGES))

test-build:
	rm -f builds/failed.log
ifneq ($(MAKE_JOBS), )
	for package in $(PACKAGES); do \
		$(MAKE) $${package}-ipk -j$(MAKE_JOBS) || (echo "$${package}" >> builds/failed.log); \
	done
else
	for package in $(PACKAGES); do \
		$(MAKE) $${package}-ipk || (echo "$${package}" >> builds/failed.log); \
	done
endif

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
ifneq ($(MAKE_JOBS), )
	$(MAKE) index -j$(MAKE_JOBS)
else
	$(MAKE) index
endif

package-only: $(PACKAGES_IPKG)

.PHONY: all clean dirclean distclean directories packages source toolchain \
	buildroot-toolchain libuclibc++-toolchain \
	autoclean \
	check-dependencies \
	$(PACKAGES) $(PACKAGES_SOURCE) $(PACKAGES_DIRCLEAN) \
	$(PACKAGES_STAGE) $(PACKAGES_IPKG) \
	query-%

query-%:
	@echo $($(*))

TARGET_CC_VER = $(shell test -x "$(TARGET_CC)" && $(TARGET_CC) -dumpversion)

include $(shell ls make/*.mk)

.NOTPARALLEL: %/.configured %/.built %/.staged %.ipk %/.packaged

directories: $(DL_DIR) $(BUILD_DIR) $(STAGING_DIR) $(STAGING_PREFIX) \
	$(STAGING_LIB_DIR) $(STAGING_INCLUDE_DIR) $(TOOL_BUILD_DIR) \
	$(PACKAGE_DIR) $(TMPDIR) $(STAGING_PREFIX)/lib64

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

$(STAGING_PREFIX)/lib64:
	ln -sf lib $(STAGING_PREFIX)/lib64

source: $(PACKAGES_SOURCE)

check-packages:
	@$(PERL) -w scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) --objdump-path=$(TARGET_CROSS)objdump --base-dir=$(BASE_DIR) $(filter-out $(BUILD_DIR)/crosstool-native-%,$(wildcard $(BUILD_DIR)/*.ipk))

check-dependencies:
	@rm -rf test
	@mkdir test
	@READELF=$(TARGET_READELF) PACKAGESDIR=packages TEST=test scripts/dependencies_check.sh

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

ifneq ($(DEFAULT_TARGET_PREFIX), $(TARGET_PREFIX))
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
else
%-target %/.configured:
	[ -e ${DL_DIR} ] || mkdir -p ${DL_DIR}
	[ -e $*/Makefile ] || ( \
		mkdir -p $* ; \
		cd $* ; \
		echo "OPTWARE_TARGET=$*" > Makefile ; \
		echo "include ../Makefile" >> Makefile ; \
		ln -s ../downloads downloads ; \
		ln -s ../make make ; \
		ln -s ../scripts scripts ; \
		ln -s ../sources sources ; \
	)
	touch $*/.configured
endif


make/%.mk:
	PKG_UP=$$(echo $* | tr [a-z\-] [A-Z_]);			\
	sed -e "s/<foo>/$*/g" -e "s/<FOO>/$${PKG_UP}/g"		\
		 -e '6,11d' make/template.mk > $@

ifeq ($(OPTWARE_TOP), $(BASE_DIR))

# Use this to build *all* feeds (all targets from `cat Optware_targets_list`)

OPTWARE_BUILD_TARGETS:=$(shell echo `cat Optware_targets_list`)

ifneq ($(DEFAULT_TARGET_PREFIX), $(TARGET_PREFIX))
%/.configured:
	[ -e ${DL_DIR} ] || mkdir -p ${DL_DIR}
	[ -e $*/Makefile ] || ( \
		mkdir -p $* ; \
		cd $* ; \
		echo "OPTWARE_TARGET=$*" > Makefile ; \
		echo "include ../Makefile" >> Makefile ; \
		ln -s ../downloads downloads ; \
		ln -s ../make make ; \
		ln -s ../scripts scripts ; \
		ln -s ../sources sources ; \
	)
	touch $*/.configured
endif

%-feed: %/.configured
ifneq ($(MAKE_JOBS), )
	$(MAKE) -C $* directories -j$(MAKE_JOBS)
	$(MAKE) -C $* host/.configured -j$(MAKE_JOBS)
	$(MAKE) -C $* ipkg-utils -j$(MAKE_JOBS)
	$(MAKE) -C $* toolchain -j$(MAKE_JOBS)
	$(MAKE) -C $* packages -j$(MAKE_JOBS)
else
	$(MAKE) -C $* directories
	$(MAKE) -C $* host/.configured
	$(MAKE) -C $* ipkg-utils
	$(MAKE) -C $* toolchain
	$(MAKE) -C $* packages
endif

%-feed-build: %/.configured
ifneq ($(MAKE_JOBS), )
	$(MAKE) -C $* directories -j$(MAKE_JOBS)
	$(MAKE) -C $* host/.configured -j$(MAKE_JOBS)
	$(MAKE) -C $* ipkg-utils -j$(MAKE_JOBS)
	$(MAKE) -C $* toolchain -j$(MAKE_JOBS)
	$(MAKE) -C $* package-only -j$(MAKE_JOBS)
else
	$(MAKE) -C $* directories
	$(MAKE) -C $* host/.configured
	$(MAKE) -C $* ipkg-utils
	$(MAKE) -C $* toolchain
	$(MAKE) -C $* package-only
endif

%-feed-test-build: %/.configured
ifneq ($(MAKE_JOBS), )
	$(MAKE) -C $* directories -j$(MAKE_JOBS)
	$(MAKE) -C $* host/.configured -j$(MAKE_JOBS)
	$(MAKE) -C $* ipkg-utils -j$(MAKE_JOBS)
	$(MAKE) -C $* toolchain -j$(MAKE_JOBS)
	$(MAKE) -C $* test-build -j$(MAKE_JOBS)
else
	$(MAKE) -C $* directories
	$(MAKE) -C $* host/.configured
	$(MAKE) -C $* ipkg-utils
	$(MAKE) -C $* toolchain
	$(MAKE) -C $* test-build
endif

allfeeds: $(patsubst %,%-feed,$(OPTWARE_BUILD_TARGETS))

endif

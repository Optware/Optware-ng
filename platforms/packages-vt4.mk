# Packages that *only* work for vt4 - do not just put new packages here.
SPECIFIC_PACKAGES = \
	vt4-optware-bootstrap \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \
	vt4-kernel-modules \

# Packages that do not work for vt4.
BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	$(ERLANG_PACKAGES) \
	amule aria2 aspell \
	asterisk14 asterisk14-chan-capi \
	asterisk16 asterisk16-addons \
	atftp avahi \
	bacula bitlbee boost bsdgames btg btpd bzflag \
	centerim climm \
	castget cdargs cherokee clamav clinkcc cryptcat \
	ctorrent ctrlproxy cups \
	dansguardian dspam \
	emacs22 enhanced-ctorrent esniper \
	ficy finch firedrill-httptunnel flip freeradius fuppes \
	ggrab ghostscript gloox gnokii gnupg1 gnupg \
	gnet gsnmp \
	gnuplot gnutls gtk gutenprint \
	hplip \
	icecast icu id3lib iksemel imagemagick \
	iotop iptraf ivorbis-tools \
	jabberd jikes \
	kismet \
	launchtool ldconfig lftp liba52 libbt libcapi20 libcdio \
	libdvb libextractor libmrss libnxml libopensync \
	libpar2 libsigc++ libsoup libsndfile libstdc++ libtiff \
	libtorrent libtorrent-rasterbar \
	libebml libmatroska mkvtoolnix \
	llink loudmouth \
	mcabber \
	mediatomb mimms minidlna moc motion mod-fastcgi moe \
	mp3blaster mpd mpdscribble mpop msmtp msynctool \
	mod-python mod-wsgi \
	motor \
	newsbeuter nget nmap nload nzbget nzbget-testing \
	open2300 openldap obexftp openser oww \
	p7zip p910nd par2cmdline pcapsipdump \
	picolisp player puppy py-mysql \
	qemu quickie \
	re2c rhtvision rsstail rtorrent \
	sablevm \
	samba samba34 samba35 \
	sandbox sane-backends \
	scli scrobby \
	simh smartmontools snort \
	spandsp splix sqsh srecord swi-prolog \
	subvertpy svn bzr-svn \
	swig \
	taglib tesseract-ocr tshark transcode \
	ulogd uncia unrar upslug2 upx \
	vlc vnstat vorbis-tools vte \
	weechat wget wput wxbase \
	xerces-c xmlrpc-c xchat \
	yougrabber \
	perl-net-dns perl-unix-syslog \

DBUS_NO_DAEMON_LDFLAGS := 1

E2FSPROGS_VERSION = 1.41.1
E2FSPROGS_IPK_VERSION = 1

LINPHONE_LDFLAGS := -lpthread -lresolv -lrt

MYSQL5_CONFIG_ENV_EXTRA := ac_cv_func_fesetround=no

NE_VERSION := 2.0.2
NE_IPK_VERSION := 1

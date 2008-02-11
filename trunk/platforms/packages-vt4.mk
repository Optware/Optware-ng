# Packages that *only* work for vt4 - do not just put new packages here.
SPECIFIC_PACKAGES = \
	vt4-optware-bootstrap \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

# Packages that do not work for vt4.
BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	amule apache aspell asterisk asterisk14 asterisk14-chan-capi \
	atftp avahi \
	bitlbee bsdgames btpd bzflag \
	castget cdargs cherokee chillispot clamav ctorrent ctrlproxy cups \
	dansguardian dspam \
	emacs22 enhanced-ctorrent esniper erlang erl-yaws \
	ficy finch firedrill-httptunnel flac flip freeradius fuppes \
	gconv-modules ggrab ghostscript gnokii gnupg \
	gnuplot gnutls gtk gutenprint \
	hplip \
	icecast id3lib iksemel imagemagick iptraf ivorbis-tools \
	jabberd jikes \
	kismet \
	launchtool ldconfig lftp liba52 libbt libcapi20 libcdio \
	libdvb libextractor libmrss libnsl libnxml libopensync \
	libpar2 libsigc++ libsoup libsndfile libstdc++ libtiff libtorrent \
	loudmouth \
	mediatomb moc motion mod-fastcgi moe \
	monotone mp3blaster mpd mpdscribble mpop msmtp msynctool \
	mysql mysql-connector-odbc mod-python mod-wsgi \
	newsbeuter nget nmap nload nzbget \
	open2300 openldap obexftp openser oww \
	p7zip par2cmdline pcapsipdump php-apache \
	picolisp player postfix puppy py-mysql \
	qemu quickie \
	re2c rhtvision rsstail rtorrent \
	sablevm samba sane-backends simh snort spandsp \
	swi-prolog svn \
	taglib tshark transcode \
	unrar upslug2 upx \
	vlc vnstat vorbis-tools vte \
	weechat wget wput wxbase \
	xmlrpc-c xchat \
	yougrabber \
	perl-dbd-mysql perl-net-dns perl-unix-syslog slimserver \

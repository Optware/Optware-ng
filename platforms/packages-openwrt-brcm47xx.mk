SPECIFIC_PACKAGES = \
	libiconv \
	$(UCLIBC_SPECIFIC_PACKAGES) \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \
	$(UCLIBC++_SPECIFIC_PACKAGES) \


BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	$(UCLIBC++_BROKEN_PACKAGES) \
	$(UCLIBC_BROKEN_PACKAGES) \
	boost \
	buildroot uclibc-opt \
	lm-sensors module-init-tools \
	$(BROKEN_PACKAGES_REPORT_ACHILLES) \


PERL_MAJOR_VER=5.10
JAMVM_VERSION = 1.5.1
JAMVM_IPK_VERSION = 1


# TODO upgrade: phpmyadmin lynx (upgrade), py-codeville (site broken), perl-assp (difficult upgrade)
# perl-bit-vector perl-business-isbn-data  perl-business-isbn perl-carp-clan perl-class-accessor
# perl-class-dbi perl-date-calc perl-date-manip perl-email-mime perl-email-send perl-*...
#
# TODO: remove system kerberos detect (/usr/include/krb5.h) for samba et al.
# for f in $(make query-BROKEN_PACKAGES_REPORT);do make $f-dirclean;done

BROKEN_PACKAGES_REPORT_ACHILLES = \
	dump e2fsprogs e2tools libtheora pinentry ppp py-mx-base py-psycopg py-pygresql ulogd \
	amule aspell bacula bsdgames busybox \
	calc castget centerim clinkcc confuse cpio cyrus-imapd \
	distcc dspam erl-ejabberd fuppes gambit-c gcal git \
         gloox grep gtmess id3lib inetutils inferno ipac-ng \
         libdvb libmad libnsl libopensync ltrace madplay mediatomb \
         minidlna moc motor mpd msynctool mt-daapd newt \
         nget ntp obexftp openser phoneme-advanced picolisp postfix \
         puppy bzr bzr-rewrite bzrtools dstat getmail gitosis \
         hellanzb iotop ipython mailman pssh putmail pyrex \
         sabnzbd stgit py-4suite py-amara py-beaker py-bittorrent py-boto \
         py-buildutils py-celementtree py-cheetah py-cherrypy py-cherrytemplate py-cjson py-clips \
         py-codeville py-configobj py-constraint py-crypto py-curl py-decorator py-decoratortools \
         py-django py-docutils py-duplicity py-elementtree py-feedparser py-flup py-formencode \
         py-genshi py-gnosis-utils py-hgsubversion py-hgsvn py-kid py-lepl py-lxml \
         py-mako py-markdown py-mercurial py-moin py-mysql py-myghty py-myghtyutils \
         py-nose py-openssl py-paramiko py-paste py-pastedeploy py-pastescript py-pastewebkit \
         py-pexpect py-pil py-ply py-protocols py-psycopg2 py-pudge py-pylons \
         py-pyro py-quixote py-reportlab py-routes py-roundup py-ruledispatch py-selector \
         py-setuptools py-silvercity py-simplejson py-simpy py-soappy py-sqlalchemy py-sqlite \
         py-sqlobject py-tailor py-tgfastdata py-trac py-turbocheetah py-turbogears py-turbojson \
         py-turbokid py-urwid py-usb py-weatherget py-webpy py-wsgiref py-webhelpers \
         py-xml py-yaml py-yenc py-zope-interface py-twisted py-axiom py-epsilon \
         py-mantissa py-nevow quagga recode rhtvision sablevm samba35 \
         sandbox sox streamripper taglib textutils tinyscheme tnftp \
         updatedd util-linux util-linux-ng vlc weechat x264 perl-bit-vector \
         perl-business-isbn-data perl-business-isbn perl-carp-clan perl-date-calc \
	 perl-date-manip perl-email-mime perl-email-send \
         perl-html-parser perl-libwww perl-term-readline-gnu perl-timedate perlbal spamassassin

BROKEN_PACKAGES_REPORT_DUO = \
         amule appweb apache aspell bacula \
         bsdgames bsdmainutils busybox bluez-utils calc castget ccollect \
         centerim clinkcc confuse cpio cyrus-imapd dcraw distcc \
         dspam eaccelerator ecl ettercap-ng erl-ejabberd esound ffmpeg \
         fuppes gambit-c gcal git gloox golang grep \
         gtmess gift-ares gift-opennap id3lib inetutils inferno \
         ipac-ng ivorbis-tools jove libao libcdio libdlna libdvb \
         libmad libmpdclient libnsl libopensync logrotate ltrace madplay \
         mc mdadm mediatomb memtester minidlna moc motion \
         motor mod-fastcgi mpc mpd mpdscribble msynctool mt-daapd \
         mt-daapd-svn ncmpc netatalk newt nget ntop ntp \
         obexftp openser phoneme-advanced php php-apache php-fcgi php-thttpd \
         phpmyadmin picolisp pkgconfig postfix puppy bzr bzr-rewrite \
         bzrtools dstat getmail gitosis hellanzb iotop ipython \
         mailman mod-python mod-wsgi pssh putmail pyrex sabnzbd \
         stgit subvertpy py-4suite py-amara py-beaker py-bittorrent py-boto \
         py-buildutils py-celementtree py-cheetah py-cherrypy py-cherrytemplate py-cjson py-clips \
         py-codeville py-configobj py-constraint py-crypto py-curl py-decorator py-decoratortools \
         py-django py-docutils py-duplicity py-elementtree py-feedparser py-flup py-formencode \
         py-genshi py-gnosis-utils py-hgsubversion py-hgsvn py-kid py-lepl py-lxml \
         py-mako py-markdown py-mercurial py-moin py-mysql py-myghty py-myghtyutils \
         py-nose py-openssl py-paramiko py-paste py-pastedeploy py-pastescript py-pastewebkit \
         py-pexpect py-pil py-ply py-protocols py-psycopg2 py-pudge py-pylons \
         py-pyro py-quixote py-reportlab py-routes py-roundup py-ruledispatch py-selector \
         py-setuptools py-silvercity py-simplejson py-simpy py-soappy py-sqlalchemy py-sqlite \
         py-sqlobject py-tailor py-tgfastdata py-trac py-turbocheetah py-turbogears py-turbojson \
         py-turbokid py-urwid py-usb py-weatherget py-webpy py-wsgiref py-webhelpers \
         py-xml py-yaml py-yenc py-zope-interface py-twisted py-axiom py-epsilon \
         py-mantissa py-nevow quagga recode rhtvision rtorrent ruby \
         rubygems rxtx sablevm samba35 sandbox sendmail sox \
         squeak streamripper taglib textutils tinyscheme tnftp \
         transcode updatedd ushare util-linux util-linux-ng vlc vorbis-tools \
         w3m weechat xerces-c x264 xvid perl-assp perl-bit-vector \
         perl-business-isbn-data perl-business-isbn perl-carp-clan \
	 perl-class-accessor perl-class-dbi perl-date-calc perl-date-manip \
         perl-digest-hmac perl-digest-sha1 perl-email-mime perl-email-send \
	 perl-html-parser perl-io-socket-ssl perl-lexical-persistence \
         perl-libwww perl-module-refresh perl-net-dns perl-term-readline-gnu \
	 perl-timedate perl-unix-syslog perl-uri  perlbal spamassassin

BAD =$(filter-out $(UCLIBC_BROKEN_PACKAGES), $(BROKEN_PACKAGES))
GOOD=$(filter-out  $(BROKEN_PACKAGES), $(UCLIBC_BROKEN_PACKAGES))
BROKEN_PACKAGES = bluez-hcidump xinetd libdb\
	 9base abook adduser adns amule analog appweb \
	 apache apr apr-util arping arpwatch \
	 atftp atop avahi \
	 bash bftpd bind bip bison bitchx bsdgames \
	 bsdmainutils btpd busybox byrequest bzflag bzip2 bluez-utils \
	 bluez2-utils cairo calc calcurse castget ccxstream cdargs \
	 cherokee chicken chillispot chrpath cksfv clamav clearsilver \
	 clips coreutils cscope ctorrent ctrlproxy cups cyrus-imapd \
	 cyrus-sasl dansguardian dash davtools dcraw dfu-util dialog \
	 dict digitemp dhcp dmsetup dosfstools dovecot dspam \
	 dump e2fsprogs e2tools eaccelerator ecl elinks emacs22 \
	 enhanced-ctorrent esmtp esniper erlang erl-yaws eggdrop extract-xiso \
	 fcgi fetchmail ffmpeg ficy finch findutils firedrill-httptunnel \
	 fish fixesext freecell freeradius freetds ftpcopy ftpd-topfield \
	 fuppes gambit-c gawk gcal gdb gdchart ggrab \
	 ghostscript git gnokii gnu-smalltalk gnugo gnupg gnuplot \
	 gpsd grep gtmess gtk gutenprint gphoto2 libgphoto2 \
	 gift giftcurs gift-ares gift-fasttrack gift-gnutella gift-openft gift-opennap \
	 haproxy haserl hdparm hexcurse heyu hnb hpijs \
	 hping htop httping ice icecast iftop ii \
	 imagemagick imap inetutils ipac-ng iptables iptraf ircd-hybrid \
	 irssi ivorbis-tools jabberd jamvm jed jove joe \
	 kismet kissdx knock lame launchtool lcd4linux ldconfig \
	 leafnode less lftp liba52 libbt libcapi20 libcdio \
	 libcurl libdlna libdvb libdvdnav libdvdread libesmtp libextractor \
	 libftdi libgc libgd libjpeg libmrss libmtp libnetfilter-queue \
	 libnfnetlink libnsl libnxml libopensync libpar2 libpcap librsync \
	 libsigc++ libsoup libsndfile libstdc++ libtiff libtorrent libupnp \
	 libusb libvncserver libxml2 libxslt lighttpd lirc littlesmalltalk \
	 lookat lsof ltrace lua luarocks lynx m4 \
	 mc mcabber md5deep mdadm mediatomb memcached metalog \
	 memtester mg mimms minicom mlocate moblock moc \
	 modutils monit most motion mod-fastcgi moe \
	 mp3blaster mpd mpdscribble mpop mrtg msmtp msort \
	 msynctool mt-daapd mtr multitail mutt mysql mysql-connector-odbc \
	 nagios-plugins nail nano ncdu ncftp ncmpc ncurses \
	 ncursesw nd ne nemesis neon net-snmp netatalk \
	 nethack newsbeuter newt nfs-server nfs-utils nget nginx \
	 ngrep nickle ninvaders nmap nload nrpe ntop \
	 ntp ntpclient nut nvi nzbget ocaml oleo \
	 open2300 obexftp openldap openser openssh openssl openvpn \
	 ossp-js oww pal p7zip palantir pango par2cmdline \
	 pcapsipdump pciutils pcre phoneme-advanced php php-apache php-fcgi \
	 php-thttpd picocom picolisp pkgconfig player polipo poptop \
	 portmap postgresql postfix pound privoxy procps proftpd \
	 proxytunnel psmisc puppy pure-ftpd python24 python25 getmail \
	 hellanzb hplip ipython mailman mod-python mod-wsgi putmail \
	 pyrex sabnzbd scons py-4suite py-amara py-apsw py-bazaar-ng \
	 py-beaker py-bittorrent py-bluez py-buildutils py-celementtree py-cheetah py-cherrypy \
	 py-cjson py-clips py-codeville py-configobj py-constraint py-crypto py-curl \
	 py-decorator py-decoratortools py-django py-docutils py-duplicity py-elementtree py-flup \
	 py-formencode py-gdchart2 py-gd py-genshi py-gnosis-utils py-hgsvn py-kid \
	 py-lxml py-mako py-markdown py-mercurial py-moin py-mssql py-mx-base \
	 py-mysql py-myghty py-myghtyutils py-nose py-openssl py-paste py-pastedeploy \
	 py-pastescript py-pastewebkit py-pexpect py-pil py-ply py-protocols py-pgsql \
	 py-psycopg py-psycopg2 py-pygresql py-pudge py-pylons py-pyro py-quixote \
	 py-rdiff-backup py-reportlab py-routes py-roundup py-ruledispatch py-scgi py-selector \
	 py-setuptools py-silvercity py-simplejson py-simpy py-sqlalchemy py-sqlite py-sqlobject \
	 py-tailor py-tgfastdata py-trac py-turbocheetah py-turbogears py-turbojson py-turbokid \
	 py-urwid py-usb py-weatherget py-webpy py-wsgiref py-webhelpers py-xml \
	 py-yaml py-yenc py-zope-interface py-twisted py-axiom py-epsilon py-mantissa \
	 py-nevow qemacs qemu qemu-libc-i386 quagga quickie re2c \
	 renderext rhtvision rlfe rlwrap rrdcollect rssh rsstail \
	 rtorrent rtpproxy ruby sablevm samba samba2 sane-backends \
	 scli screen scsi-idle sdl sdparm sendmail ser \
	 simh slang slrn sm smartmontools snort snownews \
	 socat softflowd spandsp spindown sqlite sqlite2 sqsh \
	 srelay sslwrap strace stunnel streamripper swi-prolog svn \
	 syslog-ng syx taged tcl tcpwrappers tcpdump tcpflow \
	 tcsh texinfo tig tin tinyscheme tmsnc tnftpd \
	 tor torrentflux transcode transmission tree trickle tshark tsocks \
	 tz uemacs unfs3 unixodbc unrar unzip up-imapproxy \
	 updatedd upslug2 upx usbutils ushare utf8proc util-linux \
	 util-linux-ng vblade vdr-mediamvp vim vlc vnstat vorbis-tools \
	 vsftpd vte vtun w3cam w3m webalizer weechat \
	 wget wizd wpa-supplicant wxbase xmlrpc-c x11 xauth \
	 xaw xchat xcursor xdpyinfo xext xfixes xft \
	 xmu xpm xrender xt xterm xtst x264 \
	 xmail xvid yafc yougrabber zile zsh

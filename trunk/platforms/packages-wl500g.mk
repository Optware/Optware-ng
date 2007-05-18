# Packages that *only* work for wl500g - do not just put new packages here.
SPECIFIC_PACKAGES = wiley-feeds libuclibc++ libiconv firmware-oleg

# Packages that do not work for wl500g.
BROKEN_PACKAGES = \
	 amule \
	$(ASTERISK_PACKAGES) \
	 atk avahi bitlbee bsdmainutils bzflag \
	 calc chicken coreutils ctrlproxy \
	 dansguardian dcraw dnsmasq dump \
	 ecl elinks \
	$(ERLANG_PACKAGES) \
	 fcgi ficy fish freetds gambit-c gawk \
	 giftcurs git-core gnokii gnupg gphoto2 ggrab libgphoto2 hnb htop ice \
	 glib gtk gnet gsnmp \
	 id3lib iperf iptables irssi jabberd jamvm jikes \
	 launchtool ldconfig lftp \
	 libcdio libdaemon libdvb libftdi libidn liblcms \
	 libmtp libopensync libtorrent \
	 loudmouth \
	 ltrace \
	 mc mcabber mdadm minicom mod-fastcgi mod-python \
	 monotone msynctool mtr mutt \
	 ncmpc ncursesw netatalk nfs-server nfs-utils nget ntfsprogs ntp nvi \
	 nylon obexftp openldap openser \
	 p7zip pango pcapsipdump postfix psmisc py-mssql \
	 qemu qemu-libc-i386 quickie rtorrent rtpproxy \
	 sablevm scli scponly sdl ser sm snort snownews sqsh swi-prolog \
	 taglib tcsh tethereal tnftpd transcode \
	 uemacs unrar \
	 varnish vlc vte \
	 w3m weechat wget wget-ssl wxbase x11 \
	 xauth xaw xchat xcursor xdpyinfo xext xfixes \
	 xft xmu xpm xrender xt xterm xtst zsh \


# Packages that *only* work for wl500g - do not just put new packages here.
SPECIFIC_PACKAGES = wiley-feeds libuclibc++ libiconv firmware-oleg

# Packages that do not work for wl500g.
BROKEN_PACKAGES = \
	 $(UCLIBC_BROKEN_PACKAGES) \
	 amule \
	$(ASTERISK_PACKAGES) \
	 atk avahi bitlbee bsdmainutils \
	 calc chicken coreutils ctrlproxy \
	 dansguardian dcraw dnsmasq dump \
	 ecl elinks \
	$(ERLANG_PACKAGES) \
	 ficy freetds gambit-c gawk \
	 giftcurs git-core gnokii gnupg gphoto2 ggrab libgphoto2 hnb htop ice \
	 glib gnet gsnmp \
	 id3lib iperf irssi jikes \
	 lftp \
	 libcdio libdaemon libdvb libftdi libidn liblcms \
	 libmtp libopensync libtorrent \
	 loudmouth \
	 ltrace \
	 mc mcabber mdadm minicom mod-fastcgi mod-python \
	 msynctool mutt \
	 ncmpc ncursesw netatalk nget ntfsprogs ntp nvi \
	 nylon obexftp openldap openser \
	 p7zip pcapsipdump postfix psmisc py-mssql \
	 rtorrent rtpproxy \
	 sablevm scli scponly sdl ser snort snownews sqsh swi-prolog \
	 tcsh tethereal tnftpd transcode \
	 unrar \
	 varnish vlc \
	 w3m weechat wget wget-ssl wxbase x11 \
	 xdpyinfo xext \
	 xpm xtst zsh \


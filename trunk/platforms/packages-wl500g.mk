# Packages that *only* work for wl500g - do not just put new packages here.
SPECIFIC_PACKAGES = wiley-feeds libuclibc++ libiconv firmware-oleg

# Packages that do not work for wl500g.
BROKEN_PACKAGES = \
	 $(UCLIBC_BROKEN_PACKAGES) \
	 amule \
	$(ASTERISK_PACKAGES) \
	 atk avahi bitlbee bsdgames bsdmainutils btpd \
	boost \
	 cairo \
	 calc castget chicken coreutils ctrlproxy \
	 dansguardian dcraw dnsmasq dump \
	 ecl elinks emacs22 \
	$(ERLANG_PACKAGES) \
	 ficy finch freetds gambit-c gawk \
	 giftcurs git-core gnokii gnupg gphoto2 ggrab libgphoto2 hnb ice \
	 glib gloox gnet gsnmp gtmess \
	golang \
	 id3lib inferno iperf irssi jikes \
	 lftp \
	 libcdio libdaemon libdvb libftdi libidn liblcms \
	 libmtp libopensync libsoup libtorrent \
	 loudmouth \
	 ltrace \
	 mc mcabber mdadm minicom minidlna mlocate moc \
	 mod-fastcgi mod-python \
	 mpdscribble \
	 msort msynctool mutt \
	 ncmpc ncursesw netatalk newt nget ntfsprogs ntp nvi \
	 nylon obexftp openldap openser \
	 pal p7zip pcapsipdump \
	 postfix player py-mssql \
	 rhtvision rtorrent rtpproxy \
	 sablevm samba scli sdl ser snort \
	 snownews sqsh swi-prolog syslog-ng \
	 taglib tshark tnftpd transcode \
	 unrar \
	 vlc \
	 w3m weechat wget wxbase x11 \
	 xdpyinfo xext \
	 xpm xtst zsh \

PROCPS_VERSION=3.2.3
PROCPS_IPK_VERSION=6

TAR_VERSION=1.16.1
TAR_IPK_VERSION=3

SAMBA_VERSION := 3.0.14a
SAMBA_IPK_VERSION := 6

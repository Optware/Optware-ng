# Packages that *only* work for fsg3v4 - do not just put new packages here.
SPECIFIC_PACKAGES = \
	fsg3v4-bootstrap \
	$(PERL_PACKAGES)

# Packages that do not work for fsg3v4.
BROKEN_PACKAGES = \
	antinat asterisk \
	asterisk14 asterisk14-chan-capi atftp audiofile \
	bitlbee busybox bzflag \
	cherokee chillispot chrpath clearsilver \
	ctrlproxy cups cyrus-imapd \
	diffutils dspam dtach dhcp digitemp dnsmasq dump \
	eaccelerator ecl eggdrop elinks emacs22 erlang erl-yaws esound extract-xiso \
	fcgi ffmpeg ficy finch freeradius \
	gconv-modules gdb \
	gnupg gnuplot gnutls grep \
	hexcurse \
	icecast iksemel irssi ivorbis-tools \
	ldconfig libao libgc libgcrypt libgpg-error \
	libnsl libpcap libshout loudmouth ltrace \
	madplay	mktemp moc monotone most mpack mpd mutt \
	nemesis net-snmp net-tools netatalk newt nmap nzbget \
	oleo opencdk openldap openser \
	phoneme-advanced postfix python24 \
	py-duplicity py-rdiff-backup \
	qemu qemu-libc-i386 quagga quickie \
	samba scponly snort speex sqsh strace streamripper swi-prolog \
	tcl textutils \
	uemacs \
	vlc vorbis-tools \
	w3m weechat wput \
	xinetd

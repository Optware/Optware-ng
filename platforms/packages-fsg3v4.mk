# Packages that *only* work for fsg3v4 - do not just put new packages here.
SPECIFIC_PACKAGES = \
	fsg3v4-bootstrap \
	$(PERL_PACKAGES)

# Packages that do not work for fsg3v4.
BROKEN_PACKAGES = \
	antinat asterisk \
	asterisk14 asterisk14-chan-capi atftp audiofile \
	bitlbee busybox \
	chillispot chrpath clearsilver \
	cyrus-imapd \
	diffutils dspam dtach dhcp digitemp dnsmasq dump \
	eaccelerator ecl eggdrop elinks erlang erl-yaws esound extract-xiso \
	fcgi ffmpeg ficy finch freeradius \
	gconv-modules gdb \
	gnupg gnuplot grep \
	hexcurse \
	icecast iksemel ivorbis-tools \
	ldconfig libao libgc \
	libnsl libpcap libshout loudmouth ltrace \
	madplay	mktemp moc monotone most mpack mpd mutt \
	nemesis net-snmp net-tools netatalk newt nmap nzbget \
	oleo openser \
	phoneme-advanced postfix \
	py-duplicity py-rdiff-backup \
	qemu qemu-libc-i386 quagga quickie \
	scponly snort speex sqsh strace streamripper swi-prolog \
	tcl textutils \
	uemacs \
	vlc vorbis-tools \
	w3m weechat wput \
	xinetd

# Packages that *only* work for fsg3v4 - do not just put new packages here.
SPECIFIC_PACKAGES = \
	fsg3v4-bootstrap \
	$(PERL_PACKAGES)

# Packages that do not work for fsg3v4.
# First group is unsorted.
# Second group is config.sub related.
# Third group are sorted dependency trees.
BROKEN_PACKAGES = \
	antinat asterisk \
	asterisk14 asterisk14-chan-capi atftp \
	bitlbee busybox \
	chillispot chrpath clearsilver \
	cyrus-imapd \
	dhcp \
	ecl erlang erl-yaws esound \
	fcgi ffmpeg freeradius \
	gconv-modules gdb \
	gnuplot \
	ldconfig \
	libnsl libpcap libshout loudmouth \
	madplay	mktemp moc monotone most mpack mpd mutt \
	net-snmp net-tools netatalk newt nmap nzbget \
	phoneme-advanced \
	py-duplicity py-rdiff-backup \
	qemu qemu-libc-i386 quagga quickie \
	\
	diffutils hexcurse nemesis scponly snort sqsh streamripper xinetd \
	\
	audiofile libao ivorbis-tools vorbis-tools \
	libgc w3m \
	ltrace \
	oleo \
	openser \
	postfix \
	speex icecast vlc \
	strace \
	swi-prolog \
	textutils \
	uemacs \

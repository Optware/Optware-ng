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
	chillispot chrpath \
	cyrus-imapd \
	dhcp \
	ecl eggdrop erlang erl-yaws \
	fcgi ffmpeg freeradius \
	gconv-modules gdb \
	gnuplot \
	ldconfig \
	libpcap libshout loudmouth \
	madplay	mktemp moc monotone most mpack mpd \
	net-snmp net-tools netatalk nmap \
	phoneme-advanced \
	qemu qemu-libc-i386 quagga quickie \
	\
	hexcurse nemesis nzbget snort sqsh streamripper \
	\
	ltrace \
	oleo \
	openser \
	strace \
	swi-prolog \
	textutils \
	uemacs \

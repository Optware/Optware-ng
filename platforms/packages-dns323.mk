SPECIFIC_PACKAGES = \
	ipkg-opt \
	libiconv \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	9base appweb \
	asterisk asterisk14 asterisk14-chan-capi asterisk16 asterisk16-addons \
	btpd castget dspam fcgi \
	ficy fish freeradius fuppes ghostscript gnu-smalltalk gpsd \
	gtmess gtk ice id3lib ipac-ng iptraf kismet \
	launchtool ldconfig liba52 lighttpd mcabber mediatomb monotone \
	mt-daapd mtr mysql-connector-odbc nagios-plugins \
	nail net-snmp nfs-server nfs-utils \
	nrpe ntop openser pango pcapsipdump \
	phoneme-advanced \
	picolisp privoxy hplip py-mysql \
	qemu quagga \
	rssh sablevm simh sm srelay tcpwrappers \
	transcode tz uemacs util-linux vlc vnstat \
	vte xauth xaw xchat xmu xt xterm \
	slimserver \


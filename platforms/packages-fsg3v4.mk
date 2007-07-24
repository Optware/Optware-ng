# Packages that *only* work for fsg3v4 - do not just put new packages here.
SPECIFIC_PACKAGES = \
	fsg3v4-bootstrap \
	$(PERL_PACKAGES) \

# Packages that do not work for fsg3v4.
BROKEN_PACKAGES = \
	abook adns \
	bzflag bzip2 \
	calc ccxstream cherokee chillispot clearsilver \
	cron ctag ctrlproxy cups cvs cyrus-imapd \
	dspam dtach dhcp digitemp dnsmasq dump \
	eaccelerator ecl eggdrop elinks emacs22 erlang erl-yaws esound extract-xiso \
	ffmpeg ficy finch freeradius \
	gnutls \
	libgcrypt libgpg-error \
	opencdk openldap \
	php python24 \
	tcl

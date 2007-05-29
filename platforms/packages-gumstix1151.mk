SPECIFIC_PACKAGES = \
	ipkg-opt \
	libiconv \
	$(PERL_PACKAGES) \
	$(UCLIBC_SPECIFIC_PACKAGES) \

# openldap: daemon.o: In function `slapd_daemon_task':
# 	servers/slapd/daemon.c:1973: undefined reference to `in6addr_any'
BROKEN_PACKAGES = \
	$(UCLIBC_BROKEN_PACKAGES) \
	dansguardian \
	htop \
	libdvb \
	ltrace \
	nget \
	oleo \
	openldap \
	par2cmdline \
	zsh \

# BROKEN_PACKAGES = \
	amule asterisk asterisk14-chan-capi bluez-hcidump cherokee chillispot \
	cyrus-imapd dovecot dump esound fcgi fish ficy \
	gdb git-core gnupg gnuplot gtk htop ice \
	inetutils iptables ircd-hybrid irssi ivorbis-tools jamvm kissdx \
	launchtool ldconfig libao libopensync lsof madplay mc \
	mdadm monotone mpd msynctool mtr netatalk nfs-server \
	nfs-utils obexftp openldap pango phoneme-advanced portmap puppy \
	py-duplicity qemu quagga quickie sendmail sm strace \
	swi-prolog

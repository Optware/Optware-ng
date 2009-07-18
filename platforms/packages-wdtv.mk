PERL_MAJOR_VER = 5.10

SPECIFIC_PACKAGES = \
	ipkg-opt libiconv uclibc-opt \
	$(PACKAGES_REQUIRE_LINUX26) \
	$(PERL_PACKAGES) \
	binutils libc-dev gcc \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	9base \
	cdrtools fcgi ficy fish \
	fuppes gnu-smalltalk gtmess gtk gutenprint \
	ice iptraf launchtool ldconfig ltrace moc \
	mtr newsbeuter nfs-server nfs-utils pango pinentry \
	puppy qemu rssh \
	rxtx \
	sm transcode uemacs vte \
	xauth xaw xchat xmu xt xterm lm-sensors \

RTORRENT_VERSION := 0.8.2
RTORRENT_IPK_VERSION := 2

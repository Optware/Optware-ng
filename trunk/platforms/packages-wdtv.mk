PERL_MAJOR_VER = 5.10

SPECIFIC_PACKAGES = \
	ipkg-opt libiconv uclibc-opt \
	$(PACKAGES_REQUIRE_LINUX26) \
	$(PERL_PACKAGES) \
	binutils libc-dev gcc \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	9base cdrtools fcgi ficy fish \
	fuppes gnu-smalltalk gtmess gtk gutenprint \
	inferno \
	ice iptraf launchtool ldconfig ltrace microdc2 moc \
	mtr newsbeuter nfs-server nfs-utils pango pinentry \
	player puppy mod-python qemu rssh \
	sm taged transcode uemacs vte \
	xauth xaw xchat xmu xt xterm lm-sensors \
	slimserver

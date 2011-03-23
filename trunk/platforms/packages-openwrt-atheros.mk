SPECIFIC_PACKAGES = \
	libiconv \
	$(UCLIBC_SPECIFIC_PACKAGES) \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	9base \
	boost \
	buildroot uclibc-opt \
	cairo \
	ecl \
	fcgi ficy fish \
	gloox \
	golang \
	inferno \
	gnu-smalltalk gtmess gtk \
	hpijs hplip \
	ice \
	lame launchtool ldconfig \
	minidlna \
	moc mtr \
	nfs-server nfs-utils nickle ntop \
	pango puppy \
	qemu qemu-libc-i386 quickie \
	sandbox \
	sm syx \
	transcode \
	uemacs \
	vte \
	xt xmu xauth xaw xchat xterm


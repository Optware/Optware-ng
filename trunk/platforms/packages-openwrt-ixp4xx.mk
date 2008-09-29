SPECIFIC_PACKAGES = \
	$(UCLIBC_SPECIFIC_PACKAGES) \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \
	binutils gcc libc-dev \
	libiconv \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	9base \
	asterisk16-addons \
	buildroot uclibc-opt \
	cairo \
	ecl \
	fcgi ficy fish \
	gloox \
	gnu-smalltalk gtmess gtk \
	hpijs hplip \
	ice iptables \
	lame launchtool ldconfig \
	moc monotone mtr \
	nfs-server nfs-utils nickle ntop \
	pango puppy \
	qemu qemu-libc-i386 quickie \
	sm syx \
	transcode \
	uemacs \
	vte \
	xt xmu xauth xaw xchat xterm


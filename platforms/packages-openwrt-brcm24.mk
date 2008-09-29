SPECIFIC_PACKAGES = \
	libiconv \
	$(PERL_PACKAGES) \
	$(UCLIBC_SPECIFIC_PACKAGES) \
	uclibcnotimpl libuclibc++ \
	binutils gcc libc-dev \

BROKEN_PACKAGES = \
	$(UCLIBC_BROKEN_PACKAGES) \
	asterisk16-addons \
	buildroot uclibc-opt \
	aspell \
	cdrtools \
	centerim \
	ecl \
	cairo fixesext \
	gloox \
	gtmess \
	iptraf \
	libdvb \
	ltrace \
	nget nickle \
	player \
	recordext renderext \
	sdl \
	taglib \
	x11 xdpyinfo xext xpm xtst

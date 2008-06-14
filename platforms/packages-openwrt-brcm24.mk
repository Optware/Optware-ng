SPECIFIC_PACKAGES = \
	libiconv \
	$(PERL_PACKAGES) \
	$(UCLIBC_SPECIFIC_PACKAGES) \
	uclibcnotimpl libuclibc++ \

BROKEN_PACKAGES = \
	$(UCLIBC_BROKEN_PACKAGES) \
	asterisk16-addons \
	buildroot uclibc-opt \
	aspell \
	ecl \
	cairo fixesext \
	gtmess \
	iptraf \
	libdvb \
	libnsl ltrace \
	nget nickle \
	player \
	recordext renderext \
	sdl \
	taglib \
	x11 xdpyinfo xext xpm xtst

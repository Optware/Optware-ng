SPECIFIC_PACKAGES = \
	libiconv \
	$(PERL_PACKAGES) \
	$(UCLIBC++_SPECIFIC_PACKAGES) \
	uclibcnotimpl libuclibc++ \
	binutils gcc libc-dev \

BROKEN_PACKAGES = \
	$(UCLIBC++_BROKEN_PACKAGES) \
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
	minidlna \
	motor \
	nget nickle \
	player \
	recordext renderext \
	sane-backends \
	sdl slrn \
	taglib \
	x11 xdpyinfo xext xpm xtst

SPECIFIC_PACKAGES = \
	libiconv \
	$(UCLIBC_SPECIFIC_PACKAGES) \
	uclibcnotimpl libuclibc++ \

BROKEN_PACKAGES = \
	$(UCLIBC_BROKEN_PACKAGES) \
	buildroot uclibc-opt \
	aspell \
	ecl \
	fixesext \
	iptraf \
	libdvb \
	libnsl ltrace \
	nget nickle \
	player \
	quagga \
	recordext renderext \
	sdl \
	x11 xdpyinfo xext xpm xtst

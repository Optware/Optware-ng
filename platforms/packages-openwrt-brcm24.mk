SPECIFIC_PACKAGES = \
	libiconv \
	$(UCLIBC_SPECIFIC_PACKAGES) \
	uclibcnotimpl libuclibc++ \

BROKEN_PACKAGES = \
	$(UCLIBC_BROKEN_PACKAGES) \
	buildroot uclibc-opt \
	arping \
	aspell \
	ecl \
	fixesext gdb \
	iptraf \
	libdvb \
	libnsl ltrace \
	nget nickle \
	player \
	quagga \
	recordext renderext \
	sdl ser \
	vlc x11 xdpyinfo xext xpm xtst

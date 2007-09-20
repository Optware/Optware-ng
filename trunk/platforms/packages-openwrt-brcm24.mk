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
	gphoto2 libgphoto2 \
	libcdio libdvb libextractor \
	libmtp libnsl libopensync loudmouth ltrace \
	msynctool netatalk nget nickle \
	obexftp \
	player \
	quagga \
	recordext renderext \
	rhtvision sdl ser \
	vlc x11 xdpyinfo xext xpm xtst

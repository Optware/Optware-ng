SPECIFIC_PACKAGES = \
	libiconv \
	$(UCLIBC_SPECIFIC_PACKAGES) \
	uclibcnotimpl libuclibc++ \

BROKEN_PACKAGES = \
	$(UCLIBC_BROKEN_PACKAGES) \
	buildroot uclibc-opt \
	aspell bogofilter \
	bluez-utils \
	ecl erl-yaws \
	fixesext fuppes gambit-c gdb \
	gnugo gsnmp gphoto2 libgphoto2 libcdio \
	libdvb libextractor libmtp libnsl libopensync loudmouth ltrace \
	msynctool multitail netatalk nget \
	obexftp phoneme-advanced \
	player psmisc \
	quagga \
	recordext renderext \
	rhtvision scli sdl ser slsc \
	tcsh tshark vlc x11 xdpyinfo xext xpm xtst zile

SPECIFIC_PACKAGES = \
	libiconv \
	$(UCLIBC_SPECIFIC_PACKAGES) \
	uclibcnotimpl libuclibc++ \

BBROKEN_PACKAGES = \
	$(UCLIBC_BROKEN_PACKAGES) \
	buildroot uclibc-opt \
	aspell asterisk14-chan-capi bogofilter \
	bluez-utils \
	ecl erlang erl-yaws \
	fixesext fuppes gambit-c gdb \
	gnugo gsnmp gphoto2 libgphoto2 joe libcdio \
	libdvb libextractor libmtp libnsl libopensync loudmouth ltrace \
	msynctool multitail netatalk nget \
	obexftp phoneme-advanced \
	player psmisc \
	quagga \
	recordext renderext \
	rhtvision scli sdl ser slsc squeak \
	tcsh tethereal vlc x11 xdpyinfo xext xpm xtst zile

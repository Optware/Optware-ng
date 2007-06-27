SPECIFIC_PACKAGES = \
	libiconv \
	$(UCLIBC_SPECIFIC_PACKAGES) \
	uclibcnotimpl libuclibc++ \

BROKEN_PACKAGES = \
	$(UCLIBC_BROKEN_PACKAGES) \
	buildroot uclibc-opt \
	appweb aspell asterisk14-chan-capi bogofilter \
	bluez-utils cups eaccelerator \
	ecl erlang erl-yaws \
	fixesext fuppes gambit-c gdb \
	gnugo gsnmp gphoto2 libgphoto2 joe libcdio \
	libdvb libextractor libmtp libnsl libopensync loudmouth ltrace \
	msynctool multitail netatalk nget \
	openobex obexftp phoneme-advanced php php-apache php-fcgi \
	php-thttpd player psmisc \
	quagga \
	recordext renderext \
	rhtvision samba scli sdl ser slsc squeak \
	tcsh tethereal vlc x11 xdpyinfo xext xpm xtst zile

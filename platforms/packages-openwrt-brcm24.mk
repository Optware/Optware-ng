SPECIFIC_PACKAGES = \
	libiconv \
	$(PERL_PACKAGES) \
	$(UCLIBC++_SPECIFIC_PACKAGES) \
	uclibcnotimpl libuclibc++ \
	binutils gcc libc-dev \

# linphone: undefined reference to `log10f'
BROKEN_PACKAGES = \
	$(UCLIBC++_BROKEN_PACKAGES) \
	boost \
	buildroot uclibc-opt \
	aspell \
	centerim \
	ecl \
	erl-ejabberd \
	cairo fixesext \
	gloox \
	golang \
	gtmess \
	iptraf \
	libdvb \
	linphone \
	ltrace \
	minidlna \
	motion \
	motor \
	nget nickle \
	recordext renderext \
	sandbox \
	sdl slrn \
	squid3 \
	taglib \
	x11 xdpyinfo xext xpm xtst \
	clinkcc libopensync msynctool obexftp \

RTORRENT_VERSION := 0.8.0
RTORRENT_IPK_VERSION := 2

LAME_VERSION := 3.98.4
LAME_IPK_VERSION := 1

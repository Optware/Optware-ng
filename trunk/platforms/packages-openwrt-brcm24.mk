SPECIFIC_PACKAGES = \
	libiconv \
	$(UCLIBC_SPECIFIC_PACKAGES) \
	uclibcnotimpl libuclibc++ \

BROKEN_PACKAGES = \
	$(UCLIBC_BROKEN_PACKAGES) \
	buildroot uclibc-opt \
	appweb aspell asterisk14-chan-capi bogofilter \
	bsdmainutils bluez-utils cups eaccelerator ecl erlang \
	erl-yaws fixesext fuppes gambit-c gcal git \
	gnugo gsnmp gphoto2 libgphoto2 joe libcdio \
	libdvb libextractor libmtp libopensync loudmouth ltrace \
	mediatomb mpc mpd msynctool multitail netatalk newt nget \
	openobex obexftp phoneme-advanced php php-apache php-fcgi \
	php-thttpd player psmisc py-duplicity py-lxml py-psycopg \
	py-psycopg2 py-pygresql py-pudge py-pylons py-pyro \
	py-quixote py-rdiff-backup py-reportlab py-routes \
	py-roundup py-ruledispatch py-scgi py-selector py-serial \
	py-silvercity py-simplejson quagga renderext rhtvision ruby \
	rubygems samba scli sdl ser slsc snownews squeak \
	tcsh tethereal vlc weechat x11 xdpyinfo xext xpm xtst zile


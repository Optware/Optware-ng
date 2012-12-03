SPECIFIC_PACKAGES = \
	ipkg-opt \
	libiconv \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	$(UCLIBC_BROKEN_PACKAGES) \
	appweb \
	erl-ejabberd \
	ficy fuppes gnu-smalltalk \
	gloox \
	inferno \
	gtmess ipac-ng iptraf kamailio kismet \
	mediatomb \
	mysql-connector-odbc \
	ntop openser pcapsipdump \
	py-mysql \
	quagga \
	rssh sablevm \
	util-linux vnstat \
	slimserver \
	telldus-core \
	btg clinkcc libopensync msynctool obexftp \

PSMISC_VERSION := 22.11

RTORRENT_VERSION := 0.8.2
RTORRENT_IPK_VERSION := 2

TSHARK_VERSION := 1.2.12
TSHARK_IPK_VERSION := 1

ZNC_CONFIG_ARGS:=gl_cv_cc_visibility=true

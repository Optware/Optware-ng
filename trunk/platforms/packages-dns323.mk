SPECIFIC_PACKAGES = \
	ipkg-opt \
	libiconv \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	$(UCLIBC_BROKEN_PACKAGES) \
	appweb \
	ficy fuppes gnu-smalltalk \
	gloox \
	inferno \
	gtmess ipac-ng iptraf kismet \
	mediatomb \
	mysql-connector-odbc \
	ntop openser pcapsipdump \
	py-mysql \
	quagga \
	rssh sablevm \
	util-linux vnstat \
	slimserver \
	btg clinkcc libopensync msynctool obexftp \

RTORRENT_VERSION := 0.8.2
RTORRENT_IPK_VERSION := 2


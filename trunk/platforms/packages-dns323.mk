SPECIFIC_PACKAGES = \
	ipkg-opt \
	libiconv \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	9base appweb \
	fcgi ficy fish fuppes gnu-smalltalk \
	gloox \
	inferno \
	gtmess gtk ice ipac-ng iptraf kismet \
	launchtool ldconfig mediatomb \
	mtr mysql-connector-odbc \
	newsbeuter nfs-server nfs-utils \
	ntop openser pango pcapsipdump \
	py-mysql \
	qemu quagga \
	rssh sablevm sm \
	transcode uemacs util-linux vnstat \
	vte xauth xaw xchat xmu xt xterm \


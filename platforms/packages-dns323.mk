SPECIFIC_PACKAGES = \
	ipkg-opt \
	libiconv \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	9base appweb \
	castget fcgi \
	ficy fish freeradius fuppes gnu-smalltalk \
	gtmess gtk ice id3lib ipac-ng iptraf kismet \
	launchtool ldconfig liba52 lighttpd mediatomb monotone \
	mtr mysql-connector-odbc \
	nfs-server nfs-utils \
	ntop openser pango pcapsipdump \
	py-mysql \
	qemu quagga \
	rssh sablevm sm \
	transcode uemacs util-linux vlc vnstat \
	vte xauth xaw xchat xmu xt xterm \
	slimserver \


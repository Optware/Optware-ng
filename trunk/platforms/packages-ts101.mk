SPECIFIC_PACKAGES = \
	ipkg-opt \
	libiconv \
	py-ctypes \
	ts101-kernel-modules \
	$(PERL_PACKAGES) \


BROKEN_PACKAGES = \
	$(filter-out libstdc++, $(UCLIBC_BROKEN_PACKAGES)) \
	amule cdrtools ecl ficy \
	gift giftcurs \
	gift-ares gift-fasttrack gift-gnutella \
	gift-openft gift-opennap \
	gloox \
	gtmess \
	iptraf \
	nfs-server nfs-utils \
	player \
	transcode \
	util-linux \
	\
	asterisk14 asterisk14-chan-capi asterisk16 asterisk16-addons \
	taged \
	ts101-kernel-modules

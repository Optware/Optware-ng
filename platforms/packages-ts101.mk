SPECIFIC_PACKAGES = \
	ipkg-opt \
	libiconv \
	py-ctypes \
	ts101-kernel-modules \
	$(PERL_PACKAGES) \


BROKEN_PACKAGES = \
	$(UCLIBC++_BROKEN_PACKAGES) \
	amule cdrtools ecl ficy \
	gift giftcurs \
	gift-ares gift-fasttrack gift-gnutella \
	gift-openft gift-opennap \
	gloox \
	inferno \
	gtmess \
	iptraf \
	nfs-server nfs-utils \
	player \
	sane-backends \
	transcode \
	util-linux \
	\
	asterisk14 asterisk14-chan-capi asterisk16 asterisk16-addons \
	taged \
	ts101-kernel-modules

E2FSPROGS_VERSION := 1.40.3
E2FSPROGS_IPK_VERSION := 5

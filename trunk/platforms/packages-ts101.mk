SPECIFIC_PACKAGES = \
	libiconv \
	py-ctypes \
	ts101-kernel-modules \
	$(PERL_PACKAGES) \


BROKEN_PACKAGES = \
	$(filter-out libstdc++ newsbeuter, $(UCLIBC_BROKEN_PACKAGES)) \
	amule ecl ficy \
	gift giftcurs \
	gift-ares gift-fasttrack gift-gnutella \
	gift-openft gift-opennap \
	gtmess \
	iptraf \
	motion \
	nfs-server nfs-utils \
	player \
	taglib \
	transcode \
	util-linux vsftpd \
	wget \
	\
	asterisk14 asterisk14-chan-capi asterisk16 asterisk16-addons \
	newsbeuter taged \
	ts101-kernel-modules slimserver

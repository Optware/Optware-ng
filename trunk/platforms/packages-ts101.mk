SPECIFIC_PACKAGES = \
	libiconv \
	py-ctypes \
	ts101-kernel-modules \
	$(PERL_PACKAGES) \


BROKEN_PACKAGES = \
	$(filter-out libstdc++ newsbeuter, $(UCLIBC_BROKEN_PACKAGES)) \
	amule ecl erl-escript erl-yaws ficy \
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

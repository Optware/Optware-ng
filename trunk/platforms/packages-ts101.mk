SPECIFIC_PACKAGES = \
	libiconv \
	py-ctypes \
	ts101-kernel-modules \
	$(UCLIBC_SPECIFIC_PACKAGES) \


BROKEN_PACKAGES = \
	$(filter-out libstdc++ newsbeuter, $(UCLIBC_BROKEN_PACKAGES)) \
	amule chillispot ecl erl-escript erl-yaws ficy \
	gift giftcurs \
	gift-ares gift-fasttrack gift-gnutella \
	gift-openft gift-opennap \
	iptraf \
	motion \
	nfs-server nfs-utils \
	player \
	transcode \
	util-linux vsftpd \
	wget buildroot uclibc-opt ipkg-opt \

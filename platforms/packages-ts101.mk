SPECIFIC_PACKAGES = \
	libiconv \
	py-ctypes \
	ts101-kernel-modules \
	$(UCLIBC_SPECIFIC_PACKAGES) \

BROKEN_PACKAGES = \
	$(UCLIBC_BROKEN_PACKAGES) \
	amule chillispot ecl erl-escript erl-yaws ficy gdb gift \
	giftcurs gift-ares gift-fasttrack gift-gnutella gift-openft \
	gift-opennap htop libopensync motion msynctool nfs-server \
	nfs-utils obexftp quagga squeak transcode \
	varnish vsftpd \
	wget wget-ssl buildroot uclibc-opt ipkg-opt \

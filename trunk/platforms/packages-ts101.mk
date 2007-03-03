SPECIFIC_PACKAGES = \
	libiconv \
	py-ctypes \
	ts101-kernel-modules \
	$(UCLIBC_SPECIFIC_PACKAGES) \

BROKEN_PACKAGES = \
	$(UCLIBC_BROKEN_PACKAGES) \
	amule chillispot ecl erl-escript erl-yaws ffmpeg \
	ficy gdb gift giftcurs gift-ares gift-fasttrack \
	gift-gnutella gift-openft gift-opennap htop icecast \
	ivorbis-tools libopensync libshout \
	motion msynctool nfs-server nfs-utils \
	obexftp quagga squeak streamripper \
	transcode ushare vlc vorbis-tools vsftpd wget wget-ssl \
	buildroot uclibc-opt ipkg-opt \

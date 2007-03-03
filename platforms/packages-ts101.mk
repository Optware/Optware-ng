SPECIFIC_PACKAGES = \
	libiconv \
	py-ctypes \
	ts101-kernel-modules \
	$(UCLIBC_SPECIFIC_PACKAGES) \

BROKEN_PACKAGES = \
	$(UCLIBC_BROKEN_PACKAGES) \
	amule at chillispot ecl erl-escript erl-yaws ffmpeg \
	ficy freeradius gdb gift giftcurs gift-ares gift-fasttrack \
	gift-gnutella gift-openft gift-opennap htop icecast id3lib \
	ivorbis-tools libcdio libopensync libshout libsigc++ libtorrent \
	motion msynctool nfs-server nfs-utils \
	obexftp openser quagga rtorrent ruby sablevm squeak streamripper \
	transcode ushare vlc vorbis-tools vsftpd wget wget-ssl \
	buildroot uclibc-opt ipkg-opt perl-business-isbn \

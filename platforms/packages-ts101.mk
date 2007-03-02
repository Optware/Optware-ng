SPECIFIC_PACKAGES = \
	libiconv \
	py-ctypes \
	ts101-kernel-modules \
	$(UCLIBC_SPECIFIC_PACKAGES) \

BROKEN_PACKAGES = \
	$(UCLIBC_BROKEN_PACKAGES) \
	nft-utils ecl nfs-server erl-escript erl-yaws \
	amule at chillispot ecl ffmpeg \
	ficy freeradius gdb gift giftcurs gift-ares gift-fasttrack \
	gift-gnutella gift-openft gift-opennap htop icecast id3lib \
	ivorbis-tools libcdio libopensync libshout libsigc++ libtorrent \
	mediatomb motion msynctool mysql-connector-odbc obexftp openser \
	quagga rtorrent ruby sablevm squeak streamripper swi-prolog svn \
	transcode ushare vlc vorbis-tools vsftpd wget wget-ssl \
	buildroot uclibc-opt ipkg-opt perl-business-isbn \

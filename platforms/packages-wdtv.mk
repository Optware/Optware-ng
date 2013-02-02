PERL_MAJOR_VER = 5.10

SPECIFIC_PACKAGES = \
	ipkg-opt libiconv uclibc-opt \
	$(PACKAGES_REQUIRE_LINUX26) \
	$(PERL_PACKAGES) \
	binutils libc-dev gcc \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	$(UCLIBC_BROKEN_PACKAGES) \
	aiccu \
	boost \
	ficy fuppes \
	golang \
	gtmess gutenprint \
	iptraf moc \
	mkvtoolnix \
	mtr \
	pinentry \
	puppy rssh \
	sandbox \
	srecord \
	lm-sensors \
	btg clinkcc libopensync msynctool obexftp \

ARIA2_PATCHES := $(SOURCE_DIR)/aria2/IPV6_V6ONLY-wdtv.patch

RTORRENT_VERSION := 0.8.2
RTORRENT_IPK_VERSION := 2

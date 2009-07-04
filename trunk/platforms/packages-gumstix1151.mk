SPECIFIC_PACKAGES = \
	ipkg-opt \
	libiconv \
	$(PERL_PACKAGES) \
	binutils gcc libc-dev \

# iptraf: sys/types.h and linux/types.h conflicting
BROKEN_PACKAGES = \
	buildroot uclibc-opt \
	$(UCLIBC_BROKEN_PACKAGES) \
	asterisk \
	bluez-hcidump \
	dump ficy \
	fuppes \
	gloox \
	gtmess \
	inferno \
	iptraf \
	ircd-hybrid \
	mdadm \
	puppy sendmail \
	scrobby \
	tesseract-ocr \

RTORRENT_VERSION := 0.8.0
RTORRENT_IPK_VERSION := 2

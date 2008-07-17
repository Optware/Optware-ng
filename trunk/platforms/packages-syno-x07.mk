SPECIFIC_PACKAGES = \
	syno-x07-optware-bootstrap \
	syno-x07-kernel-modules \
	binutils gcc libc-dev \
	cacao \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	amule \
	asterisk14-chan-capi \
	busybox \
	gambit-c gnu-smalltalk \
	gift giftcurs gift-ares gift-fasttrack gift-gnutella gift-openft gift-opennap \
	iptraf \
	ldconfig libcapi20 libextractor \
	monotone \
	ncftp ntop \
	p7zip \
	player puppy \
	qemu sablevm \
	varnish \

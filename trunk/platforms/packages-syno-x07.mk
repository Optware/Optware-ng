SPECIFIC_PACKAGES = \
	syno-x07-optware-bootstrap \
	syno-x07-kernel-modules \
	binutils gcc libc-dev \
	mono \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	amule \
	asterisk14-chan-capi \
	busybox \
	centerim \
	gambit-c gnu-smalltalk \
	iptraf \
	ldconfig libcapi20 libextractor \
	monotone \
	ntop \
	p7zip \
	player puppy \
	qemu sablevm \
	varnish \

E2FSPROGS_VERSION := 1.40.3
E2FSPROGS_IPK_VERSION := 5

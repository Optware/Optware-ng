SPECIFIC_PACKAGES = \
	syno-x07-optware-bootstrap \
	syno-x07-kernel-modules \
	binutils gcc libc-dev \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

# btpd: arm-marvell-linux-gnu/sys-include/sys/epoll.h:62: error: syntax error before "uint32_t"
BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	amule \
	asterisk14-chan-capi \
	btpd \
	busybox \
	centerim \
	gambit-c gnu-smalltalk \
	iptraf \
	ldconfig libcapi20 \
	ntop \
	p7zip \
	player puppy \
	qemu sablevm \
	varnish \

E2FSPROGS_VERSION := 1.40.3
E2FSPROGS_IPK_VERSION := 5

JAMVM_VERSION = 1.5.1
JAMVM_IPK_VERSION = 1

SPECIFIC_PACKAGES = \
	optware-bootstrap kernel-modules \
	$(PACKAGES_REQUIRE_LINUX26) \
	py-ctypes \
	$(PERL_PACKAGES) \
	binutils gcc libc-dev \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	asterisk14-chan-capi \
	golang \
	inferno \
	iptraf \
	ldconfig libcapi20 \
	puppy \
	sandbox \
	transcode \
	x264 lm-sensors \

E2FSPROGS_VERSION := 1.40.3
E2FSPROGS_IPK_VERSION := 5

SLANG_VERSION := 2.2.2
SLANG_IPK_VERSION := 1

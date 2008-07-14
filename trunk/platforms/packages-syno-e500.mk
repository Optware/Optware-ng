SPECIFIC_PACKAGES = \
	optware-bootstrap \
	$(PACKAGES_REQUIRE_LINUX26) \
	py-ctypes \
	$(PERL_PACKAGES) \
	binutils gcc libc-dev \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	asterisk14-chan-capi \
	iptraf \
	ldconfig libcapi20 monotone \
	pciutils puppy transcode \
	x264 lm-sensors \
	slimserver \

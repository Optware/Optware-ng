PERL_MAJOR_VER = 5.10

SPECIFIC_PACKAGES = \
	$(PACKAGES_REQUIRE_LINUX26) \
	$(PERL_PACKAGES) \
	ipkg-opt \
	cacao \
	binutils gcc libc-dev \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	asterisk \
	bitchx \
	iptables ivorbis-tools lcd4linux \
	ldconfig puppy \
	mod-python qemu taged transcode \

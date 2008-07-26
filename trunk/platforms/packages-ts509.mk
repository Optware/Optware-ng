SPECIFIC_PACKAGES = \
	$(PACKAGES_REQUIRE_LINUX26) \
	$(PERL_PACKAGES) \
	ipkg-opt \
	binutils gcc libc-dev \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	asterisk bitchx bzflag iptables ivorbis-tools lcd4linux \
	ldconfig phoneme-advanced puppy \
	mod-python py-reportlab qemu taged transcode \

PERL_MAJOR_VER = 5.10

# Packages that *only* work for cs08q1armel - do not just put new packages here.
SPECIFIC_PACKAGES = \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \
	ipkg-opt \
	cacao mono \
	binutils gcc libc-dev \

# Packages that do not work for cs08q1armel.
BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	boost \
	iptables iptraf ldconfig \
	nfs-utils puppy mod-python qemu \
	taged transcode \

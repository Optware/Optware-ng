PERL_MAJOR_VER = 5.10

SPECIFIC_PACKAGES = \
	$(PACKAGES_REQUIRE_LINUX26) \
	$(PERL_PACKAGES) \
	ipkg-opt \
	cacao \
	redis \
	binutils gcc libc-dev \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	asterisk \
	bitchx \
	ecl \
	ivorbis-tools lcd4linux \
	ldconfig puppy \
	qemu \

SLANG_VERSION := 2.2.2
SLANG_IPK_VERSION := 1

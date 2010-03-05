SPECIFIC_PACKAGES = \
	$(UCLIBC_SPECIFIC_PACKAGES) \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \
	binutils gcc libc-dev \
	libiconv \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	$(UCLIBC_BROKEN_PACKAGES) \
	buildroot uclibc-opt \
	ecl \
	ficy \
	gloox \
	golang \
	gtmess \
	hpijs hplip \
	inferno \
	iptables \
	lame \
	moc \
	motion \
	nickle ntop \
	puppy \
	quickie \
	sandbox \

JAMVM_VERSION = 1.5.1
JAMVM_IPK_VERSION = 1

MYSQL5_CPPFLAGS := -fno-builtin-rint


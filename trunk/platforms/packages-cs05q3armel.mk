# Packages that *only* work for mssii - do not just put new packages here.
SPECIFIC_PACKAGES = \
	lspro-optware-bootstrap \
	teraprov2-optware-bootstrap \
	hpmv2-optware-bootstrap \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \
	binutils gcc libc-dev \
	cacao \
	redis \

# Packages that do not work for mssii.
BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	amule \
	libcapi20 \
	erl-ejabberd \
	iptraf \
	ldconfig \
	qemu qemu-libc-i386 \
	sandbox \

E2FSPROGS_VERSION := 1.40.3
E2FSPROGS_IPK_VERSION := 5

REDIS_VERSION := 2.0.4
REDIS_PATCHES := $(SOURCE_DIR)/redis/no_sa_sigaction.patch

TSHARK_VERSION := 1.2.12
TSHARK_IPK_VERSION := 1

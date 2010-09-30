# Packages that *only* work for ds101g+ - do not just put new packages here.
SPECIFIC_PACKAGES = \
	ipkg-opt \
	ds101g-kernel-modules \
	ds101g-kernel-modules-fuse \
	ds101-bootstrap \
	crosstool-native \
	mono \
	redis \
	py-ctypes \
	$(PERL_PACKAGES) \

# Packages that do not work for ds101g+.
BROKEN_PACKAGES = \
	btg \
	ecl \
	erl-ejabberd \
	golang \
	ldconfig \
	sandbox \

HDPARM_VERSION := 9.28

STRACE_VERSION := 4.5.17
STRACE_IPK_VERSION := 1

REDIS_PATCHES := $(SOURCE_DIR)/redis/no_sa_sigaction.patch

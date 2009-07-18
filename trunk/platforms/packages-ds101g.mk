# Packages that *only* work for ds101g+ - do not just put new packages here.
SPECIFIC_PACKAGES = \
	ipkg-opt \
	ds101g-kernel-modules \
	ds101g-kernel-modules-fuse \
	ds101-bootstrap \
	crosstool-native \
	mono \
	py-ctypes \
	$(PERL_PACKAGES) \

# Packages that do not work for ds101g+.
BROKEN_PACKAGES = \
	btg \
	ecl \
	inferno \
	ldconfig \

STRACE_VERSION := 4.5.17
STRACE_IPK_VERSION := 1

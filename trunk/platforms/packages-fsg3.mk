# Packages that *only* work for fsg3 - do not just put new packages here.
SPECIFIC_PACKAGES = \
	fsg3-kernel-modules \
	fsg3-bootstrap \
	crosstool-native \
	$(PERL_PACKAGES) \

# Packages that do not work for fsg3.
BROKEN_PACKAGES = \
	$(COMMON_NATIVE_PACKAGES) \
	qemu-libc-i386 \
	varnish \


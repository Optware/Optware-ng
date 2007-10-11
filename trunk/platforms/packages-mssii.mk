# Packages that *only* work for mssii - do not just put new packages here.
SPECIFIC_PACKAGES = \
	optware-bootstrap \
	mssii-kernel-modules \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

# Packages that do not work for mssii.
BROKEN_PACKAGES = \
	asterisk14-chan-capi libcapi20 \
	gnuplot \
	iptraf \
	ldconfig \
	modutils \
	monotone \
	player \
	puppy \
	qemu qemu-libc-i386 \
	quagga \
	socat \
	spindown \
	uemacs \

# Packages that *only* work for mssii - do not just put new packages here.
SPECIFIC_PACKAGES = \
	ipkg-opt \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

# Packages that do not work for mssii.
BROKEN_PACKAGES = \
	asterisk asterisk14 asterisk14-chan-capi libcapi20 \
	gnuplot \
	iptraf \
	ldconfig \
	monotone \
	player \
	puppy \
	qemu qemu-libc-i386 \
	quagga \
	socat \
	uemacs \
	usbutils \
	gtk vte xchat \

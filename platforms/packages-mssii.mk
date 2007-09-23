# Packages that *only* work for mssii - do not just put new packages here.
SPECIFIC_PACKAGES = \
	ipkg-opt \
	$(PERL_PACKAGES)

# Packages that do not work for mssii.
BROKEN_PACKAGES = \
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

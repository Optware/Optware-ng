SPECIFIC_PACKAGES = \
	ipkg-opt \
	libiconv \
	$(UCLIBC_SPECIFIC_PACKAGES) \

BROKEN_PACKAGES = \
	buildroot uclibc-opt \
	$(filter-out libstdc++, $(UCLIBC_BROKEN_PACKAGES)) \
	amule asterisk \
	bluez-hcidump chillispot \
	dump ficy gdb \
	gnuplot htop \
	ircd-hybrid \
	libopensync mdadm \
	msynctool obexftp \
	puppy quagga sendmail \
	usbutils util-linux

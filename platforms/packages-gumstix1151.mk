SPECIFIC_PACKAGES = \
	ipkg-opt \
	libiconv \
	$(UCLIBC_SPECIFIC_PACKAGES) \

# iptraf: sys/types.h and linux/types.h conflicting
BROKEN_PACKAGES = \
	buildroot uclibc-opt \
	$(filter-out libstdc++ newsbeuter, $(UCLIBC_BROKEN_PACKAGES)) \
	amule asterisk \
	bluez-hcidump chillispot \
	dump ficy gdb \
	gnuplot htop \
	iptraf \
	ircd-hybrid \
	libopensync mdadm \
	msynctool obexftp \
	puppy quagga sendmail \
	usbutils util-linux

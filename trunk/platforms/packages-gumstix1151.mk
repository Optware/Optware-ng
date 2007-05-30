SPECIFIC_PACKAGES = \
	ipkg-opt \
	libiconv \
	$(PERL_PACKAGES) \
	$(UCLIBC_SPECIFIC_PACKAGES) \

BROKEN_PACKAGES = \
	$(UCLIBC_BROKEN_PACKAGES) \
	amule asterisk asterisk14-chan-capi \
	bluez-hcidump chillispot \
	dump ficy gdb \
	gnuplot htop inetutils \
	ircd-hybrid \
	libopensync lsof mdadm \
	msynctool netatalk obexftp \
	portmap puppy quagga sendmail \
	unfs3 usbutils xinetd

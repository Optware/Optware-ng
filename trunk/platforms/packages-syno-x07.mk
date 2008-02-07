SPECIFIC_PACKAGES = \
	ipkg-opt \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	asterisk asterisk14-chan-capi \
	busybox \
	chillispot classpath \
	gambit-c gconv-modules gnu-smalltalk \
	gift giftcurs gift-ares gift-fasttrack gift-gnutella gift-openft gift-opennap \
	iptraf \
	ldconfig libcapi20 libextractor \
	monotone \
	ncftp net-snmp ntop \
	openser p7zip \
	player puppy \
	qemu sablevm \
	socat \
	varnish \

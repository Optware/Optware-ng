# Packages that *only* work for angstromle - do not just put new packages here.
SPECIFIC_PACKAGES = \
	ipkg-opt \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

# Packages that do not work for angstromle.
BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	asterisk \
	atftp bitchx bzflag \
	gconv-modules ipac-ng \
	iptables iptraf ivorbis-tools ldconfig madplay monotone mt-daapd \
	netatalk nfs-utils phoneme-advanced player puppy \
	qemu squeak \
	atk gtk vte xchat

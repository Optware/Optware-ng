# Packages that *only* work for fsg3v4 - do not just put new packages here.
SPECIFIC_PACKAGES = \
	fsg3v4-bootstrap fsg3v4-kernel-modules \
	$(PACKAGES_REQUIRE_LINUX26) \
	$(PERL_PACKAGES)

# Packages that do not work for fsg3v4.

# crosstool-native is not available (and therefore neither is optware-devel)
# nfs-kernel is not useful, cause the kernel does not have NFSD enabled
# ufsd is only for NSLU2 firmware

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	crosstool-native optware-devel ufsd \
	\
	amule \
	antinat asterisk \
	asterisk14 asterisk14-chan-capi \
	asterisk16 asterisk16-addons \
	busybox \
	chillispot \
	dhcp \
	ecl eggdrop \
	fcgi \
	gdb \
	ldconfig \
	libpcap loudmouth \
	monotone \
	net-snmp net-tools netatalk nmap \
	phoneme-advanced \
	qemu qemu-libc-i386 \
	quagga \
	\
	openser \
	snort \
	strace \
	uemacs \

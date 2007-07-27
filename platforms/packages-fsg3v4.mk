# Packages that *only* work for fsg3v4 - do not just put new packages here.
SPECIFIC_PACKAGES = \
	fsg3v4-bootstrap \
	$(PERL_PACKAGES)

# Packages that do not work for fsg3v4.
# First group is unsorted.
# Second group is config.sub related.
# Third group are sorted dependency trees.

# crosstool-native is not available (and therefore neither is optware-devel)
# modutils is for 2.4 kernels only
# nfs-kernel is not useful, cause the kernel does not have NFSD enabled
# ufsd is only for NSLU2 firmware

BROKEN_PACKAGES = \
	crosstool-native optware-devel modutils nfs-kernel ufsd \
	\
	antinat asterisk \
	asterisk14 asterisk14-chan-capi \
	busybox \
	chillispot \
	dhcp \
	ecl eggdrop \
	fcgi freeradius \
	gdb \
	gnuplot \
	ldconfig \
	libpcap loudmouth \
	monotone \
	net-snmp net-tools netatalk nmap \
	phoneme-advanced \
	qemu qemu-libc-i386 quagga \
	\
	oleo \
	openser \
	snort \
	strace \
	swi-prolog \
	uemacs \

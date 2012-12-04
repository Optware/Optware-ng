# Packages that *only* work for fsg3v4 - do not just put new packages here.
SPECIFIC_PACKAGES = \
	fsg3v4-optware-bootstrap fsg3v4-kernel-modules \
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
	chillispot \
	clinkcc \
	cpufrequtils \
	dcled \
	dhcp \
	ecl eggdrop \
	erl-ejabberd \
	fcgi \
	gdb \
	golang \
	ldconfig \
	loudmouth \
	net-snmp net-tools netatalk nmap \
	opensips \
	phoneme-advanced \
	ppp \
	qemu qemu-libc-i386 \
	quagga \
	\
	sandbox \
	snort \
	softflowd \
	strace \
	uemacs \
	vte xchat \

ARPING_CONFIG_ENVS := ac_cv_header_net_bpf_h=no

E2FSPROGS_VERSION := 1.40.3
E2FSPROGS_IPK_VERSION := 5

TSHARK_VERSION := 1.2.12
TSHARK_IPK_VERSION := 1

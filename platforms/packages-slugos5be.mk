PERL_MAJOR_VER = 5.10
LIBNSL_SO_DIR = $(TARGET_TOP)/staging/armv5teb-linux-gnueabi/lib

SPECIFIC_PACKAGES = \
	optware-bootstrap \
	redis \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	alsa-lib \
	bitchx \
	golang \
	gtk ipac-ng iptables iptraf ldconfig \
	nfs-utils \
	puppy qemu softflowd \
	vte xchat \

ARPING_CONFIG_ENVS := ac_cv_header_net_bpf_h=no

SLANG_VERSION := 2.2.2
SLANG_IPK_VERSION := 1

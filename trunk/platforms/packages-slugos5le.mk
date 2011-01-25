PERL_MAJOR_VER = 5.10
LIBNSL_SO_DIR = $(TARGET_TOP)/staging/armv5te-linux-gnueabi/lib

SPECIFIC_PACKAGES = \
	optware-bootstrap \
	redis \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	aiccu \
	atk \
	bitchx \
	gtk iptraf ldconfig \
	nfs-utils \
	puppy qemu \
	softflowd \
	vte xchat \

ARPING_CONFIG_ENVS := ac_cv_header_net_bpf_h=no

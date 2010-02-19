PERL_MAJOR_VER = 5.10
LIBNSL_SO_DIR = $(TARGET_TOP)/staging/armv5te-linux-gnueabi/lib

SPECIFIC_PACKAGES = \
	optware-bootstrap \
	redis \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	atk \
	bitchx \
	gtk ipac-ng iptables iptraf ldconfig \
	nfs-utils \
	puppy qemu \
	softflowd \
	transcode vte xchat \

SLANG_VERSION := 2.2.2
SLANG_IPK_VERSION := 1
# Packages that *only* work for ds101g+ - do not just put new packages here.
SPECIFIC_PACKAGES = \
	ipkg-opt \
	ds101g-kernel-modules \
	ds101g-kernel-modules-fuse \
	ds101-bootstrap \
	crosstool-native \
	redis \
	py-ctypes \
	$(PERL_PACKAGES) \

# Packages that do not work for ds101g+.
BROKEN_PACKAGES = \
	btg \
	ecl \
	erl-ejabberd \
	golang \
	kamailio \
	ldconfig \
	mkvtoolnix \
	sandbox \
	telldus-core \

REDIS_VERSION := 2.0.4
REDIS_PATCHES := $(SOURCE_DIR)/redis/no_sa_sigaction.patch

SAMBA34_VERSION := 3.4.13
SAMBA34_IPK_VERSION := 2

SAMBA35_VERSION := 3.5.9
SAMBA35_IPK_VERSION := 1

STRACE_VERSION := 4.5.17
STRACE_IPK_VERSION := 1

ZNC_CONFIG_ARGS:=gl_cv_cc_visibility=true

# Packages that *only* work for nslu2 - do not just put new packages here.
SPECIFIC_PACKAGES = unslung-feeds unslung-feeds-unstable unslung-devel crosstool-native ufsd \
	$(PERL_PACKAGES) \

# Packages that do not work for nslu2.
BROKEN_PACKAGES = \
	btg \
	erl-ejabberd \
	sandbox \
	golang \
	libtorrent-rasterbar \
	linphone \
	mkvtoolnix \
	strongswan \
	telldus-core \

BTPD_VERSION=0.13
BTPD_IPK_VERSION=2

DBUS_LDFLAGS := -lpthread

NETATALK_CONFIG_ARGS := netatalk_cv_HAVE_SENDFILE=no netatalk_cv_HAVE_BROKEN_LINUX_SENDFILE=no

PSMISC_VERSION := 22.11

SAMBA34_VERSION := 3.4.13
SAMBA34_IPK_VERSION := 2

SAMBA35_VERSION := 3.5.9
SAMBA35_IPK_VERSION := 1

TRANSMISSION_CONFIG_ENV := ac_cv_func_pread=no ac_cv_func_pwrite=no

ZNC_CONFIG_ARGS:=gl_cv_cc_visibility=true

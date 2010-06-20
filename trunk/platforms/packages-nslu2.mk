# Packages that *only* work for nslu2 - do not just put new packages here.
SPECIFIC_PACKAGES = unslung-feeds unslung-feeds-unstable unslung-devel crosstool-native ufsd \
	$(PERL_PACKAGES) \

# Packages that do not work for nslu2.
BROKEN_PACKAGES = \
	sandbox \
	golang \
	linphone \

BTPD_VERSION=0.13
BTPD_IPK_VERSION=2

DBUS_LDFLAGS := -lpthread

PERL_MAJOR_VER := 5.10

# Packages that *only* work for mssii - do not just put new packages here.
SPECIFIC_PACKAGES = \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \
	ipkg-opt \
	cacao \
	redis \

# Packages that do not work for mssii.
BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	amule \
	libcapi20 \
	bluez-utils bluez-hcidump \
	iptraf \
	ldconfig \
	qemu qemu-libc-i386 \
	sandbox \
	gtk vte xchat \

CUPS_GCC_DOES_NOT_SUPPORT_PIE := 1

E2FSPROGS_VERSION := 1.40.3
E2FSPROGS_IPK_VERSION := 1

DBUS_NO_DAEMON_LDFLAGS := 1

REDIS_VERSION := 2.0.4
REDIS_PATCHES := $(SOURCE_DIR)/redis/no_sa_sigaction.patch

TSHARK_VERSION := 1.2.12
TSHARK_IPK_VERSION := 1

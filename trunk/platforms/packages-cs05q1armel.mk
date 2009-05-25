PERL_MAJOR_VER := 5.10

# Packages that *only* work for mssii - do not just put new packages here.
SPECIFIC_PACKAGES = \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \
	ipkg-opt \
	cacao mono \

# Packages that do not work for mssii.
BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	amule \
	asterisk14-chan-capi libcapi20 \
	bluez-utils bluez-hcidump \
	iptraf \
	ldconfig \
	qemu qemu-libc-i386 \
	gtk vte xchat \
	microdc2 \
	taged transcode slimserver \

E2FSPROGS_VERSION := 1.40.3
E2FSPROGS_IPK_VERSION := 1

DBUS_VERSION := 1.1.2
DBUS_IPK_VERSION := 1

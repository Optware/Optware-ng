# Packages that *only* work for mssii - do not just put new packages here.
SPECIFIC_PACKAGES = \
	lspro-optware-bootstrap \
	teraprov2-optware-bootstrap \
	hpmv2-optware-bootstrap \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \
	libc-dev \

# Packages that do not work for mssii.
BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	amule \
	asterisk14-chan-capi libcapi20 \
	iptraf \
	ldconfig \
	monotone \
	player \
	qemu qemu-libc-i386 \

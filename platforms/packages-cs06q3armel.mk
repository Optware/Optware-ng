# Packages that *only* work for mssii - do not just put new packages here.
SPECIFIC_PACKAGES = \
	lspro-optware-bootstrap \
	teraprov2-optware-bootstrap \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

# Packages that do not work for mssii.
BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	asterisk14-chan-capi libcapi20 \
	gnuplot \
	iptraf \
	ldconfig \
	monotone \
	player \
	puppy \
	qemu qemu-libc-i386 \
	socat \
	uemacs \

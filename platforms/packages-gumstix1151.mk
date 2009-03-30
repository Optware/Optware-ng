SPECIFIC_PACKAGES = \
	ipkg-opt \
	libiconv \
	$(PERL_PACKAGES) \
	binutils gcc libc-dev \

# iptraf: sys/types.h and linux/types.h conflicting
BROKEN_PACKAGES = \
	buildroot uclibc-opt \
	$(filter-out libstdc++, $(UCLIBC_BROKEN_PACKAGES)) \
	amule asterisk \
	bluez-hcidump \
	dump ficy \
	fuppes \
	gloox \
	gtmess \
	iptraf \
	ircd-hybrid \
	mdadm \
	player \
	puppy sendmail \
	scrobby \

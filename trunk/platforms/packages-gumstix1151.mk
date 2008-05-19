SPECIFIC_PACKAGES = \
	ipkg-opt \
	libiconv \
	$(PERL_PACKAGES) \

# iptraf: sys/types.h and linux/types.h conflicting
BROKEN_PACKAGES = \
	buildroot uclibc-opt \
	$(filter-out libstdc++, $(UCLIBC_BROKEN_PACKAGES)) \
	amule asterisk \
	bluez-hcidump \
	dump ficy \
	fuppes \
	gtmess \
	iptraf \
	ircd-hybrid \
	mdadm \
	player \
	puppy sendmail \

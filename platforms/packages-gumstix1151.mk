SPECIFIC_PACKAGES = \
	ipkg-opt \
	libiconv \
	$(PERL_PACKAGES) \

# iptraf: sys/types.h and linux/types.h conflicting
BROKEN_PACKAGES = \
	buildroot uclibc-opt \
	$(filter-out libstdc++ newsbeuter, $(UCLIBC_BROKEN_PACKAGES)) \
	amule asterisk \
	bluez-hcidump chillispot \
	dump ficy \
	gtmess \
	iptraf \
	ircd-hybrid \
	mdadm \
	player \
	puppy sendmail \
	util-linux

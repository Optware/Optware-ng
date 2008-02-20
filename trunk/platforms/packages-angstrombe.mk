# Packages that *only* work for angstrombe - do not just put new packages here.
SPECIFIC_PACKAGES = \
	ipkg-opt \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

# Packages that do not work for angstrombe.
BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	antinat asterisk asterisk14 asterisk14-chan-capi \
	atftp atk bitchx bzflag \
	cabextract dircproxy \
	ecl eggdrop fcgi gconv-modules gtk \
	inadyn ipac-ng iptables iptraf ivorbis-tools \
	ldconfig libcapi20 madplay microcom monotone mt-daapd \
	netatalk nfs-utils nget \
	phoneme-advanced player puppy py-soappy \
	slrn spandsp qemu squeak vte xchat 

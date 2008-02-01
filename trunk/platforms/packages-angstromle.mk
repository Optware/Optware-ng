# Packages that *only* work for angstromle - do not just put new packages here.
SPECIFIC_PACKAGES = \
	ipkg-opt \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

# Packages that do not work for angstromle.
BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \

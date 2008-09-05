# Packages that *only* work for nslu2 - do not just put new packages here.
SPECIFIC_PACKAGES = unslung-feeds unslung-devel crosstool-native ufsd \
	$(PERL_PACKAGES) \

# Packages that do not work for nslu2.
# lftp - runtime segfaults
BROKEN_PACKAGES = \


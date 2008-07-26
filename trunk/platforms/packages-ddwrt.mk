SPECIFIC_PACKAGES = \
	firmware-oleg \
	$(PERL_PACKAGES) \
	$(UCLIBC_SPECIFIC_PACKAGES) \

# firmware-oleg 1) needs specific version of old make; 2) requires wl500g toolchain
# rssh: rssh needs wordexp() to compile
BROKEN_PACKAGES = \
	$(UCLIBC_BROKEN_PACKAGES) \
	cdrtools \
	centerim \
	dansguardian \
	dialog \
	gambit-c \
	iptraf \
	libdvb \
	ltrace \
	nget \
	player \
	rssh \
	taglib \
	\
	firmware-oleg \

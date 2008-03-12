SPECIFIC_PACKAGES = \
	firmware-oleg \
	$(PERL_PACKAGES) \
	$(UCLIBC_SPECIFIC_PACKAGES) \

# firmware-oleg 1) needs specific version of old make; 2) requires wl500g toolchain
# lirc depends on firmware-oleg
# rssh: rssh needs wordexp() to compile
BROKEN_PACKAGES = \
	$(UCLIBC_BROKEN_PACKAGES) \
	dansguardian \
	dialog \
	gambit-c \
	libdvb \
	ltrace \
	nget \
	player \
	rssh \
	taglib \
	zsh \
	\
	firmware-oleg \
	lirc \


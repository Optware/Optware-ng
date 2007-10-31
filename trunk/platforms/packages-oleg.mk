SPECIFIC_PACKAGES = \
	firmware-oleg \
	$(UCLIBC_SPECIFIC_PACKAGES) \

# firmware-oleg 1) needs specific version of old make; 2) requires wl500g toolchain
# lirc depends on firmware-oleg
BROKEN_PACKAGES = \
	$(UCLIBC_BROKEN_PACKAGES) \
	dansguardian \
	dialog \
	gambit-c \
	libdvb \
	ltrace \
	nget \
	player \
	zsh \
	\
	firmware-oleg \
	lirc \


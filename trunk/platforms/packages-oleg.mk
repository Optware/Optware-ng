SPECIFIC_PACKAGES = \
	firmware-oleg \
	$(PERL_PACKAGES) \
	$(UCLIBC++_SPECIFIC_PACKAGES) \

# firmware-oleg 1) needs specific version of old make; 2) requires wl500g toolchain
# lirc depends on firmware-oleg
# rssh: rssh needs wordexp() to compile
BROKEN_PACKAGES = \
	$(UCLIBC++_BROKEN_PACKAGES) \
	cdrtools \
	centerim \
	clinkcc \
	dansguardian \
	dialog \
	gambit-c \
	gloox \
	libdvb \
	ltrace \
	minidlna \
	motor \
	nget \
	player \
	rssh \
	scrobby \
	taglib \
	\
	firmware-oleg \
	lirc \

JAMVM_VERSION = 1.5.1
JAMVM_IPK_VERSION = 1

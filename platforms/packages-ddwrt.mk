SPECIFIC_PACKAGES = \
	firmware-oleg \
	$(PERL_PACKAGES) \
	$(UCLIBC++_SPECIFIC_PACKAGES) \

# firmware-oleg 1) needs specific version of old make; 2) requires wl500g toolchain
# rssh: rssh needs wordexp() to compile
BROKEN_PACKAGES = \
	$(UCLIBC++_BROKEN_PACKAGES) \
	cdrtools \
	centerim \
	dansguardian \
	dialog \
	gambit-c \
	gloox \
	iptraf \
	libdvb \
	ltrace \
	minidlna \
	motor \
	nget \
	player \
	rssh \
	sane-backends \
	scrobby \
	taglib \
	\
	firmware-oleg \

JAMVM_VERSION = 1.5.1
JAMVM_IPK_VERSION = 1

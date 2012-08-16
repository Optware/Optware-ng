SPECIFIC_PACKAGES = \
	firmware-oleg \
	$(PERL_PACKAGES) \
	$(UCLIBC++_SPECIFIC_PACKAGES) \

# firmware-oleg 1) needs specific version of old make; 2) requires wl500g toolchain
# rssh: rssh needs wordexp() to compile
BROKEN_PACKAGES = \
	$(UCLIBC++_BROKEN_PACKAGES) \
	boost \
	clinkcc \
	centerim \
	dansguardian \
	dialog \
	erl-ejabberd \
	gambit-c \
	gloox \
	golang \
	iptraf \
	libdvb \
	minidlna \
	motor \
	nget \
	rssh \
	sandbox \
	scrobby \
	taglib \
	\
	firmware-oleg \

JAMVM_VERSION = 1.5.1
JAMVM_IPK_VERSION = 1

#SAMBA35_CONFIG_ARGS_EXTRA := --without-cifsmount --without-cifsumount

PYTHON3_CONFIGURE_ENV:=ac_cv_func_wcsftime=no

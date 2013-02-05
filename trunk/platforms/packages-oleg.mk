SPECIFIC_PACKAGES = \
	firmware-oleg \
	$(PERL_PACKAGES) \
	$(UCLIBC++_SPECIFIC_PACKAGES) \

# firmware-oleg 1) needs specific version of old make; 2) requires wl500g toolchain
# lirc depends on firmware-oleg
# rssh: rssh needs wordexp() to compile
BROKEN_PACKAGES = \
	$(UCLIBC++_BROKEN_PACKAGES) \
	boost \
	centerim \
	clinkcc \
	dansguardian \
	dialog \
	erl-ejabberd \
	gambit-c \
	gloox \
	golang \
	libdvb \
	minidlna \
	motor \
	nget \
	rssh \
	sandbox \
	scrobby \
	taglib \
	libunistring \
	firmware-oleg \
	lirc \
	asterisk18 \

JAMVM_VERSION = 1.5.1
JAMVM_IPK_VERSION = 1

MD5DEEP_LDFLAGS := -lpthread

PYTHON3_CONFIGURE_ENV:=ac_cv_func_wcsftime=no

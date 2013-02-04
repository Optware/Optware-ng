SPECIFIC_PACKAGES = \
	syno-x07-optware-bootstrap \
	syno-x07-kernel-modules \
	binutils gcc libc-dev \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

# btpd: arm-marvell-linux-gnu/sys-include/sys/epoll.h:62: error: syntax error before "uint32_t"
# mkvtoolnix:
#	src/merge/mkvmerge.cpp: In function `void parse_arg_compression(const std::string&, track_info_c&)':
#	src/merge/mkvmerge.cpp:302: internal compiler error: Segmentation fault
BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	aiccu \
	amule \
	boost \
	btg \
	btpd \
	busybox \
	centerim \
	erl-ejabberd \
	gambit-c gnu-smalltalk \
	iptraf \
	libtorrent-rasterbar \
	ldconfig libcapi20 \
	linphone \
	mkvtoolnix \
	ntop \
	p7zip \
	puppy \
	qemu \
	rtpproxy \
	sablevm \
	sandbox \
	tesseract-ocr \
	varnish \

CUPS_GCC_DOES_NOT_SUPPORT_PIE := 1

DBUS_NO_DAEMON_LDFLAGS := 1
DBUS_LDFLAGS := -lpthread

DSPAM_CPPFLAGS := -DULLONG_MAX=18446744073709551615ULL

E2FSPROGS_VERSION := 1.40.3
E2FSPROGS_IPK_VERSION := 5

JAMVM_VERSION = 1.5.1
JAMVM_IPK_VERSION = 1

LIBMICROHTTPD_CPPFLAGS := -DSSIZE_MAX=LONG_MAX

PSMISC_VERSION := 22.11

PY-LXML_VERSION := 2.1.1
PY-LXML_IPK_VERSION := 1

SAMBA34_VERSION := 3.4.13
SAMBA34_IPK_VERSION := 2

SAMBA35_VERSION := 3.5.9
SAMBA35_IPK_VERSION := 1

SUDO_CPPFLAGS := -DNGROUPS_MAX=32

TSHARK_VERSION := 1.2.12
TSHARK_IPK_VERSION := 1

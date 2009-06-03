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
	amule \
	asterisk14-chan-capi \
	btg \
	btpd \
	busybox \
	centerim \
	gambit-c gnu-smalltalk \
	iptraf \
	libtorrent-rasterbar \
	ldconfig libcapi20 \
	mkvtoolnix \
	ntop \
	p7zip \
	puppy \
	qemu sablevm \
	tesseract-ocr \
	varnish \

E2FSPROGS_VERSION := 1.40.3
E2FSPROGS_IPK_VERSION := 5

JAMVM_VERSION = 1.5.1
JAMVM_IPK_VERSION = 1

DBUS_VERSION := 1.1.1
DBUS_IPK_VERSION := 3

PY-LXML_VERSION := 2.1.1
PY-LXML_IPK_VERSION := 1

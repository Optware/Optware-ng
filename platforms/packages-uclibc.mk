# Packages that do not work for uclibc
# locale-archive: not needed
# moc - conflicting types for '__glibc_strerror_r'
# alsa-oss:	In file included from alsa-oss.c:732:
# 		stdioemu.c:40:19: error: libio.h: No such file or directory
UCLIBC_BROKEN_PACKAGES = \
	locale-archive \
	9base \
	alsa-oss \
	bzflag \
	delegate \
	fish \
	gnu-smalltalk \
	launchtool ldconfig \
	moe mtr \
	newsbeuter \
	nfs-server nfs-utils \
	nmon \
	qemu qemu-libc-i386 \
	syx \
	xchat \

UCLIBC++_BROKEN_PACKAGES = \
	$(UCLIBC_BROKEN_PACKAGES) \
	boost \
	btg \
	cppunit \
	libstdc++ \
	libtorrent-rasterbar \
	mkvtoolnix \
	player \
	srecord \
	uncia \
	znc \

# Packages that *only* work for uclibc++ - do not just put new packages here.
UCLIBC++_SPECIFIC_PACKAGES = \
	libuclibc++ buildroot uclibc-opt ipkg-opt \

## UCLIBC_NG value indicates whether uclibc used is uclibc-ng
ifneq ($(CROSS_CONFIGURATION_UCLIBC_VERSION),)
ifeq ($(shell test $(shell echo $(CROSS_CONFIGURATION_UCLIBC_VERSION) | cut -d '.' -f 1) -gt 0; echo $$?),0)
UCLIBC_NG=yes
endif
endif

UCLIBC_NG ?= no

ifneq ($(UCLIBC_NG), yes)

SUDO_UPSTREAM_VERSION := 1.7.4p6
SUDO_VERSION := 1.7.4.6
SUDO_IPK_VERSION := 1

E2FSPROGS_VERSION := 1.41.12
E2FSPROGS_IPK_VERSION := 1

HTOP_VERSION := 0.8.3
HTOP_IPK_VERSION := 2

M4_VERSION := 1.4.13

MXML_VERSION := 2.5
MXML_IPK_VERSION := 1

MKVTOOLNIX_VERSION ?= 2.9.8
MKVTOOLNIX_IPK_VERSION ?= 2

PSMISC_VERSION := 22.13

SLANG_VERSION := 2.1.4
SLANG_IPK_VERSION := 1

endif

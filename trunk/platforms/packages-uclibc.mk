# Packages that do not work for uclibc
# moc - conflicting types for '__glibc_strerror_r'
# alsa-oss:	In file included from alsa-oss.c:732:
# 		stdioemu.c:40:19: error: libio.h: No such file or directory
UCLIBC_BROKEN_PACKAGES = \
	 9base \
	alsa-oss \
	 bzflag \
	 cairo \
         delegate \
	 fcgi fish \
	 gnu-smalltalk ice jabberd \
	 launchtool ldconfig \
	 moe mtr \
	 newsbeuter \
	 nfs-server nfs-utils \
	nmon \
	opensips \
	 pango \
	 qemu qemu-libc-i386 quickie \
	 sm syx \
	 uemacs \
	 gtk vte xchat \
	 xauth xaw xcursor xfixes xft xrender xmu xt xterm \

UCLIBC++_BROKEN_PACKAGES = \
	$(UCLIBC_BROKEN_PACKAGES) \
	boost \
	btg \
	libstdc++ \
	libtorrent-rasterbar \
	mkvtoolnix \
	player \
	srecord \
	uncia \
        znc \

# Packages that *only* work for uclibc - do not just put new packages here.
UCLIBC++_SPECIFIC_PACKAGES = \
	libuclibc++ buildroot uclibc-opt ipkg-opt \

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

MKVTOOLNIX_VERSION := 2.9.8
MKVTOOLNIX_IPK_VERSION := 2

PSMISC_VERSION := 22.13

SLANG_VERSION := 2.1.4
SLANG_IPK_VERSION := 1

# Packages that do not work for uclibc
# moc - conflicting types for '__glibc_strerror_r'
UCLIBC_BROKEN_PACKAGES = \
	 9base \
	 bzflag \
	 cairo \
         delegate \
	 fcgi fish \
	 gnu-smalltalk ice iptables jabberd \
	 launchtool ldconfig \
	 moe mtr \
	 newsbeuter \
	 nfs-server nfs-utils \
	opensips \
	 pango \
	 qemu qemu-libc-i386 quickie \
	 sm syx \
	 uemacs \
	 gtk vte xchat \
	 xauth xaw xcursor xfixes xft xrender xmu xt xterm

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

# Packages that *only* work for uclibc - do not just put new packages here.
UCLIBC++_SPECIFIC_PACKAGES = \
	libuclibc++ buildroot uclibc-opt ipkg-opt \

HDPARM_VERSION := 9.28

M4_VERSION := 1.4.13

MXML_VERSION := 2.5
MXML_IPK_VERSION := 1

MKVTOOLNIX_VERSION := 2.9.8
MKVTOOLNIX_IPK_VERSION := 2

SLANG_VERSION := 2.1.4
SLANG_IPK_VERSION := 1

# Packages that do not work for uclibc
# moc - conflicting types for '__glibc_strerror_r'
UCLIBC_BROKEN_PACKAGES = \
	 9base \
	 bzflag \
	 cairo \
	 fcgi fish \
	 gnu-smalltalk ice iptables jabberd \
	 launchtool ldconfig \
	 moe mtr \
	 newsbeuter \
	 nfs-server nfs-utils \
	 pango \
	 qemu qemu-libc-i386 quickie \
	 sm syx \
	 uemacs \
	 gtk vte xchat \
	 xauth xaw xcursor xfixes xft xrender xmu xt xterm

UCLIBC++_BROKEN_PACKAGES = \
	$(UCLIBC_BROKEN_PACKAGES) \
	 boost \
	 libstdc++ \
	 libtorrent-rasterbar \

# Packages that *only* work for uclibc - do not just put new packages here.
UCLIBC++_SPECIFIC_PACKAGES = \
	libuclibc++ buildroot uclibc-opt ipkg-opt \

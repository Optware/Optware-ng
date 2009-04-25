# Packages that do not work for uclibc
# moc - conflicting types for '__glibc_strerror_r'
UCLIBC++_BROKEN_PACKAGES = \
	 9base \
	 boost \
	 bzflag \
	 cairo \
	 fcgi fish \
	 gnu-smalltalk gtk ice iptables jabberd \
	 launchtool ldconfig libstdc++ \
	 moe mtr \
	 newsbeuter \
	 nfs-server nfs-utils \
	 pango \
	 qemu qemu-libc-i386 quickie \
	 sm syx \
	 uemacs vte \
	 xauth xaw xchat xcursor \
	 xfixes xft xrender xmu xt xterm

# Packages that *only* work for uclibc - do not just put new packages here.
UCLIBC++_SPECIFIC_PACKAGES = \
	libuclibc++ buildroot uclibc-opt ipkg-opt \

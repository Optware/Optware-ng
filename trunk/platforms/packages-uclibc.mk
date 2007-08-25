# Packages that do not work for uclibc
# moc - conflicting types for '__glibc_strerror_r'
UCLIBC_BROKEN_PACKAGES = \
	 bzflag \
	 fcgi fish \
	 gnu-smalltalk gtk ice iptables jabberd \
	 jamvm launchtool ldconfig libstdc++ \
	 moe monotone mtr \
	 newsbeuter \
	 nfs-server nfs-utils \
	 pango \
	 qemu qemu-libc-i386 quickie \
	 sm syx \
	 taglib uemacs vte \
	 xauth xaw xchat xcursor \
	 xfixes xft xrender xmu xt xterm

# Packages that *only* work for uclibc - do not just put new packages here.
UCLIBC_SPECIFIC_PACKAGES = \
	libuclibc++ buildroot uclibc-opt ipkg-opt \
	$(PERL_PACKAGES) \

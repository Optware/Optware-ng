# Packages that do not work for uclibc
UCLIBC_BROKEN_PACKAGES = \
	 bzflag dansguardian \
	 fcgi fish ggrab \
	 gphoto2 libgphoto2 \
	 gtk ice iperf iptables jabberd \
	 jamvm launchtool ldconfig libstdc++ libdvb monotone \
	 mtr nfs-server nfs-utils nget \
	 pango \
	 qemu qemu-libc-i386 quickie sm \
	 taglib vte xauth xaw xchat xcursor \
	 xfixes xft xrender xmu xt xterm

# Packages that *only* work for uclibc - do not just put new packages here.
UCLIBC_SPECIFIC_PACKAGES = \
	libuclibc++ buildroot uclibc-opt ipkg-opt \
	$(PERL_PACKAGES) \

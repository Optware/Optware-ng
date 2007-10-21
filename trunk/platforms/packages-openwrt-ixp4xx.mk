SPECIFIC_PACKAGES = \
	libiconv \
	$(UCLIBC_SPECIFIC_PACKAGES) \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

BROKEN_PACKAGES = \
	9base \
	buildroot uclibc-opt \
	cairo \
	chillispot \
	ecl \
	fcgi ficy fish \
	gnu-smalltalk gnuplot gtk \
	hpijs \
	ice iptables \
	kismet \
	lame launchtool ldconfig \
	moc monotone mtr \
	nfs-server nfs-utils nickle ntop \
	pango puppy \
	qemu qemu-libc-i386 quagga quickie \
	sm spindown syx \
	transcode \
	uemacs util-linux \
	vsftpd vte \
	xt xmu xauth xaw xchat xterm


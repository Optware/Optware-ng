SPECIFIC_PACKAGES = \
	libiconv \
	module-init-tools \
	$(UCLIBC_SPECIFIC_PACKAGES) \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

BROKEN_PACKAGES = \
	buildroot uclibc-opt \
	asterisk \
	cairo \
	chillispot \
	ecl \
	fcgi ficy fish \
	gnu-smalltalk gnuplot gtk \
	hpijs \
	ice iptables \
	jamvm \
	kismet \
	lame launchtool ldconfig \
	moc monotone mtr \
	nfs-server nfs-utils nickle ntop \
	pango puppy \
	qemu qemu-libc-i386 quagga quickie \
	sm syx \
	transcode \
	uemacs usbutils util-linux \
	vsftpd vte \
	xt xmu xauth xaw xchat xterm


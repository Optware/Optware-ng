SPECIFIC_PACKAGES = \
	libiconv \
	module-init-tools \
	$(UCLIBC_SPECIFIC_PACKAGES) \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

BROKEN_PACKAGES = \
	buildroot uclibc-opt \
	asterisk \
	chillispot \
	ecl \
	fcgi ficy fish \
	gdb gnu-smalltalk gnugo gnuplot gtk \
	hpijs \
	ice iptables \
	jamvm \
	kismet \
	lame launchtool ldconfig libopensync \
	moc monotone msynctool mtr multitail \
	nfs-server nfs-utils ntop \
	oleo obexftp \
	pango par2cmdline phoneme-advanced puppy \
	qemu qemu-libc-i386 quagga quickie \
	sm syx \
	transcode \
	uemacs usbutils util-linux \
	vsftpd vte \
	xt xmu xauth xaw xchat xterm


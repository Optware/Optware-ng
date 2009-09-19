SPECIFIC_PACKAGES = \
	$(UCLIBC_SPECIFIC_PACKAGES) \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \
	binutils gcc libc-dev \
	libiconv \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	9base \
	buildroot uclibc-opt \
	cairo \
	ecl \
	fcgi ficy fish \
	gloox \
	gnu-smalltalk gtmess gtk \
	hpijs hplip \
	inferno \
	ice iptables \
	lame launchtool ldconfig \
	moc mtr \
	nfs-server nfs-utils nickle ntop \
	pango puppy \
	qemu qemu-libc-i386 quickie \
	sandbox \
	sm syx \
	transcode \
	uemacs \
	vte \
	xt xmu xauth xaw xchat xterm

JAMVM_VERSION = 1.5.1
JAMVM_IPK_VERSION = 1

# compilation error starting with 1.2beta3
#mdf.c: In function 'speex_echo_state_init_mc':
#fixed_arm5e.h:41: error: 'asm' operand requires impossible reload
#fixed_arm5e.h:41: error: 'asm' operand requires impossible reload
SPEEX_VERSION := 1.2beta2
SPEEX_IPK_VERSION := 1

PERL_MAJOR_VER = 5.10

SPECIFIC_PACKAGES = \
	$(PACKAGES_REQUIRE_LINUX26) \
	$(PERL_PACKAGES) \
	ipkg-opt \
	cacao \
	redis \
	binutils gcc libc-dev \

# samba34: smbd/notify_inotify.c:29:25: error: sys/inotify.h: No such file or directory
BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	asterisk \
	bitchx btg \
	clinkcc \
	ecl \
	fuppes \
	gtk \
	ivorbis-tools lcd4linux \
	ldconfig \
	nfs-utils puppy \
	qemu \
	samba34 \
	samba35 \
	util-linux \
	vlc vte \
	x264 xaw xchat xterm

SLANG_VERSION := 2.2.2
SLANG_IPK_VERSION := 1

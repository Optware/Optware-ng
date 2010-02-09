PERL_MAJOR_VER := 5.10
PERL_BUILD_EXTRA_ENV := CROSS_COMPILE=ppc_4xxFP

SPECIFIC_PACKAGES = \
        ipkg-opt \
        $(PACKAGES_REQUIRE_LINUX26) \
        $(PERL_PACKAGES) \
	binutils gcc libc-dev \

BROKEN_PACKAGES = \
        $(PACKAGES_ONLY_WORK_ON_LINUX24) \
	amule bitchx cairo clamav dmsetup inferno iptables \
	iptraf ldconfig mpdscribble nfs-utils openser opensips \
	pango pixman puppy qemu vlc vte xchat \
	x264 lm-sensors

ATFTP_EXTRA_PATCHES = $(ATFTP_SOURCE_DIR)/argz.h.patch

BUSYBOX_BUILD_EXTRA_ENV := CROSS_COMPILE=$(TARGET_CROSS)

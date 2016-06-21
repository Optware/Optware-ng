SPECIFIC_PACKAGES = \
	libiconv uclibc-opt \
	$(PERL_PACKAGES) \
	binutils libc-dev gcc \
	ipkg-static \

# iptraf: sys/types.h and linux/types.h conflicting
# wayland: requires signalfd, timerfd_* and epoll_create1
# inferno: failing with asm-arm.S:30: Error: invalid constant (900001) after fixup
# libexplain: kernel-related issues
# node: linux/auxvec.h: No such file or directory
# libopenzwave: linux/hidraw.h: No such file or directory
BROKEN_PACKAGES = \
	6relayd \
	buildroot \
	$(UCLIBC_BROKEN_PACKAGES) \
	clamav \
	rssh \
	sandbox \
	lm-sensors \
	libopensync msynctool obexftp \
	modutils \
	wayland \
	inferno \
	libexplain \
	node \
	libopenzwave py-openzwave

STRACE_VERSION = 4.5.20
STRACE_IPK_VERSION = 1
STRACE_SOURCE = strace-$(STRACE_VERSION).tar.bz2
STRACE_UNZIP = bzcat
STRACE_PATCHES = $(STRACE_SOURCE_DIR)/strace-4.5.20_sockaddr.patch $(STRACE_SOURCE_DIR)/strace-4.5.20_USE_PROCFS.patch

PERL_MAJOR_VER := 5.22

HTOP_VERSION := 1.0.1
HTOP_IPK_VERSION := 1

TSHARK_VERSION := 1.2.12
TSHARK_IPK_VERSION := 1

FFMPEG_CONFIG_OPTS := --disable-armv6

OPENSSL_VERSION := 1.0.2

BOOST_ADDITIONAL_LIBS:= atomic \
			chrono \
			container \
			graph-parallel \
			locale \
			log \
			timer \
			exception \
			serialization \
			wave

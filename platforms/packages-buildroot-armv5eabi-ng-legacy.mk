SPECIFIC_PACKAGES = \

# iptraf: sys/types.h and linux/types.h conflicting
# wayland: requires signalfd, timerfd_* and epoll_create1
# inferno: failing with asm-arm.S:30: Error: invalid constant (900001) after fixup
# libexplain: kernel-related issues
# node: linux/auxvec.h: No such file or directory
# libopenzwave: linux/hidraw.h: No such file or directory
# unionfs-fuse:
#	builds/unionfs-fuse/src/uioctl.h:19:2: error: declaration of type name as array of voids
#	  UNIONFS_STATS_BYTES_WRITTEN = _IOW('E', 3, void),
BROKEN_PACKAGES = \
	6relayd \
	buildroot \
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
	libopenzwave py-openzwave \
	unionfs-fuse

STRACE_VERSION = 4.5.20
STRACE_IPK_VERSION = 1
STRACE_SOURCE = strace-$(STRACE_VERSION).tar.bz2
STRACE_UNZIP = bzcat
STRACE_PATCHES = $(STRACE_SOURCE_DIR)/strace-4.5.20_sockaddr.patch $(STRACE_SOURCE_DIR)/strace-4.5.20_USE_PROCFS.patch

HTOP_VERSION := 1.0.1
HTOP_IPK_VERSION := 2

FFMPEG_CONFIG_OPTS := --disable-armv6

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

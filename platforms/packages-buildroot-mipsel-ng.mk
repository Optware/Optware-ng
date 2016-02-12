SPECIFIC_PACKAGES = \
	libiconv uclibc-opt \
	$(PERL_PACKAGES) \
	binutils libc-dev gcc \
	ipkg-static \

# iptraf: sys/types.h and linux/types.h conflicting
# clamav: missing fanotify_init and fanotify_mark system calls in 2.6.22.19 kernel
BROKEN_PACKAGES = \
	buildroot \
	$(UCLIBC_BROKEN_PACKAGES) \
	bluez-hcidump \
	clamav \
	golang \
	inferno \
	phoneme-advanced \
	rssh \
	sandbox \
	libopensync msynctool obexftp \
	modutils

PERL_MAJOR_VER := 5.20

TSHARK_VERSION := 1.2.12
TSHARK_IPK_VERSION := 1

FFMPEG_CONFIG_OPTS := --disable-mipsfpu

OPENSSL_VERSION := 1.0.2

MPD_VERSION := 0.19.9
MPD_IPK_VERSION := 2

BOOST_VERSION := 1_59_0
BOOST_IPK_VERSION := 2
BOOST_EXTERNAL_JAM := no
BOOST_GCC_CONF := tools/build/src/tools/gcc
BOOST_JAM_ROOT := tools/build
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

### boost packages
## These are packages that depend
## on boost. Since boost libraries SONAMEs
## change with every new release,
## ipk versions have to be bumped
## and packages re-built on every
## boost upgrade.
## Use
### make boost-packages-dirclean
## to clean all boost packages build dirs

LIBTORRENT-RASTERBAR_IPK_VERSION := 1

MKVTOOLNIX_VERSION := 8.8.0
MKVTOOLNIX_IPK_VERSION := 1
MKVTOOLNIX_ADDITIONAL_PATCHES=$(SOURCE_DIR)/mkvtoolnix/8.8.0/llround-lround.patch

PLAYER_IPK_VERSION := 3

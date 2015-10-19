SPECIFIC_PACKAGES = \
	libiconv uclibc-opt \
	$(PERL_PACKAGES) \
	binutils libc-dev gcc \
	ipkg-static \

# iptraf: sys/types.h and linux/types.h conflicting
BROKEN_PACKAGES = \
	buildroot \
	$(UCLIBC_BROKEN_PACKAGES) \
	bluez-hcidump \
	golang \
	inferno \
	phoneme-advanced \
	rssh \
	sandbox \
	libopensync msynctool obexftp \
	modutils

PERL_MAJOR_VER := 5.20
PERL_LDFLAGS_EXTRA = -lgcc_s

PSMISC_VERSION := 22.21

LIBTORRENT_VERSION := 0.13.4
LIBTORRENT_IPK_VERSION := 1

RTORRENT_VERSION := 0.9.4
RTORRENT_IPK_VERSION := 1
RTORRENT_AUTOMAKE=automake-1.14
RTORRENT_ACLOCAL=aclocal-1.14
RTORRENT_CPPUNIT := yes

STRACE_VERSION := 4.10
STRACE_IPK_VERSION := 1
STRACE_SOURCE := strace-$(STRACE_VERSION).tar.xz
STRACE_UNZIP := xzcat
STRACE_PATCHES :=
STRACE_CPPFLAGS_PRE := -I$(SOURCE_DIR)/strace/include

TSHARK_VERSION := 1.2.12
TSHARK_IPK_VERSION := 1

FFMPEG_CONFIG_OPTS := --disable-mipsfpu

ZNC_CONFIG_ARGS:=gl_cv_cc_visibility=true

BINUTILS_VERSION := 2.25.1
BINUTILS_IPK_VERSION := 1

OPENSSL_VERSION := 1.0.2

E2FSPROGS_VERSION := 1.42.12
E2FSPROGS_IPK_VERSION := 1

M4_VERSION := 1.4.17

MPD_VERSION := 0.19.9
MPD_IPK_VERSION := 1

BOOST_VERSION := 1_59_0
BOOST_IPK_VERSION := 1
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

MKVTOOLNIX_VERSION := 8.3.0
MKVTOOLNIX_IPK_VERSION := 1
MKVTOOLNIX_ADDITIONAL_PATCHES=$(SOURCE_DIR)/mkvtoolnix/8.3.0/llround.patch

PLAYER_IPK_VERSION := 1

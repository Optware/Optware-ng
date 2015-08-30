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
	gtmess \
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
RTORRENT_AUTOMAKE=$(AUTOMAKE_NEW)
RTORRENT_ACLOCAL=$(ACLOCAL_NEW)
RTORRENT_CPPUNIT := yes

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

BOOST_VERSION := 1_57_0
BOOST_IPK_VERSION := 2
BOOST_EXTERNAL_JAM := no
BOOST_GCC_CONF := tools/build/src/tools/gcc
BOOST_JAM_ROOT := tools/build
BOOST_ADDITIONAL_LIBS:= atomic \
			chrono \
			container \
			locale \
			log \
			timer \
			exception \
			serialization \
			wave

MKVTOOLNIX_VERSION := 7.7.0
MKVTOOLNIX_IPK_VERSION := 1

MPD_VERSION := 0.19.9
MPD_IPK_VERSION := 1

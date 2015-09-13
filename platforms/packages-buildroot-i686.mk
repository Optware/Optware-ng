SPECIFIC_PACKAGES = \
	glibc-opt \
	glibc-locale \
	$(PERL_PACKAGES) \
	binutils libc-dev gcc \
	ipkg-static \

BROKEN_PACKAGES = \
	ecl \
	gnu-smalltalk \
	qemu \
	qemu-libc-i386 \
	syx \
	ldconfig modutils samba2

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

ZNC_CONFIG_ARGS:=gl_cv_cc_visibility=true

BINUTILS_VERSION := 2.25.1
BINUTILS_IPK_VERSION := 1

OPENSSL_VERSION := 1.0.2

E2FSPROGS_VERSION := 1.42.12
E2FSPROGS_IPK_VERSION := 1

M4_VERSION := 1.4.17

MPD_VERSION := 0.19.9
MPD_IPK_VERSION := 2

TAR_VERSION := 1.28
TAR_IPK_VERSION := 1

BOOST_VERSION := 1_59_0
BOOST_IPK_VERSION := 1
BOOST_EXTERNAL_JAM := no
BOOST_GCC_CONF := tools/build/src/tools/gcc
BOOST_JAM_ROOT := tools/build
BOOST_ADDITIONAL_LIBS:= atomic \
			chrono \
			container \
			context \
			coroutine \
			coroutine2 \
			graph-parallel \
			locale \
			log \
			timer \
			exception \
			serialization \
			test \
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

LIBTORRENT-RASTERBAR_IPK_VERSION := 4

MKVTOOLNIX_VERSION := 8.3.0
MKVTOOLNIX_IPK_VERSION := 3

PLAYER_IPK_VERSION := 8

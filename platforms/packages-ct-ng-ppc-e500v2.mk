SPECIFIC_PACKAGES = \
	glibc-opt \
	glibc-locale \
	$(PERL_PACKAGES) \
	binutils libc-dev gcc \
	ipkg-static \

# lm-sensors: No rule to make target `sys/io.h'
# inferno: inferno/Linux/power/include/fpuctl.h:31:2: error: impossible constraint in 'asm'
BROKEN_PACKAGES = \
	ecl \
	gnu-smalltalk \
	golang \
	phoneme-advanced \
	qemu \
	qemu-libc-i386 \
	syx \
	inferno \
	lm-sensors \
	ldconfig modutils samba2

PERL_MAJOR_VER := 5.22

OPENSSL_VERSION := 1.0.2

TAR_VERSION := 1.28
TAR_IPK_VERSION := 1

FFMPEG_OLD_CONFIG_OPTS := --disable-altivec

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

MKVTOOLNIX_VERSION := 8.8.0
MKVTOOLNIX_IPK_VERSION := 1

PLAYER_IPK_VERSION := 1

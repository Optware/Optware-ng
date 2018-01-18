SPECIFIC_PACKAGES = \

# lm-sensors: No rule to make target `sys/io.h'
# libmemcache: memcache.c: error: invalid application of ‘sizeof’ to incomplete type ‘struct addrinfo’
BROKEN_PACKAGES = \
	$(GOLANG_PACKAGES) \
	ecl \
	gnu-smalltalk \
	golang \
	phoneme-advanced \
	qemu \
	qemu-libc-i386 \
	syx \
	libmemcache \
	lm-sensors \
	ldconfig modutils samba2 node010

FFMPEG_CONFIG_OPTS := --disable-altivec
FFMPEG_OLD_CONFIG_OPTS := --disable-altivec

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

GOTTY_VERSION:=0.0.13
GOTTY_IPK_VERSION:=1

SHELL2HTTP_VERSION:=1.8
SHELL2HTTP_IPK_VERSION:=1

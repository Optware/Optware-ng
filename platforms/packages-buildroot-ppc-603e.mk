SPECIFIC_PACKAGES = \
	glibc-opt \
	glibc-locale \
	$(PERL_PACKAGES) \
	binutils libc-dev gcc \
	ipkg-static \

# lm-sensors: No rule to make target `sys/io.h'
BROKEN_PACKAGES = \
	ecl \
	gnu-smalltalk \
	golang \
	phoneme-advanced \
	qemu \
	qemu-libc-i386 \
	syx \
	lm-sensors \
	ldconfig modutils samba2

PERL_MAJOR_VER := 5.22

OPENSSL_VERSION := 1.0.2

TAR_VERSION := 1.28
TAR_IPK_VERSION := 1

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

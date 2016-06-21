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

PERL_MAJOR_VER := 5.22

OPENSSL_VERSION := 1.0.2

TAR_VERSION := 1.28
TAR_IPK_VERSION := 1

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

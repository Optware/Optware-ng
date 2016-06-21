SPECIFIC_PACKAGES = \
	libiconv uclibc-opt \
	$(PERL_PACKAGES) \
	binutils libc-dev gcc \
	ipkg-static \

# iptraf: sys/types.h and linux/types.h conflicting
BROKEN_PACKAGES = \
	buildroot \
	$(UCLIBC_BROKEN_PACKAGES) \
	rssh \
	sandbox \
	libopensync msynctool obexftp \
	modutils

PERL_MAJOR_VER := 5.22

TSHARK_VERSION := 1.2.12
TSHARK_IPK_VERSION := 1

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

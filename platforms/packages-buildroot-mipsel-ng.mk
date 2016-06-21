SPECIFIC_PACKAGES = \
	libiconv uclibc-opt \
	$(PERL_PACKAGES) \
	binutils libc-dev gcc \
	ipkg-static \

# iptraf: sys/types.h and linux/types.h conflicting
# clamav: missing fanotify_init and fanotify_mark system calls in 2.6.22.19 kernel
# lm-sensors: No rule to make target `sys/io.h'
# libopenzwave: linux/hidraw.h: No such file or directory
BROKEN_PACKAGES = \
	buildroot \
	$(UCLIBC_BROKEN_PACKAGES) \
	clamav \
	golang \
	inferno \
	phoneme-advanced \
	rssh \
	sandbox \
	lm-sensors \
	libopensync msynctool obexftp \
	modutils \
	libopenzwave py-openzwave

PERL_MAJOR_VER := 5.22

TSHARK_VERSION := 1.2.12
TSHARK_IPK_VERSION := 1

FFMPEG_CONFIG_OPTS := --disable-mipsfpu

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

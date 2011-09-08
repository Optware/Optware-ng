SPECIFIC_PACKAGES = \
	ipkg-opt libiconv uclibc-opt \
	$(PERL_PACKAGES) \
	binutils libc-dev \

# iptraf: sys/types.h and linux/types.h conflicting
BROKEN_PACKAGES = \
	buildroot \
	$(UCLIBC_BROKEN_PACKAGES) \
	asterisk16 \
	bluez-hcidump \
	ficy \
	fuppes \
	gcc \
	gtmess \
	\
	rssh \
	sandbox \
	\
	btg clinkcc libopensync msynctool obexftp \

PERL_MAJOR_VER=5.10

PSMISC_VERSION := 22.11

RTORRENT_VERSION := 0.8.0
RTORRENT_IPK_VERSION := 2

TSHARK_VERSION := 1.2.12
TSHARK_IPK_VERSION := 1

FFMPEG_CONFIG_OPTS := --disable-armv6

ZNC_CONFIG_ARGS:=gl_cv_cc_visibility=true

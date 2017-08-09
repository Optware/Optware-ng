SPECIFIC_PACKAGES = \

# iptraf: sys/types.h and linux/types.h conflicting
BROKEN_PACKAGES = \
	buildroot \
	rssh \
	sandbox \
	libopensync msynctool obexftp \
	modutils \
	node

FFMPEG_CONFIG_OPTS := --disable-armv6

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

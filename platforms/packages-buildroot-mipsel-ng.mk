SPECIFIC_PACKAGES = \

# iptraf: sys/types.h and linux/types.h conflicting
# clamav: missing fanotify_init and fanotify_mark system calls in 2.6.22.19 kernel
# lm-sensors: No rule to make target `sys/io.h'
# libopenzwave: linux/hidraw.h: No such file or directory
BROKEN_PACKAGES = \
	buildroot \
	clamav \
	inferno \
	phoneme-advanced \
	rssh \
	sandbox \
	lm-sensors \
	libopensync msynctool obexftp \
	modutils \
	libopenzwave py-openzwave

FFMPEG_CONFIG_OPTS := --disable-mipsfpu

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

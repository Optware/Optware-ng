SPECIFIC_PACKAGES = \

# lm-sensors: No rule to make target `sys/io.h'
# inferno: inferno/Linux/power/include/fpuctl.h:31:2: error: impossible constraint in 'asm'
BROKEN_PACKAGES = \
	$(GOLANG_PACKAGES) \
	ecl \
	gnu-smalltalk \
	golang \
	phoneme-advanced \
	qemu \
	qemu-libc-i386 \
	syx \
	inferno \
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

RUBY_ARCH := powerpc-linux-gnuspe

# Packages that *only* work for slugosbe - do not just put new packages here.
SPECIFIC_PACKAGES = \
	ipkg-opt \
	module-init-tools \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

# Packages that do not work for slugosbe.
# puppy: usb_io.h:33:23: error: linux/usb.h: No such file or directory
# heyu: xwrite.c:34:30: error: linux/serial_reg.h: No such file or directory
# iptraf: sys/types.h and linux/types.h conflicting, the ipk for unslung seems to work though
BROKEN_PACKAGES = \
	gdb \
	heyu \
	iptraf \
	ldconfig modutils \
	monotone \
	netatalk \
	nfs-utils \
	oleo \
	par2cmdline \
	phoneme-advanced \
	puppy \
	py-psycopg \
	qemu \
	ushare \


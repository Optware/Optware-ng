# Packages that *only* work for slugosbe - do not just put new packages here.
SPECIFIC_PACKAGES = \
	ipkg-opt \
	$(PERL_PACKAGES) \

# Packages that do not work for slugosbe.
# puppy: usb_io.h:33:23: error: linux/usb.h: No such file or directory
# heyu: xwrite.c:34:30: error: linux/serial_reg.h: No such file or directory
BROKEN_PACKAGES = \
	atftp \
	ftpd-topfield \
	gdb \
	heyu \
	ldconfig modutils \
	monotone \
	netatalk \
	nfs-utils \
	par2cmdline \
	puppy \
	py-psycopg \
	qemu \
	ushare \


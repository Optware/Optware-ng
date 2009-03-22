# Packages that *only* work for slugosbe - do not just put new packages here.
SPECIFIC_PACKAGES = \
	ipkg-opt \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

# Packages that do not work for slugosbe.
# puppy: usb_io.h:33:23: error: linux/usb.h: No such file or directory
# heyu: xwrite.c:34:30: error: linux/serial_reg.h: No such file or directory
# iptraf: sys/types.h and linux/types.h conflicting, the ipk for unslung seems to work though
# softflowd: staging/opt/include/pcap/pcap.h:339: error: conflicting types for 'bpf_filter' (with armeb-linux/include/net/bpf.h:779)
BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	heyu \
	iptraf \
	ldconfig \
	netatalk \
	puppy \
	qemu \
	softflowd \
	ushare \
	\
	atk gtk nfs-utils transcode \
	vte xchat \

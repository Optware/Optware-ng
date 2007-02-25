SPECIFIC_PACKAGES = \
	libiconv \
	py-ctypes \
	ts101-kernel-modules \
	$(UCLIBC_SPECIFIC_PACKAGES) \

BROKEN_PACKAGES = \
	$(UCLIBC_BROKEN_PACKAGES) \
         atop bitlbee \
         chillispot \
	 ecl freeze ftpcopy gnupg \
         openser \
         ser squeak \
         tethereal ushare vsftpd \
	 uclibc-opt \
	 buildroot

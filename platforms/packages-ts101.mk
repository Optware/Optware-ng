SPECIFIC_PACKAGES = \
	libiconv \
	py-ctypes \
	ts101-kernel-modules \
	$(UCLIBC_SPECIFIC_PACKAGES) \

BROKEN_PACKAGES = \
	$(UCLIBC_BROKEN_PACKAGES) \
         atop bitlbee \
         bluez-utils chillispot \
	 ecl freeze ftpcopy gnupg \
	 gtk ice \
	 kissdx \
 	 mediatomb \
         obexftp openobex openser \
         pango \
         screen \
         ser squeak \
         tethereal ushare vsftpd \
	 uclibc-opt \
	 buildroot

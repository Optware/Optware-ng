SPECIFIC_PACKAGES = \
	libiconv \
	py-ctypes \
	ts101-kernel-modules \
	$(UCLIBC_SPECIFIC_PACKAGES) \

BROKEN_PACKAGES = \
	$(UCLIBC_BROKEN_PACKAGES) \
         atop \
         chillispot \
	 ecl \
	 freeze \
	 ftpcopy \
         openser \
         ser \
	 squeak \
         ushare \
	 vsftpd \
	 uclibc-opt \
	 buildroot

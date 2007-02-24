SPECIFIC_PACKAGES = \
	libiconv \
	py-ctypes \
	ts101-kernel-modules \
	$(UCLIBC_SPECIFIC_PACKAGES) \

BROKEN_PACKAGES = \
	$(UCLIBC_BROKEN_PACKAGES) \
         appweb atop bitlbee \
         bzflag bluez-utils chillispot cdargs \
	 cups cyrus-imapd dansguardian eaccelerator \
	 ecl fcgi fish ficy freeze ftpcopy gnupg \
	 gtk gphoto2 libgphoto2 ice \
	 jabberd jamvm kismet kissdx ldconfig libdvb \
 	 mediatomb metalog memtester monotone mrtg \
         mtr mysql-connector-odbc nfs-server nfs-utils nget \
         nload noip obexftp openser \
         pango par2cmdline \
         pound qemu qemu-libc-i386 quagga quickie \
         rrdcollect rrdtool sablevm screen sendmail \
         ser sm snort squeak taglib \
         tethereal ushare vsftpd vte \
         xauth xaw xchat xmu xt \
         xterm perl-spamassassin spamassassin \
	 Mail-SpamAssassin microcom \
	 mod-python perl-dbd-sqlite uclibc-opt \
	 buildroot

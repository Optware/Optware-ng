SPECIFIC_PACKAGES = \
	libiconv \
	py-ctypes \
	$(UCLIBC_SPECIFIC_PACKAGES) \

# Most of these broken packages are caused by either this:
#
# checking host system type... Invalid configuration `powerpc-linux-uclibc': system `uclibc' not recognized
# configure: error: /bin/bash ./support/config.sub powerpc-linux-uclibc failed
#
# or this:
#
# *** You must have either have gettext support in your C library, or use the
# *** GNU gettext library. (http://www.gnu.org/software/gettext/gettext.html

BROKEN_PACKAGES = \
	$(UCLIBC_BROKEN_PACKAGES) \
         appweb asterisk14 asterisk14-chan-capi at bind bitlbee bsdmainutils \
         bzflag bluez-utils chillispot cdargs cherokee cups cyrus-imapd \
         dansguardian dcraw eaccelerator ecl erl-escript erl-yaws fcgi \
         fish flip ficy flac gnupg gnutls gtk \
         gphoto2 libgphoto2 hexcurse ice id3lib iksemel irssi \
         jabberd jamvm kismet ldconfig libdvb libgcrypt lighttpd \
         loudmouth mediatomb metalog memtester monotone mpd mrtg \
         mtr mysql-connector-odbc netcat nfs-server nfs-utils nget nmap \
         nload noip ntop nzbget obexftp opencdk openser \
         pango par2cmdline pcre php php-apache php-fcgi postfix \
         pound python25 py-simpy qemu qemu-libc-i386 quagga quickie \
         rc rrdcollect rrdtool ruby sablevm screen sendmail \
         ser sm snort snownews squeak swi-prolog taglib \
         tethereal transcode upslug2 ushare vlc vsftpd vte \
         w3m wput xauth xaw xchat xmu xt \
         xterm zip

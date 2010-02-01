PERL_MAJOR_VER = 5.10

SPECIFIC_PACKAGES = \
	optware-bootstrap kernel-modules \
	$(PACKAGES_REQUIRE_LINUX26) \
	py-ctypes \
	$(PERL_PACKAGES) \
	binutils gcc libc-dev \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
         asterisk14-chan-capi atftp btg dialog gconv-modules \
         iptraf ivorbis-tools lcd4linux ldconfig libcapi20 libnsl \
         mpdscribble nagios-plugins ntop opendchub openser opensips postfix \
         puppy qemu rrdcollect rrdtool samba sandbox \
         vte xchat \

E2FSPROGS_VERSION := 1.40.3
E2FSPROGS_IPK_VERSION := 5

SLANG_VERSION := 2.2.2
SLANG_IPK_VERSION := 1

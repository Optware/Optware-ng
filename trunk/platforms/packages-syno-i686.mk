PERL_MAJOR_VER = 5.10

SPECIFIC_PACKAGES = \
	optware-bootstrap kernel-modules \
	$(PACKAGES_REQUIRE_LINUX26) \
	py-ctypes \
	$(PERL_PACKAGES) \
	binutils gcc libc-dev \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
         asterisk14-chan-capi atftp btg dialog ecl \
         iptraf ivorbis-tools lcd4linux ldconfig libcapi20 \
         mpdscribble nagios-plugins ntop opendchub opensips \
         puppy qemu \
	samba samba34 samba35 \
	sandbox slimserver \
         vte xchat \

BIND_CONFIG_ARGS := --disable-epoll

BITLBEE_VERSION := 1.2.8
BITLBEE_IPK_VERSION := 1

ERLANG_SMP := --enable-smp-support

E2FSPROGS_VERSION := 1.40.3
E2FSPROGS_IPK_VERSION := 5

OPENSSH_CONFIG_OPTS := --without-stackprotect

SLANG_VERSION := 2.2.2
SLANG_IPK_VERSION := 1

SQUID_EPOLL := --disable-epoll

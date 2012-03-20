PERL_MAJOR_VER = 5.10

SPECIFIC_PACKAGES = \
	optware-bootstrap kernel-modules \
	$(PACKAGES_REQUIRE_LINUX26) \
	py-ctypes \
	redis \
	$(PERL_PACKAGES) \
	binutils gcc libc-dev \

# samba36: auth/pampass.c:46:31: error: security/pam_appl.h: No such file or directory
BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
         asterisk14-chan-capi atftp btg dialog ecl \
         iptraf ivorbis-tools lcd4linux ldconfig libcapi20 \
         mpdscribble nagios-plugins ntop opendchub opensips \
         puppy qemu \
	samba samba34 samba35 samba36 \
	sandbox slimserver \
         vte xchat \

BIND_CONFIG_ARGS := --disable-epoll

ERLANG_SMP := --enable-smp-support

E2FSPROGS_VERSION := 1.40.3
E2FSPROGS_IPK_VERSION := 5

OPENSSH_CONFIG_OPTS := --without-stackprotect

SQUID_EPOLL := --disable-epoll

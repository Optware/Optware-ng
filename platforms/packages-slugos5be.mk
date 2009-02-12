PERL_MAJOR_VER = 5.10
LIBNSL_SO_DIR = $(TARGET_TOP)/staging/armv5teb-linux-gnueabi/lib

SPECIFIC_PACKAGES = \
	optware-bootstrap \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	amule \
	bitchx bzflag \
	cyrus-imapd emacs22 finch fuppes \
	gtk ipac-ng iptables iptraf ldconfig \
	microdc2 monotone mpd netatalk nfs-utils pinentry \
	player proftpd puppy mod-python qemu softflowd \
	taged transcode vsftpd vte xchat \

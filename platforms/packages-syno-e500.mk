SPECIFIC_PACKAGES = \
	ipkg-opt \
	$(PACKAGES_REQUIRE_LINUX26) \
	py-ctypes \
	$(PERL_PACKAGES) \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	asterisk14 asterisk14-chan-capi asterisk16 asterisk16-addons \
	atftp \
	finch gconv-modules iptraf \
	ldconfig libcapi20 mediatomb monotone openser \
	pciutils procps puppy ser socat transcode \
	vsftpd x264 lm-sensors \
	slimserver \

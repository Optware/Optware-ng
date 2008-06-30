SPECIFIC_PACKAGES = \
	syno-x07-optware-bootstrap \
	syno-x07-kernel-modules \
	binutils gcc libc-dev \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

# freeradius: (1.0.5 builds ok, starting from 1.1.7)
#	in linking radiusd, libc_nonshared.a(elf-init.oS): In function `__libc_csu_init':
#	elf-init.c:(.text+0x44): undefined reference to `__init_array_end'
# asterisk16: need to make net-snmp optional
BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	amule \
	asterisk asterisk14-chan-capi \
	asterisk16 asterisk16-addons \
	busybox \
	classpath \
	freeradius \
	gambit-c gconv-modules gnu-smalltalk \
	gift giftcurs gift-ares gift-fasttrack gift-gnutella gift-openft gift-opennap \
	iptraf \
	ldconfig libcapi20 libextractor \
	monotone \
	ncftp net-snmp ntop \
	openser p7zip \
	player puppy \
	qemu sablevm \
	varnish \

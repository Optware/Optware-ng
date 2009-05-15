SPECIFIC_PACKAGES = \
	ipkg-opt libiconv uclibc-opt \
	$(PERL_PACKAGES) \
	binutils gcc libc-dev \

# iptraf: sys/types.h and linux/types.h conflicting
BROKEN_PACKAGES = \
	buildroot \
	$(UCLIBC_BROKEN_PACKAGES) \
	asterisk \
	bluez-hcidump \
	dump ficy \
	fuppes \
	gloox \
	gtmess \
	inferno \
	iptraf \
	ircd-hybrid \
	mdadm \
	player \
	puppy sendmail \
	scrobby \
	\
	microdc2 \
	mysql-connector-odbc \
	mod-python \
	rssh \
	taged \
	transcode \
	util-linux \
	slimserver \

PERL_MAJOR_VER=5.10

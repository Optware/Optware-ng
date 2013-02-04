SPECIFIC_PACKAGES = \
	ipkg-opt \
	libiconv \
	py-ctypes \
	ts101-kernel-modules \
	$(PERL_PACKAGES) \

# samba34: smbd/trans2.c: In function `get_lanman2_dir_entry':./../lib/util/byteorder.h:114: error: inconsistent operand constraints in an `asm'
BROKEN_PACKAGES = \
	$(UCLIBC_BROKEN_PACKAGES) \
	ecl ficy \
	erl-ejabberd \
	gift giftcurs \
	gift-ares gift-fasttrack gift-gnutella \
	gift-openft gift-opennap \
	gloox \
	golang \
	gtmess \
	hplip \
	iptraf \
	linphone \
	nfs-server nfs-utils \
	samba34 \
	samba35 \
	samba36 \
	sane-backends \
	sandbox \
	util-linux \
	ts101-kernel-modules

E2FSPROGS_VERSION := 1.40.3
E2FSPROGS_IPK_VERSION := 5

RTORRENT_VERSION := 0.8.2
RTORRENT_IPK_VERSION := 2

X264_UPSTREAM_VERSION := snapshot-20081231-2245
X264_VERSION := 0.0.20081231-svn2245

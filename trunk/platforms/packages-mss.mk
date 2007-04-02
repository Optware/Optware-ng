# Packages that *only* work for mss - do not just put new packages here.
SPECIFIC_PACKAGES = 

# Packages that do not work for mss.
BROKEN_PACKAGES = \
	amule apache apr-util \
	$(ASTERISK_PACKAGES) \
	clamav \
	elinks \
	$(ERLANG_PACKAGES) \
	gambit-c gawk \
	jamvm \
	gnokii \
	ldconfig \
	mod-fastcgi mod-python monotone \
	ntp \
	php-apache py-lxml \
	qemu qemu-libc-i386 quickie \
	sablevm svn \
	tethereal \
	varnish \
	wxbase \


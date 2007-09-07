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
	gnu-smalltalk \
	jamvm \
	gnokii \
	ldconfig \
	ltrace \
	mod-fastcgi mod-python monotone \
	newt ntp \
	php-apache player py-lxml \
	qemu qemu-libc-i386 quickie \
	sablevm svn \
	tshark \
	wxbase \


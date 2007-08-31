# Packages that *only* work for ts72xx - do not just put new packages here.
SPECIFIC_PACKAGES = 

# Packages that do not work for ts72xx.
BROKEN_PACKAGES = \
	appweb \
	$(ASTERISK_PACKAGES) \
	classpath clearsilver dict dspam \
	eaccelerator ecl \
	$(ERLANG_PACKAGES) \
	freeradius \
	ldconfig lighttpd \
	motion mysql nfs-server nrpe \
	oleo \
	php php-apache pure-ftpd py-mysql py-soappy \
	qemu qemu-libc-i386 quagga rtorrent \
	sablevm tshark transcode w3m xvid \


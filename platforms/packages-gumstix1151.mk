SPECIFIC_PACKAGES = \
	libiconv \
	$(UCLIBC_SPECIFIC_PACKAGES) \

# openldap: daemon.o: In function `slapd_daemon_task':
# 	servers/slapd/daemon.c:1973: undefined reference to `in6addr_any'
BROKEN_PACKAGES = \
	$(UCLIBC_BROKEN_PACKAGES) \
	dansguardian \
	gambit-c \
	htop \
	libdvb \
	ltrace \
	nget \
	oleo \
	openldap \
	par2cmdline \
	zsh \


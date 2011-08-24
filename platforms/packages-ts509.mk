PERL_MAJOR_VER = 5.10

SPECIFIC_PACKAGES = \
	$(PACKAGES_REQUIRE_LINUX26) \
	$(PERL_PACKAGES) \
	ipkg-opt \
	cacao \
	redis \
	binutils gcc libc-dev \

# samba36: auth/pampass.c:46:31: error: security/pam_appl.h: No such file or directory
BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	asterisk \
	bitchx \
	ecl \
	ivorbis-tools lcd4linux \
	ldconfig puppy \
	qemu \
	samba35 \
        samba36 \

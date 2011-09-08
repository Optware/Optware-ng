# Packages that *only* work for ds101 - do not just put new packages here.
SPECIFIC_PACKAGES = \
	ds101-bootstrap \
	ds101-kernel-modules \

# Packages that do not work for ds101.
BROKEN_PACKAGES = \
	bpalogin \
	erl-ejabberd \
	freeradius \
	golang \
	imagemagick \
	ldconfig lftp \
	motion \
	qemu qemu-libc-i386 \
	sandbox \
	telldus-core \

PSMISC_VERSION := 22.11

SAMBA34_VERSION := 3.4.13
SAMBA34_IPK_VERSION := 2

SAMBA35_VERSION := 3.5.9
SAMBA35_IPK_VERSION := 1

ZNC_CONFIG_ARGS:=gl_cv_cc_visibility=true

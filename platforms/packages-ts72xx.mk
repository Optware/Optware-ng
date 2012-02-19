# Packages that *only* work for ts72xx - do not just put new packages here.
SPECIFIC_PACKAGES = 

# Packages that do not work for ts72xx.
BROKEN_PACKAGES = \
	asterisk \
	erl-ejabberd \
	ldconfig \
	mkvtoolnix \
	py-bazaar-ng py-simplejson \
	qemu qemu-libc-i386 \
	sandbox \
	slrn spandsp \
	telldus-core \

PSMISC_VERSION := 22.11

SAMBA34_VERSION := 3.4.13
SAMBA34_IPK_VERSION := 2

SAMBA35_VERSION := 3.5.9
SAMBA35_IPK_VERSION := 1

ZNC_CONFIG_ARGS:=gl_cv_cc_visibility=true

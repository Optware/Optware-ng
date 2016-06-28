# Packages that do not work for uclibc
# locale-archive: not needed
# moc - conflicting types for '__glibc_strerror_r'
# alsa-oss:	In file included from alsa-oss.c:732:
# 		stdioemu.c:40:19: error: libio.h: No such file or directory
BROKEN_PACKAGES += \
	locale-archive \
	glibc-opt glibc-locale \
	9base \
	alsa-oss \
	bzflag \
	delegate \
	fish \
	gnu-smalltalk \
	launchtool ldconfig \
	moe mtr \
	newsbeuter \
	nfs-server nfs-utils \
	nmon \
	qemu qemu-libc-i386 \
	syx \
	xchat \

SPECIFIC_PACKAGES += libiconv uclibc-opt

TSHARK_VERSION := 1.2.12
TSHARK_IPK_VERSION := 1

TAR_VERSION := 1.26
TAR_IPK_VERSION := 1

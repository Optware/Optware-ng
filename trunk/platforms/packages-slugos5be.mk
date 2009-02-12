PERL_MAJOR_VER = 5.10
PERL_ERRNO_H_DIR = $(TARGET_TOP)/staging/armv5teb-linux/usr/include
LIBNSL_SO_DIR = $(TARGET_TOP)/staging/armv5teb-linux-gnueabi/lib

SPECIFIC_PACKAGES = \
	optware-bootstrap \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \

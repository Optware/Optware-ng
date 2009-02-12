PERL_MAJOR_VER = 5.10
PERL_ERRNO_H_DIR = $(shell cd $(BASE_DIR)/../../slugos/tmp/staging/armv5teb-linux/usr/include; pwd)

SPECIFIC_PACKAGES = \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \

BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \

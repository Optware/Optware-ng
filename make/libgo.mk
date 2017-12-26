###########################################################
#
# libgo
#
###########################################################

LIBGO_VERSION?=9.0.0
LIBGO_MAJOR=$(shell echo $(LIBGO_VERSION) | sed 's/\..*//')

LIBGO_DIR=libgo-$(LIBGO_VERSION)
LIBGO_LIBNAME=libgo.so
LIBGO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBGO_DESCRIPTION=Runtime Go support library, needed for dynamically linked Go programs
LIBGO_SECTION=util
LIBGO_PRIORITY=optional
LIBGO_DEPENDS=
LIBGO_CONFLICTS=

LIBGO_LIBNAME_FULL=libgo.so.$(LIBGO_VERSION)
LIBGO_LIBNAME_MAJOR=libgo.so.$(LIBGO_MAJOR)

LIBGO_IPK_VERSION=3

LIBGO_TARGET_LIBDIR ?= $(TARGET_LIBDIR)

LIBGO_BUILD_DIR=$(BUILD_DIR)/libgo
LIBGO_SOURCE_DIR=$(SOURCE_DIR)/libgo
LIBGO_IPK_DIR=$(BUILD_DIR)/libgo-$(LIBGO_VERSION)-ipk
LIBGO_IPK=$(BUILD_DIR)/libgo_$(LIBGO_VERSION)-$(LIBGO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libgo-unpack libgo libgo-stage libgo-ipk libgo-clean libgo-dirclean

$(LIBGO_BUILD_DIR)/.configured: $(LIBGO_PATCHES) make/libgo.mk
	# we take libgo from gcc
	$(MAKE) gcc
	rm -rf $(BUILD_DIR)/$(LIBGO_DIR) $(@D)
	mkdir -p $(@D)
	cp -af $(GCC_BUILD_DIR)/$(GCC_TARGET_NAME)/libgo/.libs/$(LIBGO_LIBNAME_FULL) $(@D)/
	touch $@

libgo-unpack: $(LIBGO_BUILD_DIR)/.configured

$(LIBGO_BUILD_DIR)/.built: $(LIBGO_BUILD_DIR)/.configured
	rm -f $@
	touch $@

libgo: $(LIBGO_BUILD_DIR)/.built

$(LIBGO_BUILD_DIR)/.staged: $(LIBGO_BUILD_DIR)/.built
	rm -f $@
	$(INSTALL) -d $(STAGING_LIB_DIR)
	$(INSTALL) -m 644 $(@D)/$(LIBGO_LIBNAME_FULL) $(STAGING_LIB_DIR)
	(cd $(STAGING_LIB_DIR); \
	 ln -sf $(LIBGO_LIBNAME_FULL) $(LIBGO_LIBNAME); \
	 ln -sf $(LIBGO_LIBNAME_FULL) $(LIBGO_LIBNAME_MAJOR) \
	)
	touch $@

libgo-stage: $(LIBGO_BUILD_DIR)/.staged

$(LIBGO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libgo" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBGO_PRIORITY)" >>$@
	@echo "Section: $(LIBGO_SECTION)" >>$@
	@echo "Version: $(LIBGO_VERSION)-$(LIBGO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBGO_MAINTAINER)" >>$@
	@echo "Source: $(LIBGO_SITE)/$(LIBGO_SOURCE)" >>$@
	@echo "Description: $(LIBGO_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBGO_DEPENDS)" >>$@
	@echo "Conflicts: $(LIBGO_CONFLICTS)" >>$@

$(LIBGO_IPK): $(LIBGO_BUILD_DIR)/.built
	rm -rf $(LIBGO_IPK_DIR) $(BUILD_DIR)/libgo_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(LIBGO_IPK_DIR)$(TARGET_PREFIX)/lib
	$(INSTALL) -m 644 $(LIBGO_BUILD_DIR)/$(LIBGO_LIBNAME_FULL) $(LIBGO_IPK_DIR)$(TARGET_PREFIX)/lib
	(cd $(LIBGO_IPK_DIR)$(TARGET_PREFIX)/lib; \
	 ln -s $(LIBGO_LIBNAME_FULL) $(LIBGO_LIBNAME); \
	 ln -s $(LIBGO_LIBNAME_FULL) $(LIBGO_LIBNAME_MAJOR) \
	)
	$(MAKE) $(LIBGO_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBGO_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBGO_IPK_DIR)

libgo-ipk: $(LIBGO_IPK)

libgo-clean:
	rm -rf $(LIBGO_BUILD_DIR)/*

libgo-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBGO_DIR) $(LIBGO_BUILD_DIR) $(LIBGO_IPK_DIR) $(LIBGO_IPK)

libgo-check: $(LIBGO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^

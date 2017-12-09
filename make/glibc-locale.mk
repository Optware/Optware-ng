###########################################################
#
# glibc-locale
#
###########################################################

TARGET_BIN ?= $(shell cd $(TARGET_LIBDIR)/../bin; pwd)
TARGET_SHARE ?= $(shell cd $(TARGET_LIBDIR)/../share; pwd)

GLIBC_LOCALE_VERSION=$(GLIBC-OPT_VERSION)
GLIBC_LOCALE_IPK_VERSION=5

GLIBC_LOCALE_SOURCE=toolchain
GLIBC_LOCALE_DIR=glibc-locale-$(GLIBC_LOCALE_VERSION)
GLIBC_LOCALE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GLIBC_LOCALE_DESCRIPTION=glibc locale tools and data. Useful for targets with glibc patched to use $(TARGET_PREFIX)/lib/locale and $(TARGET_PREFIX)/share/i18n
GLIBC_LOCALE_SECTION=lib
GLIBC_LOCALE_PRIORITY=optional
GLIBC_LOCALE_DEPENDS=gconv-modules
GLIBC_LOCALE_CONFLICTS=

GLIBC_LOCALE_BUILD_DIR=$(BUILD_DIR)/glibc-locale
GLIBC_LOCALE_SOURCE_DIR=$(SOURCE_DIR)/glibc-locale
GLIBC_LOCALE_IPK_DIR=$(BUILD_DIR)/glibc-locale-$(GLIBC_LOCALE_VERSION)-ipk
GLIBC_LOCALE_IPK=$(BUILD_DIR)/glibc-locale_$(GLIBC_LOCALE_VERSION)-$(GLIBC_LOCALE_IPK_VERSION)_$(TARGET_ARCH).ipk

GLIBC_LOCALE_BIN?=$(strip \
	$(if $(filter syno-e500 syno-i686, $(OPTWARE_TARGET)), $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/$(GNU_TARGET_NAME)/bin, \
	$(if $(filter syno-x07, $(OPTWARE_TARGET)), $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/bin, \
	$(if $(filter vt4, $(OPTWARE_TARGET)), $(TARGET_LIBDIR)/../../../../target/bin, \
	$(TARGET_USRLIBDIR)/../bin))))

GLIBC_LOCALE_SHARE ?= $(TARGET_USRLIBDIR)/../share

.PHONY: glibc-locale-source glibc-locale-unpack glibc-locale glibc-locale-stage glibc-locale-ipk glibc-locale-clean glibc-locale-dirclean glibc-locale-check

$(GLIBC_LOCALE_BUILD_DIR)/.configured: $(GLIBC_LOCALE_PATCHES) make/glibc-locale.mk
	rm -rf $(BUILD_DIR)/$(GLIBC_LOCALE_DIR) $(@D)
	mkdir -p $(GLIBC_LOCALE_BUILD_DIR)
	touch $@

glibc-locale-unpack: $(GLIBC_LOCALE_BUILD_DIR)/.configured

$(GLIBC_LOCALE_BUILD_DIR)/.built: $(GLIBC_LOCALE_BUILD_DIR)/.configured
	rm -f $@
	touch $@

glibc-locale: $(GLIBC_LOCALE_BUILD_DIR)/.built

$(GLIBC_LOCALE_BUILD_DIR)/.staged: $(GLIBC_LOCALE_BUILD_DIR)/.built
	rm -f $@
	touch $@

glibc-locale-stage: $(GLIBC_LOCALE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/glibc-locale
#
$(GLIBC_LOCALE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: glibc-locale" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GLIBC_LOCALE_PRIORITY)" >>$@
	@echo "Section: $(GLIBC_LOCALE_SECTION)" >>$@
	@echo "Version: $(GLIBC_LOCALE_VERSION)-$(GLIBC_LOCALE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GLIBC_LOCALE_MAINTAINER)" >>$@
	@echo "Source: $(GLIBC_LOCALE_SOURCE)" >>$@
	@echo "Description: $(GLIBC_LOCALE_DESCRIPTION)" >>$@
	@echo "Depends: $(GLIBC_LOCALE_DEPENDS)" >>$@
	@echo "Conflicts: $(GLIBC_LOCALE_CONFLICTS)" >>$@

$(GLIBC_LOCALE_IPK): $(GLIBC_LOCALE_BUILD_DIR)/.built
	rm -rf $(GLIBC_LOCALE_IPK_DIR) $(BUILD_DIR)/glibc-locale_*_$(TARGET_ARCH).ipk
ifneq ($(LIBC_STYLE),uclibc)
	$(INSTALL) -d $(GLIBC_LOCALE_IPK_DIR)$(TARGET_PREFIX)/lib/locale \
		$(GLIBC_LOCALE_IPK_DIR)$(TARGET_PREFIX)/share/i18n \
		$(GLIBC_LOCALE_IPK_DIR)$(TARGET_PREFIX)/bin
	$(INSTALL) -m 755 $(GLIBC_LOCALE_BIN)/locale $(GLIBC_LOCALE_IPK_DIR)$(TARGET_PREFIX)/bin
	$(INSTALL) -m 755 $(GLIBC_LOCALE_BIN)/localedef $(GLIBC_LOCALE_IPK_DIR)$(TARGET_PREFIX)/bin
	cp -af $(GLIBC_LOCALE_SHARE)/i18n/* $(GLIBC_LOCALE_IPK_DIR)$(TARGET_PREFIX)/share/i18n
	$(INSTALL) -d $(GLIBC_LOCALE_IPK_DIR)/CONTROL
	$(INSTALL) -m 755 $(GLIBC_LOCALE_SOURCE_DIR)/postinst $(GLIBC_LOCALE_IPK_DIR)/CONTROL/postinst
endif
	$(MAKE) $(GLIBC_LOCALE_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GLIBC_LOCALE_IPK_DIR)

glibc-locale-ipk: $(GLIBC_LOCALE_IPK)

glibc-locale-clean:
	rm -rf $(GLIBC_LOCALE_BUILD_DIR)/*

glibc-locale-dirclean:
	rm -rf $(BUILD_DIR)/$(GLIBC_LOCALE_DIR) $(GLIBC_LOCALE_BUILD_DIR) $(GLIBC_LOCALE_IPK_DIR) $(GLIBC_LOCALE_IPK)

glibc-locale-check: $(GLIBC_LOCALE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^

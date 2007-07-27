###########################################################
#
# gconv-modules
#
###########################################################

GCONV_MODULES_VERSION=2.2.5
GCONV_MODULES_SOURCE=toolchain
GCONV_MODULES_DIR=gconv-modules-$(GCONV_MODULES_VERSION)
GCONV_MODULES_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
GCONV_MODULES_DESCRIPTION=Provides gconv modules missing from the firmware.  These are used by glibc's iconv() implementation.
GCONV_MODULES_SECTION=lib
GCONV_MODULES_PRIORITY=optional
GCONV_MODULES_DEPENDS=
GCONV_MODULES_CONFLICTS=

GCONV_MODULES_IPK_VERSION=7

GCONV_MODULES_BUILD_DIR=$(BUILD_DIR)/gconv-modules
GCONV_MODULES_SOURCE_DIR=$(SOURCE_DIR)/gconv-modules
GCONV_MODULES_IPK_DIR=$(BUILD_DIR)/gconv-modules-$(GCONV_MODULES_VERSION)-ipk
GCONV_MODULES_IPK=$(BUILD_DIR)/gconv-modules_$(GCONV_MODULES_VERSION)-$(GCONV_MODULES_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: gconv-modules-source gconv-modules-unpack gconv-modules gconv-modules-stage gconv-modules-ipk gconv-modules-clean gconv-modules-dirclean gconv-modules-check

$(GCONV_MODULES_BUILD_DIR)/.configured: $(GCONV_MODULES_PATCHES) make/gconv-modules.mk
	rm -rf $(BUILD_DIR)/$(GCONV_MODULES_DIR) $(GCONV_MODULES_BUILD_DIR)
	mkdir -p $(GCONV_MODULES_BUILD_DIR)
	touch $@

gconv-modules-unpack: $(GCONV_MODULES_BUILD_DIR)/.configured

$(GCONV_MODULES_BUILD_DIR)/.built: $(GCONV_MODULES_BUILD_DIR)/.configured
	rm -f $@
	touch $@

gconv-modules: $(GCONV_MODULES_BUILD_DIR)/.built

$(GCONV_MODULES_BUILD_DIR)/.staged: $(GCONV_MODULES_BUILD_DIR)/.built
	rm -f $@
	touch $@

gconv-modules-stage: $(GCONV_MODULES_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gconv-modules
#
$(GCONV_MODULES_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: gconv-modules" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GCONV_MODULES_PRIORITY)" >>$@
	@echo "Section: $(GCONV_MODULES_SECTION)" >>$@
	@echo "Version: $(GCONV_MODULES_VERSION)-$(GCONV_MODULES_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GCONV_MODULES_MAINTAINER)" >>$@
	@echo "Source: $(GCONV_MODULES_SOURCE)" >>$@
	@echo "Description: $(GCONV_MODULES_DESCRIPTION)" >>$@
	@echo "Depends: $(GCONV_MODULES_DEPENDS)" >>$@
	@echo "Conflicts: $(GCONV_MODULES_CONFLICTS)" >>$@

$(GCONV_MODULES_IPK): $(GCONV_MODULES_BUILD_DIR)/.built
	rm -rf $(GCONV_MODULES_IPK_DIR) $(BUILD_DIR)/gconv-modules_*_$(TARGET_ARCH).ipk
ifeq ($(LIBC_STYLE),uclibc)
else
    ifeq ($(OPTWARE_TARGET), slugosbe)
    else
	install -d $(GCONV_MODULES_IPK_DIR)/opt/lib/gconv
	cp $(TARGET_USRLIBDIR)/gconv/* $(GCONV_MODULES_IPK_DIR)/opt/lib/gconv
	rm -f $(GCONV_MODULES_IPK_DIR)/opt/lib/gconv/EUC-*.so
	rm -f $(GCONV_MODULES_IPK_DIR)/opt/lib/gconv/ISO-2022-*.so
	rm -f $(GCONV_MODULES_IPK_DIR)/opt/lib/gconv/JOHAB.so
	rm -f $(GCONV_MODULES_IPK_DIR)/opt/lib/gconv/UHC.so
	$(STRIP_COMMAND) $(GCONV_MODULES_IPK_DIR)/opt/lib/gconv/*.so
    ifneq ($(OPTWARE_TARGET), fsg3v4)
	install -d $(GCONV_MODULES_IPK_DIR)/opt/bin
	cp $(TARGET_LIBDIR)/../bin/iconv $(GCONV_MODULES_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(GCONV_MODULES_IPK_DIR)/opt/bin/*
    endif
	install -d $(GCONV_MODULES_IPK_DIR)/opt/etc/init.d
	install -m 755 $(GCONV_MODULES_SOURCE_DIR)/postinst $(GCONV_MODULES_IPK_DIR)/opt/etc/init.d/S05gconv-modules
	install -d $(GCONV_MODULES_IPK_DIR)/CONTROL/
	install -m 644 $(GCONV_MODULES_SOURCE_DIR)/postinst $(GCONV_MODULES_IPK_DIR)/CONTROL/postinst
    endif
endif
	$(MAKE) $(GCONV_MODULES_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GCONV_MODULES_IPK_DIR)

gconv-modules-ipk: $(GCONV_MODULES_IPK)

gconv-modules-clean:
	rm -rf $(GCONV_MODULES_BUILD_DIR)/*

gconv-modules-dirclean:
	rm -rf $(BUILD_DIR)/$(GCONV_MODULES_DIR) $(GCONV_MODULES_BUILD_DIR) $(GCONV_MODULES_IPK_DIR) $(GCONV_MODULES_IPK)

gconv-modules-check: $(GCONV_MODULES_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GCONV_MODULES_IPK)

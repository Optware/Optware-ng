###########################################################
#
# gconv-modules
#
###########################################################

GCONV_MODULES_VERSION=2.2.5
GCONV_MODULES_DIR=gconv-modules-$(GCONV_MODULES_VERSION)

GCONV_MODULES_IPK_VERSION=3

GCONV_MODULES_BUILD_DIR=$(BUILD_DIR)/gconv-modules
GCONV_MODULES_SOURCE_DIR=$(SOURCE_DIR)/gconv-modules
GCONV_MODULES_IPK_DIR=$(BUILD_DIR)/gconv-modules-$(GCONV_MODULES_VERSION)-ipk
GCONV_MODULES_IPK=$(BUILD_DIR)/gconv-modules_$(GCONV_MODULES_VERSION)-$(GCONV_MODULES_IPK_VERSION)_armeb.ipk

$(GCONV_MODULES_BUILD_DIR)/.configured: $(GCONV_MODULES_PATCHES)
	rm -rf $(BUILD_DIR)/$(GCONV_MODULES_DIR) $(GCONV_MODULES_BUILD_DIR)
	mkdir -p $(GCONV_MODULES_BUILD_DIR)
	touch $(GCONV_MODULES_BUILD_DIR)/.configured

gconv-modules-unpack: $(GCONV_MODULES_BUILD_DIR)/.configured

$(GCONV_MODULES_BUILD_DIR)/.built: $(GCONV_MODULES_BUILD_DIR)/.configured
	rm -f $(GCONV_MODULES_BUILD_DIR)/.built
	touch $(GCONV_MODULES_BUILD_DIR)/.built

gconv-modules: $(GCONV_MODULES_BUILD_DIR)/.built

$(GCONV_MODULES_BUILD_DIR)/.staged: $(GCONV_MODULES_BUILD_DIR)/.built
	rm -f $(GCONV_MODULES_BUILD_DIR)/.staged
	touch $(GCONV_MODULES_BUILD_DIR)/.staged

gconv-modules-stage: $(GCONV_MODULES_BUILD_DIR)/.staged

$(GCONV_MODULES_IPK): $(GCONV_MODULES_BUILD_DIR)/.built
	rm -rf $(GCONV_MODULES_IPK_DIR) $(BUILD_DIR)/gconv-modules_*_armeb.ipk
	install -d $(GCONV_MODULES_IPK_DIR)/opt/lib/gconv
	cp $(TARGET_LIBDIR)/gconv/* $(GCONV_MODULES_IPK_DIR)/opt/lib/gconv
	install -d $(GCONV_MODULES_IPK_DIR)/opt/bin
	cp $(TARGET_LIBDIR)/../bin/iconv $(GCONV_MODULES_IPK_DIR)/opt/bin
	install -d $(GCONV_MODULES_IPK_DIR)/opt/etc/init.d
	install -m 755 $(GCONV_MODULES_SOURCE_DIR)/postinst $(GCONV_MODULES_IPK_DIR)/opt/etc/init.d/S05gconv-modules

	install -d $(GCONV_MODULES_IPK_DIR)/CONTROL
	install -m 644 $(GCONV_MODULES_SOURCE_DIR)/control $(GCONV_MODULES_IPK_DIR)/CONTROL/control
	install -m 644 $(GCONV_MODULES_SOURCE_DIR)/postinst $(GCONV_MODULES_IPK_DIR)/CONTROL/postinst
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GCONV_MODULES_IPK_DIR)

gconv-modules-ipk: $(GCONV_MODULES_IPK)

gconv-modules-clean:
	rm -rf $(GCONV_MODULES_BUILD_DIR)/*

gconv-modules-dirclean:
	rm -rf $(BUILD_DIR)/$(GCONV_MODULES_DIR) $(GCONV_MODULES_BUILD_DIR) $(GCONV_MODULES_IPK_DIR) $(GCONV_MODULES_IPK)

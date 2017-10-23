#############################################################
#
# ntpclient - Time Service -- installation
#
#############################################################

NTPPATCHES_SITE=
NTPPATCHES_VERSION=0.0.0
NTPPATCHES_SOURCE=ntppatches.tar.gz
NTPPATCHES_DIR=ntppatches-$(NTPPATCHES_VERSION)
NTPPATCHES_UNZIP=zcat

NTPPATCHES_IPK_VERSION=1

NTPPATCHES_PATCHES=

NTPPATCHES_BUILD_DIR=$(BUILD_DIR)/ntppatches
NTPPATCHES_SOURCE_DIR=$(SOURCE_DIR)/ntppatches
NTPPATCHES_IPK_DIR:=$(BUILD_DIR)/ntppatches-$(NTPPATCHES_VERSION)-ipk
NTPPATCHES_IPK=$(BUILD_DIR)/ntppatches_$(NTPPATCHES_VERSION)-$(NTPPATCHES_IPK_VERSION)_$(TARGET_ARCH).ipk

# Kit requires a "source" tarball -- even though this package is self-contained
$(DL_DIR)/$(NTPPATCHES_SOURCE):
	tar -czf $(DL_DIR)/$(NTPPATCHES_SOURCE) /dev/null

ntppatches-source: $(DL_DIR)/$(NTPPATCHES_SOURCE) $(NTPPATCHES_PATCHES)

$(NTPPATCHES_BUILD_DIR)/.configured: $(DL_DIR)/$(NTPPATCHES_SOURCE)
	mkdir -p $(NTPPATCHES_BUILD_DIR)
	touch $(NTPPATCHES_BUILD_DIR)/.configured

ntppatches-unpack: $(NTPPATCHES_BUILD_DIR)/.configured

$(NTPPATCHES_BUILD_DIR)/.built: $(NTPPATCHES_BUILD_DIR)/.configured
	touch $(NTPPATCHES_BUILD_DIR)/.built

ntppatches: $(NTPPATCHES_BUILD_DIR)/.built

$(NTPPATCHES_IPK): $(NTPPATCHES_BUILD_DIR)/.built
	rm -rf $(NTPPATCHES_IPK_DIR) $(BUILD_DIR)/ntppatches_*_$(TARGET_ARCH).ipk
	mkdir -p $(NTPPATCHES_IPK_DIR)
	$(INSTALL) -d $(NTPPATCHES_IPK_DIR)/unslung
	$(INSTALL) -m 755 $(NTPPATCHES_SOURCE_DIR)/rc.crond $(NTPPATCHES_IPK_DIR)/unslung/rc.crond
	$(INSTALL) -m 755 $(NTPPATCHES_SOURCE_DIR)/rc.rstimezone $(NTPPATCHES_IPK_DIR)/unslung/rc.rstimezone
	$(INSTALL) -d $(NTPPATCHES_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(NTPPATCHES_SOURCE_DIR)/S10ntpclient $(NTPPATCHES_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S10ntpclient
	$(INSTALL) -d $(NTPPATCHES_IPK_DIR)/CONTROL
	$(INSTALL) -m 644 $(NTPPATCHES_SOURCE_DIR)/control  $(NTPPATCHES_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(NTPPATCHES_SOURCE_DIR)/postinst $(NTPPATCHES_IPK_DIR)/CONTROL/postinst
	$(INSTALL) -m 755 $(NTPPATCHES_SOURCE_DIR)/prerm    $(NTPPATCHES_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NTPPATCHES_IPK_DIR)

ntppatches-ipk: $(NTPPATCHES_IPK)

ntppatches-clean:
	-$(MAKE) -C $(NTPPATCHES_BUILD_DIR) clean

ntppatches-dirclean:
	rm -rf $(BUILD_DIR)/$(NTPPATCHES_BUILD_DIR) $(NTPPATCHES_BUILD_DIR) $(NTPPATCHES_IPK_DIR) $(NTPPATCHES_IPK)

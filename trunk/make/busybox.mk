#############################################################
#
# busybox
#
#############################################################

BUSYBOX_DIR:=$(BUILD_DIR)/busybox

ifneq ($(strip $(USE_BUSYBOX_SNAPSHOT)),)
# Be aware that this changes daily....
BUSYBOX:=busybox-$(strip $(USE_BUSYBOX_SNAPSHOT))
BUSYBOX_SITE:=http://www.busybox.net/downloads/snapshots
else
BUSYBOX:=busybox-1.00-rc3
BUSYBOX_SITE:=http://www.busybox.net/downloads
endif
BUSYBOX_SOURCE:=$(BUSYBOX).tar.bz2
BUSYBOX_UNZIP=bzcat
BUSYBOX_CONFIG:=$(SOURCE_DIR)/busybox.config

$(DL_DIR)/$(BUSYBOX_SOURCE):
	 $(WGET) -P $(DL_DIR) $(BUSYBOX_SITE)/$(BUSYBOX_SOURCE)

busybox-source: $(DL_DIR)/$(BUSYBOX_SOURCE) $(BUSYBOX_CONFIG)

$(BUSYBOX_DIR)/.configured: $(DL_DIR)/$(BUSYBOX_SOURCE) $(BUSYBOX_CONFIG)
	@rm -rf $(BUILD_DIR)/$(BUSYBOX) $(BUILD_DIR)/busybox
	$(BUSYBOX_UNZIP) $(DL_DIR)/$(BUSYBOX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(BUSYBOX) $(BUILD_DIR)/busybox
	cp $(BUSYBOX_CONFIG) $(BUSYBOX_DIR)/.config
#ifeq ($(strip $(BUILD_WITH_LARGEFILE)),true)
#	$(SED) "s/^.*CONFIG_LFS.*/CONFIG_LFS=y/;" $(BUSYBOX_DIR)/.config
#else
#	$(SED) "s/^.*CONFIG_LFS.*/CONFIG_LFS=n/;" $(BUSYBOX_DIR)/.config
#endif
	$(MAKE) CC=$(TARGET_CC) CROSS="$(TARGET_CROSS)" -C $(BUSYBOX_DIR) oldconfig
	touch $(BUSYBOX_DIR)/.configured

busybox-unpack: $(BUSYBOX_DIR)/.configured

$(BUSYBOX_DIR)/busybox: $(BUSYBOX_DIR)/.configured
	$(MAKE) CROSS="$(TARGET_CROSS)" PREFIX="$(TARGET_DIR)/busybox" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS) -fomit-frame-pointer" -C $(BUSYBOX_DIR)

$(TARGET_DIR)/busybox/bin/busybox: $(BUSYBOX_DIR)/busybox
	$(MAKE) CROSS="$(TARGET_CROSS)" PREFIX="$(TARGET_DIR)/busybox" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" -C $(BUSYBOX_DIR) install

busybox: $(BUSYBOX_DIR)/busybox

$(PACKAGE_DIR)/busybox_1.0.0-rc3_armeb.ipk: busybox
	install -d  $(PACKAGE_DIR)/busybox/opt
	cp -rp $(TARGET_DIR)/busybox/* $(PACKAGE_DIR)/busybox/opt
	install -d $(PACKAGE_DIR)/busybox/CONTROL
	install -m 644 $(SOURCE_DIR)/busybox.control $(PACKAGE_DIR)/busybox/CONTROL/control
	./ipkg-build -c -o root -g root $(PACKAGE_DIR)/busybox $(PACKAGE_DIR)

busybox-ipk: $(PACKAGE_DIR)/busybox_1.0.0-rc3_armeb.ipk

busybox-clean:
	-$(MAKE) -C $(BUSYBOX_DIR) clean

#############################################################
#
# busybox
#
#############################################################

BUSYBOX_DIR:=$(BUILD_DIR)/busybox

ifneq ($(strip $(USE_BUSYBOX_SNAPSHOT)),)
# Be aware that this changes daily....
BUSYBOX_VERSION:=$(strip $(USE_BUSYBOX_SNAPSHOT))
BUSYBOX:=busybox-$(BUSYBOX_VERSION)
BUSYBOX_SITE:=http://www.busybox.net/downloads/snapshots
else
BUSYBOX_VERSION:=1.00-rc3
BUSYBOX:=busybox-$(BUSYBOX_VERSION)
BUSYBOX_SITE:=http://www.busybox.net/downloads
endif
BUSYBOX_SOURCE:=$(BUSYBOX).tar.bz2
BUSYBOX_UNZIP:=bzcat

BUSYBOX_CONFIG:=$(SOURCE_DIR)/busybox.config

BUSYBOX_IPK:=$(BUILD_DIR)/busybox_$(BUSYBOX_VERSION)_armeb.ipk
BUSYBOX_IPK_DIR:=$(BUILD_DIR)/busybox-$(BUSYBOX_VERSION)-ipk

$(DL_DIR)/$(BUSYBOX_SOURCE):
	$(WGET) -P $(DL_DIR) $(BUSYBOX_SITE)/$(BUSYBOX_SOURCE)

busybox-source: $(DL_DIR)/$(BUSYBOX_SOURCE) $(BUSYBOX_CONFIG)

$(BUSYBOX_DIR)/.configured: $(DL_DIR)/$(BUSYBOX_SOURCE) $(BUSYBOX_CONFIG)
	@rm -rf $(BUILD_DIR)/$(BUSYBOX) $(BUSYBOX_DIR)
	$(BUSYBOX_UNZIP) $(DL_DIR)/$(BUSYBOX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(BUSYBOX) $(BUSYBOX_DIR)
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
	$(MAKE) CROSS="$(TARGET_CROSS)" PREFIX="$(BUILD_DIR)/busybox" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS) -fomit-frame-pointer" -C $(BUSYBOX_DIR)

busybox: $(BUSYBOX_DIR)/busybox

$(BUSYBOX_IPK): $(BUSYBOX_DIR)/busybox
	install -d $(BUSYBOX_IPK_DIR)/CONTROL $(BUSYBOX_IPK_DIR)/opt
	$(MAKE) CROSS="$(TARGET_CROSS)" PREFIX="$(BUSYBOX_IPK_DIR)/opt" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" -C $(BUSYBOX_DIR) install
	install -m 644 $(SOURCE_DIR)/busybox.control $(BUSYBOX_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BUSYBOX_IPK_DIR)

busybox-ipk: $(BUSYBOX_IPK)

busybox-clean:
	-$(MAKE) -C $(BUSYBOX_DIR) clean

busybox-dirclean:
	rm -rf $(BUSYBOX_DIR) $(BUSYBOX_IPK_DIR)

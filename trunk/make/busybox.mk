#############################################################
#
# busybox
#
#############################################################

ifneq ($(strip $(USE_BUSYBOX_SNAPSHOT)),)
# Be aware that this changes daily....
BUSYBOX_SITE=http://www.busybox.net/downloads/snapshots
BUSYBOX_VERSION=$(strip $(USE_BUSYBOX_SNAPSHOT))
BUSYBOX_DIR=busybox-$(BUSYBOX_VERSION)
else
BUSYBOX_SITE=http://www.busybox.net/downloads
BUSYBOX_VERSION=1.00
BUSYBOX_DIR=busybox-$(BUSYBOX_VERSION)
endif
BUSYBOX_SOURCE=busybox-$(BUSYBOX_VERSION).tar.bz2
BUSYBOX_UNZIP=bzcat

BUSYBOX_IPK_VERSION=6

BUSYBOX_CONFIG=$(BUSYBOX_SOURCE_DIR)/defconfig

BUSYBOX_BUILD_DIR=$(BUILD_DIR)/busybox
BUSYBOX_SOURCE_DIR=$(SOURCE_DIR)/busybox
BUSYBOX_IPK_DIR=$(BUILD_DIR)/busybox-$(BUSYBOX_VERSION)-ipk
BUSYBOX_IPK=$(BUILD_DIR)/busybox_$(BUSYBOX_VERSION)-$(BUSYBOX_IPK_VERSION)_armeb.ipk

$(DL_DIR)/$(BUSYBOX_SOURCE):
	$(WGET) -P $(DL_DIR) $(BUSYBOX_SITE)/$(BUSYBOX_SOURCE)

busybox-source: $(DL_DIR)/$(BUSYBOX_SOURCE) $(BUSYBOX_CONFIG)

$(BUSYBOX_BUILD_DIR)/.configured: $(DL_DIR)/$(BUSYBOX_SOURCE) $(BUSYBOX_CONFIG)
	rm -rf $(BUILD_DIR)/$(BUSYBOX_DIR) $(BUSYBOX_BUILD_DIR)
	$(BUSYBOX_UNZIP) $(DL_DIR)/$(BUSYBOX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(BUSYBOX_DIR) $(BUSYBOX_BUILD_DIR)
	cp $(BUSYBOX_CONFIG) $(BUSYBOX_BUILD_DIR)/.config
#ifeq ($(strip $(BUILD_WITH_LARGEFILE)),true)
#	$(SED) "s/^.*CONFIG_LFS.*/CONFIG_LFS=y/;" $(BUSYBOX_BUILD_DIR)/.config
#else
#	$(SED) "s/^.*CONFIG_LFS.*/CONFIG_LFS=n/;" $(BUSYBOX_BUILD_DIR)/.config
#endif
	$(MAKE) HOSTCC=$(HOSTCC) CC=$(TARGET_CC) CROSS="$(TARGET_CROSS)" -C $(BUSYBOX_BUILD_DIR) oldconfig
	touch $(BUSYBOX_BUILD_DIR)/.configured

busybox-unpack: $(BUSYBOX_BUILD_DIR)/.configured

$(BUSYBOX_BUILD_DIR)/busybox: $(BUSYBOX_BUILD_DIR)/.configured
	$(MAKE) CROSS="$(TARGET_CROSS)" PREFIX="$(BUILD_DIR)/busybox" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS) -fomit-frame-pointer" -C $(BUSYBOX_BUILD_DIR)

busybox: $(BUSYBOX_BUILD_DIR)/busybox

$(BUSYBOX_IPK): $(BUSYBOX_BUILD_DIR)/busybox
	rm -rf $(BUSYBOX_IPK_DIR) $(BUILD_DIR)/busybox_*_armeb.ipk
	install -d $(BUSYBOX_IPK_DIR)/opt
	$(MAKE) CROSS="$(TARGET_CROSS)" PREFIX="$(BUSYBOX_IPK_DIR)/opt" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" -C $(BUSYBOX_BUILD_DIR) install
	# Remove the symlinks for potential "stock functionality" applets.
	rm $(BUSYBOX_IPK_DIR)/opt/sbin/fdisk
	rm $(BUSYBOX_IPK_DIR)/opt/sbin/insmod
	install -d $(BUSYBOX_IPK_DIR)/CONTROL
	install -m 644 $(BUSYBOX_SOURCE_DIR)/control $(BUSYBOX_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BUSYBOX_IPK_DIR)

busybox-ipk: $(BUSYBOX_IPK)

busybox-clean:
	-$(MAKE) -C $(BUSYBOX_BUILD_DIR) clean

busybox-dirclean: busybox-clean
	rm -rf $(BUSYBOX_BUILD_DIR) $(BUSYBOX_IPK_DIR) $(BUSYBOX_IPK)

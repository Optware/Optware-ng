#############################################################
#
# slingbox
#
#############################################################

ifneq ($(strip $(USE_SLINGBOX_SNAPSHOT)),)
# Be aware that this changes daily....
SLINGBOX_SITE=http://www.busybox.net/downloads/snapshots
SLINGBOX_VERSION=$(strip $(USE_SLINGBOX_SNAPSHOT))
SLINGBOX_DIR=busybox-$(SLINGBOX_VERSION)
else
SLINGBOX_SITE=http://www.busybox.net/downloads
SLINGBOX_VERSION=1.00
SLINGBOX_DIR=busybox-$(SLINGBOX_VERSION)
endif
SLINGBOX_SOURCE=busybox-$(SLINGBOX_VERSION).tar.bz2
SLINGBOX_UNZIP=bzcat

SLINGBOX_CONFIG=$(SLINGBOX_SOURCE_DIR)/defconfig

SLINGBOX_BUILD_DIR=$(BUILD_DIR)/slingbox
SLINGBOX_SOURCE_DIR=$(SOURCE_DIR)/slingbox

# Handled by busybox.mk
# $(DL_DIR)/$(SLINGBOX_SOURCE):
# 	 $(WGET) -P $(DL_DIR) $(SLINGBOX_SITE)/$(SLINGBOX_SOURCE)

slingbox-source: $(DL_DIR)/$(SLINGBOX_SOURCE) $(SLINGBOX_CONFIG)

$(SLINGBOX_BUILD_DIR)/.configured: $(DL_DIR)/$(SLINGBOX_SOURCE) $(SLINGBOX_CONFIG)
	rm -rf $(BUILD_DIR)/$(SLINGBOX_DIR) $(BUILD_DIR)/slingbox
	$(SLINGBOX_UNZIP) $(DL_DIR)/$(SLINGBOX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	patch -d $(BUILD_DIR)/$(SLINGBOX_DIR) -p1 < $(SLINGBOX_SOURCE_DIR)/slingbox.patch
	mv $(BUILD_DIR)/$(SLINGBOX_DIR) $(BUILD_DIR)/slingbox
	cp $(SLINGBOX_CONFIG) $(SLINGBOX_BUILD_DIR)/.config
#ifeq ($(strip $(BUILD_WITH_LARGEFILE)),true)
#	$(SED) "s/^.*CONFIG_LFS.*/CONFIG_LFS=y/;" $(SLINGBOX_BUILD_DIR)/.config
#else
#	$(SED) "s/^.*CONFIG_LFS.*/CONFIG_LFS=n/;" $(SLINGBOX_BUILD_DIR)/.config
#endif
	$(MAKE) CC=$(TARGET_CC) CROSS="$(TARGET_CROSS)" -C $(SLINGBOX_BUILD_DIR) oldconfig
	touch $(SLINGBOX_BUILD_DIR)/.configured

slingbox-unpack: $(SLINGBOX_BUILD_DIR)/.configured

$(SLINGBOX_BUILD_DIR)/busybox: $(SLINGBOX_BUILD_DIR)/.configured
	$(MAKE) CROSS="$(TARGET_CROSS)" PREFIX="$(BUILD_DIR)/slingbox" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS) -fomit-frame-pointer" -C $(SLINGBOX_BUILD_DIR)

slingbox: $(SLINGBOX_BUILD_DIR)/busybox

$(FIRMWARE_DIR)/slingbox: $(SLINGBOX_BUILD_DIR)/busybox
	install -m 755 $(SLINGBOX_BUILD_DIR)/busybox $(FIRMWARE_DIR)/slingbox

slingbox-install: $(FIRMWARE_DIR)/slingbox

slingbox-clean:
	-$(MAKE) -C $(SLINGBOX_BUILD_DIR) clean

slingbox-dirclean:
	rm -rf $(SLINGBOX_BUILD_DIR)

#############################################################
#
# slingbox
#
#############################################################

SLINGBOX_DIR:=$(BUILD_DIR)/slingbox

ifneq ($(strip $(USE_SLINGBOX_SNAPSHOT)),)
# Be aware that this changes daily....
SLINGBOX:=busybox-$(strip $(USE_BUSYBOX_SNAPSHOT))
SLINGBOX_SITE:=http://www.busybox.net/downloads/snapshots
else
SLINGBOX:=busybox-1.00-rc3
SLINGBOX_SITE:=http://www.busybox.net/downloads
endif
SLINGBOX_SOURCE:=$(SLINGBOX).tar.bz2
SLINGBOX_UNZIP=bzcat
SLINGBOX_CONFIG:=$(SOURCE_DIR)/slingbox.config

$(DL_DIR)/$(SLINGBOX_SOURCE):
	 $(WGET) -P $(DL_DIR) $(SLINGBOX_SITE)/$(SLINGBOX_SOURCE)

slingbox-source: $(DL_DIR)/$(SLINGBOX_SOURCE) $(SLINGBOX_CONFIG)

$(SLINGBOX_DIR)/.configured: $(DL_DIR)/$(SLINGBOX_SOURCE) $(SLINGBOX_CONFIG)
	@rm -rf $(BUILD_DIR)/$(SLINGBOX) $(BUILD_DIR)/slingbox
	$(SLINGBOX_UNZIP) $(DL_DIR)/$(SLINGBOX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	patch -d $(BUILD_DIR)/$(SLINGBOX) -p1 < $(SOURCE_DIR)/slingbox.patch
	mv $(BUILD_DIR)/$(SLINGBOX) $(BUILD_DIR)/slingbox
	cp $(SLINGBOX_CONFIG) $(SLINGBOX_DIR)/.config
#ifeq ($(strip $(BUILD_WITH_LARGEFILE)),true)
#	$(SED) "s/^.*CONFIG_LFS.*/CONFIG_LFS=y/;" $(SLINGBOX_DIR)/.config
#else
#	$(SED) "s/^.*CONFIG_LFS.*/CONFIG_LFS=n/;" $(SLINGBOX_DIR)/.config
#endif
	$(MAKE) CC=$(TARGET_CC) CROSS="$(TARGET_CROSS)" -C $(SLINGBOX_DIR) oldconfig
	touch $(SLINGBOX_DIR)/.configured

slingbox-unpack: $(SLINGBOX_DIR)/.configured

$(SLINGBOX_DIR)/busybox: $(SLINGBOX_DIR)/.configured
	$(MAKE) CROSS="$(TARGET_CROSS)" PREFIX="$(TARGET_DIR)/slingbox" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS) -fomit-frame-pointer" -C $(SLINGBOX_DIR)

$(FIRMWARE_DIR)/slingbox: $(SLINGBOX_DIR)/busybox
	install -m 755 $(SLINGBOX_DIR)/busybox $(FIRMWARE_DIR)/slingbox

slingbox: $(SLINGBOX_DIR)/busybox

slingbox-install: $(FIRMWARE_DIR)/slingbox

slingbox-clean:
	-$(MAKE) -C $(SLINGBOX_DIR) clean

###########################################################
#
# busybox
#
###########################################################

ifneq ($(strip $(USE_BUSYBOX_SNAPSHOT)),)
# Be aware that this changes daily....
BUSYBOX_SITE=http://www.busybox.net/downloads/snapshots
BUSYBOX_VERSION=$(strip $(USE_BUSYBOX_SNAPSHOT))
else
BUSYBOX_SITE=http://www.busybox.net/downloads
BUSYBOX_VERSION=1.00
endif

BUSYBOX_SOURCE=busybox-$(BUSYBOX_VERSION).tar.bz2
BUSYBOX_DIR=busybox-$(BUSYBOX_VERSION)
BUSYBOX_UNZIP=bzcat
BUSYBOX_CONFIG=$(BUSYBOX_SOURCE_DIR)/defconfig

BUSYBOX_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BUSYBOX_DESCRIPTION=A userland replacement for embedded systems.
BUSYBOX_SECTION=core
BUSYBOX_PRIORITY=optional
BUSYBOX_DEPENDS=
BUSYBOX_CONFLICTS=

BUSYBOX_IPK_VERSION=9

BUSYBOX_BUILD_DIR=$(BUILD_DIR)/busybox
BUSYBOX_SOURCE_DIR=$(SOURCE_DIR)/busybox
BUSYBOX_IPK_DIR=$(BUILD_DIR)/busybox-$(BUSYBOX_VERSION)-ipk
BUSYBOX_IPK=$(BUILD_DIR)/busybox_$(BUSYBOX_VERSION)-$(BUSYBOX_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(BUSYBOX_SOURCE):
	$(WGET) -P $(DL_DIR) $(BUSYBOX_SITE)/$(BUSYBOX_SOURCE)

busybox-source: $(DL_DIR)/$(BUSYBOX_SOURCE) $(BUSYBOX_PATCHES)

$(BUSYBOX_BUILD_DIR)/.configured: $(DL_DIR)/$(BUSYBOX_SOURCE) $(BUSYBOX_PATCHES)
	rm -rf $(BUILD_DIR)/$(BUSYBOX_DIR) $(BUSYBOX_BUILD_DIR)
	$(BUSYBOX_UNZIP) $(DL_DIR)/$(BUSYBOX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(BUSYBOX_DIR) $(BUSYBOX_BUILD_DIR)
	cp $(BUSYBOX_CONFIG) $(BUSYBOX_BUILD_DIR)/.config
#ifeq ($(strip $(BUILD_WITH_LARGEFILE)),true)
#	$(SED) "s/^.*CONFIG_LFS.*/CONFIG_LFS=y/;" $(BUSYBOX_BUILD_DIR)/.config
#else
#	$(SED) "s/^.*CONFIG_LFS.*/CONFIG_LFS=n/;" $(BUSYBOX_BUILD_DIR)/.config
#endif
	$(MAKE) HOSTCC=$(HOSTCC) CC=$(TARGET_CC) CROSS="$(TARGET_CROSS)" \
		-C $(BUSYBOX_BUILD_DIR) oldconfig
	touch $(BUSYBOX_BUILD_DIR)/.configured

busybox-unpack: $(BUSYBOX_BUILD_DIR)/.configured

$(BUSYBOX_BUILD_DIR)/.built: $(BUSYBOX_BUILD_DIR)/.configured
	rm -f $(BUSYBOX_BUILD_DIR)/.built
	$(MAKE) CROSS="$(TARGET_CROSS)" PREFIX="$(BUILD_DIR)/busybox" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS) -fomit-frame-pointer" \
		-C $(BUSYBOX_BUILD_DIR)
	touch $(BUSYBOX_BUILD_DIR)/.built

busybox: $(BUSYBOX_BUILD_DIR)/.built

$(BUSYBOX_BUILD_DIR)/.staged: $(BUSYBOX_BUILD_DIR)/.built
	rm -f $(BUSYBOX_BUILD_DIR)/.staged
	$(MAKE) -C $(BUSYBOX_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(BUSYBOX_BUILD_DIR)/.staged

busybox-stage: $(BUSYBOX_BUILD_DIR)/.staged

$(BUSYBOX_IPK_DIR)/CONTROL/control:
	@install -d $(BUSYBOX_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: busybox" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BUSYBOX_PRIORITY)" >>$@
	@echo "Section: $(BUSYBOX_SECTION)" >>$@
	@echo "Version: $(BUSYBOX_VERSION)-$(BUSYBOX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BUSYBOX_MAINTAINER)" >>$@
	@echo "Source: $(BUSYBOX_SITE)/$(BUSYBOX_SOURCE)" >>$@
	@echo "Description: $(BUSYBOX_DESCRIPTION)" >>$@
	@echo "Depends: busybox-base (= $(BUSYBOX_VERSION)-$(BUSYBOX_IPK_VERSION)), busybox-links (= $(BUSYBOX_VERSION)-$(BUSYBOX_IPK_VERSION))" >>$@
	@echo "Conflicts: $(BUSYBOX_CONFLICTS)" >>$@

$(BUSYBOX_IPK_DIR)-base/CONTROL/control:
	@install -d $(BUSYBOX_IPK_DIR)-base/CONTROL
	@rm -f $@
	@echo "Package: busybox-base" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BUSYBOX_PRIORITY)" >>$@
	@echo "Section: $(BUSYBOX_SECTION)" >>$@
	@echo "Version: $(BUSYBOX_VERSION)-$(BUSYBOX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BUSYBOX_MAINTAINER)" >>$@
	@echo "Source: $(BUSYBOX_SITE)/$(BUSYBOX_SOURCE)" >>$@
	@echo "Description: $(BUSYBOX_DESCRIPTION)" >>$@
	@echo "Depends: $(BUSYBOX_DEPENDS)" >>$@
	@echo "Conflicts: $(BUSYBOX_CONFLICTS)" >>$@

$(BUSYBOX_IPK_DIR)-links/CONTROL/control:
	@install -d $(BUSYBOX_IPK_DIR)-links/CONTROL
	@rm -f $@
	@echo "Package: busybox-links" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BUSYBOX_PRIORITY)" >>$@
	@echo "Section: $(BUSYBOX_SECTION)" >>$@
	@echo "Version: $(BUSYBOX_VERSION)-$(BUSYBOX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BUSYBOX_MAINTAINER)" >>$@
	@echo "Source: $(BUSYBOX_SITE)/$(BUSYBOX_SOURCE)" >>$@
	@echo "Description: $(BUSYBOX_DESCRIPTION)" >>$@
	@echo "Depends: busybox-base (= $(BUSYBOX_VERSION)-$(BUSYBOX_IPK_VERSION))" >>$@
	@echo "Conflicts: $(BUSYBOX_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BUSYBOX_IPK_DIR)/opt/sbin or $(BUSYBOX_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BUSYBOX_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BUSYBOX_IPK_DIR)/opt/etc/busybox/...
# Documentation files should be installed in $(BUSYBOX_IPK_DIR)/opt/doc/busybox/...
# Daemon startup scripts should be installed in $(BUSYBOX_IPK_DIR)/opt/etc/init.d/S??busybox
#
# You may need to patch your application to make it use these locations.
#
$(BUSYBOX_IPK): $(BUSYBOX_BUILD_DIR)/.built
	rm -rf $(BUSYBOX_IPK_DIR) $(BUILD_DIR)/busybox_*_$(TARGET_ARCH).ipk
	install -d $(BUSYBOX_IPK_DIR)/opt
	$(MAKE) CROSS="$(TARGET_CROSS)" PREFIX="$(BUSYBOX_IPK_DIR)/opt" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" -C $(BUSYBOX_BUILD_DIR) install

	rm -rf $(BUSYBOX_IPK_DIR)-base
	install -d $(BUSYBOX_IPK_DIR)-base/opt/bin
	mv $(BUSYBOX_IPK_DIR)/opt/bin/busybox $(BUSYBOX_IPK_DIR)-base/opt/bin
	$(MAKE) $(BUSYBOX_IPK_DIR)-base/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BUSYBOX_IPK_DIR)-base

	rm -rf $(BUSYBOX_IPK_DIR)-links
	install -d $(BUSYBOX_IPK_DIR)-links/opt/bin
	install -d $(BUSYBOX_IPK_DIR)-links/opt/sbin
	mv $(BUSYBOX_IPK_DIR)/opt/bin/* $(BUSYBOX_IPK_DIR)-links/opt/bin
	mv $(BUSYBOX_IPK_DIR)/opt/sbin/* $(BUSYBOX_IPK_DIR)-links/opt/sbin
	# Remove the symlinks for potential "stock functionality" applets.
	rm $(BUSYBOX_IPK_DIR)-links/opt/sbin/fdisk
	rm $(BUSYBOX_IPK_DIR)-links/opt/sbin/insmod
	# Remove broken df - stock is better
	rm $(BUSYBOX_IPK_DIR)-links/opt/bin/df
	$(MAKE) $(BUSYBOX_IPK_DIR)-links/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BUSYBOX_IPK_DIR)-links

	rm -rf $(BUSYBOX_IPK_DIR)/opt
	$(MAKE) $(BUSYBOX_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BUSYBOX_IPK_DIR)

busybox-ipk: $(BUSYBOX_IPK)

busybox-clean:
	-$(MAKE) -C $(BUSYBOX_BUILD_DIR) clean

busybox-dirclean:
	rm -rf $(BUILD_DIR)/$(BUSYBOX_DIR) $(BUSYBOX_BUILD_DIR) $(BUSYBOX_IPK_DIR) $(BUSYBOX_IPK)

###########################################################
#
# u-boot
#
###########################################################
U-BOOT_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/u-boot
U-BOOT_VERSION=1.1.6
U-BOOT_SOURCE=u-boot-$(U-BOOT_VERSION).tar.bz2
U-BOOT_DIR=u-boot-$(U-BOOT_VERSION)
U-BOOT_UNZIP=bzcat
U-BOOT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
U-BOOT_DESCRIPTION=Universal Bootloader.
U-BOOT_SECTION=system
U-BOOT_PRIORITY=optional
U-BOOT_DEPENDS=
U-BOOT_SUGGESTS=
U-BOOT_CONFLICTS=

U-BOOT_IPK_VERSION=1

#U-BOOT_CONFFILES=/opt/etc/u-boot.conf /opt/etc/init.d/SXXu-boot

#U-BOOT_PATCHES=$(U-BOOT_SOURCE_DIR)/configure.patch

U-BOOT_CPPFLAGS=
U-BOOT_LDFLAGS=

U-BOOT_SOURCE_DIR=$(SOURCE_DIR)/u-boot
U-BOOT_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/u-boot
#U-BOOT_BUILD_DIR=$(BUILD_DIR)/u-boot
#U-BOOT_IPK_DIR=$(BUILD_DIR)/u-boot-$(U-BOOT_VERSION)-ipk
#U-BOOT_IPK=$(BUILD_DIR)/u-boot_$(U-BOOT_VERSION)-$(U-BOOT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: u-boot-source u-boot-mkimage

$(DL_DIR)/$(U-BOOT_SOURCE):
	$(WGET) -P $(DL_DIR) $(U-BOOT_SITE)/$(U-BOOT_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(U-BOOT_SOURCE)

u-boot-source: $(DL_DIR)/$(U-BOOT_SOURCE) $(U-BOOT_PATCHES)

$(HOST_STAGING_PREFIX)/bin/mkimage: host/.configured $(DL_DIR)/$(U-BOOT_SOURCE) $(U-BOOT_PATCHES) make/u-boot.mk
	rm -rf $(HOST_BUILD_DIR)/$(U-BOOT_DIR) $(U-BOOT_HOST_BUILD_DIR) $@
	$(U-BOOT_UNZIP) $(DL_DIR)/$(U-BOOT_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test -n "$(U-BOOT_PATCHES)" ; \
		then cat $(U-BOOT_PATCHES) | \
		patch -d $(HOST_BUILD_DIR)/$(U-BOOT_DIR) -p0 ; \
	fi
	if test "$(HOST_BUILD_DIR)/$(U-BOOT_DIR)" != "$(U-BOOT_HOST_BUILD_DIR)" ; \
		then mv $(HOST_BUILD_DIR)/$(U-BOOT_DIR) $(U-BOOT_HOST_BUILD_DIR) ; \
	fi
	cd $(U-BOOT_HOST_BUILD_DIR)/tools; \
	$(HOSTCC) -DUSE_HOSTCC -I../include -o mkimage mkimage.c ../lib_generic/crc32.c
	install -d $(HOST_STAGING_PREFIX)/bin
	strip $(U-BOOT_HOST_BUILD_DIR)/tools/mkimage -o $@

u-boot-mkimage: $(HOST_STAGING_PREFIX)/bin/mkimage

ifdef U-BOOT_BUILD_DIR

.PHONY: u-boot-unpack u-boot u-boot-stage u-boot-ipk u-boot-clean u-boot-dirclean u-boot-check

$(U-BOOT_BUILD_DIR)/.configured: $(DL_DIR)/$(U-BOOT_SOURCE) $(U-BOOT_PATCHES) make/u-boot.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(U-BOOT_DIR) $(U-BOOT_BUILD_DIR)
	$(U-BOOT_UNZIP) $(DL_DIR)/$(U-BOOT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(U-BOOT_PATCHES)" ; \
		then cat $(U-BOOT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(U-BOOT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(U-BOOT_DIR)" != "$(U-BOOT_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(U-BOOT_DIR) $(U-BOOT_BUILD_DIR) ; \
	fi
	touch $@

u-boot-unpack: $(U-BOOT_BUILD_DIR)/.configured

$(U-BOOT_BUILD_DIR)/.built: $(U-BOOT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(U-BOOT_BUILD_DIR)
	touch $@

u-boot: $(U-BOOT_BUILD_DIR)/.built

$(U-BOOT_BUILD_DIR)/.staged: $(U-BOOT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(U-BOOT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

u-boot-stage: $(U-BOOT_BUILD_DIR)/.staged

$(U-BOOT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: u-boot" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(U-BOOT_PRIORITY)" >>$@
	@echo "Section: $(U-BOOT_SECTION)" >>$@
	@echo "Version: $(U-BOOT_VERSION)-$(U-BOOT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(U-BOOT_MAINTAINER)" >>$@
	@echo "Source: $(U-BOOT_SITE)/$(U-BOOT_SOURCE)" >>$@
	@echo "Description: $(U-BOOT_DESCRIPTION)" >>$@
	@echo "Depends: $(U-BOOT_DEPENDS)" >>$@
	@echo "Suggests: $(U-BOOT_SUGGESTS)" >>$@
	@echo "Conflicts: $(U-BOOT_CONFLICTS)" >>$@

$(U-BOOT_IPK): $(U-BOOT_BUILD_DIR)/.built
	rm -rf $(U-BOOT_IPK_DIR) $(BUILD_DIR)/u-boot_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(U-BOOT_BUILD_DIR) DESTDIR=$(U-BOOT_IPK_DIR) install-strip
	$(MAKE) $(U-BOOT_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(U-BOOT_IPK_DIR)

u-boot-ipk: $(U-BOOT_IPK)

u-boot-clean:
	rm -f $(U-BOOT_BUILD_DIR)/.built
	-$(MAKE) -C $(U-BOOT_BUILD_DIR) clean

u-boot-dirclean:
	rm -rf $(BUILD_DIR)/$(U-BOOT_DIR) $(U-BOOT_BUILD_DIR) $(U-BOOT_IPK_DIR) $(U-BOOT_IPK)

u-boot-check: $(U-BOOT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(U-BOOT_IPK)

endif

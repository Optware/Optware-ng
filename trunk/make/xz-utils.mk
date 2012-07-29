###########################################################
#
# xz-utils
#
###########################################################
XZ_UTILS_SITE=http://tukaani.org/xz
XZ_UTILS_VERSION=5.0.4
XZ_UTILS_SOURCE=xz-$(XZ_UTILS_VERSION).tar.bz2
XZ_UTILS_DIR=xz-$(XZ_UTILS_VERSION)
XZ_UTILS_UNZIP=bzcat
XZ_UTILS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
XZ_UTILS_DESCRIPTION=A free general-purpose data compression software with high compression ratio
XZ_UTILS_SECTION=utils
XZ_UTILS_PRIORITY=optional
XZ_UTILS_DEPENDS=liblzma0
XZ_UTILS_SUGGESTS=
XZ_UTILS_CONFLICTS=

XZ_UTILS_IPK_VERSION=1

#XZ_UTILS_CONFFILES=/opt/etc/xz-utils.conf /opt/etc/init.d/SXXxz-utils

#XZ_UTILS_PATCHES=$(XZ_UTILS_SOURCE_DIR)/configure.patch

XZ_UTILS_CPPFLAGS=
XZ_UTILS_LDFLAGS=

XZ_UTILS_BUILD_DIR=$(BUILD_DIR)/xz-utils
XZ_UTILS_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/xz-utils

XZ_UTILS_SOURCE_DIR=$(SOURCE_DIR)/xz-utils

XZ_UTILS_IPK_DIR=$(BUILD_DIR)/xz-utils-$(XZ_UTILS_VERSION)-ipk
XZ_UTILS_IPK=$(BUILD_DIR)/xz-utils_$(XZ_UTILS_VERSION)-$(XZ_UTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBLZMA0_IPK_DIR=$(BUILD_DIR)/liblzma0-$(XZ_UTILS_VERSION)-ipk
LIBLZMA0_IPK=$(BUILD_DIR)/liblzma0_$(XZ_UTILS_VERSION)-$(XZ_UTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: xz-utils-source xz-utils-unpack xz-utils xz-utils-stage xz-utils-ipk xz-utils-clean xz-utils-dirclean xz-utils-check

$(DL_DIR)/$(XZ_UTILS_SOURCE):
	$(WGET) -P $(@D) $(XZ_UTILS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

xz-utils-source: $(DL_DIR)/$(XZ_UTILS_SOURCE) $(XZ_UTILS_PATCHES)

$(XZ_UTILS_HOST_BUILD_DIR)/.staged: host/.configured $(DL_DIR)/$(XZ_UTILS_SOURCE) $(XZ_UTILS_PATCHES) make/xz-utils.mk
	rm -rf $(HOST_BUILD_DIR)/$(XZ_UTILS_DIR) $(@D)
	$(XZ_UTILS_UNZIP) $(DL_DIR)/$(XZ_UTILS_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test -n "$(XZ_UTILS_PATCHES)" ; \
		then cat $(XZ_UTILS_PATCHES) | \
		patch -d $(HOST_BUILD_DIR)/$(XZ_UTILS_DIR) -p0 ; \
	fi
	if test "$(HOST_BUILD_DIR)/$(XZ_UTILS_DIR)" != "$(@D)" ; \
		then mv $(HOST_BUILD_DIR)/$(XZ_UTILS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(GNU_HOST_NAME) \
		--prefix=/opt \
		--disable-nls \
		--enable-static \
		--disable-shared \
		--disable-assembler \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	$(MAKE) -C $(@D) DESTDIR=$(HOST_STAGING_DIR) install
	rm -f $(HOST_STAGING_LIB_DIR)/liblzma.la
	sed -i -e 's|^prefix=|&$(HOST_STAGING_PREFIX)|' $(HOST_STAGING_LIB_DIR)/pkgconfig/liblzma.pc
	touch $@

xz-utils-host-stage: $(XZ_UTILS_HOST_BUILD_DIR)/.staged

$(XZ_UTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(XZ_UTILS_SOURCE) $(XZ_UTILS_PATCHES) make/xz-utils.mk
	rm -rf $(BUILD_DIR)/$(XZ_UTILS_DIR) $(@D)
	$(XZ_UTILS_UNZIP) $(DL_DIR)/$(XZ_UTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(XZ_UTILS_PATCHES)" ; \
		then cat $(XZ_UTILS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(XZ_UTILS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(XZ_UTILS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(XZ_UTILS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XZ_UTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XZ_UTILS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

xz-utils-unpack: $(XZ_UTILS_BUILD_DIR)/.configured

$(XZ_UTILS_BUILD_DIR)/.built: $(XZ_UTILS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

xz-utils: $(XZ_UTILS_BUILD_DIR)/.built

$(XZ_UTILS_BUILD_DIR)/.staged: $(XZ_UTILS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/liblzma.la
	sed -i -e 's|^prefix=|&$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/liblzma.pc
	touch $@

xz-utils-stage: $(XZ_UTILS_BUILD_DIR)/.staged

$(XZ_UTILS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: xz-utils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XZ_UTILS_PRIORITY)" >>$@
	@echo "Section: $(XZ_UTILS_SECTION)" >>$@
	@echo "Version: $(XZ_UTILS_VERSION)-$(XZ_UTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XZ_UTILS_MAINTAINER)" >>$@
	@echo "Source: $(XZ_UTILS_SITE)/$(XZ_UTILS_SOURCE)" >>$@
	@echo "Description: $(XZ_UTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(XZ_UTILS_DEPENDS)" >>$@
	@echo "Suggests: $(XZ_UTILS_SUGGESTS)" >>$@
	@echo "Conflicts: $(XZ_UTILS_CONFLICTS)" >>$@

$(LIBLZMA0_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: liblzma0" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XZ_UTILS_PRIORITY)" >>$@
	@echo "Section: $(XZ_UTILS_SECTION)" >>$@
	@echo "Version: $(XZ_UTILS_VERSION)-$(XZ_UTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XZ_UTILS_MAINTAINER)" >>$@
	@echo "Source: $(XZ_UTILS_SITE)/$(XZ_UTILS_SOURCE)" >>$@
	@echo "Description: $(XZ_UTILS_DESCRIPTION)" >>$@
	@echo "Depends: " >>$@
	@echo "Suggests: " >>$@
	@echo "Conflicts: " >>$@

$(XZ_UTILS_IPK) $(LIBLZMA0_IPK): $(XZ_UTILS_BUILD_DIR)/.built
	rm -rf $(XZ_UTILS_IPK_DIR) $(LIBLZMA0_IPK_DIR) \
		$(BUILD_DIR)/xz-utils_*_$(TARGET_ARCH).ipk \
		$(BUILD_DIR)/liblzma0_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XZ_UTILS_BUILD_DIR) DESTDIR=$(XZ_UTILS_IPK_DIR) install-strip
	install -d $(LIBLZMA0_IPK_DIR)/opt
	mv $(XZ_UTILS_IPK_DIR)/opt/include $(XZ_UTILS_IPK_DIR)/opt/lib $(LIBLZMA0_IPK_DIR)/opt/
	$(MAKE) $(XZ_UTILS_IPK_DIR)/CONTROL/control $(LIBLZMA0_IPK_DIR)/CONTROL/control
#	echo $(XZ_UTILS_CONFFILES) | sed -e 's/ /\n/g' > $(XZ_UTILS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XZ_UTILS_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBLZMA0_IPK_DIR)

xz-utils-ipk: $(XZ_UTILS_IPK) $(LIBLZMA0_IPK)

xz-utils-clean:
	rm -f $(XZ_UTILS_BUILD_DIR)/.built
	-$(MAKE) -C $(XZ_UTILS_BUILD_DIR) clean

xz-utils-dirclean:
	rm -rf $(BUILD_DIR)/$(XZ_UTILS_DIR) $(XZ_UTILS_BUILD_DIR) \
		$(XZ_UTILS_IPK_DIR) $(XZ_UTILS_IPK) \
		$(LIBLZMA0_IPK_DIR) $(LIBLZMA0_IPK)

xz-utils-check: $(XZ_UTILS_IPK) $(LIBLZMA0_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^

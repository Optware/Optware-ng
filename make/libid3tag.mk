###########################################################
#
# libid3tag
#
###########################################################

LIBID3TAG_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/mad
LIBID3TAG_VERSION=0.15.1b
LIBID3TAG_LIB_VERSION=0.3.0
LIBID3TAG_SOURCE=libid3tag-$(LIBID3TAG_VERSION).tar.gz
LIBID3TAG_DIR=libid3tag-$(LIBID3TAG_VERSION)
LIBID3TAG_UNZIP=zcat
LIBID3TAG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBID3TAG_DESCRIPTION=The library used for ID3 tag reading
LIBID3TAG_SECTION=libs
LIBID3TAG_PRIORITY=optional
LIBID3TAG_DEPENDS=zlib
LIBID3TAG_SUGGESTS=
LIBID3TAG_CONFLICTS=

LIBID3TAG_IPK_VERSION=1

LIBID3TAG_BUILD_DIR=$(BUILD_DIR)/libid3tag
LIBID3TAG_SOURCE_DIR=$(SOURCE_DIR)/libid3tag
LIBID3TAG_IPK_DIR=$(BUILD_DIR)/libid3tag-$(LIBID3TAG_VERSION)-ipk
LIBID3TAG_IPK=$(BUILD_DIR)/libid3tag_$(LIBID3TAG_VERSION)-$(LIBID3TAG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libid3tag-source libid3tag-unpack libid3tag libid3tag-stage libid3tag-ipk libid3tag-clean libid3tag-dirclean libid3tag-check

$(DL_DIR)/$(LIBID3TAG_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBID3TAG_SITE)/$(LIBID3TAG_SOURCE)

libid3tag-source: $(DL_DIR)/$(LIBID3TAG_SOURCE)

$(LIBID3TAG_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBID3TAG_SOURCE)
	$(MAKE) zlib-stage
	rm -rf $(BUILD_DIR)/$(LIBID3TAG_DIR) $(LIBID3TAG_BUILD_DIR)
	$(LIBID3TAG_UNZIP) $(DL_DIR)/$(LIBID3TAG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(LIBID3TAG_DIR) $(LIBID3TAG_BUILD_DIR)
	(cd $(LIBID3TAG_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	);
	touch $(LIBID3TAG_BUILD_DIR)/.configured

libid3tag-unpack: $(LIBID3TAG_BUILD_DIR)/.configured

$(LIBID3TAG_BUILD_DIR)/.built: $(LIBID3TAG_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBID3TAG_BUILD_DIR)
	touch $@

libid3tag: $(LIBID3TAG_BUILD_DIR)/.built

$(LIBID3TAG_BUILD_DIR)/.staged: $(LIBID3TAG_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBID3TAG_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

libid3tag-stage: $(LIBID3TAG_BUILD_DIR)/.staged

$(LIBID3TAG_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libid3tag" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBID3TAG_PRIORITY)" >>$@
	@echo "Section: $(LIBID3TAG_SECTION)" >>$@
	@echo "Version: $(LIBID3TAG_VERSION)-$(LIBID3TAG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBID3TAG_MAINTAINER)" >>$@
	@echo "Source: $(LIBID3TAG_SITE)/$(LIBID3TAG_SOURCE)" >>$@
	@echo "Description: $(LIBID3TAG_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBID3TAG_DEPENDS)" >>$@
	@echo "Suggests: $(LIBID3TAG_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBID3TAG_CONFLICTS)" >>$@

$(LIBID3TAG_IPK): $(LIBID3TAG_BUILD_DIR)/.built
	rm -rf $(LIBID3TAG_IPK_DIR) $(BUILD_DIR)/libid3tag_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBID3TAG_BUILD_DIR) DESTDIR=$(LIBID3TAG_IPK_DIR) install
	$(STRIP_COMMAND) $(LIBID3TAG_IPK_DIR)$(TARGET_PREFIX)/lib/*.so.*
	rm -f $(LIBID3TAG_IPK_DIR)$(TARGET_PREFIX)/lib/*.{la,a}
	$(MAKE) $(LIBID3TAG_IPK_DIR)/CONTROL/control
#	$(INSTALL) -d $(LIBID3TAG_IPK_DIR)/CONTROL
#	sed -e "s/@ARCH@/$(TARGET_ARCH)/" -e "s/@VERSION@/$(LIBID3TAG_VERSION)/" \
#		-e "s/@RELEASE@/$(LIBID3TAG_IPK_VERSION)/" $(LIBID3TAG_SOURCE_DIR)/control > $(LIBID3TAG_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBID3TAG_IPK_DIR)

libid3tag-ipk: $(LIBID3TAG_IPK)

libid3tag-clean:
	rm -f $(LIBID3TAG_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBID3TAG_BUILD_DIR) clean

libid3tag-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBID3TAG_DIR) $(LIBID3TAG_BUILD_DIR) $(LIBID3TAG_IPK_DIR) $(LIBID3TAG_IPK)

libid3tag-check: $(LIBID3TAG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^



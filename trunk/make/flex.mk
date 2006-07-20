###########################################################
#
# flex
#
###########################################################

FLEX_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/flex
FLEX_VERSION=2.5.33
FLEX_LIB_VERSION=2.5.33
FLEX_SOURCE=flex-$(FLEX_VERSION).tar.bz2
FLEX_DIR=flex-2.5.33
FLEX_UNZIP=bzcat
FLEX_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FLEX_DESCRIPTION=Generates programs that perform pattern-matching on text.
FLEX_SECTION=devel
FLEX_PRIORITY=optional
FLEX_DEPENDS=
FLEX_CONFLICTS=

FLEX_IPK_VERSION=1

FLEX_BUILD_DIR=$(BUILD_DIR)/flex
FLEX_SOURCE_DIR=$(SOURCE_DIR)/flex
FLEX_IPK_DIR=$(BUILD_DIR)/flex-$(FLEX_VERSION)-ipk
FLEX_IPK=$(BUILD_DIR)/flex_$(FLEX_VERSION)-$(FLEX_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(FLEX_SOURCE):
	$(WGET) -P $(DL_DIR) $(FLEX_SITE)/$(FLEX_SOURCE)

flex-source: $(DL_DIR)/$(FLEX_SOURCE)

$(FLEX_BUILD_DIR)/.configured: $(DL_DIR)/$(FLEX_SOURCE)
	rm -rf $(BUILD_DIR)/$(FLEX_DIR) $(FLEX_BUILD_DIR)
	$(FLEX_UNZIP) $(DL_DIR)/$(FLEX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(FLEX_DIR) $(FLEX_BUILD_DIR)
	(cd $(FLEX_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	)
	touch $(FLEX_BUILD_DIR)/.configured

flex-unpack: $(FLEX_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FLEX_BUILD_DIR)/.built: $(FLEX_BUILD_DIR)/.configured
	rm -f $(FLEX_BUILD_DIR)/.built
	$(MAKE) -C $(FLEX_BUILD_DIR)
	touch $(FLEX_BUILD_DIR)/.built

#
# This is the build convenience target.
#
flex: $(FLEX_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FLEX_BUILD_DIR)/.staged: $(FLEX_BUILD_DIR)/.built
	rm -f $(FLEX_BUILD_DIR)/.staged
	$(MAKE) -C $(FLEX_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
ifneq ($(HOSTCC), $(TARGET_CC)) # prevent PATH=staging/opt/bin problems
	if test -x $(STAGING_DIR)/opt/bin/flex ;\
		 then rm $(STAGING_DIR)/opt/bin/flex ;\
	fi
endif
	touch $(FLEX_BUILD_DIR)/.staged

flex-stage: $(FLEX_BUILD_DIR)/.staged

$(FLEX_IPK_DIR)/CONTROL/control:
	@install -d $(FLEX_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: flex" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FLEX_PRIORITY)" >>$@
	@echo "Section: $(FLEX_SECTION)" >>$@
	@echo "Version: $(FLEX_VERSION)-$(FLEX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FLEX_MAINTAINER)" >>$@
	@echo "Source: $(FLEX_SITE)/$(FLEX_SOURCE)" >>$@
	@echo "Description: $(FLEX_DESCRIPTION)" >>$@
	@echo "Depends: $(FLEX_DEPENDS)" >>$@
	@echo "Conflicts: $(FLEX_CONFLICTS)" >>$@

$(FLEX_IPK): $(FLEX_BUILD_DIR)/.built
	rm -rf $(FLEX_IPK_DIR) $(BUILD_DIR)/flex_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(FLEX_BUILD_DIR) DESTDIR=$(FLEX_IPK_DIR) install-strip
	rm -rf $(FLEX_IPK_DIR)/opt/man
	$(MAKE) $(FLEX_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FLEX_IPK_DIR)

flex-ipk: $(FLEX_IPK)

flex-clean:
	-$(MAKE) -C $(FLEX_BUILD_DIR) clean

flex-dirclean:
	rm -rf $(BUILD_DIR)/$(FLEX_DIR) $(FLEX_BUILD_DIR) $(FLEX_IPK_DIR) $(FLEX_IPK)


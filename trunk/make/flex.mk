###########################################################
#
# flex
#
###########################################################

FLEX_DIR=$(BUILD_DIR)/flex

FLEX_VERSION=2.5.4a
FLEX_LIBVERSION=2.5.4
FLEX=flex-$(FLEX_VERSION)
FLEX_SITE=ftp://ftp.gnu.org/gnu/non-gnu/flex
FLEX_SOURCE=$(FLEX).tar.gz
FLEX_UNZIP=zcat

FLEX_IPK=$(BUILD_DIR)/flex_$(FLEX_VERSION)-1_armeb.ipk
FLEX_IPK_DIR=$(BUILD_DIR)/flex-$(FLEX_VERSION)-ipk

$(DL_DIR)/$(FLEX_SOURCE):
	$(WGET) -P $(DL_DIR) $(FLEX_SITE)/$(FLEX_SOURCE)

flex-source: $(DL_DIR)/$(FLEX_SOURCE)

$(FLEX_DIR)/.source: $(DL_DIR)/$(FLEX_SOURCE)
	$(FLEX_UNZIP) $(DL_DIR)/$(FLEX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/flex-$(FLEX_LIBVERSION) $(FLEX_DIR)
	touch $(FLEX_DIR)/.source

$(FLEX_DIR)/.configured: $(FLEX_DIR)/.source
	(cd $(FLEX_DIR); \
		./configure \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=$(FLEX_IPK_DIR)/opt \
	);
	touch $(FLEX_DIR)/.configured

$(FLEX_IPK_DIR)/opt/lib/libfl.a: $(FLEX_DIR)/.configured
	$(MAKE) -C $(FLEX_DIR) CC=$(TARGET_CC) \
	RANLIB=$(TARGET_RANLIB) AR=$(TARGET_AR) LD=$(TARGET_LD) install

flex-headers: $(FLEX_IPK_DIR)/opt/lib/libfl.a

flex: $(FLEX_IPK_DIR)/opt/lib/libfl.a

$(FLEX_IPK): $(FLEX_IPK_DIR)/opt/lib/libfl.a
	mkdir -p $(FLEX_IPK_DIR)/CONTROL
	cp $(SOURCE_DIR)/flex.control $(FLEX_IPK_DIR)/CONTROL/control
	cp -r $(FLEX_IPK_DIR)/opt/include/ $(STAGING_DIR)/include
	cp -r $(FLEX_IPK_DIR)/opt/lib $(STAGING_DIR)/lib
	rm -rf $(STAGING_DIR)/CONTROL
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FLEX_IPK_DIR)

flex-ipk: $(FLEX_IPK)

flex-source: $(DL_DIR)/$(FLEX_SOURCE)

flex-clean:
	-$(MAKE) -C $(FLEX_DIR) uninstall
	-$(MAKE) -C $(FLEX_DIR) clean

flex-distclean:
	-rm $(FLEX_DIR)/.configured
	-$(MAKE) -C $(FLEX_DIR) distclean


###########################################################
#
# flex
#
###########################################################

FLEX_SITE=ftp://ftp.gnu.org/gnu/non-gnu/flex
FLEX_VERSION=2.5.4a
FLEX_LIB_VERSION=2.5.4
FLEX_SOURCE=flex-$(FLEX_VERSION).tar.gz
FLEX_DIR=flex-2.5.4
FLEX_UNZIP=zcat

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

$(FLEX_BUILD_DIR)/libfl.a: $(FLEX_BUILD_DIR)/.configured
	$(MAKE) -C $(FLEX_BUILD_DIR)

flex: $(FLEX_BUILD_DIR)/libfl.a

$(STAGING_DIR)/opt/lib/libfl.a: $(FLEX_BUILD_DIR)/libfl.a
	$(MAKE) -C $(FLEX_BUILD_DIR) prefix=$(STAGING_DIR)/opt install
	rm -rf $(STAGING_DIR)/opt/bin/flex*
	rm -rf $(STAGING_DIR)/opt/man

flex-stage: $(STAGING_DIR)/opt/lib/libfl.a

$(FLEX_IPK): $(FLEX_BUILD_DIR)/libfl.a
	$(MAKE) -C $(FLEX_BUILD_DIR) prefix=$(FLEX_IPK_DIR)/opt install
	rm -rf $(FLEX_IPK_DIR)/opt/man
	install -d $(FLEX_IPK_DIR)/CONTROL
	install -m 644 $(FLEX_SOURCE_DIR)/control $(FLEX_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FLEX_IPK_DIR)

flex-ipk: $(FLEX_IPK)

flex-clean:
	-$(MAKE) -C $(FLEX_BUILD_DIR) clean

flex-dirclean:
	rm -rf $(BUILD_DIR)/$(FLEX_DIR) $(FLEX_BUILD_DIR) $(FLEX_IPK_DIR) $(FLEX_IPK)


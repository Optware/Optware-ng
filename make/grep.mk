###########################################################
#
# grep
#
###########################################################

GREP_DIR=$(BUILD_DIR)/grep

GREP_VERSION=2.4.2
GREP=grep-$(GREP_VERSION)
GREP_SITE=ftp://ftp.gnu.org/pub/gnu/grep
GREP_SOURCE=$(GREP).tar.gz
GREP_UNZIP=zcat

GREP_IPK=$(BUILD_DIR)/grep_$(GREP_VERSION)-1_armeb.ipk
GREP_IPK_DIR=$(BUILD_DIR)/grep-$(GREP_VERSION)-ipk

$(DL_DIR)/$(GREP_SOURCE):
	$(WGET) -P $(DL_DIR) $(GREP_SITE)/$(GREP_SOURCE)

grep-source: $(DL_DIR)/$(GREP_SOURCE)

$(GREP_DIR)/.configured: $(DL_DIR)/$(GREP_SOURCE)
	$(GREP_UNZIP) $(DL_DIR)/$(GREP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/grep-$(GREP_VERSION) $(GREP_DIR)
	(cd $(GREP_DIR); \
		./configure \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=$(GREP_IPK_DIR)/opt \
	);
	touch $(GREP_DIR)/.configured

grep-unpack: $(GREP_DIR)/.configured

$(GREP_DIR)/src/grep: $(GREP_DIR)/.configured
	$(MAKE) -C $(GREP_DIR) CC=$(TARGET_CC) \
	RANLIB=$(TARGET_RANLIB) AR=$(TARGET_AR) LD=$(TARGET_LD) install

grep: $(GREP_DIR)/src/grep

$(GREP_IPK): $(GREP_DIR)/src/grep
	mkdir -p $(GREP_IPK_DIR)/CONTROL
	cp $(SOURCE_DIR)/grep/control $(GREP_IPK_DIR)/CONTROL/control
	$(STRIP) $(GREP_DIR)/src/grep
	$(STRIP) $(GREP_DIR)/src/egrep
	$(STRIP) $(GREP_DIR)/src/fgrep
	rm -rf $(STAGING_DIR)/CONTROL
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GREP_IPK_DIR)

grep-ipk: $(GREP_IPK)

grep-clean:
	-$(MAKE) -C $(GREP_DIR) clean

grep-dirclean:
	rm -rf $(BUILD_DIR)/$(GREP_DIR) $(GREP_BUILD_DIR) $(GREP_IPK_DIR) $(GREP_IPK)

###########################################################
#
# rdate
#
###########################################################

RDATE_DIR=$(BUILD_DIR)/rdate
RDATE_SOURCE_DIR=$(SOURCE_DIR)/rdate

RDATE_VERSION=1.4
RDATE=rdate-$(RDATE_VERSION)
RDATE_SITE=http://freshmeat.net/redir/rdate/8862/url_tgz/
RDATE_SOURCE=$(RDATE).tar.gz
RDATE_UNZIP=zcat

RDATE_IPK_VERSION=1

RDATE_IPK=$(BUILD_DIR)/rdate_$(RDATE_VERSION)-$(RDATE_IPK_VERSION)_$(TARGET_ARCH).ipk
RDATE_IPK_DIR=$(BUILD_DIR)/rdate-$(RDATE_VERSION)-ipk

$(DL_DIR)/$(RDATE_SOURCE):
	$(WGET) -P $(DL_DIR) $(RDATE_SITE)/$(RDATE_SOURCE)

rdate-source: $(DL_DIR)/$(RDATE_SOURCE)

$(RDATE_DIR)/.configured: $(DL_DIR)/$(RDATE_SOURCE)
	$(RDATE_UNZIP) $(DL_DIR)/$(RDATE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/rdate-$(RDATE_VERSION) $(RDATE_DIR)
	touch $(RDATE_DIR)/.configured

rdate-unpack: $(RDATE_DIR)/.configured

$(RDATE_DIR)/rdate: $(RDATE_DIR)/.configured
	$(MAKE) -C $(RDATE_DIR) CC=$(TARGET_CC) \
	RANLIB=$(TARGET_RANLIB) AR=$(TARGET_AR) LD=$(TARGET_LD) 

rdate: $(RDATE_DIR)/rdate

$(RDATE_IPK): $(RDATE_DIR)/rdate
	mkdir -p $(RDATE_IPK_DIR)/CONTROL
	install -d $(RDATE_IPK_DIR)/opt/bin
	cp $(RDATE_SOURCE_DIR)/control $(RDATE_IPK_DIR)/CONTROL/control
	$(STRIP_COMMAND) $(RDATE_DIR)/rdate -o $(RDATE_IPK_DIR)/opt/bin/rdate
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RDATE_IPK_DIR)

rdate-ipk: $(RDATE_IPK)

rdate-clean:
	-$(MAKE) -C $(RDATE_DIR) clean

rdate-distclean:
	-rm $(RDATE_DIR)/.configured
	-$(MAKE) -C $(RDATE_DIR) clean

rdate-dirclean:
	rm -rf $(RDATE_DIR) $(RDATE_IPK_DIR) $(RDATE_IPK)

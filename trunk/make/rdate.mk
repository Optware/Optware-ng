###########################################################
#
# rdate
#
###########################################################

RDATE_DIR=$(BUILD_DIR)/rdate

RDATE_VERSION=1.4
RDATE=rdate-$(RDATE_VERSION)
RDATE_SITE=http://freshmeat.net/redir/rdate/8862/url_tgz/
RDATE_SOURCE=$(RDATE).tar.gz
RDATE_UNZIP=zcat

RDATE_IPK=$(BUILD_DIR)/rdate_$(RDATE_VERSION)-1_armeb.ipk
RDATE_IPK_DIR=$(BUILD_DIR)/rdate-$(RDATE_VERSION)-ipk

$(DL_DIR)/$(RDATE_SOURCE):
	$(WGET) -P $(DL_DIR) $(RDATE_SITE)/$(RDATE_SOURCE)

rdate-source: $(DL_DIR)/$(RDATE_SOURCE)

$(RDATE_DIR)/.source: $(DL_DIR)/$(RDATE_SOURCE)
	$(RDATE_UNZIP) $(DL_DIR)/$(RDATE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/rdate-$(RDATE_VERSION) $(RDATE_DIR)
	touch $(RDATE_DIR)/.source

$(RDATE_DIR)/.configured: $(RDATE_DIR)/.source
	touch $(RDATE_DIR)/.configured

$(RDATE_IPK_DIR): $(RDATE_DIR)/.configured
	$(MAKE) -C $(RDATE_DIR) CC=$(TARGET_CC) \
	RANLIB=$(TARGET_RANLIB) AR=$(TARGET_AR) LD=$(TARGET_LD) 

rdate-headers: $(RDATE_IPK_DIR)

rdate: $(RDATE_IPK_DIR)

$(RDATE_IPK): $(RDATE_IPK_DIR)
	mkdir -p $(RDATE_IPK_DIR)/CONTROL
	cp $(SOURCE_DIR)/rdate.control $(RDATE_IPK_DIR)/CONTROL/control
	$(STRIP) $(RDATE_DIR)/rdate
	rm -rf $(STAGING_DIR)/CONTROL
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RDATE_IPK_DIR)

rdate-ipk: $(RDATE_IPK)

rdate-source: $(DL_DIR)/$(RDATE_SOURCE)

rdate-clean:
	-$(MAKE) -C $(RDATE_DIR) uninstall
	-$(MAKE) -C $(RDATE_DIR) clean

rdate-distclean:
	-rm $(RDATE_DIR)/.configured
	-$(MAKE) -C $(RDATE_DIR) distclean


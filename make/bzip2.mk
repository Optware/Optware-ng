###########################################################
#
# bzip2
#
###########################################################

BZIP2_DIR=$(BUILD_DIR)/bzip2

BZIP2_VERSION=1.0.2
BZIP2=bzip2-$(BZIP2_VERSION)
BZIP2_SITE=ftp://sources.redhat.com/pub/bzip2/v102/
BZIP2_SOURCE=$(BZIP2).tar.gz
BZIP2_UNZIP=zcat

BZIP2_IPK=$(BUILD_DIR)/bzip2_$(BZIP2_VERSION)-1_armeb.ipk
BZIP2_IPK_DIR=$(BUILD_DIR)/bzip2-$(BZIP2_VERSION)-ipk


$(DL_DIR)/$(BZIP2_SOURCE):
	$(WGET) -P $(DL_DIR) $(BZIP2_SITE)/$(BZIP2_SOURCE)

bzip2-source: $(DL_DIR)/$(BZIP2_SOURCE)

$(BZIP2_DIR)/.source: $(DL_DIR)/$(BZIP2_SOURCE)
	$(BZIP2_UNZIP) $(DL_DIR)/$(BZIP2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/bzip2-$(BZIP2_VERSION) $(BZIP2_DIR)
	touch $(BZIP2_DIR)/.source

$(BZIP2_DIR)/.configured: $(BZIP2_DIR)/.source
	touch $(BZIP2_DIR)/.configured

$(BZIP2_IPK_DIR): $(BZIP2_DIR)/.configured
	$(MAKE) \
	  -C $(BZIP2_DIR) \
	  CC_FOR_BUILD=$(CC) \
	  CC=$(TARGET_CC) \
	  RANLIB=$(TARGET_RANLIB) \
	  AR=$(TARGET_AR) \
	  LD=$(TARGET_LD) \
	bzip2

bzip2-headers: $(BZIP2_IPK_DIR)

bzip2: $(BZIP2_IPK_DIR)

$(BZIP2_IPK): $(BZIP2_IPK_DIR)
	mkdir -p $(BZIP2_IPK_DIR)/CONTROL
	cp $(SOURCE_DIR)/bzip2.control $(BZIP2_IPK_DIR)/CONTROL/control
	$(STRIP) $(BZIP2_DIR)/bzip2
	$(STRIP) $(BZIP2_DIR)/bzip2recover
	rm -rf $(STAGING_DIR)/CONTROL
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BZIP2_IPK_DIR)

$(BZIP2_IPK)/staging: $(BZIP2_IPK_DIR)
	cp $(BZIP2_DIR)/bzlib.h $(STAGING_DIR)/include
	cp $(BZIP2_DIR)/*.a $(STAGING_DIR)/lib

bzip2-ipk: $(BZIP2_IPK)/staging $(BZIP2_IPK)

bzip2-source: $(DL_DIR)/$(BZIP2_SOURCE)

bzip2-clean:
	-$(MAKE) -C $(BZIP2_DIR) uninstall
	-$(MAKE) -C $(BZIP2_DIR) clean

bzip2-distclean:
	-rm $(BZIP2_DIR)/.configured
	-$(MAKE) -C $(BZIP2_DIR) distclean

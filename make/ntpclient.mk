###########################################################
#
# ntpclient
#
###########################################################

NTPCLIENT_DIR=$(BUILD_DIR)/ntpclient
NTPCLIENT_SOURCE_DIR=$(SOURCE_DIR)/ntpclient

NTPCLIENT_VERSION=2003_194
NTPCLIENT=ntpclient_$(NTPCLIENT_VERSION)
#NTPCLIENT_SITE=http://doolittle.faludi.com/ntpclient/
NTPCLIENT_SITE=ipkg.nslu2-linux.org/downloads
NTPCLIENT_SOURCE=$(NTPCLIENT).tar.gz
NTPCLIENT_UNZIP=zcat

NTPCLIENT_IPK=$(BUILD_DIR)/ntpclient_$(NTPCLIENT_VERSION)-1_armeb.ipk
NTPCLIENT_IPK_DIR=$(BUILD_DIR)/ntpclient-$(NTPCLIENT_VERSION)-ipk

$(DL_DIR)/$(NTPCLIENT_SOURCE):
	$(WGET) -P $(DL_DIR) $(NTPCLIENT_SITE)/$(NTPCLIENT_SOURCE)

ntpclient-source: $(DL_DIR)/$(NTPCLIENT_SOURCE)

$(NTPCLIENT_DIR)/.configured: $(DL_DIR)/$(NTPCLIENT_SOURCE)
	$(NTPCLIENT_UNZIP) $(DL_DIR)/$(NTPCLIENT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	touch $(NTPCLIENT_DIR)/.configured

ntpclient-unpack: $(NTPCLIENT_DIR)/.configured

$(NTPCLIENT_DIR)/ntpclient: $(NTPCLIENT_DIR)/.configured
	$(MAKE) -C $(NTPCLIENT_DIR) ntpclient adjtimex CC=$(TARGET_CC) \
	RANLIB=$(TARGET_RANLIB) AR=$(TARGET_AR) LD=$(TARGET_LD) 

ntpclient: $(NTPCLIENT_DIR)/ntpclient

$(NTPCLIENT_IPK): $(NTPCLIENT_DIR)/ntpclient
	mkdir -p $(NTPCLIENT_IPK_DIR)/CONTROL
	install -d $(NTPCLIENT_IPK_DIR)/opt/bin $(NTPCLIENT_IPK_DIR)/opt/sbin
	cp $(NTPCLIENT_SOURCE_DIR)/control $(NTPCLIENT_IPK_DIR)/CONTROL/control
	$(STRIP) $(NTPCLIENT_DIR)/ntpclient -o $(NTPCLIENT_IPK_DIR)/opt/bin/ntpclient
	$(STRIP) $(NTPCLIENT_DIR)/adjtimex -o $(NTPCLIENT_IPK_DIR)/opt/sbin/adjtimex
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NTPCLIENT_IPK_DIR)

ntpclient-ipk: $(NTPCLIENT_IPK)

ntpclient-clean:
	-$(MAKE) -C $(NTPCLIENT_DIR) clean

ntpclient-distclean:
	-rm $(NTPCLIENT_DIR)/.configured
	-$(MAKE) -C $(NTPCLIENT_DIR) clean

ntpclient-dirclean:
	rm -rf $(NTPCLIENT_DIR) $(NTPCLIENT_IPK_DIR) $(NTPCLIENT_IPK)

###########################################################
#
# ntp
#
###########################################################

NTP_DIR=$(BUILD_DIR)/ntp

NTP_VERSION=4.2.0
NTP=ntp-$(NTP_VERSION)
NTP_SITE=http://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/
NTP_SOURCE=$(NTP).tar.gz
NTP_UNZIP=zcat

NTP_IPK=$(BUILD_DIR)/ntp_$(NTP_VERSION)-1_armeb.ipk
NTP_IPK_DIR=$(BUILD_DIR)/ntp-$(NTP_VERSION)-ipk

$(DL_DIR)/$(NTP_SOURCE):
	$(WGET) -P $(DL_DIR) $(NTP_SITE)/$(NTP_SOURCE)

ntp-source: $(DL_DIR)/$(NTP_SOURCE)

$(NTP_DIR)/.source: $(DL_DIR)/$(NTP_SOURCE)
	$(NTP_UNZIP) $(DL_DIR)/$(NTP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/ntp-$(NTP_VERSION) $(NTP_DIR)
	touch $(NTP_DIR)/.source

$(NTP_DIR)/.configured: $(NTP_DIR)/.source
	(cd $(NTP_DIR); \
		./configure \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=$(NTP_IPK_DIR)/opt \
	  --without-crypto \
	);
	touch $(NTP_DIR)/.configured

$(NTP_IPK_DIR): $(NTP_DIR)/.configured
	$(MAKE) -C $(NTP_DIR) CC=$(TARGET_CC) \
	RANLIB=$(TARGET_RANLIB) AR=$(TARGET_AR) LD=$(TARGET_LD) install

ntp-headers: $(NTP_IPK_DIR)

ntp: $(NTP_IPK_DIR)

$(NTP_IPK): $(NTP_IPK_DIR)
	mkdir -p $(NTP_IPK_DIR)/CONTROL
	cp $(SOURCE_DIR)/ntp/control $(NTP_IPK_DIR)/CONTROL/control
	$(STRIP) $(NTP_DIR)/src/ntp -o $(NTP_IPK_DIR)/opt/bin
	$(STRIP) $(NTP_DIR)/src/entp -o $(NTP_IPK_DIR)/opt/bin
	$(STRIP) $(NTP_DIR)/src/fntp -o $(NTP_IPK_DIR)/opt/bin
	rm -rf $(STAGING_DIR)/CONTROL
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NTP_IPK_DIR)

ntp-ipk: $(NTP_IPK)

ntp-source: $(DL_DIR)/$(NTP_SOURCE)

ntp-clean:
	-$(MAKE) -C $(NTP_DIR) uninstall
	-$(MAKE) -C $(NTP_DIR) clean

ntp-distclean:
	-rm $(NTP_DIR)/.configured
	-$(MAKE) -C $(NTP_DIR) distclean


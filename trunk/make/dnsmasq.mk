#############################################################
#
# dns and dhcp server
#
#############################################################

DNSMASQ_DIR:=$(BUILD_DIR)/dnsmasq
DNSMASQ_VERSION=2.15
DNSMASQ=dnsmasq-$(DNSMASQ_VERSION)
DNSMASQ_SITE=http://www.thekelleys.org.uk/dnsmasq
DNSMASQ_SOURCE:=$(DNSMASQ).tar.gz
DNSMASQ_UNZIP=zcat

DNSMASQ_IPK=$(BUILD_DIR)/dnsmasq_$(DNSMASQ_VERSION)_armeb.ipk
DNSMASQ_IPK_DIR:=$(BUILD_DIR)/dnsmasq-$(DNSMASQ_VERSION)-ipk

$(DL_DIR)/$(DNSMASQ_SOURCE):
	$(WGET) -P $(DL_DIR) $(DNSMASQ_SITE)/$(DNSMASQ_SOURCE)

dnsmasq-source: $(DL_DIR)/$(DNSMASQ_SOURCE)


# make changes to the BUILD options below.  If you are using TCP Wrappers, 
# set --libwrap-directory=pathname 

$(DNSMASQ_DIR)/.configured: $(DL_DIR)/$(DNSMASQ_SOURCE)
	@rm -rf $(BUILD_DIR)/$(DNSMASQ) $(DNSMASQ_DIR)
	$(DNSMASQ_UNZIP) $(DL_DIR)/$(DNSMASQ_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(DNSMASQ) $(DNSMASQ_DIR)
	touch $(DNSMASQ_DIR)/.configured

dnsmasq-unpack: $(DNSMASQ_DIR)/.configured

$(DNSMASQ_DIR)/src/dnsmasq: $(DNSMASQ_DIR)/.configured
	make -C $(DNSMASQ_DIR) CC=$(TARGET_CC) AR=$(TARGET_AR) RANLIB=$(TARGET_RANLIB) 

#dhcp: $(DHCP_DIR)/dhcpd

$(DNSMASQ_IPK): $(DNSMASQ_DIR)/src/dnsmasq
	install -d $(DNSMASQ_IPK_DIR)/CONTROL $(DNSMASQ_IPK_DIR)/opt/man/man8
	install -d $(DNSMASQ_IPK_DIR)/opt/sbin $(DNSMASQ_IPK_DIR)/opt/etc/init.d
	$(STRIP) $(DNSMASQ_DIR)/src/dnsmasq -o $(DNSMASQ_IPK_DIR)/opt/sbin/dnsmasq
	install -m 755 $(SOURCE_DIR)/dnsmasq.rc $(DNSMASQ_IPK_DIR)/opt/etc/init.d/S56dnsmasq
	install -m 755 $(SOURCE_DIR)/dnsmasq.control $(DNSMASQ_IPK_DIR)/CONTROL/control
	install -m 755 $(SOURCE_DIR)/dnsmasq.postinst $(DNSMASQ_IPK_DIR)/CONTROL/postinst
	install -m 644 $(DNSMASQ_DIR)/dnsmasq.conf.example  $(DNSMASQ_IPK_DIR)/opt/etc/dnsmasq.conf.sample
	install -m 644 $(DNSMASQ_DIR)/dnsmasq.8  $(DNSMASQ_IPK_DIR)/opt/man/man8/dnsmasq.8
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DNSMASQ_IPK_DIR)

dnsmasq-ipk: $(DNSMASQ_IPK)

dnsmasq-clean:
	-make -C $(DNSMASQ_DIR) clean

dnsmasq-dirclean:
	rm -rf $(DNSMASQ_DIR) $(DNSMASQ_IPK_DIR) $(DNSMASQ_IPK)

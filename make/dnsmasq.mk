#############################################################
#
# dns and dhcp server
#
#############################################################

DNSMASQ_SITE=http://www.thekelleys.org.uk/dnsmasq
DNSMASQ_VERSION=2.15
DNSMASQ_SOURCE:=dnsmasq-$(DNSMASQ_VERSION).tar.gz
DNSMASQ_DIR:=dnsmasq-$(DNSMASQ_VERSION)
DNSMASQ_UNZIP=zcat

DNSMASQ_IPK_VERSION=3

DNSMASQ_PATCHES=$(DNSMASQ_SOURCE_DIR)/conffile.patch

DNSMASQ_BUILD_DIR=$(BUILD_DIR)/dnsmasq
DNSMASQ_SOURCE_DIR=$(SOURCE_DIR)/dnsmasq
DNSMASQ_IPK_DIR:=$(BUILD_DIR)/dnsmasq-$(DNSMASQ_VERSION)-ipk
DNSMASQ_IPK=$(BUILD_DIR)/dnsmasq_$(DNSMASQ_VERSION)-$(DNSMASQ_IPK_VERSION)_armeb.ipk

$(DL_DIR)/$(DNSMASQ_SOURCE):
	$(WGET) -P $(DL_DIR) $(DNSMASQ_SITE)/$(DNSMASQ_SOURCE)

dnsmasq-source: $(DL_DIR)/$(DNSMASQ_SOURCE)

$(DNSMASQ_BUILD_DIR)/.configured: $(DL_DIR)/$(DNSMASQ_SOURCE) $(DNSMASQ_PATCHES)
	rm -rf $(BUILD_DIR)/$(DNSMASQ_DIR) $(DNSMASQ_BUILD_DIR)
	$(DNSMASQ_UNZIP) $(DL_DIR)/$(DNSMASQ_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(DNSMASQ_PATCHES) | patch -d $(BUILD_DIR)/$(DNSMASQ_DIR) -p0
	mv $(BUILD_DIR)/$(DNSMASQ_DIR) $(DNSMASQ_BUILD_DIR)
	touch $(DNSMASQ_BUILD_DIR)/.configured

dnsmasq-unpack: $(DNSMASQ_BUILD_DIR)/.configured

$(DNSMASQ_BUILD_DIR)/src/dnsmasq: $(DNSMASQ_BUILD_DIR)/.configured
	$(MAKE) -C $(DNSMASQ_BUILD_DIR) $(TARGET_CONFIGURE_OPTS)

dnsmasq: $(DNSMASQ_BUILD_DIR)/src/dnsmasq

$(DNSMASQ_IPK): $(DNSMASQ_BUILD_DIR)/src/dnsmasq
	install -d $(DNSMASQ_IPK_DIR)/opt/sbin $(DNSMASQ_IPK_DIR)/opt/etc/init.d
	$(STRIP) $(DNSMASQ_BUILD_DIR)/src/dnsmasq -o $(DNSMASQ_IPK_DIR)/opt/sbin/dnsmasq
	install -m 755 $(DNSMASQ_SOURCE_DIR)/rc.dnsmasq $(DNSMASQ_IPK_DIR)/opt/etc/init.d/S56dnsmasq
	install -d $(DNSMASQ_IPK_DIR)/CONTROL
	install -m 644 $(DNSMASQ_SOURCE_DIR)/control $(DNSMASQ_IPK_DIR)/CONTROL/control
	install -m 644 $(DNSMASQ_SOURCE_DIR)/postinst $(DNSMASQ_IPK_DIR)/CONTROL/postinst
	install -m 644 $(DNSMASQ_SOURCE_DIR)/prerm $(DNSMASQ_IPK_DIR)/CONTROL/prerm
	install -d $(DNSMASQ_IPK_DIR)/opt/man/man8 $(DNSMASQ_IPK_DIR)/opt/doc/dnsmasq
	install -m 644 $(DNSMASQ_BUILD_DIR)/dnsmasq.8  $(DNSMASQ_IPK_DIR)/opt/man/man8/dnsmasq.8
	install -m 644 $(DNSMASQ_BUILD_DIR)/dnsmasq.conf.example \
		$(DNSMASQ_IPK_DIR)/opt/doc/dnsmasq/dnsmasq.conf.example
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DNSMASQ_IPK_DIR)

dnsmasq-ipk: $(DNSMASQ_IPK)

dnsmasq-clean:
	-$(MAKE) -C $(DNSMASQ_BUILD_DIR) clean

dnsmasq-dirclean: dnsmasq-clean
	rm -rf $(DNSMASQ_BUILD_DIR) $(DNSMASQ_IPK_DIR) $(DNSMASQ_IPK)

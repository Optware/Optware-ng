#############################################################
#
# dhcp server
#
#############################################################

DHCP_DIR:=$(BUILD_DIR)/dhcp

DHCP_VERSION=3.0.1
DHCP=dhcp-$(DHCP_VERSION)
DHCP_SITE=ftp://ftp.isc.org/isc/dhcp/
DHCP_SOURCE:=$(DHCP).tar.gz
DHCP_UNZIP=zcat
DHCP_IPK=$(BUILD_DIR)/dhcp_$(DHCP_VERSION)-1_armeb.ipk
DHCP_IPK_DIR:=$(BUILD_DIR)/dhcp-$(DHCP_VERSION)-ipk

$(DL_DIR)/$(DHCP_SOURCE):
	$(WGET) -P $(DL_DIR) $(DHCP_SITE)/$(DHCP_SOURCE)

dhcp-source: $(DL_DIR)/$(DHCP_SOURCE) $(DHCP_PATCH)


# make changes to the BUILD options below.  If you are using TCP Wrappers, 
# set --libwrap-directory=pathname 

$(DHCP_DIR)/.configured: $(DL_DIR)/$(DHCP_SOURCE)
	@rm -rf $(BUILD_DIR)/$(DHCP) $(DHCP_DIR)
	$(DHCP_UNZIP) $(DL_DIR)/$(DHCP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(DHCP) $(DHCP_DIR)
	(cd $(DHCP_DIR) && \
   ./configure)
	touch $(DHCP_DIR)/.configured

dhcp-unpack: $(DHCP_DIR)/.configured

$(DHCP_DIR)/dhcpd: $(DHCP_DIR)/.configured
	make -C $(DHCP_DIR) CC=$(TARGET_CC) AR=$(TARGET_AR) RANLIB=$(TARGET_RANLIB) 

dhcp: $(DHCP_DIR)/dhcpd

$(DHCP_IPK): $(DHCP_DIR)/dhcpd
	install -d $(DHCP_IPK_DIR)/CONTROL
	install -d $(DHCP_IPK_DIR)/opt/sbin $(DHCP_IPK_DIR)/opt/etc/init.d
	$(STRIP) $(DHCP_DIR)/`find  builds/dhcp -name work* | cut -d/ -f3`/server/dhcpd -o $(DHCP_IPK_DIR)/opt/sbin/dhcpd
	install -m 755 $(SOURCE_DIR)/dhcp.rc $(DHCP_IPK_DIR)/opt/etc/init.d/S56dhcp
	install -m 644 $(SOURCE_DIR)/dhcp.control  $(DHCP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DHCP_IPK_DIR)

dhcp-ipk: $(DHCP_IPK)

dhcp-clean:
	-make -C $(DHCP_DIR) clean

dhcp-dirclean:
	rm -rf $(DHCP_DIR) $(DHCP_IPK_DIR) $(DHCP_IPK)

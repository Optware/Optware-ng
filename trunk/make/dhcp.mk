#############################################################
#
# dhcp server
#
#############################################################

DHCP_DIR:=$(BUILD_DIR)/dhcp

DHCP_VERSION=3.1.0
DHCP=dhcp-$(DHCP_VERSION)
DHCP_SITE=ftp://ftp.isc.org/isc/dhcp/
DHCP_SOURCE:=$(DHCP).tar.gz
DHCP_UNZIP=zcat
DHCP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DHCP_DESCRIPTION=A DHCP Server
DHCP_SECTION=net
DHCP_PRIORITY=optional
DHCP_DEPENDS=
DHCP_SUGGESTS=
DHCP_CONFLICTS=

DHCP_IPK_VERSION=1

DHCP_IPK=$(BUILD_DIR)/dhcp_$(DHCP_VERSION)-$(DHCP_IPK_VERSION)_$(TARGET_ARCH).ipk
DHCP_IPK_DIR:=$(BUILD_DIR)/dhcp-$(DHCP_VERSION)-ipk

$(DL_DIR)/$(DHCP_SOURCE):
	$(WGET) -P $(DL_DIR) $(DHCP_SITE)/$(DHCP_SOURCE)

.PHONY: dhcp-source dhcp-unpack dhcp dhcp-stage dhcp-ipk dhcp-clean dhcp-dirclean dhcp-check

dhcp-source: $(DL_DIR)/$(DHCP_SOURCE) $(DHCP_PATCH)


# make changes to the BUILD options below.  If you are using TCP Wrappers, 
# set --libwrap-directory=pathname 

$(DHCP_DIR)/.configured: $(DL_DIR)/$(DHCP_SOURCE)
	@rm -rf $(BUILD_DIR)/$(DHCP) $(DHCP_DIR)
	$(DHCP_UNZIP) $(DL_DIR)/$(DHCP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(DHCP) $(DHCP_DIR)
	sed -ie 's/\/\* #define _PATH_DHCPD_PID.*/#define _PATH_DHCPD_PID      "\/opt\/var\/run\/dhcpd.pid"/' $(DHCP_DIR)/includes/site.h
	sed -ie 's/\/\* #define _PATH_DHCPD_DB.*/#define _PATH_DHCPD_DB      "\/opt\/etc\/dhcpd.leases"/' $(DHCP_DIR)/includes/site.h
	sed -ie 's/\/\* #define _PATH_DHCPD_CONF.*/#define _PATH_DHCPD_CONF      "\/opt\/etc\/dhcpd.conf"/' $(DHCP_DIR)/includes/site.h
	(cd $(DHCP_DIR) && \
		./configure)
	touch $@

dhcp-unpack: $(DHCP_DIR)/.configured

$(DHCP_DIR)/.built: $(DHCP_DIR)/.configured
	rm -f $@
	make -C $(DHCP_DIR) CC=$(TARGET_CC) AR=$(TARGET_AR) RANLIB=$(TARGET_RANLIB)
	touch $@

dhcp: $(DHCP_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dhcp
#
$(DHCP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: dhcp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DHCP_PRIORITY)" >>$@
	@echo "Section: $(DHCP_SECTION)" >>$@
	@echo "Version: $(DHCP_VERSION)-$(DHCP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DHCP_MAINTAINER)" >>$@
	@echo "Source: $(DHCP_SITE)/$(DHCP_SOURCE)" >>$@
	@echo "Description: $(DHCP_DESCRIPTION)" >>$@
	@echo "Depends: $(DHCP_DEPENDS)" >>$@
	@echo "Suggests: $(DHCP_SUGGESTS)" >>$@
	@echo "Conflicts: $(DHCP_CONFLICTS)" >>$@

$(DHCP_IPK): $(DHCP_DIR)/.built
	rm -rf $(DHCP_IPK_DIR) $(BUILD_DIR)/dhcp_*_$(TARGET_ARCH).ipk
	install -d $(DHCP_IPK_DIR)/CONTROL
	install -d $(DHCP_IPK_DIR)/opt/sbin $(DHCP_IPK_DIR)/opt/etc/init.d
	$(STRIP_COMMAND) $(DHCP_DIR)/`find  builds/dhcp -name work* | cut -d/ -f3`/server/dhcpd -o $(DHCP_IPK_DIR)/opt/sbin/dhcpd
	install -m 755 $(SOURCE_DIR)/dhcp.rc $(DHCP_IPK_DIR)/opt/etc/init.d/S56dhcp
	touch $(DHCP_IPK_DIR)/opt/etc/dhcpd.leases
	cp $(DHCP_DIR)/server/dhcpd.conf $(DHCP_IPK_DIR)/opt/etc/
	$(MAKE) $(DHCP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DHCP_IPK_DIR)

dhcp-ipk: $(DHCP_IPK)

dhcp-clean:
	-make -C $(DHCP_DIR) clean

dhcp-dirclean:
	rm -rf $(DHCP_DIR) $(DHCP_IPK_DIR) $(DHCP_IPK)

dhcp-check: $(DHCP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(DHCP_IPK)

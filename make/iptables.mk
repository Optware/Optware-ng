###########################################################
#
# iptables
#
###########################################################

IPTABLES_SITE=http://www.netfilter.org/files/
IPTABLES_VERSION=1.2.11
IPTABLES_SOURCE=iptables-$(IPTABLES_VERSION).tar.bz2
IPTABLES_DIR=iptables-$(IPTABLES_VERSION)
IPTABLES_UNZIP=bzcat
IPTABLES_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
IPTABLES_DESCRIPTION=Userland utilities for controlling firewalling rules
IPTABLES_SECTION=net
IPTABLES_PRIORITY=optional
IPTABLES_DEPENDS=
IPTABLES_SUGGESTS=
IPTABLES_CONFLICTS=

IPTABLES_IPK_VERSION=2

IPTABLES_BUILD_DIR=$(BUILD_DIR)/iptables
IPTABLES_SOURCE_DIR=$(SOURCE_DIR)/iptables
IPTABLES_IPK_DIR=$(BUILD_DIR)/iptables-$(IPTABLES_VERSION)-ipk
IPTABLES_IPK=$(BUILD_DIR)/iptables_$(IPTABLES_VERSION)-$(IPTABLES_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(IPTABLES_SOURCE):
	$(WGET) -P $(DL_DIR) $(IPTABLES_SITE)/$(IPTABLES_SOURCE)

iptables-source: $(DL_DIR)/$(IPTABLES_SOURCE)

$(IPTABLES_BUILD_DIR)/.configured: $(DL_DIR)/$(IPTABLES_SOURCE)
	rm -rf $(BUILD_DIR)/$(IPTABLES_DIR) $(IPTABLES_BUILD_DIR)
	$(IPTABLES_UNZIP) $(DL_DIR)/$(IPTABLES_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(IPTABLES_DIR) $(IPTABLES_BUILD_DIR)
	touch $(IPTABLES_BUILD_DIR)/.configured

iptables-unpack: $(IPTABLES_BUILD_DIR)/.configured

$(IPTABLES_BUILD_DIR)/iptables: $(IPTABLES_BUILD_DIR)/.configured
	$(MAKE) -C $(IPTABLES_BUILD_DIR) all \
		$(TARGET_CONFIGURE_OPTS) PREFIX=/opt

iptables: $(IPTABLES_BUILD_DIR)/iptables

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/iptables
#
$(IPTABLES_IPK_DIR)/CONTROL/control:
	@install -d $(IPTABLES_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: iptables" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IPTABLES_PRIORITY)" >>$@
	@echo "Section: $(IPTABLES_SECTION)" >>$@
	@echo "Version: $(IPTABLES_VERSION)-$(IPTABLES_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IPTABLES_MAINTAINER)" >>$@
	@echo "Source: $(IPTABLES_SITE)/$(IPTABLES_SOURCE)" >>$@
	@echo "Description: $(IPTABLES_DESCRIPTION)" >>$@
	@echo "Depends: $(IPTABLES_DEPENDS)" >>$@
	@echo "Suggests: $(IPTABLES_SUGGESTS)" >>$@
	@echo "Conflicts: $(IPTABLES_CONFLICTS)" >>$@

$(IPTABLES_IPK): $(IPTABLES_BUILD_DIR)/iptables
	$(MAKE) -C $(IPTABLES_BUILD_DIR) install \
		$(TARGET_CONFIGURE_OPTS) PREFIX=/opt DESTDIR=$(IPTABLES_IPK_DIR)
	$(MAKE) $(IPTABLES_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IPTABLES_IPK_DIR)

iptables-ipk: $(IPTABLES_IPK)

iptables-clean:
	-$(MAKE) -C $(IPTABLES_BUILD_DIR) clean

iptables-dirclean:
	rm -rf $(BUILD_DIR)/$(IPTABLES_DIR) $(IPTABLES_BUILD_DIR) $(IPTABLES_IPK_DIR) $(IPTABLES_IPK)


#############################################################
#
# dns and dhcp server
#
#############################################################

DNSMASQ_SITE=http://www.thekelleys.org.uk/dnsmasq
DNSMASQ_VERSION=2.45
DNSMASQ_SOURCE:=dnsmasq-$(DNSMASQ_VERSION).tar.gz
DNSMASQ_DIR:=dnsmasq-$(DNSMASQ_VERSION)
DNSMASQ_UNZIP=zcat
DNSMASQ_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DNSMASQ_DESCRIPTION=DNS and DHCP server
DNSMASQ_SECTION=net
DNSMASQ_PRIORITY=optional
DNSMASQ_DEPENDS=
DNSMASQ_CONFLICTS=

DNSMASQ_IPK_VERSION=2

# DNSMASQ_CONFFILES should be a list of user-editable files
DNSMASQ_CONFFILES=/opt/etc/dnsmasq.conf

DNSMASQ_PATCHES=$(DNSMASQ_SOURCE_DIR)/conffile.patch $(DNSMASQ_SOURCE_DIR)/src-dnsmasq.h.patch

DNSMASQ_MAKE_FLAGS=$(strip \
$(if $(or $(filter no, $(IPV6)), $(filter oleg, $(OPTWARE_TARGET))), COPTS=-DNO_IPV6, ))

DNSMASQ_BUILD_DIR=$(BUILD_DIR)/dnsmasq
DNSMASQ_SOURCE_DIR=$(SOURCE_DIR)/dnsmasq
DNSMASQ_IPK_DIR:=$(BUILD_DIR)/dnsmasq-$(DNSMASQ_VERSION)-ipk
DNSMASQ_IPK=$(BUILD_DIR)/dnsmasq_$(DNSMASQ_VERSION)-$(DNSMASQ_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: dnsmasq-source dnsmasq-unpack dnsmasq dnsmasq-stage dnsmasq-ipk dnsmasq-clean dnsmasq-dirclean dnsmasq-check

$(DL_DIR)/$(DNSMASQ_SOURCE):
	$(WGET) -P $(@D) $(DNSMASQ_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

dnsmasq-source: $(DL_DIR)/$(DNSMASQ_SOURCE)

$(DNSMASQ_BUILD_DIR)/.configured: $(DL_DIR)/$(DNSMASQ_SOURCE) $(DNSMASQ_PATCHES)
	rm -rf $(BUILD_DIR)/$(DNSMASQ_DIR) $(@D)
	$(DNSMASQ_UNZIP) $(DL_DIR)/$(DNSMASQ_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(DNSMASQ_PATCHES) | patch -d $(BUILD_DIR)/$(DNSMASQ_DIR) -p0
	mv $(BUILD_DIR)/$(DNSMASQ_DIR) $(@D)
	touch $@

dnsmasq-unpack: $(DNSMASQ_BUILD_DIR)/.configured

$(DNSMASQ_BUILD_DIR)/.built: $(DNSMASQ_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) $(TARGET_CONFIGURE_OPTS) $(DNSMASQ_MAKE_FLAGS)
	touch $@

dnsmasq: $(DNSMASQ_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dnsmasq
#
$(DNSMASQ_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: dnsmasq" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DNSMASQ_PRIORITY)" >>$@
	@echo "Section: $(DNSMASQ_SECTION)" >>$@
	@echo "Version: $(DNSMASQ_VERSION)-$(DNSMASQ_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DNSMASQ_MAINTAINER)" >>$@
	@echo "Source: $(DNSMASQ_SITE)/$(DNSMASQ_SOURCE)" >>$@
	@echo "Description: $(DNSMASQ_DESCRIPTION)" >>$@
	@echo "Depends: $(DNSMASQ_DEPENDS)" >>$@
	@echo "Conflicts: $(DNSMASQ_CONFLICTS)" >>$@

$(DNSMASQ_IPK): $(DNSMASQ_BUILD_DIR)/.built
	rm -rf $(DNSMASQ_IPK_DIR) $(BUILD_DIR)/dnsmasq_*_$(TARGET_ARCH).ipk
	install -d $(DNSMASQ_IPK_DIR)/opt/sbin $(DNSMASQ_IPK_DIR)/opt/etc/init.d
	$(STRIP_COMMAND) $(DNSMASQ_BUILD_DIR)/src/dnsmasq -o $(DNSMASQ_IPK_DIR)/opt/sbin/dnsmasq
	install -m 644 $(DNSMASQ_BUILD_DIR)/dnsmasq.conf.example $(DNSMASQ_IPK_DIR)/opt/etc/dnsmasq.conf
	install -m 755 $(DNSMASQ_SOURCE_DIR)/rc.dnsmasq $(DNSMASQ_IPK_DIR)/opt/etc/init.d/S56dnsmasq
	$(MAKE) $(DNSMASQ_IPK_DIR)/CONTROL/control	
	echo $(DNSMASQ_CONFFILES) | sed -e 's/ /\n/g' > $(DNSMASQ_IPK_DIR)/CONTROL/conffiles
	install -m 644 $(DNSMASQ_SOURCE_DIR)/postinst $(DNSMASQ_IPK_DIR)/CONTROL/postinst
	install -m 644 $(DNSMASQ_SOURCE_DIR)/prerm $(DNSMASQ_IPK_DIR)/CONTROL/prerm
	install -d $(DNSMASQ_IPK_DIR)/opt/man/man8 $(DNSMASQ_IPK_DIR)/opt/doc/dnsmasq
	install -m 644 $(DNSMASQ_BUILD_DIR)/man/dnsmasq.8  $(DNSMASQ_IPK_DIR)/opt/man/man8/dnsmasq.8
	install -m 644 $(DNSMASQ_BUILD_DIR)/dnsmasq.conf.example \
		$(DNSMASQ_IPK_DIR)/opt/doc/dnsmasq/dnsmasq.conf.example
	install -m 644 $(DNSMASQ_BUILD_DIR)/doc.html \
		$(DNSMASQ_IPK_DIR)/opt/doc/dnsmasq/doc.html
	install -m 644 $(DNSMASQ_BUILD_DIR)/setup.html \
		$(DNSMASQ_IPK_DIR)/opt/doc/dnsmasq/setup.html
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DNSMASQ_IPK_DIR)

dnsmasq-ipk: $(DNSMASQ_IPK)

dnsmasq-clean:
	-$(MAKE) -C $(DNSMASQ_BUILD_DIR) clean

dnsmasq-dirclean:
	rm -rf $(BUILD_DIR)/$(DNSMASQ_DIR) $(DNSMASQ_BUILD_DIR) $(DNSMASQ_IPK_DIR) $(DNSMASQ_IPK)

dnsmasq-check: $(DNSMASQ_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(DNSMASQ_IPK)

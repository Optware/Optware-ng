###########################################################
#
# rdate
#
###########################################################

RDATE_DIR=$(BUILD_DIR)/rdate
RDATE_SOURCE_DIR=$(SOURCE_DIR)/rdate

RDATE_VERSION=1.4
RDATE=rdate-$(RDATE_VERSION)
RDATE_SITE=http://sources.nslu2-linux.org/sources/
RDATE_SOURCE=$(RDATE).tar.gz
RDATE_UNZIP=zcat
RDATE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
RDATE_DESCRIPTION=Using RFC868, retrieves a remote date and time and sets the local time
RDATE_SECTION=network
RDATE_PRIORITY=optional
RDATE_DEPENDS=
RDATE_CONFLICTS=

RDATE_IPK_VERSION=2

RDATE_IPK=$(BUILD_DIR)/rdate_$(RDATE_VERSION)-$(RDATE_IPK_VERSION)_$(TARGET_ARCH).ipk
RDATE_IPK_DIR=$(BUILD_DIR)/rdate-$(RDATE_VERSION)-ipk

$(DL_DIR)/$(RDATE_SOURCE):
	$(WGET) -P $(DL_DIR) $(RDATE_SITE)/$(RDATE_SOURCE)

rdate-source: $(DL_DIR)/$(RDATE_SOURCE)

$(RDATE_DIR)/.configured: $(DL_DIR)/$(RDATE_SOURCE)
	$(RDATE_UNZIP) $(DL_DIR)/$(RDATE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/rdate-$(RDATE_VERSION) $(RDATE_DIR)
	touch $(RDATE_DIR)/.configured

rdate-unpack: $(RDATE_DIR)/.configured

$(RDATE_DIR)/rdate: $(RDATE_DIR)/.configured
	$(MAKE) -C $(RDATE_DIR) CC=$(TARGET_CC) \
	RANLIB=$(TARGET_RANLIB) AR=$(TARGET_AR) LD=$(TARGET_LD) 

rdate: $(RDATE_DIR)/rdate

$(RDATE_IPK_DIR)/CONTROL/control:
	@install -d $(RDATE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: rdate" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(RDATE_PRIORITY)" >>$@
	@echo "Section: $(RDATE_SECTION)" >>$@
	@echo "Version: $(RDATE_VERSION)-$(RDATE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RDATE_MAINTAINER)" >>$@
	@echo "Source: $(RDATE_SITE)/$(RDATE_SOURCE)" >>$@
	@echo "Description: $(RDATE_DESCRIPTION)" >>$@
	@echo "Depends: $(RDATE_DEPENDS)" >>$@
	@echo "Conflicts: $(RDATE_CONFLICTS)" >>$@

$(RDATE_IPK): $(RDATE_DIR)/rdate
	install -d $(RDATE_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(RDATE_DIR)/rdate -o $(RDATE_IPK_DIR)/opt/bin/rdate
	$(MAKE) $(RDATE_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RDATE_IPK_DIR)

rdate-ipk: $(RDATE_IPK)

rdate-clean:
	-$(MAKE) -C $(RDATE_DIR) clean

rdate-distclean:
	-rm $(RDATE_DIR)/.configured
	-$(MAKE) -C $(RDATE_DIR) clean

rdate-dirclean:
	rm -rf $(RDATE_DIR) $(RDATE_IPK_DIR) $(RDATE_IPK)

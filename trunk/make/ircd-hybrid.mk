###########################################################
#
# ircd-hybrid
#
###########################################################

IRCD_HYBRID_DIR=$(BUILD_DIR)/ircd-hybrid

IRCD_HYBRID_VERSION=7.0.3
IRCD_HYBRID=ircd-hybrid-$(IRCD_HYBRID_VERSION)
IRCD_HYBRID_SITE=http://aleron.dl.sourceforge.net/sourceforge/ircd-hybrid
IRCD_HYBRID_SOURCE=$(IRCD_HYBRID).tgz
IRCD_HYBRID_UNZIP=zcat

IRCD_HYBRID_IPK=$(BUILD_DIR)/ircd-hybrid_$(IRCD_HYBRID_VERSION)-1_armeb.ipk
IRCD_HYBRID_IPK_DIR=$(BUILD_DIR)/ircd-hybrid-$(IRCD_HYBRID_VERSION)-ipk

MY_STAGING_LDFLAGS="$(STAGING_LDFLAGS) -L$(STAGING_DIR)/lib/lib"

$(DL_DIR)/$(IRCD_HYBRID_SOURCE):
	$(WGET) -P $(DL_DIR) $(IRCD_HYBRID_SITE)/$(IRCD_HYBRID_SOURCE)

ircd-hybrid-source: $(DL_DIR)/$(IRCD_HYBRID_SOURCE)

$(IRCD_HYBRID_DIR)/.source: $(DL_DIR)/$(IRCD_HYBRID_SOURCE)
	$(IRCD_HYBRID_UNZIP) $(DL_DIR)/$(IRCD_HYBRID_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/ircd-hybrid-$(IRCD_HYBRID_VERSION) $(IRCD_HYBRID_DIR)
	touch $(IRCD_HYBRID_DIR)/.source

$(IRCD_HYBRID_DIR)/.configured: $(IRCD_HYBRID_DIR)/.source
	(cd $(IRCD_HYBRID_DIR); \
		./configure \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
	);
	touch $(IRCD_HYBRID_DIR)/.configured

$(IRCD_HYBRID_DIR)/src/ircd-hybrid: $(IRCD_HYBRID_DIR)/.configured
	$(MAKE) -C $(IRCD_HYBRID_DIR) \
	CC=$(TARGET_CC) AR=$(TARGET_AR) CFLAGS=$(STAGING_CPPFLAGS) LDFLAGS=$(MY_STAGING_LDFLAGS) RANLIB=$(TARGET_RANLIB)

ircd-hybrid: $(IRCD_HYBRID_DIR)/src/ircd-hybrid

$(IRCD_HYBRID_IPK): $(IRCD_HYBRID_DIR)/src/ircd-hybrid
	mkdir -p $(IRCD_HYBRID_IPK_DIR)/CONTROL
	mkdir -p $(IRCD_HYBRID_IPK_DIR)/opt
	mkdir -p $(IRCD_HYBRID_IPK_DIR)/opt/bin
	$(STRIP) $(IRCD_HYBRID_DIR)/src/ircd -o $(IRCD_HYBRID_IPK_DIR)/opt/bin/ircd
	cp $(SOURCE_DIR)/ircd-hybrid.control $(IRCD_HYBRID_IPK_DIR)/CONTROL/control
	mkdir -p $(IRCD_HYBRID_IPK_DIR)/opt/etc
	cp $(IRCD_HYBRID_DIR)/doc/simple.conf $(IRCD_HYBRID_IPK_DIR)/opt/etc/ircd-hybrid-simple.conf
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IRCD_HYBRID_IPK_DIR)

ircd-hybrid-ipk: $(IRCD_HYBRID_IPK)

ircd-hybrid-clean:
	-$(MAKE) -C $(IRCD_HYBRID_DIR) uninstall
	-$(MAKE) -C $(IRCD_HYBRID_DIR) clean

ircd-hybrid-distclean:
	-rm $(IRCD_HYBRID_DIR)/.configured
	-$(MAKE) -C $(IRCD_HYBRID_DIR) distclean

ircd-hybrid-dirclean:
	rm -rf $(IRCD_HYBRID_DIR) $(IRCD_HYBRID_IPK_DIR) $(IRCD_HYBRID_IPK)

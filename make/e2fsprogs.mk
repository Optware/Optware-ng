###########################################################
#
# e2fsprogs
#
###########################################################

E2FSPROGS_DIR=$(BUILD_DIR)/e2fsprogs

E2FSPROGS_VERSION=1.35
E2FSPROGS=e2fsprogs-$(E2FSPROGS_VERSION)
E2FSPROGS_SITE=http://aleron.dl.sourceforge.net/sourceforge/e2fsprogs/
E2FSPROGS_SOURCE=$(E2FSPROGS).tar.gz
E2FSPROGS_UNZIP=zcat

E2FSPROGS_IPK=$(BUILD_DIR)/e2fsprogs_$(E2FSPROGS_VERSION)-1_armeb.ipk
E2FSPROGS_IPK_DIR=$(BUILD_DIR)/e2fsprogs-$(E2FSPROGS_VERSION)-ipk

$(DL_DIR)/$(E2FSPROGS_SOURCE):
	$(WGET) -P $(DL_DIR) $(E2FSPROGS_SITE)/$(E2FSPROGS_SOURCE)

e2fsprogs-source: $(DL_DIR)/$(E2FSPROGS_SOURCE)

$(E2FSPROGS_DIR)/.source: $(DL_DIR)/$(E2FSPROGS_SOURCE)
	$(E2FSPROGS_UNZIP) $(DL_DIR)/$(E2FSPROGS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/e2fsprogs-$(E2FSPROGS_VERSION) $(E2FSPROGS_DIR)
	touch $(E2FSPROGS_DIR)/.source

$(E2FSPROGS_DIR)/.configured: $(E2FSPROGS_DIR)/.source
	(cd $(E2FSPROGS_DIR); \
		./configure \
		--prefix=$(E2FSPROGS_IPK_DIR)/opt \
	);
	touch $(E2FSPROGS_DIR)/.configured

$(E2FSPROGS_IPK_DIR): $(E2FSPROGS_DIR)/.configured
	$(MAKE) \
	  -C $(E2FSPROGS_DIR) \
	  CC_FOR_BUILD=$(CC) \
	  CC=$(TARGET_CC) \
	  RANLIB=$(TARGET_RANLIB) \
	  AR=$(TARGET_AR) \
	  LD=$(TARGET_LD) \
	libs

e2fsprogs-headers: $(E2FSPROGS_IPK_DIR)

e2fsprogs: $(E2FSPROGS_IPK_DIR)

$(E2FSPROGS_IPK): $(E2FSPROGS_IPK_DIR)
	mkdir -p $(E2FSPROGS_IPK_DIR)/CONTROL
	mkdir -p $(E2FSPROGS_IPK_DIR)/opt/lib
	cp $(SOURCE_DIR)/e2fsprogs.control $(E2FSPROGS_IPK_DIR)/CONTROL/control
	cp $(E2FSPROGS_DIR)/lib/*.a $(E2FSPROGS_IPK_DIR)/opt/lib
	rm -rf $(STAGING_DIR)/CONTROL
	cd $(BUILD_DIR); $(IPKG_BUILD) $(E2FSPROGS_IPK_DIR)

$(E2FSPROGS_IPK)/staging:
	rm -rf $(STAGING_DIR)/include/blkid
	rm -rf $(STAGING_DIR)/include/ext2fs
	rm -rf $(STAGING_DIR)/include/et
	mkdir -p $(STAGING_DIR)/include/blkid
	mkdir -p $(STAGING_DIR)/include/ext2fs
	mkdir -p $(STAGING_DIR)/include/et
	cp $(E2FSPROGS_DIR)/lib/*.a $(STAGING_DIR)/lib
	cp $(E2FSPROGS_DIR)/lib/blkid/*.h $(STAGING_DIR)/include/blkid
	cp $(E2FSPROGS_DIR)/lib/ext2fs/*.h $(STAGING_DIR)/include/ext2fs
	cp $(E2FSPROGS_DIR)/lib/et/*.h $(STAGING_DIR)/include/et

e2fsprogs-ipk: $(E2FSPROGS_IPK)/staging $(E2FSPROGS_IPK)

e2fsprogs-source: $(DL_DIR)/$(E2FSPROGS_SOURCE)

e2fsprogs-clean:
	-$(MAKE) -C $(E2FSPROGS_DIR) uninstall
	-$(MAKE) -C $(E2FSPROGS_DIR) clean

e2fsprogs-distclean:
	-rm $(E2FSPROGS_DIR)/.configured
	-$(MAKE) -C $(E2FSPROGS_DIR) distclean


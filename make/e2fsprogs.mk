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
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/opt \
	);
	touch $(E2FSPROGS_DIR)/.configured

$(E2FSPROGS_IPK_DIR): $(E2FSPROGS_DIR)/.configured
	$(MAKE) \
	  -C $(E2FSPROGS_DIR) \
	  CC_FOR_BUILD=$(CC) \
	  CC=$(TARGET_CC) \
	  RANLIB=$(TARGET_RANLIB) \
	  AR=$(TARGET_AR) \
	  LD=$(TARGET_CC)

e2fsprogs-headers: $(E2FSPROGS_IPK_DIR)

e2fsprogs: $(E2FSPROGS_IPK_DIR)

$(E2FSPROGS_IPK): $(E2FSPROGS_IPK_DIR)
	mkdir -p $(E2FSPROGS_IPK_DIR)/CONTROL
	mkdir -p $(E2FSPROGS_IPK_DIR)/opt/lib
	mkdir -p $(E2FSPROGS_IPK_DIR)/opt/sbin
	cp $(SOURCE_DIR)/e2fsprogs/control $(E2FSPROGS_IPK_DIR)/CONTROL/control
	cp $(E2FSPROGS_DIR)/lib/*.a $(E2FSPROGS_IPK_DIR)/opt/lib

	$(STRIP) $(E2FSPROGS_DIR)/debugfs/debugfs
	cp $(E2FSPROGS_DIR)/debugfs/debugfs $(E2FSPROGS_IPK_DIR)/opt/sbin

	$(STRIP) $(E2FSPROGS_DIR)/e2fsck/e2fsck
	cp $(E2FSPROGS_DIR)/e2fsck/e2fsck.static $(E2FSPROGS_IPK_DIR)/opt/sbin
	cp $(E2FSPROGS_DIR)/e2fsck/e2fsck.shared $(E2FSPROGS_IPK_DIR)/opt/sbin
	cp $(E2FSPROGS_DIR)/e2fsck/e2fsck $(E2FSPROGS_IPK_DIR)/opt/sbin

	$(STRIP) $(E2FSPROGS_DIR)/resize/resize2fs
	cp $(E2FSPROGS_DIR)/resize/resize2fs $(E2FSPROGS_IPK_DIR)/opt/sbin

	rm -rf $(STAGING_DIR)/CONTROL
	cd $(BUILD_DIR); $(IPKG_BUILD) $(E2FSPROGS_IPK_DIR)

e2fsprogs-stage: $(E2FSPROGS_IPK_DIR)
	rm -rf $(STAGING_INCLUDE_DIR)/blkid
	rm -rf $(STAGING_INCLUDE_DIR)/ext2fs
	rm -rf $(STAGING_INCLUDE_DIR)/et
	mkdir -p $(STAGING_INCLUDE_DIR)/blkid
	mkdir -p $(STAGING_INCLUDE_DIR)/ext2fs
	mkdir -p $(STAGING_INCLUDE_DIR)/et
	cp $(E2FSPROGS_DIR)/lib/*.a $(STAGING_LIB_DIR)
	cp $(E2FSPROGS_DIR)/lib/blkid/*.h $(STAGING_INCLUDE_DIR)/blkid
	cp $(E2FSPROGS_DIR)/lib/ext2fs/*.h $(STAGING_INCLUDE_DIR)/ext2fs
	cp $(E2FSPROGS_DIR)/lib/et/*.h $(STAGING_INCLUDE_DIR)/et

e2fsprogs-ipk: $(E2FSPROGS_IPK)/staging $(E2FSPROGS_IPK)

e2fsprogs-source: $(DL_DIR)/$(E2FSPROGS_SOURCE)

e2fsprogs-clean:
	-$(MAKE) -C $(E2FSPROGS_DIR) uninstall
	-$(MAKE) -C $(E2FSPROGS_DIR) clean

e2fsprogs-distclean:
	-rm $(E2FSPROGS_DIR)/.configured
	-$(MAKE) -C $(E2FSPROGS_DIR) distclean


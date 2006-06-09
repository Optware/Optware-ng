###########################################################
#
# dump
#
###########################################################

DUMP_DIR=$(BUILD_DIR)/dump

DUMP_VERSION=0.4b37
DUMP=dump-$(DUMP_VERSION)
DUMP_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/dump/
DUMP_SOURCE=$(DUMP).tar.gz
DUMP_UNZIP=zcat

DUMP_IPK=$(BUILD_DIR)/dump_$(DUMP_VERSION)-2_$(TARGET_ARCH).ipk
DUMP_IPK_DIR=$(BUILD_DIR)/dump-$(DUMP_VERSION)-ipk

DUMP_CFLAGS="-I $(STAGING_INCLUDE_DIR)"
DUMP_LDFLAGS="-L $(STAGING_LIB_DIR)"


$(DL_DIR)/$(DUMP_SOURCE):
	$(WGET) -P $(DL_DIR) $(DUMP_SITE)/$(DUMP_SOURCE)

dump-source: $(DL_DIR)/$(DUMP_SOURCE)

$(DUMP_DIR)/.source: $(DL_DIR)/$(DUMP_SOURCE)
	$(DUMP_UNZIP) $(DL_DIR)/$(DUMP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/dump-$(DUMP_VERSION) $(DUMP_DIR)
	touch $(DUMP_DIR)/.source

$(DUMP_DIR)/.configured: $(DUMP_DIR)/.source
	$(MAKE) e2fsprogs-stage
	$(MAKE) bzip2-stage
	$(MAKE) zlib-stage
	(cd $(DUMP_DIR); \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		PKG_CONFIG_LIBDIR=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--disable-readline \
		--includedir=$(STAGING_INCLUDE_DIR) \
		--libdir=$(STAGING_LIB_DIR) \
		--prefix=/opt \
	);
	touch $(DUMP_DIR)/.configured

$(DUMP_DIR)/dump/dump: $(DUMP_DIR)/.configured
	$(MAKE) \
	  -C $(DUMP_DIR) \
	  CC_FOR_BUILD=$(CC) \
	  CC=$(TARGET_CC) \
	  OPT=$(DUMP_CFLAGS) \
	  ALL_LDFLAGS=$(DUMP_LDFLAGS) \
	  RANLIB=$(TARGET_RANLIB) \
	  AR=$(TARGET_AR) \
	  LD=$(TARGET_CC)


dump-stage: $(DUMP_IPK)

dump-headers: $(DUMP_IPK)

dump: $(DUMP_IPK)

$(DUMP_IPK): $(DUMP_DIR)/dump/dump
	mkdir -p $(DUMP_IPK_DIR)/CONTROL
	cp $(SOURCE_DIR)/dump/control $(DUMP_IPK_DIR)/CONTROL/control
	mkdir -p $(DUMP_IPK_DIR)/opt/sbin

	$(STRIP_COMMAND) $(DUMP_DIR)/dump/dump
	cp $(DUMP_DIR)/dump/dump $(DUMP_IPK_DIR)/opt/sbin

	$(STRIP_COMMAND) $(DUMP_DIR)/restore/restore
	cp $(DUMP_DIR)/restore/restore $(DUMP_IPK_DIR)/opt/sbin

	$(STRIP_COMMAND) $(DUMP_DIR)/rmt/rmt
	cp $(DUMP_DIR)/rmt/rmt $(DUMP_IPK_DIR)/opt/sbin

	rm -rf $(STAGING_DIR)/CONTROL
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DUMP_IPK_DIR)


dump-ipk: $(DUMP_IPK)

dump-source: $(DL_DIR)/$(DUMP_SOURCE)

dump-clean:
	-$(MAKE) -C $(DUMP_DIR) uninstall
	-$(MAKE) -C $(DUMP_DIR) clean

dump-distclean:
	-rm $(DUMP_DIR)/.configured
	-$(MAKE) -C $(DUMP_DIR) distclean

dump-dirclean:
	rm -rf $(DUMP_DIR) $(DUMP_IPK_DIR) $(DUMP_IPK)

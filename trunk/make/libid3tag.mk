###########################################################
#
# libid3tag
#
###########################################################

LIBID3TAG_DIR=$(BUILD_DIR)/libid3tag

LIBID3TAG_VERSION=0.15.1b
LIBID3TAG=libid3tag-$(LIBID3TAG_VERSION)
LIBID3TAG_SITE=http://belnet.dl.sourceforge.net/sourceforge/mad
LIBID3TAG_SOURCE=$(LIBID3TAG).tar.gz
LIBID3TAG_UNZIP=zcat
LIBID3TAG_CFLAGS= $(TARGET_CFLAGS) -I$(STAGING_DIR)/include -fPIC
LIBID3TAG_LDFLAGS= $(TARGET_LDFLAGS) -L$(STAGING_DIR)/lib

LIBID3TAG_IPK=$(BUILD_DIR)/libid3tag_$(LIBID3TAG_VERSION)-1_armeb.ipk
LIBID3TAG_IPK_DIR=$(BUILD_DIR)/libid3tag-$(LIBID3TAG_VERSION)-ipk

$(DL_DIR)/$(LIBID3TAG_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBID3TAG_SITE)/$(LIBID3TAG_SOURCE)

$(LIBID3TAG_DIR)/.source: $(DL_DIR)/$(LIBID3TAG_SOURCE)
	$(LIBID3TAG_UNZIP) $(DL_DIR)/$(LIBID3TAG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(LIBID3TAG) $(LIBID3TAG_DIR)
	touch $(LIBID3TAG_DIR)/.source

$(LIBID3TAG_DIR)/.configured: $(LIBID3TAG_DIR)/.source
	(cd $(LIBID3TAG_DIR); \
        export CC=$(TARGET_CC) ;\
        export CFLAGS="$(LIBID3TAG_CFLAGS)" ;\
        export LDFLAGS="$(LIBID3TAG_LDFLAGS)" ;\
		./configure \
		--host=arm-linux \
		--prefix=$(STAGING_DIR) \
	);
	touch $(LIBID3TAG_DIR)/.configured;

$(STAGING_DIR)/lib/libid3tag.so.$(LIBID3TAG_VERSION): $(LIBID3TAG_DIR)/.configured
	$(MAKE) CFLAGS="$(LIBID3TAG_CFLAGS)" CC=$(TARGET_CC) -C $(LIBID3TAG_DIR) install;

libid3tag-headers: $(STAGING_DIR)/lib/libid3tag.a

libid3tag: zlib $(STAGING_DIR)/lib/libid3tag.so.$(LIBID3TAG_VERSION)

$(LIBID3TAG_IPK): $(STAGING_DIR)/lib/libid3tag.so.$(LIBID3TAG_VERSION)
	mkdir -p $(LIBID3TAG_IPK_DIR)/CONTROL
	cp $(SOURCE_DIR)/libid3tag.control $(LIBID3TAG_IPK_DIR)/CONTROL/control
	mkdir -p $(LIBID3TAG_IPK_DIR)/opt/lib
	cp -dpf $(STAGING_DIR)/lib/libid3tag.so* $(LIBID3TAG_IPK_DIR)/opt/lib;
	-$(STRIP) --strip-unneeded $(LIBID3TAG_IPK_DIR)/opt/lib/libid3tag.so*
	touch -c $(LIBID3TAG_IPK_DIR)/opt/lib/libid3tag.so.$(LIBID3TAG_VERSION)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBID3TAG_IPK_DIR)

libid3tag-ipk: $(LIBID3TAG_IPK)

libid3tag-source: $(DL_DIR)/$(LIBID3TAG_SOURCE)

libid3tag-clean:
	-$(MAKE) -C $(LIBID3TAG_DIR) uninstall
	-$(MAKE) -C $(LIBID3TAG_DIR) clean

libid3tag-dirclean: libid3tag-clean
	rm -rf $(LIBID3TAG_DIR)


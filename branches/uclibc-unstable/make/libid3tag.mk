###########################################################
#
# libid3tag
#
###########################################################

LIBID3TAG_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/mad
LIBID3TAG_VERSION=0.15.1b
LIBID3TAG_LIB_VERSION=0.3.0
LIBID3TAG_SOURCE=libid3tag-$(LIBID3TAG_VERSION).tar.gz
LIBID3TAG_DIR=libid3tag-$(LIBID3TAG_VERSION)
LIBID3TAG_UNZIP=zcat

LIBID3TAG_IPK_VERSION=1

LIBID3TAG_BUILD_DIR=$(BUILD_DIR)/libid3tag
LIBID3TAG_SOURCE_DIR=$(SOURCE_DIR)/libid3tag
LIBID3TAG_IPK_DIR=$(BUILD_DIR)/libid3tag-$(LIBID3TAG_VERSION)-ipk
LIBID3TAG_IPK=$(BUILD_DIR)/libid3tag_$(LIBID3TAG_VERSION)-$(LIBID3TAG_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(LIBID3TAG_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBID3TAG_SITE)/$(LIBID3TAG_SOURCE)

libid3tag-source: $(DL_DIR)/$(LIBID3TAG_SOURCE)

$(LIBID3TAG_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBID3TAG_SOURCE)
	$(MAKE) zlib-stage
	rm -rf $(BUILD_DIR)/$(LIBID3TAG_DIR) $(LIBID3TAG_BUILD_DIR)
	$(LIBID3TAG_UNZIP) $(DL_DIR)/$(LIBID3TAG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(LIBID3TAG_DIR) $(LIBID3TAG_BUILD_DIR)
	(cd $(LIBID3TAG_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	);
	touch $(LIBID3TAG_BUILD_DIR)/.configured

libid3tag-unpack: $(LIBID3TAG_BUILD_DIR)/.configured

$(LIBID3TAG_BUILD_DIR)/.libs/libid3tag.a: $(LIBID3TAG_BUILD_DIR)/.configured
	$(MAKE) -C $(LIBID3TAG_BUILD_DIR)

libid3tag: $(LIBID3TAG_BUILD_DIR)/.libs/libid3tag.a

$(STAGING_DIR)/opt/lib/libid3tag.a: $(LIBID3TAG_BUILD_DIR)/.libs/libid3tag.a
	$(MAKE) -C $(LIBID3TAG_BUILD_DIR) DESTDIR=$(STAGING_DIR) install

libid3tag-stage: $(STAGING_DIR)/opt/lib/libid3tag.a

$(LIBID3TAG_IPK): $(LIBID3TAG_BUILD_DIR)/.libs/libid3tag.a
	rm -rf $(LIBID3TAG_IPK_DIR) $(LIBID3TAG_IPK)
	$(MAKE) -C $(LIBID3TAG_BUILD_DIR) DESTDIR=$(LIBID3TAG_IPK_DIR) install
	$(STRIP_COMMAND) $(LIBID3TAG_IPK_DIR)/opt/lib/*.so.*
	rm -f $(LIBID3TAG_IPK_DIR)/opt/lib/*.{la,a}
	install -d $(LIBID3TAG_IPK_DIR)/CONTROL
	sed -e "s/@ARCH@/$(TARGET_ARCH)/" -e "s/@VERSION@/$(LIBID3TAG_VERSION)/" \
		-e "s/@RELEASE@/$(LIBID3TAG_IPK_VERSION)/" $(LIBID3TAG_SOURCE_DIR)/control > $(LIBID3TAG_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBID3TAG_IPK_DIR)

libid3tag-ipk: $(LIBID3TAG_IPK)

libid3tag-clean:
	-$(MAKE) -C $(LIBID3TAG_BUILD_DIR) clean

libid3tag-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBID3TAG_DIR) $(LIBID3TAG_BUILD_DIR) $(LIBID3TAG_IPK_DIR) $(LIBID3TAG_IPK)


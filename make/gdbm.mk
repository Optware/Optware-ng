###########################################################
#
# gdbm
#
###########################################################

GDBM_DIR=$(BUILD_DIR)/gdbm

GDBM_VERSION=1.8.3
GDBM_LIBVERSION=3.0.0
GDBM=gdbm-$(GDBM_VERSION)
GDBM_SITE=ftp://ftp.gnu.org/gnu/gdbm
GDBM_SOURCE=$(GDBM).tar.gz
GDBM_UNZIP=zcat
ZLIB_CFLAGS= $(TARGET_CFLAGS) -fPIC

GDBM_PATCH:=$(SOURCE_DIR)/gdbm.patch

GDBM_IPK=$(BUILD_DIR)/gdbm_$(GDBM_VERSION)-1_armeb.ipk
GDBM_IPK_DIR=$(BUILD_DIR)/gdbm-$(GDBM_VERSION)-ipk

$(DL_DIR)/$(GDBM_SOURCE):
	$(WGET) -P $(DL_DIR) $(GDBM_SITE)/$(GDBM_SOURCE)

gdbm-source: $(DL_DIR)/$(GDBM_SOURCE) $(GDBM_PATCH)

$(GDBM_DIR)/.source: $(DL_DIR)/$(GDBM_SOURCE)
	$(GDBM_UNZIP) $(DL_DIR)/$(GDBM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(GDBM_PATCH) | patch -d $(BUILD_DIR)/$(GDBM) -p1
	mv $(BUILD_DIR)/$(GDBM) $(GDBM_DIR)
	touch $(GDBM_DIR)/.source

$(GDBM_DIR)/.configured: $(GDBM_DIR)/.source
	(cd $(GDBM_DIR); \
        export CC=$(TARGET_CC) ;\
		./configure \
		--host=arm-linux \
		--prefix=$(STAGING_DIR) \
	);
	touch $(GDBM_DIR)/.configured

$(STAGING_DIR)/lib/libgdbm.so.$(GDBM_LIBVERSION): $(GDBM_DIR)/.configured
	$(MAKE) CFLAGS="$(GDBM_CFLAGS)" CC=$(TARGET_CC) -C $(GDBM_DIR) install

gdbm-headers: $(STAGING_DIR)/lib/libgdbm.a

gdbm: $(STAGING_DIR)/lib/libgdbm.so.$(GDBM_LIBVERSION)

$(GDBM_IPK): $(STAGING_DIR)/lib/libgdbm.so.$(GDBM_LIBVERSION)
	mkdir -p $(GDBM_IPK_DIR)/CONTROL
	cp $(SOURCE_DIR)/gdbm.control $(GDBM_IPK_DIR)/CONTROL/control
	mkdir -p $(GDBM_IPK_DIR)/opt/include
	cp -dpf $(STAGING_DIR)/include/gdbm.h $(GDBM_IPK_DIR)/opt/include
	mkdir -p $(GDBM_IPK_DIR)/opt/lib
	cp -dpf $(STAGING_DIR)/lib/libgdbm.so* $(GDBM_IPK_DIR)/opt/lib
	-$(STRIP) --strip-unneeded $(GDBM_IPK_DIR)/opt/lib/libgdbm.so*
	touch -c $(GDBM_IPK_DIR)/opt/lib/libgdbm.so.$(GDBM_LIBVERSION)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GDBM_IPK_DIR)

gdbm-ipk: $(GDBM_IPK)

gdbm-source: $(DL_DIR)/$(GDBM_SOURCE)

gdbm-clean:
	-$(MAKE) -C $(GDBM_DIR) uninstall
	-$(MAKE) -C $(GDBM_DIR) clean

gdbm-dirclean: gdbm-clean
	rm -rf $(GDBM_DIR) $(GDBM_IPK_DIR) $(GDBM_IPK)


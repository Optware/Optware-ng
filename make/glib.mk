###########################################################
#
# glib
#
###########################################################

GLIB_DIR=$(BUILD_DIR)/glib

GLIB_VERSION=2.2.0
GLIB=glib-$(GLIB_VERSION)
GLIB_SITE=ftp://ftp.gtk.org/pub/gtk/v2.2/
GLIB_SOURCE=$(GLIB).tar.gz
GLIB_UNZIP=zcat

GLIB_IPK=$(BUILD_DIR)/glib_$(GLIB_VERSION)-1_armeb.ipk
GLIB_IPK_DIR=$(BUILD_DIR)/glib-$(GLIB_VERSION)-ipk

$(DL_DIR)/$(GLIB_SOURCE):
	$(WGET) -P $(DL_DIR) $(GLIB_SITE)/$(GLIB_SOURCE)

glib-source: $(DL_DIR)/$(GLIB_SOURCE)

$(GLIB_DIR)/.source: $(DL_DIR)/$(GLIB_SOURCE)
	$(GLIB_UNZIP) $(DL_DIR)/$(GLIB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/glib-$(GLIB_VERSION) $(GLIB_DIR)
	touch $(GLIB_DIR)/.source

$(GLIB_DIR)/.configured: $(GLIB_DIR)/.source
	cp $(SOURCE_DIR)/glib/glib.cache $(GLIB_DIR)/arm.cache
	(cd $(GLIB_DIR); \
		./configure \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--cache-file=arm.cache \
		--disable-rebuilds \
		--prefix=/opt \
	);
	touch $(GLIB_DIR)/.configured

$(GLIB_DIR)/glib/libglib-2.0.la: $(GLIB_DIR)/.configured
	$(MAKE) -C $(GLIB_DIR) CC=$(TARGET_CC) CCLD=$(TARGET_CC) \
	RANLIB=$(TARGET_RANLIB) AR=$(TARGET_AR) LD=$(TARGET_LD) 


glib-headers: glib-ipk

glib: glib-ipk

$(GLIB_IPK): $(GLIB_DIR)/glib/libglib-2.0.la
	mkdir -p $(GLIB_IPK_DIR)/CONTROL
	cp $(SOURCE_DIR)/glib/control $(GLIB_IPK_DIR)/CONTROL/control
	mkdir -p $(GLIB_IPK_DIR)/opt/lib
	cp $(GLIB_DIR)/gmodule/.libs/* $(GLIB_IPK_DIR)/opt/lib
	cp $(GLIB_DIR)/gthread/.libs/* $(GLIB_IPK_DIR)/opt/lib
	cp $(GLIB_DIR)/glib/.libs/* $(GLIB_IPK_DIR)/opt/lib
	rm -rf $(STAGING_DIR)/CONTROL
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GLIB_IPK_DIR)

glib-stage:  $(GLIB_IPK)
	cp $(GLIB_DIR)/gmodule/.libs/* $(STAGING_LIB_DIR)
	cp $(GLIB_DIR)/gthread/.libs/* $(STAGING_LIB_DIR)
	cp $(GLIB_DIR)/glib/.libs/* $(STAGING_LIB_DIR)

	cd $(STAGING_LIB_DIR)
	rm -f $(STAGING_LIB_DIR)/libglib-2.0.a
	ln -s $(STAGING_LIB_DIR)/libglib-2.0.so $(STAGING_LIB_DIR)/libglib-2.0.a
	rm -f $(STAGING_LIB_DIR)/libgthread-2.0.a
	ln -s $(STAGING_LIB_DIR)/libgthread-2.0.so $(STAGING_LIB_DIR)/libgthread-2.0.a
	ls -l $(STAGING_LIB_DIR)/libgthread-2.0*
	rm -f $(STAGING_LIB_DIR)/libgmodule-2.0.a
	ln -s $(STAGING_LIB_DIR)/libgmodule-2.0.so $(STAGING_LIB_DIR)/libgmodule-2.0.a

	mkdir -p $(STAGING_INCLUDE_DIR)/gmodule-2.0
	cp $(GLIB_DIR)/gmodule/*.h $(STAGING_INCLUDE_DIR)/gmodule-2.0

	mkdir -p $(STAGING_INCLUDE_DIR)/glib-2.0
	cp $(GLIB_DIR)/glib/*.h $(STAGING_INCLUDE_DIR)/glib-2.0



glib-ipk: $(GLIB_IPK)

glib-source: $(DL_DIR)/$(GLIB_SOURCE)

glib-clean:
	-$(MAKE) -C $(GLIB_DIR) uninstall
	-$(MAKE) -C $(GLIB_DIR) clean

glib-distclean:
	-rm $(GLIB_DIR)/.configured
	-$(MAKE) -C $(GLIB_DIR) distclean

glib-dirclean:
	rm -rf $(GLIB_DIR) $(GLIB_IPK_DIR) $(GLIB_IPK)

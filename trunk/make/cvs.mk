###########################################################
#
# cvs
#
###########################################################

CVS_DIR=$(BUILD_DIR)/cvs

CVS_VERSION=1.12.9
CVS=cvs-$(CVS_VERSION)
CVS_SITE=https://ccvs.cvshome.org/files/documents/19/201
CVS_SOURCE=$(CVS).tar.gz
CVS_UNZIP=zcat

CVS_IPK=$(BUILD_DIR)/cvs_$(CVS_VERSION)-1_armeb.ipk
CVS_IPK_DIR=$(BUILD_DIR)/cvs-$(CVS_VERSION)-ipk

$(DL_DIR)/$(CVS_SOURCE):
	$(WGET) -P $(DL_DIR) $(CVS_SITE)/$(CVS_SOURCE)

cvs-source: $(DL_DIR)/$(CVS_SOURCE)

$(CVS_DIR)/.source: $(DL_DIR)/$(CVS_SOURCE)
	$(CVS_UNZIP) $(DL_DIR)/$(CVS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/cvs-$(CVS_VERSION) $(CVS_DIR)
	touch $(CVS_DIR)/.source

$(CVS_DIR)/.configured: $(CVS_DIR)/.source
	(cd $(CVS_DIR); \
		./configure \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--without-gssapi \
		--prefix=/opt \
		cvs_cv_func_printf=yes \
		cvs_cv_func_printf_ptr=yes \
	);
	touch $(CVS_DIR)/.configured

$(CVS_DIR)/src/cvs: $(CVS_DIR)/.configured
	$(MAKE) -C $(CVS_DIR)

cvs: $(CVS_DIR)/src/cvs

$(CVS_IPK): $(CVS_DIR)/src/cvs
	mkdir -p $(CVS_IPK_DIR)/CONTROL
	mkdir -p $(CVS_IPK_DIR)/opt
	mkdir -p $(CVS_IPK_DIR)/opt/bin
	$(STRIP) $(CVS_DIR)/src/cvs -o $(CVS_IPK_DIR)/opt/bin/cvs
	cp $(SOURCE_DIR)/cvs.control $(CVS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CVS_IPK_DIR)

cvs-ipk: $(CVS_IPK)

cvs-source: $(DL_DIR)/$(CVS_SOURCE)

cvs-clean:
	-$(MAKE) -C $(CVS_DIR) uninstall
	-$(MAKE) -C $(CVS_DIR) clean

cvs-distclean:
	-rm $(CVS_DIR)/.configured
	-$(MAKE) -C $(CVS_DIR) distclean

cvs-dirclean:
	rm -rf $(CVS_DIR) $(CVS_IPK_DIR) $(CVS_IPK)

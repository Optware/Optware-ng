###########################################################
#
# cvs
#
###########################################################

CVS_BUILD_DIR=$(BUILD_DIR)/cvs

CVS_VERSION=1.12.9
CVS_DIR=cvs-$(CVS_VERSION)
CVS_SITE=https://ccvs.cvshome.org/files/documents/19/201
CVS_SOURCE=$(CVS_DIR).tar.gz
CVS_UNZIP=zcat

CVS_IPK_VERSION=1

CVS_IPK=$(BUILD_DIR)/cvs_$(CVS_VERSION)-$(CVS_IPK_VERSION)_$(TARGET_ARCH).ipk
CVS_IPK_DIR=$(BUILD_DIR)/cvs-$(CVS_VERSION)-ipk

$(DL_DIR)/$(CVS_SOURCE):
	$(WGET) -P $(DL_DIR) $(CVS_SITE)/$(CVS_SOURCE)

cvs-source: $(DL_DIR)/$(CVS_SOURCE)

$(CVS_BUILD_DIR)/.source: $(DL_DIR)/$(CVS_SOURCE)
	$(CVS_UNZIP) $(DL_DIR)/$(CVS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/cvs-$(CVS_VERSION) $(CVS_BUILD_DIR)
	touch $(CVS_BUILD_DIR)/.source

$(CVS_BUILD_DIR)/.configured: $(CVS_BUILD_DIR)/.source
	(cd $(CVS_BUILD_DIR); \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		./configure \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--without-gssapi \
		--prefix=/opt \
		cvs_cv_func_printf=yes \
		cvs_cv_func_printf_ptr=yes \
	);
	touch $(CVS_BUILD_DIR)/.configured

$(CVS_BUILD_DIR)/src/cvs: $(CVS_BUILD_DIR)/.configured
	$(MAKE) -C $(CVS_BUILD_DIR) \
	CC=$(TARGET_CC) AR=$(TARGET_AR) RANLIB=$(TARGET_RANLIB)

cvs: $(CVS_BUILD_DIR)/src/cvs

$(CVS_IPK): $(CVS_BUILD_DIR)/src/cvs
	mkdir -p $(CVS_IPK_DIR)/CONTROL
	mkdir -p $(CVS_IPK_DIR)/opt
	mkdir -p $(CVS_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(CVS_BUILD_DIR)/src/cvs -o $(CVS_IPK_DIR)/opt/bin/cvs
	sed -e "s/@ARCH@/$(TARGET_ARCH)/" -e "s/@VERSION@/$(CVS_VERSION)/" \
		-e "s/@RELEASE@/$(CVS_IPK_VERSION)/" cvs.control > $(CVS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CVS_IPK_DIR)

cvs-ipk: $(CVS_IPK)

cvs-clean:
	-$(MAKE) -C $(CVS_BUILD_DIR) uninstall
	-$(MAKE) -C $(CVS_BUILD_DIR) clean

cvs-distclean:
	-rm $(CVS_BUILD_DIR)/.configured
	-$(MAKE) -C $(CVS_BUILD_DIR) distclean

cvs-dirclean:
	rm -rf $(CVS_BUILD_DIR) $(CVS_IPK_DIR) $(CVS_IPK)

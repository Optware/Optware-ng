###########################################################
#
# gdbm
#
###########################################################

GDBM_SITE=ftp://ftp.gnu.org/gnu/gdbm
GDBM_VERSION=1.8.3
GDBM_LIB_VERSION=3.0.0
GDBM_SOURCE=gdbm-$(GDBM_VERSION).tar.gz
GDBM_DIR=gdbm-$(GDBM_VERSION)
GDBM_UNZIP=zcat

GDBM_IPK_VERSION=1

GDBM_PATCHES=$(GDBM_SOURCE_DIR)/Makefile.patch

GDBM_BUILD_DIR=$(BUILD_DIR)/gdbm
GDBM_SOURCE_DIR=$(SOURCE_DIR)/gdbm
GDBM_IPK=$(BUILD_DIR)/gdbm_$(GDBM_VERSION)-$(GDBM_IPK_VERSION)_armeb.ipk
GDBM_IPK_DIR=$(BUILD_DIR)/gdbm-$(GDBM_VERSION)-ipk

$(DL_DIR)/$(GDBM_SOURCE):
	$(WGET) -P $(DL_DIR) $(GDBM_SITE)/$(GDBM_SOURCE)

gdbm-source: $(DL_DIR)/$(GDBM_SOURCE) $(GDBM_PATCHES)

$(GDBM_BUILD_DIR)/.configured: $(DL_DIR)/$(GDBM_SOURCE)
	rm -rf $(BUILD_DIR)/$(GDBM_DIR) $(GDBM_BUILD_DIR)
	$(GDBM_UNZIP) $(DL_DIR)/$(GDBM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(GDBM_PATCHES) | patch -d $(BUILD_DIR)/$(GDBM_DIR) -p1
	mv $(BUILD_DIR)/$(GDBM_DIR) $(GDBM_BUILD_DIR)
	(cd $(GDBM_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	);
	touch $(GDBM_BUILD_DIR)/.configured

gdbm-unpack: $(GDBM_BUILD_DIR)/.configured

$(GDBM_BUILD_DIR)/.libs/libgdbm.a: $(GDBM_BUILD_DIR)/.configured
	$(MAKE) -C $(GDBM_BUILD_DIR)

gdbm: $(GDBM_BUILD_DIR)/.libs/libgdbm.a

$(STAGING_DIR)/opt/lib/libgdbm.a: $(GDBM_BUILD_DIR)/.libs/libgdbm.a
	$(MAKE) -C $(GDBM_BUILD_DIR) INSTALL_ROOT=$(STAGING_DIR) install install-compat
	rm -rf $(STAGING_DIR)/opt/{man,info}

gdbm-stage: $(STAGING_DIR)/opt/lib/libgdbm.a

$(GDBM_IPK): $(GDBM_BUILD_DIR)/.libs/libgdbm.a
	rm -rf $(GDBM_IPK_DIR) $(GDBM_IPK)
	$(MAKE) -C $(GDBM_BUILD_DIR) INSTALL_ROOT=$(GDBM_IPK_DIR) install install-compat
	$(STRIP) --strip-unneeded $(GDBM_IPK_DIR)/opt/lib/*.so.*
	rm -rf $(GDBM_IPK_DIR)/opt/{man,info}
	rm -f $(GDBM_IPK_DIR)/opt/lib/*.{la,a}
	install -d $(GDBM_IPK_DIR)/CONTROL
	install -m 644 $(GDBM_SOURCE_DIR)/control $(GDBM_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GDBM_IPK_DIR)

gdbm-ipk: $(GDBM_IPK)

gdbm-clean:
	-$(MAKE) -C $(GDBM_BUILD_DIR) clean

gdbm-dirclean: gdbm-clean
	rm -rf $(BUILD_DIR)/$(GDBM_DIR) $(GDBM_BUILD_DIR) $(GDBM_IPK_DIR) $(GDBM_IPK)


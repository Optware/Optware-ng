#
# Openssl build for Linksys nslu2
#

OPENSSL_DIR:=$(BUILD_DIR)/openssl
OPENSSL_VERSION:=0.9.7d
OPENSSL_LIB_VERSION:=0.9.7
OPENSSL:=openssl-$(OPENSSL_VERSION)
OPENSSL_SITE:=http://www.openssl.org/source
OPENSSL_SOURCE:=$(OPENSSL).tar.gz
OPENSSL_UNZIP:=gunzip -c

OPENSSL_IPK=$(BUILD_DIR)/openssl_$(OPENSSL_VERSION)_armeb.ipk
OPENSSL_IPK_DIR:=$(BUILD_DIR)/openssl-$(OPENSSL_VERSION)-ipk

OPENSSL_PATCH:=$(SOURCE_DIR)/$(OPENSSL).patch

$(DL_DIR)/$(OPENSSL_SOURCE):
	cd $(DL_DIR) && $(WGET) $(OPENSSL_SITE)/$(OPENSSL_SOURCE)

openssl-patch: $(OPENSSL_PATCH)
	@echo "$(OPENSSL_PATCH) is present."

$(OPENSSL_DIR)/.configured: $(DL_DIR)/$(OPENSSL_SOURCE) openssl-patch
	@rm -rf $(OPENSSL_DIR)
	$(OPENSSL_UNZIP) $(DL_DIR)/$(OPENSSL_SOURCE) | tar xf - -C $(BUILD_DIR)
	mv $(BUILD_DIR)/$(OPENSSL) $(OPENSSL_DIR)
	cd $(OPENSSL_DIR) && \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		./Configure \
			shared \
			--openssldir=$(STAGING_DIR) \
			--prefix=/opt/lib \
			linux-elf-arm
	patch -d $(OPENSSL_DIR) -p1 < $(OPENSSL_PATCH)
	touch $(OPENSSL_DIR)/.configured

$(OPENSSL_DIR)/libssl.so.$(OPENSSL_LIB_VERSION): directories $(OPENSSL_DIR)/.configured
	$(MAKE) -C $(OPENSSL_DIR)

openssl: $(OPENSSL_DIR)/libssl.so.$(OPENSSL_LIB_VERSION)

$(OPENSSL_IPK): $(OPENSSL_DIR)/libssl.so.$(OPENSSL_LIB_VERSION)
	mkdir -p $(OPENSSL_IPK_DIR)/CONTROL
	cp $(SOURCE_DIR)/openssl.control $(OPENSSL_IPK_DIR)/CONTROL/control
	mkdir -p $(OPENSSL_IPK_DIR)/opt/include
	mkdir -p $(STAGING_DIR)/include
	cp -Rpf $(OPENSSL_DIR)/include/openssl $(OPENSSL_IPK_DIR)/include
	cp -Rpf $(OPENSSL_DIR)/include/openssl $(STAGING_DIR)/include
	mkdir -p $(OPENSSL_IPK_DIR)/opt/lib
	cp -pf $(OPENSSL_DIR)/lib{crypto,ssl}.* $(OPENSSL_IPK_DIR)/opt/lib
	cp -pf $(OPENSSL_DIR)/lib{crypto,ssl}.* $(STAGING_DIR)/lib
	$(STRIP) --strip-unneeded {$(OPENSSL_IPK_DIR),$(STAGING_DIR)}/opt/lib/lib{ssl,crypto}.so*
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OPENSSL_IPK_DIR)

openssl-ipk: $(OPENSSL_IPK)

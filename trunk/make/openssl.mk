#
# Openssl build for Linksys nslu2
#

OPENSSL_SITE=http://www.openssl.org/source
OPENSSL_VERSION=0.9.7d
OPENSSL_LIB_VERSION:=0.9.7
OPENSSL_SOURCE:=openssl-$(OPENSSL_VERSION).tar.gz
OPENSSL_DIR:=openssl-$(OPENSSL_VERSION)
OPENSSL_UNZIP:=zcat

OPENSSL_IPK_VERSION=1

OPENSSL_BUILD_DIR:=$(BUILD_DIR)/openssl
OPENSSL_SOURCE_DIR:=$(SOURCE_DIR)/openssl
OPENSSL_IPK_DIR:=$(BUILD_DIR)/openssl-$(OPENSSL_VERSION)-ipk
OPENSSL_IPK=$(BUILD_DIR)/openssl_$(OPENSSL_VERSION)-$(OPENSSL_IPK_VERSION)_armeb.ipk

OPENSSL_PATCHES=$(OPENSSL_SOURCE_DIR)/Configure.patch

$(DL_DIR)/$(OPENSSL_SOURCE):
	cd $(DL_DIR) && $(WGET) $(OPENSSL_SITE)/$(OPENSSL_SOURCE)

openssl-source: $(DL_DIR)/$(OPENSSL_SOURCE) $(OPENSSL_PATCHES)

$(OPENSSL_BUILD_DIR)/.configured: $(DL_DIR)/$(OPENSSL_SOURCE) $(OPENSSL_PATCHES)
	rm -rf $(BUILD_DIR)/$(OPENSSL_DIR) $(OPENSSL_BUILD_DIR)
	$(OPENSSL_UNZIP) $(DL_DIR)/$(OPENSSL_SOURCE) | tar -C $(BUILD_DIR) -xvf - 
	cat $(OPENSSL_PATCHES) | patch -d $(BUILD_DIR)/$(OPENSSL_DIR) -p1
	mv $(BUILD_DIR)/$(OPENSSL_DIR) $(OPENSSL_BUILD_DIR)
	(cd $(OPENSSL_BUILD_DIR) && \
		$(TARGET_CONFIGURE_OPTS) \
		./Configure \
			shared zlib-dynamic \
			$(STAGING_CPPFLAGS) \
			--openssldir=/opt/share/openssl \
			--prefix=/opt \
			linux-elf-armeb \
	)
	touch $(OPENSSL_BUILD_DIR)/.configured

openssl-unpack: $(OPENSSL_BUILD_DIR)/.configured

$(OPENSSL_BUILD_DIR)/libssl.so.$(OPENSSL_LIB_VERSION): $(OPENSSL_BUILD_DIR)/.configured
	$(MAKE) -C $(OPENSSL_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		AR="${TARGET_AR} r" \
		MANDIR=/opt/man \
		EX_LIBS=-ldl \
		DIRS="crypto ssl apps"

openssl: $(OPENSSL_BUILD_DIR)/libssl.so.$(OPENSSL_LIB_VERSION)

$(STAGING_DIR)/lib/libssl.so.$(OPENSSL_LIB_VERSION): $(OPENSSL_BUILD_DIR)/libssl.so.$(OPENSSL_LIB_VERSION)
	rm -rf $(STAGING_DIR)/include/openssl
	install -d $(STAGING_DIR)/include/openssl
	install -m 644 $(OPENSSL_BUILD_DIR)/include/openssl/*.h $(STAGING_DIR)/include/openssl
	install -d $(STAGING_DIR)/lib
	install -m 644 $(OPENSSL_BUILD_DIR)/lib{crypto,ssl}.* $(STAGING_DIR)/lib

openssl-stage: $(STAGING_DIR)/lib/libssl.so.$(OPENSSL_LIB_VERSION)

$(OPENSSL_IPK): $(OPENSSL_BUILD_DIR)/libssl.so.$(OPENSSL_LIB_VERSION)
	install -d $(OPENSSL_IPK_DIR)/opt/bin
	install -m 755 $(OPENSSL_BUILD_DIR)/apps/openssl $(OPENSSL_IPK_DIR)/opt/bin/openssl
	$(STRIP) --strip-unneeded $(OPENSSL_IPK_DIR)/opt/bin/opensll
	install -d $(OPENSSL_IPK_DIR)/opt/share/openssl
	install -m 755 $(OPENSSL_BUILD_DIR)/apps/openssl.cnf $(OPENSSL_IPK_DIR)/opt/share/openssl/openssl.cnf
	install -d $(OPENSSL_IPK_DIR)/opt/include/openssl
	install -m 644 $(OPENSSL_BUILD_DIR)/include/openssl/*.h $(OPENSSL_IPK_DIR)/opt/include/openssl
	install -d $(OPENSSL_IPK_DIR)/opt/lib
	install -m 644 $(OPENSSL_BUILD_DIR)/lib{crypto,ssl}.* $(OPENSSL_IPK_DIR)/opt/lib
	$(STRIP) --strip-unneeded $(OPENSSL_IPK_DIR)/opt/lib/lib{ssl,crypto}.so*
	install -d $(OPENSSL_IPK_DIR)/CONTROL
	install -m 644 $(OPENSSL_SOURCE_DIR)/control $(OPENSSL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OPENSSL_IPK_DIR)

openssl-ipk: $(OPENSSL_IPK)

openssl-clean:
	-$(MAKE) -C $(OPENSSL_BUILD_DIR) clean

openssl-dirclean: openssl-clean
	rm -rf $(BUILD_DIR)/$(OPENSSL_DIR) $(OPENSSL_BUILD_DIR) $(OPENSSL_IPK_DIR) $(OPENSSL_IPK)

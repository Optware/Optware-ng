#
# Openssl build for Linksys nslu2
#

OPENSSL_SITE=http://www.openssl.org/source
OPENSSL_VERSION=0.9.7d
OPENSSL_LIB_VERSION=0.9.7
OPENSSL_SOURCE=openssl-$(OPENSSL_VERSION).tar.gz
OPENSSL_DIR=openssl-$(OPENSSL_VERSION)
OPENSSL_UNZIP=zcat
OPENSSH_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
OPENSSH_DESCRIPTION=The OpenSSH distribution.
OPENSSH_SECTION=net
OPENSSH_PRIORITY=optional
OPENSSH_DEPENDS=openssl, zlib
OPENSSH_CONFLICTS=dropbear

OPENSSL_IPK_VERSION=3

OPENSSH_CONFFILES=/opt/etc/openssh/ssh_config /opt/etc/openssh/sshd_config /opt/etc/openssh/ssh_host_dsa_key /opt/etc/openssh/ssh_host_dsa_key.pub /opt/etc/openssh/ssh_host_key /opt/etc/openssh/ssh_host_key.pub /opt/etc/openssh/ssh_host_rsa_key /opt/etc/openssh/ssh_host_rsa_key.pub /opt/etc/openssh/moduli

OPENSSL_BUILD_DIR=$(BUILD_DIR)/openssl
OPENSSL_SOURCE_DIR=$(SOURCE_DIR)/openssl
OPENSSL_IPK_DIR=$(BUILD_DIR)/openssl-$(OPENSSL_VERSION)-ipk
OPENSSL_IPK=$(BUILD_DIR)/openssl_$(OPENSSL_VERSION)-$(OPENSSL_IPK_VERSION)_$(TARGET_ARCH).ipk

OPENSSL_PATCHES=$(OPENSSL_SOURCE_DIR)/Configure.patch

$(DL_DIR)/$(OPENSSL_SOURCE):
	cd $(DL_DIR) && $(WGET) $(OPENSSL_SITE)/$(OPENSSL_SOURCE)

openssl-source: $(DL_DIR)/$(OPENSSL_SOURCE) $(OPENSSL_PATCHES)

ifeq ($(TARGET_ARCH),mipsel)
OPENSSL_ARCH=linux-$(TARGET_ARCH)
else
OPENSSL_ARCH=linux-elf-$(TARGET_ARCH)
endif

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
			$(OPENSSL_ARCH) \
	)
	touch $(OPENSSL_BUILD_DIR)/.configured

openssl-unpack: $(OPENSSL_BUILD_DIR)/.configured

$(OPENSSL_BUILD_DIR)/libssl.so.$(OPENSSL_LIB_VERSION): $(OPENSSL_BUILD_DIR)/.configured
	$(MAKE) zlib-stage
	$(MAKE) -C $(OPENSSL_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		AR="${TARGET_AR} r" \
		MANDIR=/opt/man \
		EX_LIBS="$(STAGING_LDFLAGS) -ldl" \
		DIRS="crypto ssl apps"

openssl: $(OPENSSL_BUILD_DIR)/libssl.so.$(OPENSSL_LIB_VERSION)

$(STAGING_DIR)/opt/lib/libssl.so.$(OPENSSL_LIB_VERSION): $(OPENSSL_BUILD_DIR)/libssl.so.$(OPENSSL_LIB_VERSION)
	rm -rf $(STAGING_DIR)/opt/include/openssl
	install -d $(STAGING_DIR)/opt/include/openssl
	install -m 644 $(OPENSSL_BUILD_DIR)/include/openssl/*.h $(STAGING_DIR)/opt/include/openssl
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(OPENSSL_BUILD_DIR)/libcrypto.a $(STAGING_DIR)/opt/lib
	install -m 644 $(OPENSSL_BUILD_DIR)/libssl.a $(STAGING_DIR)/opt/lib
	install -m 644 $(OPENSSL_BUILD_DIR)/libcrypto.so.$(OPENSSL_LIB_VERSION) $(STAGING_DIR)/opt/lib
	install -m 644 $(OPENSSL_BUILD_DIR)/libssl.so.$(OPENSSL_LIB_VERSION) $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libcrypto.so.$(OPENSSL_LIB_VERSION) libcrypto.so.0
	cd $(STAGING_DIR)/opt/lib && ln -fs libcrypto.so.$(OPENSSL_LIB_VERSION) libcrypto.so
	cd $(STAGING_DIR)/opt/lib && ln -fs libssl.so.$(OPENSSL_LIB_VERSION) libssl.so.0
	cd $(STAGING_DIR)/opt/lib && ln -fs libssl.so.$(OPENSSL_LIB_VERSION) libssl.so

openssl-stage: $(STAGING_DIR)/opt/lib/libssl.so.$(OPENSSL_LIB_VERSION)

$(OPENSSH_IPK_DIR)/CONTROL/control:
	@install -d $(OPENSSH_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: openssh" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OPENSSH_PRIORITY)" >>$@
	@echo "Section: $(OPENSSH_SECTION)" >>$@
	@echo "Version: $(OPENSSH_VERSION)-$(OPENSSH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OPENSSH_MAINTAINER)" >>$@
	@echo "Source: $(OPENSSH_SITE)/$(OPENSSH_SOURCE)" >>$@
	@echo "Description: $(OPENSSH_DESCRIPTION)" >>$@
	@echo "Depends: $(OPENSSH_DEPENDS)" >>$@
	@echo "Conflicts: $(OPENSSH_CONFLICTS)" >>$@

$(OPENSSL_IPK): $(OPENSSL_BUILD_DIR)/libssl.so.$(OPENSSL_LIB_VERSION)
	rm -rf $(OPENSSL_IPK_DIR) $(BUILD_DIR)/openssl_*_$(TARGET_ARCH).ipk
	install -d $(OPENSSL_IPK_DIR)/opt/bin
	install -m 755 $(OPENSSL_BUILD_DIR)/apps/openssl $(OPENSSL_IPK_DIR)/opt/bin/openssl
	$(STRIP_COMMAND) $(OPENSSL_IPK_DIR)/opt/bin/openssl
	install -d $(OPENSSL_IPK_DIR)/opt/share/openssl
	install -m 755 $(OPENSSL_BUILD_DIR)/apps/openssl.cnf $(OPENSSL_IPK_DIR)/opt/share/openssl/openssl.cnf
	install -d $(OPENSSL_IPK_DIR)/opt/include/openssl
	install -m 644 $(OPENSSL_BUILD_DIR)/include/openssl/*.h $(OPENSSL_IPK_DIR)/opt/include/openssl
	install -d $(OPENSSL_IPK_DIR)/opt/lib
	install -m 644 $(OPENSSL_BUILD_DIR)/libcrypto.so.$(OPENSSL_LIB_VERSION) $(OPENSSL_IPK_DIR)/opt/lib
	install -m 644 $(OPENSSL_BUILD_DIR)/libssl.so.$(OPENSSL_LIB_VERSION) $(OPENSSL_IPK_DIR)/opt/lib
	$(STRIP_COMMAND) $(OPENSSL_IPK_DIR)/opt/lib/libcrypto.so*
	$(STRIP_COMMAND) $(OPENSSL_IPK_DIR)/opt/lib/libssl.so*
	cd $(OPENSSL_IPK_DIR)/opt/lib && ln -fs libcrypto.so.$(OPENSSL_LIB_VERSION) libcrypto.so.0
	cd $(OPENSSL_IPK_DIR)/opt/lib && ln -fs libcrypto.so.$(OPENSSL_LIB_VERSION) libcrypto.so
	cd $(OPENSSL_IPK_DIR)/opt/lib && ln -fs libssl.so.$(OPENSSL_LIB_VERSION) libssl.so.0
	cd $(OPENSSL_IPK_DIR)/opt/lib && ln -fs libssl.so.$(OPENSSL_LIB_VERSION) libssl.so
	$(MAKE) $(OPENSSH_IPK_DIR)/CONTROL/control
	echo $(OPENSSH_CONFFILES) | sed -e 's/ /\n/g' > $(OPENSSH_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OPENSSL_IPK_DIR)

openssl-ipk: $(OPENSSL_IPK)

openssl-clean:
	-$(MAKE) -C $(OPENSSL_BUILD_DIR) clean

openssl-dirclean:
	rm -rf $(BUILD_DIR)/$(OPENSSL_DIR) $(OPENSSL_BUILD_DIR) $(OPENSSL_IPK_DIR) $(OPENSSL_IPK)

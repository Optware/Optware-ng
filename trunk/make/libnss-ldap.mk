###########################################################
#
# libnss-ldap
#
###########################################################

LIBNSS-LDAP_SITE=http://www.padl.com/download
LIBNSS-LDAP_VERSION=239
LIBNSS-LDAP_SOURCE=nss_ldap.tgz
LIBNSS-LDAP_DIR=nss_ldap-$(LIBNSS-LDAP_VERSION)
LIBNSS-LDAP_UNZIP=zcat
LIBNSS-LDAP_MAINTAINER=Claus Rosenberger <nslu2@rocnet.de>
LIBNSS-LDAP_DESCRIPTION=The nss_ldap module provides the means for Solaris and Linux workstations to this information (such as users, hosts, and groups) from LDAP directories.
LIBNSS-LDAP_SECTION=base
LIBNSS-LDAP_PRIORITY=optional
LIBNSS-LDAP_DEPENDS=openldap-libs,ldconfig
LIBNSS-LDAP_SUGGESTS=
LIBNSS-LDAP_CONFLICTS=

#
# LIBNSS-LDAP_IPK_VERSION should be incremented when the ipk changes.
#
LIBNSS-LDAP_IPK_VERSION=2

#
# LIBNSS-LDAP_CONFFILES should be a list of user-editable files
LIBNSS-LDAP_CONFFILES=/opt/etc/libnss-ldap.conf /opt/etc/ldap.secret

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBNSS-LDAP_CPPFLAGS=
LIBNSS-LDAP_LDFLAGS=

LIBNSS-LDAP_BUILD_DIR=$(BUILD_DIR)/libnss-ldap
LIBNSS-LDAP_SOURCE_DIR=$(SOURCE_DIR)/libnss-ldap
LIBNSS-LDAP_IPK_DIR=$(BUILD_DIR)/libnss-ldap-$(LIBNSS-LDAP_VERSION)-ipk
LIBNSS-LDAP_IPK=$(BUILD_DIR)/libnss-ldap_$(LIBNSS-LDAP_VERSION)-$(LIBNSS-LDAP_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(LIBNSS-LDAP_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBNSS-LDAP_SITE)/$(LIBNSS-LDAP_SOURCE)

libnss-ldap-source: $(DL_DIR)/$(LIBNSS-LDAP_SOURCE)

$(LIBNSS-LDAP_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBNSS-LDAP_SOURCE)
	$(MAKE) openldap-stage
	rm -rf $(BUILD_DIR)/$(LIBNSS-LDAP_DIR) $(LIBNSS-LDAP_BUILD_DIR)
	$(LIBNSS-LDAP_UNZIP) $(DL_DIR)/$(LIBNSS-LDAP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(LIBNSS-LDAP_DIR) $(LIBNSS-LDAP_BUILD_DIR)
	sed -ie 's%/usr$$(libdir)%$(libdir)%g' $(LIBNSS-LDAP_BUILD_DIR)/Makefile.in
	sed -ie 's/-o $$(INST_UID)/ /g' $(LIBNSS-LDAP_BUILD_DIR)/Makefile.in
	sed -ie 's/-g $$(INST_GID)/ /g' $(LIBNSS-LDAP_BUILD_DIR)/Makefile.in
	(cd $(LIBNSS-LDAP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBNSS-LDAP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBNSS-LDAP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--sysconfdir=/opt/etc \
		--bindir=/opt/bin \
		--sbindir=/opt/sbin \
		--disable-nls \
		--with-ldap-conf-file=/opt/etc/libnss-ldap.conf \
		--with-ldap-secret-file=/opt/etc/ldap.secret \
	)
	touch $(LIBNSS-LDAP_BUILD_DIR)/.configured

libnss-ldap-unpack: $(LIBNSS-LDAP_BUILD_DIR)/.configured

$(LIBNSS-LDAP_BUILD_DIR)/.built: $(LIBNSS-LDAP_BUILD_DIR)/.configured
	rm -f $(LIBNSS-LDAP_BUILD_DIR)/.built
	$(MAKE) -C $(LIBNSS-LDAP_BUILD_DIR)
	touch $(LIBNSS-LDAP_BUILD_DIR)/ldap.secret
	touch $(LIBNSS-LDAP_BUILD_DIR)/.built

libnss-ldap: $(LIBNSS-LDAP_BUILD_DIR)/.built

$(LIBNSS-LDAP_BUILD_DIR)/.staged: $(LIBNSS-LDAP_BUILD_DIR)/.built
	rm -f $(LIBNSS-LDAP_BUILD_DIR)/.staged
	$(MAKE) -C $(LIBNSS-LDAP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(LIBNSS-LDAP_BUILD_DIR)/.staged

libnss-ldap-stage: $(LIBNSS-LDAP_BUILD_DIR)/.staged

$(LIBNSS-LDAP_IPK_DIR)/CONTROL/control:
	@install -d $(LIBNSS-LDAP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libnss-ldap" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBNSS-LDAP_PRIORITY)" >>$@
	@echo "Section: $(LIBNSS-LDAP_SECTION)" >>$@
	@echo "Version: $(LIBNSS-LDAP_VERSION)-$(LIBNSS-LDAP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBNSS-LDAP_MAINTAINER)" >>$@
	@echo "Source: $(LIBNSS-LDAP_SITE)/$(LIBNSS-LDAP_SOURCE)" >>$@
	@echo "Description: $(LIBNSS-LDAP_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBNSS-LDAP_DEPENDS)" >>$@
	@echo "Suggests: $(LIBNSS-LDAP_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBNSS-LDAP_CONFLICTS)" >>$@


$(LIBNSS-LDAP_IPK): $(LIBNSS-LDAP_BUILD_DIR)/.built
	rm -rf $(LIBNSS-LDAP_IPK_DIR) $(BUILD_DIR)/libnss-ldap_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBNSS-LDAP_BUILD_DIR) DESTDIR=$(LIBNSS-LDAP_IPK_DIR) install
	install -d $(LIBNSS-LDAP_IPK_DIR)/opt/etc/
	install -m 600 $(LIBNSS-LDAP_BUILD_DIR)/ldap.secret $(LIBNSS-LDAP_IPK_DIR)/opt/etc/ldap.secret
	$(MAKE) $(LIBNSS-LDAP_IPK_DIR)/CONTROL/control
	echo $(LIBNSS-LDAP_CONFFILES) | sed -e 's/ /\n/g' > $(LIBNSS-LDAP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBNSS-LDAP_IPK_DIR)

libnss-ldap-ipk: $(LIBNSS-LDAP_IPK)

libnss-ldap-clean:
	-$(MAKE) -C $(LIBNSS-LDAP_BUILD_DIR) clean

libnss-ldap-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBNSS-LDAP_DIR) $(LIBNSS-LDAP_BUILD_DIR) $(LIBNSS-LDAP_IPK_DIR) $(LIBNSS-LDAP_IPK)


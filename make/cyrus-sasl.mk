###########################################################
#
# cyrus-sasl
#
###########################################################

CYRUS-SASL_SITE=ftp://ftp.andrew.cmu.edu/pub/cyrus-mail
CYRUS-SASL_VERSION=2.1.20
CYRUS-SASL_SOURCE=cyrus-sasl-$(CYRUS-SASL_VERSION).tar.gz
CYRUS-SASL_DIR=cyrus-sasl-$(CYRUS-SASL_VERSION)
CYRUS-SASL_UNZIP=zcat
CYRUS-SASL_MAINTAINER=Matthias Appel <private_tweety@gmx.net>
CYRUS-SASL_DESCRIPTION=Provides client or server side authentication (see RFC 2222).
CYRUS-SASL_SECTION=util
CYRUS-SASL_PRIORITY=optional
CYRUS-SASL_DEPENDS=
CYRUS-SASL_CONFLICTS=

CYRUS-SASL_IPK_VERSION=7

CYRUS-SASL_CONFFILES=/opt/etc/init.d/S52saslauthd

CYRUS-SASL_PATCHES=$(CYRUS-SASL_SOURCE_DIR)/Makefile.in.patch

CYRUS-SASL_BUILD_DIR=$(BUILD_DIR)/cyrus-sasl
CYRUS-SASL_SOURCE_DIR=$(SOURCE_DIR)/cyrus-sasl
CYRUS-SASL_IPK_DIR=$(BUILD_DIR)/cyrus-sasl-$(CYRUS-SASL_VERSION)-ipk
CYRUS-SASL_IPK=$(BUILD_DIR)/cyrus-sasl_$(CYRUS-SASL_VERSION)-$(CYRUS-SASL_IPK_VERSION)_$(TARGET_ARCH).ipk

CYRUS-SASL-LIBS_IPK_DIR=$(BUILD_DIR)/cyrus-sasl-libs-$(CYRUS-SASL_VERSION)-ipk
CYRUS-SASL-LIBS_IPK=$(BUILD_DIR)/cyrus-sasl-libs_$(CYRUS-SASL_VERSION)-$(CYRUS-SASL_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(CYRUS-SASL_SOURCE):
	$(WGET) -P $(DL_DIR) $(CYRUS-SASL_SITE)/$(CYRUS-SASL_SOURCE)

cyrus-sasl-source: $(DL_DIR)/$(CYRUS-SASL_SOURCE) $(CYRUS-SASL_PATCHES)

$(CYRUS-SASL_BUILD_DIR)/.configured: $(DL_DIR)/$(CYRUS-SASL_SOURCE) $(CYRUS-SASL_PATCHES)
	$(MAKE) libdb-stage openssl-stage 
	rm -rf $(BUILD_DIR)/$(CYRUS-SASL_DIR) $(CYRUS-SASL_BUILD_DIR)
	$(CYRUS-SASL_UNZIP) $(DL_DIR)/$(CYRUS-SASL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(CYRUS-SASL_PATCHES) | patch -d $(BUILD_DIR)/$(CYRUS-SASL_DIR) -p1
	mv $(BUILD_DIR)/$(CYRUS-SASL_DIR) $(CYRUS-SASL_BUILD_DIR)
# We have to remove double blanks. Otherwise configure of saslauthd fails.
	(cd $(CYRUS-SASL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(strip $(STAGING_CPPFLAGS))" \
		CFLAGS="$(strip $(STAGING_CPPFLAGS))" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CYRUS-SASL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-plugindir=/opt/lib/sasl2 \
		--with-saslauthd=/opt/var/state/saslauthd \
		--with-dbpath=/opt/etc/sasl2 \
		--with-openssl="$(STAGING_PREFIX)" \
		--enable-anon \
		--enable-plain \
		--disable-login \
		--disable-gssapi \
		--disable-otp \
		--disable-krb4 \
		--disable-nls \
	)
	touch $(CYRUS-SASL_BUILD_DIR)/.configured

cyrus-sasl-unpack: $(CYRUS-SASL_BUILD_DIR)/.configured

$(CYRUS-SASL_BUILD_DIR)/.built: $(CYRUS-SASL_BUILD_DIR)/.configured
	rm -f $(CYRUS-SASL_BUILD_DIR)/.built
	$(MAKE) -C $(CYRUS-SASL_BUILD_DIR) HOSTCC=$(HOSTCC)
	touch $(CYRUS-SASL_BUILD_DIR)/.built

cyrus-sasl: $(CYRUS-SASL_BUILD_DIR)/.built

$(CYRUS-SASL_BUILD_DIR)/.staged: $(CYRUS-SASL_BUILD_DIR)/.built
	rm -f $(CYRUS-SASL_BUILD_DIR)/.staged
	$(MAKE) -C $(CYRUS-SASL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(CYRUS-SASL_BUILD_DIR)/.staged

cyrus-sasl-stage: $(CYRUS-SASL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cyrus-sasl
#
$(CYRUS-SASL_IPK_DIR)/CONTROL/control:
	@install -d $(CYRUS-SASL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: cyrus-sasl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CYRUS-SASL_PRIORITY)" >>$@
	@echo "Section: $(CYRUS-SASL_SECTION)" >>$@
	@echo "Version: $(CYRUS-SASL_VERSION)-$(CYRUS-SASL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CYRUS-SASL_MAINTAINER)" >>$@
	@echo "Source: $(CYRUS-SASL_SITE)/$(CYRUS-SASL_SOURCE)" >>$@
	@echo "Description: $(CYRUS-SASL_DESCRIPTION)" >>$@
	@echo "Depends: cyrus-sasl-libs" >>$@
	@echo "Conflicts: $(CYRUS-SASL_CONFLICTS)" >>$@

$(CYRUS-SASL-LIBS_IPK_DIR)/CONTROL/control:
	@install -d $(CYRUS-SASL-LIBS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: cyrus-sasl-libs" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CYRUS-SASL_PRIORITY)" >>$@
	@echo "Section: $(CYRUS-SASL_SECTION)" >>$@
	@echo "Version: $(CYRUS-SASL_VERSION)-$(CYRUS-SASL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CYRUS-SASL_MAINTAINER)" >>$@
	@echo "Source: $(CYRUS-SASL_SITE)/$(CYRUS-SASL_SOURCE)" >>$@
	@echo "Description: $(CYRUS-SASL_DESCRIPTION)" >>$@
	@echo "Depends: $(CYRUS-SASL_DEPENDS)" >>$@
	@echo "Conflicts: $(CYRUS-SASL_CONFLICTS)" >>$@

$(CYRUS-SASL_IPK): $(CYRUS-SASL_BUILD_DIR)/.built
	rm -rf $(CYRUS-SASL_IPK_DIR) $(BUILD_DIR)/cyrus-sasl_*_$(TARGET_ARCH).ipk
	rm -rf $(CYRUS-SASL-LIBS_IPK_DIR) $(BUILD_DIR)/cyrus-sasl-libs_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CYRUS-SASL_BUILD_DIR) DESTDIR=$(CYRUS-SASL_IPK_DIR) install-strip
	find $(CYRUS-SASL_IPK_DIR) -type d -exec chmod go+rx {} \;
	$(STRIP_COMMAND) $(CYRUS-SASL_IPK_DIR)/opt/sbin/*
	install -d $(CYRUS-SASL_IPK_DIR)/opt/var/state/saslauthd
	install -d $(CYRUS-SASL_IPK_DIR)/opt/etc/init.d
	install -m 755 $(CYRUS-SASL_SOURCE_DIR)/rc.saslauthd $(CYRUS-SASL_IPK_DIR)/opt/etc/init.d/S52saslauthd
	### build cyrus-sasl-libs
	$(MAKE) $(CYRUS-SASL-LIBS_IPK_DIR)/CONTROL/control
	install -d $(CYRUS-SASL-LIBS_IPK_DIR)/opt
	mv $(CYRUS-SASL_IPK_DIR)/opt/include $(CYRUS-SASL-LIBS_IPK_DIR)/opt
	mv $(CYRUS-SASL_IPK_DIR)/opt/lib $(CYRUS-SASL-LIBS_IPK_DIR)/opt
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CYRUS-SASL-LIBS_IPK_DIR)
	### build the main ipk
	$(MAKE) $(CYRUS-SASL_IPK_DIR)/CONTROL/control
	install -m 644 $(CYRUS-SASL_SOURCE_DIR)/postinst $(CYRUS-SASL_IPK_DIR)/CONTROL/postinst
	install -m 644 $(CYRUS-SASL_SOURCE_DIR)/prerm $(CYRUS-SASL_IPK_DIR)/CONTROL/prerm
	echo $(CYRUS-SASL_CONFFILES) | sed -e 's/ /\n/g' > $(CYRUS-SASL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CYRUS-SASL_IPK_DIR)

cyrus-sasl-ipk: $(CYRUS-SASL_IPK)

cyrus-sasl-clean:
	-$(MAKE) -C $(CYRUS-SASL_BUILD_DIR) clean

cyrus-sasl-dirclean:
	rm -rf $(BUILD_DIR)/$(CYRUS-SASL_DIR) $(CYRUS-SASL_BUILD_DIR) $(CYRUS-SASL_IPK_DIR) $(CYRUS-SASL_IPK)

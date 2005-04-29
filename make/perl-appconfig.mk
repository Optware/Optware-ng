###########################################################
#
# perl-appconfig
#
###########################################################

PERL-APPCONFIG_SITE=http://search.cpan.org/CPAN/authors/id/A/AB/ABW
PERL-APPCONFIG_VERSION=1.56
PERL-APPCONFIG_SOURCE=AppConfig-$(PERL-APPCONFIG_VERSION).tar.gz
PERL-APPCONFIG_DIR=AppConfig-$(PERL-APPCONFIG_VERSION)
PERL-APPCONFIG_UNZIP=zcat

PERL-APPCONFIG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-APPCONFIG_DESCRIPTION=Perl5 module for reading configuration files and parsing command line arguments.
PERL-APPCONFIG_SECTION=util
PERL-APPCONFIG_PRIORITY=optional
PERL-APPCONFIG_DEPENDS=perl

PERL-APPCONFIG_IPK_VERSION=1

PERL-APPCONFIG_CONFFILES=

PERL-APPCONFIG_PATCHES=

PERL-APPCONFIG_BUILD_DIR=$(BUILD_DIR)/perl-appconfig
PERL-APPCONFIG_SOURCE_DIR=$(SOURCE_DIR)/perl-appconfig
PERL-APPCONFIG_IPK_DIR=$(BUILD_DIR)/perl-appconfig-$(PERL-APPCONFIG_VERSION)-ipk
PERL-APPCONFIG_IPK=$(BUILD_DIR)/perl-appconfig_$(PERL-APPCONFIG_VERSION)-$(PERL-APPCONFIG_IPK_VERSION)_$(TARGET_ARCH).ipk

PERL-APPCONFIG_BUILD_DIR=$(BUILD_DIR)/perl-appconfig
PERL-APPCONFIG_SOURCE_DIR=$(SOURCE_DIR)/perl-appconfig
PERL-APPCONFIG_IPK_DIR=$(BUILD_DIR)/perl-appconfig-$(PERL-APPCONFIG_VERSION)-ipk
PERL-APPCONFIG_IPK=$(BUILD_DIR)/perl-appconfig_$(PERL-APPCONFIG_VERSION)-$(PERL-APPCONFIG_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-APPCONFIG_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-APPCONFIG_SITE)/$(PERL-APPCONFIG_SOURCE)

perl-appconfig-source: $(DL_DIR)/$(PERL-APPCONFIG_SOURCE) $(PERL-APPCONFIG_PATCHES)

$(PERL-APPCONFIG_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-APPCONFIG_SOURCE) $(PERL-APPCONFIG_PATCHES)
#	$(MAKE) perl-...-stage
	rm -rf $(BUILD_DIR)/$(PERL-APPCONFIG_DIR) $(PERL-APPCONFIG_BUILD_DIR)
	$(PERL-APPCONFIG_UNZIP) $(DL_DIR)/$(PERL-APPCONFIG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-APPCONFIG_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-APPCONFIG_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-APPCONFIG_DIR) $(PERL-APPCONFIG_BUILD_DIR)
	(cd $(PERL-APPCONFIG_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		perl Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-APPCONFIG_BUILD_DIR)/.configured

perl-appconfig-unpack: $(PERL-APPCONFIG_BUILD_DIR)/.configured

$(PERL-APPCONFIG_BUILD_DIR)/.built: $(PERL-APPCONFIG_BUILD_DIR)/.configured
	rm -f $(PERL-APPCONFIG_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-APPCONFIG_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-APPCONFIG_BUILD_DIR)/.built

perl-appconfig: $(PERL-APPCONFIG_BUILD_DIR)/.built

$(PERL-APPCONFIG_BUILD_DIR)/.staged: $(PERL-APPCONFIG_BUILD_DIR)/.built
	rm -f $(PERL-APPCONFIG_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-APPCONFIG_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-APPCONFIG_BUILD_DIR)/.staged

perl-appconfig-stage: $(PERL-APPCONFIG_BUILD_DIR)/.staged

$(PERL-APPCONFIG_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-APPCONFIG_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-appconfig" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-APPCONFIG_PRIORITY)" >>$@
	@echo "Section: $(PERL-APPCONFIG_SECTION)" >>$@
	@echo "Version: $(PERL-APPCONFIG_VERSION)-$(PERL-APPCONFIG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-APPCONFIG_MAINTAINER)" >>$@
	@echo "Source: $(PERL-APPCONFIG_SITE)/$(PERL-APPCONFIG_SOURCE)" >>$@
	@echo "Description: $(PERL-APPCONFIG_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-APPCONFIG_DEPENDS)" >>$@

$(PERL-APPCONFIG_IPK): $(PERL-APPCONFIG_BUILD_DIR)/.built
	rm -rf $(PERL-APPCONFIG_IPK_DIR) $(BUILD_DIR)/perl-appconfig_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-APPCONFIG_BUILD_DIR) DESTDIR=$(PERL-APPCONFIG_IPK_DIR) install
	find $(PERL-APPCONFIG_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-APPCONFIG_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-APPCONFIG_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-APPCONFIG_IPK_DIR)/CONTROL/control
#	install -m 755 $(PERL-APPCONFIG_SOURCE_DIR)/postinst $(PERL-APPCONFIG_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PERL-APPCONFIG_SOURCE_DIR)/prerm $(PERL-APPCONFIG_IPK_DIR)/CONTROL/prerm
	echo $(PERL-APPCONFIG_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-APPCONFIG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-APPCONFIG_IPK_DIR)

perl-appconfig-ipk: $(PERL-APPCONFIG_IPK)

perl-appconfig-clean:
	-$(MAKE) -C $(PERL-APPCONFIG_BUILD_DIR) clean

perl-appconfig-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-APPCONFIG_DIR) $(PERL-APPCONFIG_BUILD_DIR) $(PERL-APPCONFIG_IPK_DIR) $(PERL-APPCONFIG_IPK)

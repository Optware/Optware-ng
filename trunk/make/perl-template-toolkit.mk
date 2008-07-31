###########################################################
#
# perl-template-toolkit
#
###########################################################

PERL-TEMPLATE-TOOLKIT_SITE=http://cpan.org/modules/by-module/Template
PERL-TEMPLATE-TOOLKIT_VERSION=2.19
PERL-TEMPLATE-TOOLKIT_SOURCE=Template-Toolkit-$(PERL-TEMPLATE-TOOLKIT_VERSION).tar.gz
PERL-TEMPLATE-TOOLKIT_DIR=Template-Toolkit-$(PERL-TEMPLATE-TOOLKIT_VERSION)
PERL-TEMPLATE-TOOLKIT_UNZIP=zcat

PERL-TEMPLATE-TOOLKIT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-TEMPLATE-TOOLKIT_DESCRIPTION=The Template Toolkit is a fast, powerful and extensible template processing system. (www.template-toolkit.org)
PERL-TEMPLATE-TOOLKIT_SECTION=util
PERL-TEMPLATE-TOOLKIT_PRIORITY=optional
PERL-TEMPLATE-TOOLKIT_DEPENDS=perl, perl-appconfig

PERL-TEMPLATE-TOOLKIT_IPK_VERSION=1

PERL-TEMPLATE-TOOLKIT_CONFFILES=

PERL-TEMPLATE-TOOLKIT_PATCHES=

PERL-TEMPLATE-TOOLKIT_BUILD_DIR=$(BUILD_DIR)/perl-template-toolkit
PERL-TEMPLATE-TOOLKIT_SOURCE_DIR=$(SOURCE_DIR)/perl-template-toolkit
PERL-TEMPLATE-TOOLKIT_IPK_DIR=$(BUILD_DIR)/perl-template-toolkit-$(PERL-TEMPLATE-TOOLKIT_VERSION)-ipk
PERL-TEMPLATE-TOOLKIT_IPK=$(BUILD_DIR)/perl-template-toolkit_$(PERL-TEMPLATE-TOOLKIT_VERSION)-$(PERL-TEMPLATE-TOOLKIT_IPK_VERSION)_$(TARGET_ARCH).ipk

PERL-TEMPLATE-TOOLKIT_BUILD_DIR=$(BUILD_DIR)/perl-template-toolkit
PERL-TEMPLATE-TOOLKIT_SOURCE_DIR=$(SOURCE_DIR)/perl-template-toolkit
PERL-TEMPLATE-TOOLKIT_IPK_DIR=$(BUILD_DIR)/perl-template-toolkit-$(PERL-TEMPLATE-TOOLKIT_VERSION)-ipk
PERL-TEMPLATE-TOOLKIT_IPK=$(BUILD_DIR)/perl-template-toolkit_$(PERL-TEMPLATE-TOOLKIT_VERSION)-$(PERL-TEMPLATE-TOOLKIT_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-TEMPLATE-TOOLKIT_SOURCE):
	$(WGET) -P $(@D) $(PERL-TEMPLATE-TOOLKIT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-template-toolkit-source: $(DL_DIR)/$(PERL-TEMPLATE-TOOLKIT_SOURCE) $(PERL-TEMPLATE-TOOLKIT_PATCHES)

$(PERL-TEMPLATE-TOOLKIT_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-TEMPLATE-TOOLKIT_SOURCE) $(PERL-TEMPLATE-TOOLKIT_PATCHES) make/perl-template-toolkit.mk
	$(MAKE) perl-appconfig-stage
	rm -rf $(BUILD_DIR)/$(PERL-TEMPLATE-TOOLKIT_DIR) $(@D)
	$(PERL-TEMPLATE-TOOLKIT_UNZIP) $(DL_DIR)/$(PERL-TEMPLATE-TOOLKIT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-TEMPLATE-TOOLKIT_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-TEMPLATE-TOOLKIT_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-TEMPLATE-TOOLKIT_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
		TT_DOCS=n \
		TT_SPLASH=n \
		TT_THEME=n \
		TT_EXAMPLES=n \
		TT_EXTRAS=n \
		TT_QUIET=y \
		TT_ACCEPT=y \
		TT_DBI=n \
		TT_LATEX=n \
	)
	touch $@

perl-template-toolkit-unpack: $(PERL-TEMPLATE-TOOLKIT_BUILD_DIR)/.configured

$(PERL-TEMPLATE-TOOLKIT_BUILD_DIR)/.built: $(PERL-TEMPLATE-TOOLKIT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(PERL-TEMPLATE-TOOLKIT_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		$(PERL_INC) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $@

perl-template-toolkit: $(PERL-TEMPLATE-TOOLKIT_BUILD_DIR)/.built

$(PERL-TEMPLATE-TOOLKIT_BUILD_DIR)/.staged: $(PERL-TEMPLATE-TOOLKIT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(PERL-TEMPLATE-TOOLKIT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-template-toolkit-stage: $(PERL-TEMPLATE-TOOLKIT_BUILD_DIR)/.staged

$(PERL-TEMPLATE-TOOLKIT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-template-toolkit" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-TEMPLATE-TOOLKIT_PRIORITY)" >>$@
	@echo "Section: $(PERL-TEMPLATE-TOOLKIT_SECTION)" >>$@
	@echo "Version: $(PERL-TEMPLATE-TOOLKIT_VERSION)-$(PERL-TEMPLATE-TOOLKIT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-TEMPLATE-TOOLKIT_MAINTAINER)" >>$@
	@echo "Source: $(PERL-TEMPLATE-TOOLKIT_SITE)/$(PERL-TEMPLATE-TOOLKIT_SOURCE)" >>$@
	@echo "Description: $(PERL-TEMPLATE-TOOLKIT_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-TEMPLATE-TOOLKIT_DEPENDS)" >>$@

$(PERL-TEMPLATE-TOOLKIT_IPK): $(PERL-TEMPLATE-TOOLKIT_BUILD_DIR)/.built
	rm -rf $(PERL-TEMPLATE-TOOLKIT_IPK_DIR) $(BUILD_DIR)/perl-template-toolkit_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-TEMPLATE-TOOLKIT_BUILD_DIR) DESTDIR=$(PERL-TEMPLATE-TOOLKIT_IPK_DIR) install
	find $(PERL-TEMPLATE-TOOLKIT_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-TEMPLATE-TOOLKIT_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-TEMPLATE-TOOLKIT_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-TEMPLATE-TOOLKIT_IPK_DIR)/CONTROL/control
#	install -m 755 $(PERL-TEMPLATE-TOOLKIT_SOURCE_DIR)/postinst $(PERL-TEMPLATE-TOOLKIT_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PERL-TEMPLATE-TOOLKIT_SOURCE_DIR)/prerm $(PERL-TEMPLATE-TOOLKIT_IPK_DIR)/CONTROL/prerm
	echo $(PERL-TEMPLATE-TOOLKIT_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-TEMPLATE-TOOLKIT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-TEMPLATE-TOOLKIT_IPK_DIR)

perl-template-toolkit-ipk: $(PERL-TEMPLATE-TOOLKIT_IPK)

perl-template-toolkit-clean:
	-$(MAKE) -C $(PERL-TEMPLATE-TOOLKIT_BUILD_DIR) clean

perl-template-toolkit-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-TEMPLATE-TOOLKIT_DIR) $(PERL-TEMPLATE-TOOLKIT_BUILD_DIR) $(PERL-TEMPLATE-TOOLKIT_IPK_DIR) $(PERL-TEMPLATE-TOOLKIT_IPK)

perl-template-toolkit-check: $(PERL-TEMPLATE-TOOLKIT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERL-TEMPLATE-TOOLKIT_IPK)

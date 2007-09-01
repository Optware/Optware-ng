###########################################################
#
# perl-devel-lexalias
#
###########################################################

PERL-DEVEL-LEXALIAS_SITE=http://search.cpan.org/CPAN/authors/id/R/RC/RCLAMP
PERL-DEVEL-LEXALIAS_VERSION=0.04
PERL-DEVEL-LEXALIAS_SOURCE=Devel-LexAlias-$(PERL-DEVEL-LEXALIAS_VERSION).tar.gz
PERL-DEVEL-LEXALIAS_DIR=Devel-LexAlias-$(PERL-DEVEL-LEXALIAS_VERSION)
PERL-DEVEL-LEXALIAS_UNZIP=zcat
PERL-DEVEL-LEXALIAS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-DEVEL-LEXALIAS_DESCRIPTION=alias lexical variables.
PERL-DEVEL-LEXALIAS_SECTION=util
PERL-DEVEL-LEXALIAS_PRIORITY=optional
PERL-DEVEL-LEXALIAS_DEPENDS=perl-devel-caller
PERL-DEVEL-LEXALIAS_SUGGESTS=
PERL-DEVEL-LEXALIAS_CONFLICTS=

PERL-DEVEL-LEXALIAS_IPK_VERSION=1

PERL-DEVEL-LEXALIAS_CONFFILES=

PERL-DEVEL-LEXALIAS_BUILD_DIR=$(BUILD_DIR)/perl-devel-lexalias
PERL-DEVEL-LEXALIAS_SOURCE_DIR=$(SOURCE_DIR)/perl-devel-lexalias
PERL-DEVEL-LEXALIAS_IPK_DIR=$(BUILD_DIR)/perl-devel-lexalias-$(PERL-DEVEL-LEXALIAS_VERSION)-ipk
PERL-DEVEL-LEXALIAS_IPK=$(BUILD_DIR)/perl-devel-lexalias_$(PERL-DEVEL-LEXALIAS_VERSION)-$(PERL-DEVEL-LEXALIAS_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-DEVEL-LEXALIAS_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-DEVEL-LEXALIAS_SITE)/$(PERL-DEVEL-LEXALIAS_SOURCE)

perl-devel-lexalias-source: $(DL_DIR)/$(PERL-DEVEL-LEXALIAS_SOURCE) $(PERL-DEVEL-LEXALIAS_PATCHES)

$(PERL-DEVEL-LEXALIAS_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-DEVEL-LEXALIAS_SOURCE) $(PERL-DEVEL-LEXALIAS_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-DEVEL-LEXALIAS_DIR) $(PERL-DEVEL-LEXALIAS_BUILD_DIR)
	$(PERL-DEVEL-LEXALIAS_UNZIP) $(DL_DIR)/$(PERL-DEVEL-LEXALIAS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-DEVEL-LEXALIAS_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-DEVEL-LEXALIAS_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-DEVEL-LEXALIAS_DIR) $(PERL-DEVEL-LEXALIAS_BUILD_DIR)
	(cd $(PERL-DEVEL-LEXALIAS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

perl-devel-lexalias-unpack: $(PERL-DEVEL-LEXALIAS_BUILD_DIR)/.configured

$(PERL-DEVEL-LEXALIAS_BUILD_DIR)/.built: $(PERL-DEVEL-LEXALIAS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(PERL-DEVEL-LEXALIAS_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $@

perl-devel-lexalias: $(PERL-DEVEL-LEXALIAS_BUILD_DIR)/.built

$(PERL-DEVEL-LEXALIAS_BUILD_DIR)/.staged: $(PERL-DEVEL-LEXALIAS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(PERL-DEVEL-LEXALIAS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-devel-lexalias-stage: $(PERL-DEVEL-LEXALIAS_BUILD_DIR)/.staged

$(PERL-DEVEL-LEXALIAS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-devel-lexalias" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-DEVEL-LEXALIAS_PRIORITY)" >>$@
	@echo "Section: $(PERL-DEVEL-LEXALIAS_SECTION)" >>$@
	@echo "Version: $(PERL-DEVEL-LEXALIAS_VERSION)-$(PERL-DEVEL-LEXALIAS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-DEVEL-LEXALIAS_MAINTAINER)" >>$@
	@echo "Source: $(PERL-DEVEL-LEXALIAS_SITE)/$(PERL-DEVEL-LEXALIAS_SOURCE)" >>$@
	@echo "Description: $(PERL-DEVEL-LEXALIAS_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-DEVEL-LEXALIAS_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-DEVEL-LEXALIAS_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-DEVEL-LEXALIAS_CONFLICTS)" >>$@

$(PERL-DEVEL-LEXALIAS_IPK): $(PERL-DEVEL-LEXALIAS_BUILD_DIR)/.built
	rm -rf $(PERL-DEVEL-LEXALIAS_IPK_DIR) $(BUILD_DIR)/perl-devel-lexalias_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-DEVEL-LEXALIAS_BUILD_DIR) DESTDIR=$(PERL-DEVEL-LEXALIAS_IPK_DIR) install
	find $(PERL-DEVEL-LEXALIAS_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-DEVEL-LEXALIAS_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-DEVEL-LEXALIAS_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-DEVEL-LEXALIAS_IPK_DIR)/CONTROL/control
	echo $(PERL-DEVEL-LEXALIAS_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-DEVEL-LEXALIAS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-DEVEL-LEXALIAS_IPK_DIR)

perl-devel-lexalias-ipk: $(PERL-DEVEL-LEXALIAS_IPK)

perl-devel-lexalias-clean:
	-$(MAKE) -C $(PERL-DEVEL-LEXALIAS_BUILD_DIR) clean

perl-devel-lexalias-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-DEVEL-LEXALIAS_DIR) $(PERL-DEVEL-LEXALIAS_BUILD_DIR) $(PERL-DEVEL-LEXALIAS_IPK_DIR) $(PERL-DEVEL-LEXALIAS_IPK)

perl-devel-lexalias-check: $(PERL-DEVEL-LEXALIAS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERL-DEVEL-LEXALIAS_IPK)

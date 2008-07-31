###########################################################
#
# perl-json-xs
#
###########################################################

PERL-JSON-XS_SITE=http://search.cpan.org/CPAN/authors/id/M/ML/MLEHMANN
PERL-JSON-XS_VERSION=2.2222
PERL-JSON-XS_SOURCE=JSON-XS-$(PERL-JSON-XS_VERSION).tar.gz
PERL-JSON-XS_DIR=JSON-XS-$(PERL-JSON-XS_VERSION)
PERL-JSON-XS_UNZIP=zcat
PERL-JSON-XS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-JSON-XS_DESCRIPTION=JSON serialising/deserialising, done correctly and fast.
PERL-JSON-XS_SECTION=util
PERL-JSON-XS_PRIORITY=optional
PERL-JSON-XS_DEPENDS=perl
PERL-JSON-XS_SUGGESTS=
PERL-JSON-XS_CONFLICTS=

PERL-JSON-XS_IPK_VERSION=1

PERL-JSON-XS_CONFFILES=

PERL-JSON-XS_BUILD_DIR=$(BUILD_DIR)/perl-json-xs
PERL-JSON-XS_SOURCE_DIR=$(SOURCE_DIR)/perl-json-xs
PERL-JSON-XS_IPK_DIR=$(BUILD_DIR)/perl-json-xs-$(PERL-JSON-XS_VERSION)-ipk
PERL-JSON-XS_IPK=$(BUILD_DIR)/perl-json-xs_$(PERL-JSON-XS_VERSION)-$(PERL-JSON-XS_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-JSON-XS_SOURCE):
	$(WGET) -P $(@D) $(PERL-JSON-XS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-json-xs-source: $(DL_DIR)/$(PERL-JSON-XS_SOURCE) $(PERL-JSON-XS_PATCHES)

$(PERL-JSON-XS_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-JSON-XS_SOURCE) $(PERL-JSON-XS_PATCHES) make/perl-json-xs.mk
	$(MAKE) perl-stage
	rm -rf $(BUILD_DIR)/$(PERL-JSON-XS_DIR) $(@D)
	$(PERL-JSON-XS_UNZIP) $(DL_DIR)/$(PERL-JSON-XS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-JSON-XS_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-JSON-XS_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-JSON-XS_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

perl-json-xs-unpack: $(PERL-JSON-XS_BUILD_DIR)/.configured

$(PERL-JSON-XS_BUILD_DIR)/.built: $(PERL-JSON-XS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		$(PERL_INC) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $@

perl-json-xs: $(PERL-JSON-XS_BUILD_DIR)/.built

$(PERL-JSON-XS_BUILD_DIR)/.staged: $(PERL-JSON-XS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(PERL-JSON-XS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-json-xs-stage: $(PERL-JSON-XS_BUILD_DIR)/.staged

$(PERL-JSON-XS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-json-xs" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-JSON-XS_PRIORITY)" >>$@
	@echo "Section: $(PERL-JSON-XS_SECTION)" >>$@
	@echo "Version: $(PERL-JSON-XS_VERSION)-$(PERL-JSON-XS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-JSON-XS_MAINTAINER)" >>$@
	@echo "Source: $(PERL-JSON-XS_SITE)/$(PERL-JSON-XS_SOURCE)" >>$@
	@echo "Description: $(PERL-JSON-XS_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-JSON-XS_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-JSON-XS_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-JSON-XS_CONFLICTS)" >>$@

$(PERL-JSON-XS_IPK): $(PERL-JSON-XS_BUILD_DIR)/.built
	rm -rf $(PERL-JSON-XS_IPK_DIR) $(BUILD_DIR)/perl-json-xs_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-JSON-XS_BUILD_DIR) DESTDIR=$(PERL-JSON-XS_IPK_DIR) install
	find $(PERL-JSON-XS_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-JSON-XS_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-JSON-XS_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-JSON-XS_IPK_DIR)/CONTROL/control
	echo $(PERL-JSON-XS_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-JSON-XS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-JSON-XS_IPK_DIR)

perl-json-xs-ipk: $(PERL-JSON-XS_IPK)

perl-json-xs-clean:
	-$(MAKE) -C $(PERL-JSON-XS_BUILD_DIR) clean

perl-json-xs-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-JSON-XS_DIR) $(PERL-JSON-XS_BUILD_DIR) $(PERL-JSON-XS_IPK_DIR) $(PERL-JSON-XS_IPK)

perl-json-xs-check: $(PERL-JSON-XS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERL-JSON-XS_IPK)

###########################################################
#
# perl-html-parser
#
###########################################################

PERL-HTML-PARSER_SITE=http://search.cpan.org/CPAN/authors/id/G/GA/GAAS
PERL-HTML-PARSER_VERSION=3.60
PERL-HTML-PARSER_SOURCE=HTML-Parser-$(PERL-HTML-PARSER_VERSION).tar.gz
PERL-HTML-PARSER_DIR=HTML-Parser-$(PERL-HTML-PARSER_VERSION)
PERL-HTML-PARSER_UNZIP=zcat
PERL-HTML-PARSER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-HTML-PARSER_DESCRIPTION=A collection of modules that parse and extract information from HTML documents.
PERL-HTML-PARSER_SECTION=util
PERL-HTML-PARSER_PRIORITY=optional
PERL-HTML-PARSER_DEPENDS=perl, perl-html-tagset
PERL-HTML-PARSER_SUGGESTS=
PERL-HTML-PARSER_CONFLICTS=

PERL-HTML-PARSER_IPK_VERSION=1

PERL-HTML-PARSER_CONFFILES=

PERL-HTML-PARSER_BUILD_DIR=$(BUILD_DIR)/perl-html-parser
PERL-HTML-PARSER_SOURCE_DIR=$(SOURCE_DIR)/perl-html-parser
PERL-HTML-PARSER_IPK_DIR=$(BUILD_DIR)/perl-html-parser-$(PERL-HTML-PARSER_VERSION)-ipk
PERL-HTML-PARSER_IPK=$(BUILD_DIR)/perl-html-parser_$(PERL-HTML-PARSER_VERSION)-$(PERL-HTML-PARSER_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-HTML-PARSER_SOURCE):
	$(WGET) -P $(@D) $(PERL-HTML-PARSER_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-html-parser-source: $(DL_DIR)/$(PERL-HTML-PARSER_SOURCE) $(PERL-HTML-PARSER_PATCHES)

$(PERL-HTML-PARSER_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-HTML-PARSER_SOURCE) $(PERL-HTML-PARSER_PATCHES)
	$(MAKE) perl-html-tagset-stage
	rm -rf $(BUILD_DIR)/$(PERL-HTML-PARSER_DIR) $(@D)
	$(PERL-HTML-PARSER_UNZIP) $(DL_DIR)/$(PERL-HTML-PARSER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-HTML-PARSER_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-HTML-PARSER_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-HTML-PARSER_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

perl-html-parser-unpack: $(PERL-HTML-PARSER_BUILD_DIR)/.configured

$(PERL-HTML-PARSER_BUILD_DIR)/.built: $(PERL-HTML-PARSER_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		$(PERL_INC) \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

perl-html-parser: $(PERL-HTML-PARSER_BUILD_DIR)/.built

$(PERL-HTML-PARSER_BUILD_DIR)/.staged: $(PERL-HTML-PARSER_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-html-parser-stage: $(PERL-HTML-PARSER_BUILD_DIR)/.staged

$(PERL-HTML-PARSER_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-html-parser" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-HTML-PARSER_PRIORITY)" >>$@
	@echo "Section: $(PERL-HTML-PARSER_SECTION)" >>$@
	@echo "Version: $(PERL-HTML-PARSER_VERSION)-$(PERL-HTML-PARSER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-HTML-PARSER_MAINTAINER)" >>$@
	@echo "Source: $(PERL-HTML-PARSER_SITE)/$(PERL-HTML-PARSER_SOURCE)" >>$@
	@echo "Description: $(PERL-HTML-PARSER_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-HTML-PARSER_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-HTML-PARSER_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-HTML-PARSER_CONFLICTS)" >>$@

$(PERL-HTML-PARSER_IPK): $(PERL-HTML-PARSER_BUILD_DIR)/.built
	rm -rf $(PERL-HTML-PARSER_IPK_DIR) $(BUILD_DIR)/perl-html-parser_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-HTML-PARSER_BUILD_DIR) DESTDIR=$(PERL-HTML-PARSER_IPK_DIR) install
	find $(PERL-HTML-PARSER_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-HTML-PARSER_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-HTML-PARSER_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-HTML-PARSER_IPK_DIR)/CONTROL/control
	echo $(PERL-HTML-PARSER_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-HTML-PARSER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-HTML-PARSER_IPK_DIR)

perl-html-parser-ipk: $(PERL-HTML-PARSER_IPK)

perl-html-parser-clean:
	-$(MAKE) -C $(PERL-HTML-PARSER_BUILD_DIR) clean

perl-html-parser-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-HTML-PARSER_DIR) $(PERL-HTML-PARSER_BUILD_DIR) $(PERL-HTML-PARSER_IPK_DIR) $(PERL-HTML-PARSER_IPK)

perl-html-parser-check: $(PERL-HTML-PARSER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERL-HTML-PARSER_IPK)

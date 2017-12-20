###########################################################
#
# perl-xml-parser
#
###########################################################

PERL-XML-PARSER_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/T/TO/TODDR
PERL-XML-PARSER_VERSION=2.44
PERL-XML-PARSER_SOURCE=XML-Parser-$(PERL-XML-PARSER_VERSION).tar.gz
PERL-XML-PARSER_DIR=XML-Parser-$(PERL-XML-PARSER_VERSION)
PERL-XML-PARSER_UNZIP=zcat
PERL-XML-PARSER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-XML-PARSER_DESCRIPTION=A perl module for parsing XML documents.
PERL-XML-PARSER_SECTION=util
PERL-XML-PARSER_PRIORITY=optional
PERL-XML-PARSER_DEPENDS=perl, expat
PERL-XML-PARSER_SUGGESTS=
PERL-XML-PARSER_CONFLICTS=

PERL-XML-PARSER_IPK_VERSION=3

PERL-XML-PARSER_CONFFILES=

PERL-XML-PARSER_BUILD_DIR=$(BUILD_DIR)/perl-xml-parser
PERL-XML-PARSER_SOURCE_DIR=$(SOURCE_DIR)/perl-xml-parser
PERL-XML-PARSER_IPK_DIR=$(BUILD_DIR)/perl-xml-parser-$(PERL-XML-PARSER_VERSION)-ipk
PERL-XML-PARSER_IPK=$(BUILD_DIR)/perl-xml-parser_$(PERL-XML-PARSER_VERSION)-$(PERL-XML-PARSER_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-XML-PARSER_SOURCE):
	$(WGET) -P $(@D) $(PERL-XML-PARSER_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-xml-parser-source: $(DL_DIR)/$(PERL-XML-PARSER_SOURCE) $(PERL-XML-PARSER_PATCHES)

$(PERL-XML-PARSER_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-XML-PARSER_SOURCE) $(PERL-XML-PARSER_PATCHES) make/perl-xml-parser.mk
	$(MAKE) perl-stage expat-stage
	rm -rf $(BUILD_DIR)/$(PERL-XML-PARSER_DIR) $(PERL-XML-PARSER_BUILD_DIR)
	$(PERL-XML-PARSER_UNZIP) $(DL_DIR)/$(PERL-XML-PARSER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-XML-PARSER_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-XML-PARSER_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-XML-PARSER_DIR) $(PERL-XML-PARSER_BUILD_DIR)
	(cd $(PERL-XML-PARSER_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $(PERL-XML-PARSER_BUILD_DIR)/.configured

perl-xml-parser-unpack: $(PERL-XML-PARSER_BUILD_DIR)/.configured

$(PERL-XML-PARSER_BUILD_DIR)/.built: $(PERL-XML-PARSER_BUILD_DIR)/.configured
	rm -f $(PERL-XML-PARSER_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-XML-PARSER_BUILD_DIR)/Expat \
		$(TARGET_CONFIGURE_OPTS) \
		LD=$(TARGET_CC) \
		CCFLAGS="$(STAGING_CPPFLAGS) $(PERL_MODULES_CFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PERL_MODULES_LDFLAGS) $(PERL-XML-PARSER_LDFLAGS)" \
		LDDLFLAGS="-shared $(STAGING_LDFLAGS) $(PERL_MODULES_LDFLAGS) $(PERL-XML-PARSER_LDFLAGS)" \
		PASTHRU_INC="$(STAGING_CPPFLAGS) $(PERL-XML-PARSER_CPPFLAGS)" \
		LD_RUN_PATH=$(TARGET_PREFIX)/lib \
		$(PERL_INC) \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	$(MAKE) -C $(PERL-XML-PARSER_BUILD_DIR)
	touch $(PERL-XML-PARSER_BUILD_DIR)/.built

perl-xml-parser: $(PERL-XML-PARSER_BUILD_DIR)/.built

$(PERL-XML-PARSER_BUILD_DIR)/.staged: $(PERL-XML-PARSER_BUILD_DIR)/.built
	rm -f $(PERL-XML-PARSER_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-XML-PARSER_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-XML-PARSER_BUILD_DIR)/.staged

perl-xml-parser-stage: $(PERL-XML-PARSER_BUILD_DIR)/.staged

$(PERL-XML-PARSER_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(PERL-XML-PARSER_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-xml-parser" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-XML-PARSER_PRIORITY)" >>$@
	@echo "Section: $(PERL-XML-PARSER_SECTION)" >>$@
	@echo "Version: $(PERL-XML-PARSER_VERSION)-$(PERL-XML-PARSER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-XML-PARSER_MAINTAINER)" >>$@
	@echo "Source: $(PERL-XML-PARSER_SITE)/$(PERL-XML-PARSER_SOURCE)" >>$@
	@echo "Description: $(PERL-XML-PARSER_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-XML-PARSER_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-XML-PARSER_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-XML-PARSER_CONFLICTS)" >>$@

$(PERL-XML-PARSER_IPK): $(PERL-XML-PARSER_BUILD_DIR)/.built
	rm -rf $(PERL-XML-PARSER_IPK_DIR) $(BUILD_DIR)/perl-xml-parser_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-XML-PARSER_BUILD_DIR) DESTDIR=$(PERL-XML-PARSER_IPK_DIR) install
	find $(PERL-XML-PARSER_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-XML-PARSER_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-XML-PARSER_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-XML-PARSER_IPK_DIR)/CONTROL/control
	echo $(PERL-XML-PARSER_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-XML-PARSER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-XML-PARSER_IPK_DIR)

perl-xml-parser-ipk: $(PERL-XML-PARSER_IPK)

perl-xml-parser-clean:
	-$(MAKE) -C $(PERL-XML-PARSER_BUILD_DIR) clean

perl-xml-parser-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-XML-PARSER_DIR) $(PERL-XML-PARSER_BUILD_DIR) $(PERL-XML-PARSER_IPK_DIR) $(PERL-XML-PARSER_IPK)

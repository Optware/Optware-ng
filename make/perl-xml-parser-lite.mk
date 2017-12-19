###########################################################
#
# perl-xml-parser-lite
#
###########################################################

PERL-XML-PARSER-LITE_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/P/PH/PHRED
PERL-XML-PARSER-LITE_VERSION=0.721
PERL-XML-PARSER-LITE_SOURCE=XML-Parser-Lite-$(PERL-XML-PARSER-LITE_VERSION).tar.gz
PERL-XML-PARSER-LITE_DIR=XML-Parser-Lite-$(PERL-XML-PARSER-LITE_VERSION)
PERL-XML-PARSER-LITE_UNZIP=zcat
PERL-XML-PARSER-LITE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-XML-PARSER-LITE_DESCRIPTION=Lightweight pure-perl XML Parser (based on regexps)
PERL-XML-PARSER-LITE_SECTION=util
PERL-XML-PARSER-LITE_PRIORITY=optional
PERL-XML-PARSER-LITE_DEPENDS=
PERL-XML-PARSER-LITE_SUGGESTS=
PERL-XML-PARSER-LITE_CONFLICTS=

PERL-XML-PARSER-LITE_IPK_VERSION=3

PERL-XML-PARSER-LITE_CONFFILES=

PERL-XML-PARSER-LITE_BUILD_DIR=$(BUILD_DIR)/perl-xml-parser-lite
PERL-XML-PARSER-LITE_SOURCE_DIR=$(SOURCE_DIR)/perl-xml-parser-lite
PERL-XML-PARSER-LITE_IPK_DIR=$(BUILD_DIR)/perl-xml-parser-lite-$(PERL-XML-PARSER-LITE_VERSION)-ipk
PERL-XML-PARSER-LITE_IPK=$(BUILD_DIR)/perl-xml-parser-lite_$(PERL-XML-PARSER-LITE_VERSION)-$(PERL-XML-PARSER-LITE_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-XML-PARSER-LITE_SOURCE):
	$(WGET) -P $(@D) $(PERL-XML-PARSER-LITE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-xml-parser-lite-source: $(DL_DIR)/$(PERL-XML-PARSER-LITE_SOURCE) $(PERL-XML-PARSER-LITE_PATCHES)

$(PERL-XML-PARSER-LITE_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-XML-PARSER-LITE_SOURCE) $(PERL-XML-PARSER-LITE_PATCHES) make/perl-xml-parser-lite.mk
	rm -rf $(BUILD_DIR)/$(PERL-XML-PARSER-LITE_DIR) $(PERL-XML-PARSER-LITE_BUILD_DIR)
	$(PERL-XML-PARSER-LITE_UNZIP) $(DL_DIR)/$(PERL-XML-PARSER-LITE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-XML-PARSER-LITE_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-XML-PARSER-LITE_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-XML-PARSER-LITE_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $@

perl-xml-parser-lite-unpack: $(PERL-XML-PARSER-LITE_BUILD_DIR)/.configured

$(PERL-XML-PARSER-LITE_BUILD_DIR)/.built: $(PERL-XML-PARSER-LITE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

perl-xml-parser-lite: $(PERL-XML-PARSER-LITE_BUILD_DIR)/.built

$(PERL-XML-PARSER-LITE_BUILD_DIR)/.staged: $(PERL-XML-PARSER-LITE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-xml-parser-lite-stage: $(PERL-XML-PARSER-LITE_BUILD_DIR)/.staged

$(PERL-XML-PARSER-LITE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: perl-xml-parser-lite" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-XML-PARSER-LITE_PRIORITY)" >>$@
	@echo "Section: $(PERL-XML-PARSER-LITE_SECTION)" >>$@
	@echo "Version: $(PERL-XML-PARSER-LITE_VERSION)-$(PERL-XML-PARSER-LITE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-XML-PARSER-LITE_MAINTAINER)" >>$@
	@echo "Source: $(PERL-XML-PARSER-LITE_SITE)/$(PERL-XML-PARSER-LITE_SOURCE)" >>$@
	@echo "Description: $(PERL-XML-PARSER-LITE_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-XML-PARSER-LITE_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-XML-PARSER-LITE_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-XML-PARSER-LITE_CONFLICTS)" >>$@

$(PERL-XML-PARSER-LITE_IPK): $(PERL-XML-PARSER-LITE_BUILD_DIR)/.built
	rm -rf $(PERL-XML-PARSER-LITE_IPK_DIR) $(BUILD_DIR)/perl-xml-parser-lite_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-XML-PARSER-LITE_BUILD_DIR) DESTDIR=$(PERL-XML-PARSER-LITE_IPK_DIR) install
	find $(PERL-XML-PARSER-LITE_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-XML-PARSER-LITE_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-XML-PARSER-LITE_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-XML-PARSER-LITE_IPK_DIR)/CONTROL/control
	echo $(PERL-XML-PARSER-LITE_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-XML-PARSER-LITE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-XML-PARSER-LITE_IPK_DIR)

perl-xml-parser-lite-ipk: $(PERL-XML-PARSER-LITE_IPK)

perl-xml-parser-lite-clean:
	-$(MAKE) -C $(PERL-XML-PARSER-LITE_BUILD_DIR) clean

perl-xml-parser-lite-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-XML-PARSER-LITE_DIR) $(PERL-XML-PARSER-LITE_BUILD_DIR) $(PERL-XML-PARSER-LITE_IPK_DIR) $(PERL-XML-PARSER-LITE_IPK)

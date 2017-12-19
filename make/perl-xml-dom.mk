###########################################################
#
# perl-xml-dom
#
###########################################################

PERL-XML-DOM_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/T/TJ/TJMATHER
PERL-XML-DOM_VERSION=1.44
PERL-XML-DOM_SOURCE=XML-DOM-$(PERL-XML-DOM_VERSION).tar.gz
PERL-XML-DOM_DIR=XML-DOM-$(PERL-XML-DOM_VERSION)
PERL-XML-DOM_UNZIP=zcat
PERL-XML-DOM_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-XML-DOM_DESCRIPTION=A perl module for building DOM Level 1 compliant document structures
PERL-XML-DOM_SECTION=textproc
PERL-XML-DOM_PRIORITY=optional
PERL-XML-DOM_DEPENDS=perl-libxml, perl-xml-parser, perl-xml-regexp
PERL-XML-DOM_SUGGESTS=
PERL-XML-DOM_CONFLICTS=

PERL-XML-DOM_IPK_VERSION=3

PERL-XML-DOM_CONFFILES=

PERL-XML-DOM_BUILD_DIR=$(BUILD_DIR)/perl-xml-dom
PERL-XML-DOM_SOURCE_DIR=$(SOURCE_DIR)/perl-xml-dom
PERL-XML-DOM_IPK_DIR=$(BUILD_DIR)/perl-xml-dom-$(PERL-XML-DOM_VERSION)-ipk
PERL-XML-DOM_IPK=$(BUILD_DIR)/perl-xml-dom_$(PERL-XML-DOM_VERSION)-$(PERL-XML-DOM_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-XML-DOM_SOURCE):
	$(WGET) -P $(@D) $(PERL-XML-DOM_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-xml-dom-source: $(DL_DIR)/$(PERL-XML-DOM_SOURCE) $(PERL-XML-DOM_PATCHES)

$(PERL-XML-DOM_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-XML-DOM_SOURCE) $(PERL-XML-DOM_PATCHES) make/perl-xml-dom.mk
	$(MAKE) perl-stage
	rm -rf $(BUILD_DIR)/$(PERL-XML-DOM_DIR) $(@D)
	$(PERL-XML-DOM_UNZIP) $(DL_DIR)/$(PERL-XML-DOM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-XML-DOM_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-XML-DOM_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-XML-DOM_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $@

perl-xml-dom-unpack: $(PERL-XML-DOM_BUILD_DIR)/.configured

$(PERL-XML-DOM_BUILD_DIR)/.built: $(PERL-XML-DOM_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		PASTHRU_INC="$(STAGING_CPPFLAGS) $(PERL-XML-DOM_CPPFLAGS)" \
		LD=$(TARGET_CC) \
		LDDLFLAGS="-shared $(STAGING_LDFLAGS) $(PERL-XML-DOM_LDFLAGS)" \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		LD_RUN_PATH=$(TARGET_PREFIX)/lib \
		$(PERL_INC) \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	$(MAKE) -C $(@D)
	touch $@

perl-xml-dom: $(PERL-XML-DOM_BUILD_DIR)/.built

$(PERL-XML-DOM_BUILD_DIR)/.staged: $(PERL-XML-DOM_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-xml-dom-stage: $(PERL-XML-DOM_BUILD_DIR)/.staged

$(PERL-XML-DOM_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: perl-xml-dom" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-XML-DOM_PRIORITY)" >>$@
	@echo "Section: $(PERL-XML-DOM_SECTION)" >>$@
	@echo "Version: $(PERL-XML-DOM_VERSION)-$(PERL-XML-DOM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-XML-DOM_MAINTAINER)" >>$@
	@echo "Source: $(PERL-XML-DOM_SITE)/$(PERL-XML-DOM_SOURCE)" >>$@
	@echo "Description: $(PERL-XML-DOM_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-XML-DOM_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-XML-DOM_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-XML-DOM_CONFLICTS)" >>$@

$(PERL-XML-DOM_IPK): $(PERL-XML-DOM_BUILD_DIR)/.built
	rm -rf $(PERL-XML-DOM_IPK_DIR) $(BUILD_DIR)/perl-xml-dom_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-XML-DOM_BUILD_DIR) DESTDIR=$(PERL-XML-DOM_IPK_DIR) install
	find $(PERL-XML-DOM_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-XML-DOM_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-XML-DOM_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-XML-DOM_IPK_DIR)/CONTROL/control
	echo $(PERL-XML-DOM_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-XML-DOM_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-XML-DOM_IPK_DIR)

perl-xml-dom-ipk: $(PERL-XML-DOM_IPK)

perl-xml-dom-clean:
	-$(MAKE) -C $(PERL-XML-DOM_BUILD_DIR) clean

perl-xml-dom-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-XML-DOM_DIR) $(PERL-XML-DOM_BUILD_DIR) $(PERL-XML-DOM_IPK_DIR) $(PERL-XML-DOM_IPK)

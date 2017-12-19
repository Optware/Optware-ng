###########################################################
#
# perl-html-tagparser
#
###########################################################

PERL-HTML-TAGPARSER_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/K/KA/KAWASAKI
PERL-HTML-TAGPARSER_VERSION=0.20
PERL-HTML-TAGPARSER_SOURCE=HTML-TagParser-$(PERL-HTML-TAGPARSER_VERSION).tar.gz
PERL-HTML-TAGPARSER_DIR=HTML-TagParser-$(PERL-HTML-TAGPARSER_VERSION)
PERL-HTML-TAGPARSER_UNZIP=zcat
PERL-HTML-TAGPARSER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-HTML-TAGPARSER_DESCRIPTION=Yet another HTML document parser with DOM-like methods
PERL-HTML-TAGPARSER_SECTION=util
PERL-HTML-TAGPARSER_PRIORITY=optional
PERL-HTML-TAGPARSER_DEPENDS=
PERL-HTML-TAGPARSER_SUGGESTS=
PERL-HTML-TAGPARSER_CONFLICTS=

PERL-HTML-TAGPARSER_IPK_VERSION=3

PERL-HTML-TAGPARSER_CONFFILES=

PERL-HTML-TAGPARSER_BUILD_DIR=$(BUILD_DIR)/perl-html-tagparser
PERL-HTML-TAGPARSER_SOURCE_DIR=$(SOURCE_DIR)/perl-html-tagparser
PERL-HTML-TAGPARSER_IPK_DIR=$(BUILD_DIR)/perl-html-tagparser-$(PERL-HTML-TAGPARSER_VERSION)-ipk
PERL-HTML-TAGPARSER_IPK=$(BUILD_DIR)/perl-html-tagparser_$(PERL-HTML-TAGPARSER_VERSION)-$(PERL-HTML-TAGPARSER_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-HTML-TAGPARSER_SOURCE):
	$(WGET) -P $(@D) $(PERL-HTML-TAGPARSER_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-html-tagparser-source: $(DL_DIR)/$(PERL-HTML-TAGPARSER_SOURCE) $(PERL-HTML-TAGPARSER_PATCHES)

$(PERL-HTML-TAGPARSER_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-HTML-TAGPARSER_SOURCE) $(PERL-HTML-TAGPARSER_PATCHES) make/perl-html-tagparser.mk
	rm -rf $(BUILD_DIR)/$(PERL-HTML-TAGPARSER_DIR) $(PERL-HTML-TAGPARSER_BUILD_DIR)
	$(PERL-HTML-TAGPARSER_UNZIP) $(DL_DIR)/$(PERL-HTML-TAGPARSER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-HTML-TAGPARSER_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-HTML-TAGPARSER_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-HTML-TAGPARSER_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $@

perl-html-tagparser-unpack: $(PERL-HTML-TAGPARSER_BUILD_DIR)/.configured

$(PERL-HTML-TAGPARSER_BUILD_DIR)/.built: $(PERL-HTML-TAGPARSER_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

perl-html-tagparser: $(PERL-HTML-TAGPARSER_BUILD_DIR)/.built

$(PERL-HTML-TAGPARSER_BUILD_DIR)/.staged: $(PERL-HTML-TAGPARSER_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-html-tagparser-stage: $(PERL-HTML-TAGPARSER_BUILD_DIR)/.staged

$(PERL-HTML-TAGPARSER_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: perl-html-tagparser" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-HTML-TAGPARSER_PRIORITY)" >>$@
	@echo "Section: $(PERL-HTML-TAGPARSER_SECTION)" >>$@
	@echo "Version: $(PERL-HTML-TAGPARSER_VERSION)-$(PERL-HTML-TAGPARSER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-HTML-TAGPARSER_MAINTAINER)" >>$@
	@echo "Source: $(PERL-HTML-TAGPARSER_SITE)/$(PERL-HTML-TAGPARSER_SOURCE)" >>$@
	@echo "Description: $(PERL-HTML-TAGPARSER_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-HTML-TAGPARSER_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-HTML-TAGPARSER_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-HTML-TAGPARSER_CONFLICTS)" >>$@

$(PERL-HTML-TAGPARSER_IPK): $(PERL-HTML-TAGPARSER_BUILD_DIR)/.built
	rm -rf $(PERL-HTML-TAGPARSER_IPK_DIR) $(BUILD_DIR)/perl-html-tagparser_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-HTML-TAGPARSER_BUILD_DIR) DESTDIR=$(PERL-HTML-TAGPARSER_IPK_DIR) install
	find $(PERL-HTML-TAGPARSER_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-HTML-TAGPARSER_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-HTML-TAGPARSER_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-HTML-TAGPARSER_IPK_DIR)/CONTROL/control
	echo $(PERL-HTML-TAGPARSER_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-HTML-TAGPARSER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-HTML-TAGPARSER_IPK_DIR)

perl-html-tagparser-ipk: $(PERL-HTML-TAGPARSER_IPK)

perl-html-tagparser-clean:
	-$(MAKE) -C $(PERL-HTML-TAGPARSER_BUILD_DIR) clean

perl-html-tagparser-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-HTML-TAGPARSER_DIR) $(PERL-HTML-TAGPARSER_BUILD_DIR) $(PERL-HTML-TAGPARSER_IPK_DIR) $(PERL-HTML-TAGPARSER_IPK)

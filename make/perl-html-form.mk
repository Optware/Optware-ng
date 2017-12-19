###########################################################
#
# perl-html-form
#
###########################################################

PERL-HTML-FORM_SITE=http://$(PERL_CPAN_SITE)/CPAN/authors/id/G/GA/GAAS
PERL-HTML-FORM_VERSION=6.03
PERL-HTML-FORM_SOURCE=HTML-Form-$(PERL-HTML-FORM_VERSION).tar.gz
PERL-HTML-FORM_DIR=HTML-Form-$(PERL-HTML-FORM_VERSION)
PERL-HTML-FORM_UNZIP=zcat
PERL-HTML-FORM_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-HTML-FORM_DESCRIPTION=Class that represents an HTML form element
PERL-HTML-FORM_SECTION=www
PERL-HTML-FORM_PRIORITY=optional
PERL-HTML-FORM_DEPENDS=
PERL-HTML-FORM_SUGGESTS=
PERL-HTML-FORM_CONFLICTS=

PERL-HTML-FORM_IPK_VERSION=4

PERL-HTML-FORM_CONFFILES=

PERL-HTML-FORM_BUILD_DIR=$(BUILD_DIR)/perl-html-form
PERL-HTML-FORM_SOURCE_DIR=$(SOURCE_DIR)/perl-html-form
PERL-HTML-FORM_IPK_DIR=$(BUILD_DIR)/perl-html-form-$(PERL-HTML-FORM_VERSION)-ipk
PERL-HTML-FORM_IPK=$(BUILD_DIR)/perl-html-form_$(PERL-HTML-FORM_VERSION)-$(PERL-HTML-FORM_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-HTML-FORM_SOURCE):
	$(WGET) -P $(@D) $(PERL-HTML-FORM_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-html-form-source: $(DL_DIR)/$(PERL-HTML-FORM_SOURCE) $(PERL-HTML-FORM_PATCHES)

$(PERL-HTML-FORM_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-HTML-FORM_SOURCE) $(PERL-HTML-FORM_PATCHES) make/perl-html-form.mk
	rm -rf $(BUILD_DIR)/$(PERL-HTML-FORM_DIR) $(PERL-HTML-FORM_BUILD_DIR)
	$(PERL-HTML-FORM_UNZIP) $(DL_DIR)/$(PERL-HTML-FORM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-HTML-FORM_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-HTML-FORM_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-HTML-FORM_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $@

perl-html-form-unpack: $(PERL-HTML-FORM_BUILD_DIR)/.configured

$(PERL-HTML-FORM_BUILD_DIR)/.built: $(PERL-HTML-FORM_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

perl-html-form: $(PERL-HTML-FORM_BUILD_DIR)/.built

$(PERL-HTML-FORM_BUILD_DIR)/.staged: $(PERL-HTML-FORM_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-html-form-stage: $(PERL-HTML-FORM_BUILD_DIR)/.staged

$(PERL-HTML-FORM_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: perl-html-form" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-HTML-FORM_PRIORITY)" >>$@
	@echo "Section: $(PERL-HTML-FORM_SECTION)" >>$@
	@echo "Version: $(PERL-HTML-FORM_VERSION)-$(PERL-HTML-FORM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-HTML-FORM_MAINTAINER)" >>$@
	@echo "Source: $(PERL-HTML-FORM_SITE)/$(PERL-HTML-FORM_SOURCE)" >>$@
	@echo "Description: $(PERL-HTML-FORM_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-HTML-FORM_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-HTML-FORM_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-HTML-FORM_CONFLICTS)" >>$@

$(PERL-HTML-FORM_IPK): $(PERL-HTML-FORM_BUILD_DIR)/.built
	rm -rf $(PERL-HTML-FORM_IPK_DIR) $(BUILD_DIR)/perl-html-form_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-HTML-FORM_BUILD_DIR) DESTDIR=$(PERL-HTML-FORM_IPK_DIR) install
	find $(PERL-HTML-FORM_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-HTML-FORM_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-HTML-FORM_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-HTML-FORM_IPK_DIR)/CONTROL/control
	echo $(PERL-HTML-FORM_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-HTML-FORM_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-HTML-FORM_IPK_DIR)

perl-html-form-ipk: $(PERL-HTML-FORM_IPK)

perl-html-form-clean:
	-$(MAKE) -C $(PERL-HTML-FORM_BUILD_DIR) clean

perl-html-form-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-HTML-FORM_DIR) $(PERL-HTML-FORM_BUILD_DIR) $(PERL-HTML-FORM_IPK_DIR) $(PERL-HTML-FORM_IPK)
